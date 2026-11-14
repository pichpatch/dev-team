# Windows (and PowerShell 7 anywhere) counterpart of install.sh.
# Links this checkout into selected skill directories without replacing other work.
# Windows blocks symlinks unless Developer Mode is on or the shell is elevated; in
# that case files are copied instead (a snapshot: re-run after updating the checkout).
[CmdletBinding()]
param(
    [string[]]$Target = @(),
    [string]$SkillsDir = "",
    [switch]$DryRun,
    [switch]$Update,
    [switch]$Help
)
$ErrorActionPreference = "Stop"

$RepoDir = $PSScriptRoot
$SkillsSource = Join-Path $RepoDir "skills"
$CommandsSource = Join-Path $RepoDir "commands"
$AgentsSource = Join-Path $RepoDir "agents"
$ProfilesSource = Join-Path $RepoDir "profiles"
$RoleSkills = @("my-po", "my-design-lead", "my-tech-lead", "my-qa-lead", "my-security")
$Commands = @("my-dev-team") + $RoleSkills

function Show-Usage {
@'
Usage: ./install.ps1 [-Target HOST[,HOST...]] [-DryRun] [-Update]
       ./install.ps1 -SkillsDir DIRECTORY [-DryRun] [-Update]

Hosts: codex, claude, agy (also: antigravity, gemini), opencode, all
With no target, install for hosts whose configuration directories already exist.
-Target all explicitly selects all four hosts.
-SkillsDir installs the team skill and the role skills into a custom directory.
-DryRun prints planned links and checks conflicts without changing files.
-Update replaces destinations that this installer previously copied (a copy that
        differs from the checkout). Other files are never replaced.

Same layout as install.sh. Symlinks are tried first; if Windows refuses them
(Developer Mode off), files are copied instead.

Requires Python 3 for validation (python, py -3, or python3 on PATH).
'@ | Write-Host
}

function Fail([string]$Message) { Write-Error "Error: $Message" -ErrorAction Continue; exit 1 }

if ($Help) { Show-Usage; exit 0 }

function Get-HomeDir {
    if ($env:HOME) { return $env:HOME }
    if ($env:USERPROFILE) { return $env:USERPROFILE }
    return [Environment]::GetFolderPath("UserProfile")
}
$HomeDir = Get-HomeDir

function Find-Python {
    foreach ($candidate in @(@("python3"), @("python"), @("py", "-3"))) {
        $cmd = Get-Command $candidate[0] -ErrorAction SilentlyContinue
        if (-not $cmd) { continue }
        $extra = @($candidate | Select-Object -Skip 1)
        try {
            $null = & $cmd.Source @extra -c "import sys; sys.exit(0 if sys.version_info[0] == 3 else 1)" 2>$null
            if ($LASTEXITCODE -eq 0) { return ,@($cmd.Source) + $extra }
        } catch { }
    }
    return $null
}

# Normalise -Target so "a,b", "a b" and repeated flags all work.
$targets = New-Object System.Collections.Generic.List[string]
function Add-Target([string]$Name) {
    $name = $Name.ToLowerInvariant()
    if ($name -in @("agy", "antigravity")) { $name = "gemini" }
    if ($name -notin @("codex", "claude", "gemini", "opencode")) { Fail "Unknown host: $Name" }
    if (-not $targets.Contains($name)) { $targets.Add($name) }
}
foreach ($item in $Target) {
    foreach ($part in ($item -split "[,\s]+" | Where-Object { $_ })) {
        if ($part -eq "all") { foreach ($h in "codex", "claude", "gemini", "opencode") { Add-Target $h } }
        else { Add-Target $part }
    }
}

$python = Find-Python
if (-not $python) { Fail "Python 3 is required for validation" }
$pyArgs = @($python | Select-Object -Skip 1)
& $python[0] @pyArgs -B (Join-Path $RepoDir "scripts/validate.py")
if ($LASTEXITCODE -ne 0) { exit 1 }

$destinations = New-Object System.Collections.Generic.List[string]
$sources = New-Object System.Collections.Generic.List[string]
function Add-Pair([string]$Source, [string]$Destination) {
    $sources.Add($Source); $destinations.Add($Destination)
}

$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HomeDir ".codex" }
$ConfigHome = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { Join-Path $HomeDir ".config" }
$OpenCodeHome = Join-Path $ConfigHome "opencode"

if ($SkillsDir) {
    if ($targets.Count -gt 0) { Fail "Do not combine -SkillsDir and -Target" }
    foreach ($skill in @("my-dev-team") + $RoleSkills) {
        Add-Pair (Join-Path $SkillsSource $skill) (Join-Path $SkillsDir $skill)
    }
} else {
    if ($targets.Count -eq 0) {
        if (Test-Path -LiteralPath $CodexHome) { Add-Target codex }
        if (Test-Path -LiteralPath (Join-Path $HomeDir ".claude")) { Add-Target claude }
        if (Test-Path -LiteralPath (Join-Path $HomeDir ".gemini")) { Add-Target gemini }
        if (Test-Path -LiteralPath $OpenCodeHome) { Add-Target opencode }
    }
    if ($targets.Count -eq 0) { Fail "No host configuration found; select -Target or -SkillsDir" }
    foreach ($t in $targets) {
        $commandsDir = $null
        switch ($t) {
            "codex"    { $skillsDir = Join-Path $CodexHome "skills" }
            "claude"   { $skillsDir = Join-Path $HomeDir ".claude/skills"; $commandsDir = Join-Path $HomeDir ".claude/commands" }
            "gemini"   { $skillsDir = Join-Path $HomeDir ".gemini/config/skills" }
            "opencode" { $skillsDir = Join-Path $OpenCodeHome "skills"; $commandsDir = Join-Path $OpenCodeHome "commands" }
        }
        Add-Pair (Join-Path $SkillsSource "my-dev-team") (Join-Path $skillsDir "my-dev-team")
        if ($t -eq "opencode") {
            foreach ($role in $RoleSkills) {
                Add-Pair (Join-Path $AgentsSource "opencode/$role.md") (Join-Path $OpenCodeHome "agents/$role.md")
            }
        } elseif ($t -eq "codex") {
            foreach ($role in @("my-dev-team") + $RoleSkills) {
                Add-Pair (Join-Path $ProfilesSource "codex/$role.config.toml") (Join-Path $CodexHome "$role.config.toml")
            }
        }
        if ($commandsDir) {
            foreach ($command in $Commands) {
                Add-Pair (Join-Path $CommandsSource "$t/$command.md") (Join-Path $commandsDir "$command.md")
            }
        } else {
            foreach ($skill in $RoleSkills) {
                Add-Pair (Join-Path $SkillsSource $skill) (Join-Path $skillsDir $skill)
            }
        }
    }
}

function Test-Link([string]$Path) {
    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    return [bool]($item -and $item.LinkType)
}
function Get-LinkTarget([string]$Path) {
    $item = Get-Item -LiteralPath $Path -Force
    $t = @($item.Target)[0]
    if (-not $t) { return $null }
    if (-not [System.IO.Path]::IsPathRooted($t)) { $t = Join-Path (Split-Path $Path -Parent) $t }
    return [System.IO.Path]::GetFullPath($t).TrimEnd('\', '/')
}
function Same-Path([string]$A, [string]$B) {
    $cmp = if ($IsLinux) { "Ordinal" } else { "OrdinalIgnoreCase" }
    return [string]::Equals(
        [System.IO.Path]::GetFullPath($A).TrimEnd('\', '/'),
        [System.IO.Path]::GetFullPath($B).TrimEnd('\', '/'),
        [System.StringComparison]$cmp)
}
# True when Destination is a plain copy with exactly the same files as Source.
function Test-SameContent([string]$Source, [string]$Destination) {
    $sIsDir = Test-Path -LiteralPath $Source -PathType Container
    $dIsDir = Test-Path -LiteralPath $Destination -PathType Container
    if ($sIsDir -ne $dIsDir) { return $false }
    if (-not $sIsDir) {
        return (Get-FileHash -LiteralPath $Source).Hash -eq (Get-FileHash -LiteralPath $Destination).Hash
    }
    $sRoot = (Resolve-Path -LiteralPath $Source).Path; $dRoot = (Resolve-Path -LiteralPath $Destination).Path
    $sFiles = @(Get-ChildItem -LiteralPath $sRoot -Recurse -File -Force)
    $dFiles = @(Get-ChildItem -LiteralPath $dRoot -Recurse -File -Force)
    if ($sFiles.Count -ne $dFiles.Count) { return $false }
    foreach ($f in $sFiles) {
        $rel = $f.FullName.Substring($sRoot.Length).TrimStart('\', '/')
        $other = Join-Path $dRoot $rel
        if (-not (Test-Path -LiteralPath $other -PathType Leaf)) { return $false }
        if ((Get-FileHash -LiteralPath $f.FullName).Hash -ne (Get-FileHash -LiteralPath $other).Hash) { return $false }
    }
    return $true
}

# A plain (non-link) destination that looks like something this installer copies.
function Test-Updatable([string]$Path) {
    if (Test-Path -LiteralPath $Path -PathType Container) {
        return (Test-Path -LiteralPath (Join-Path $Path "SKILL.md") -PathType Leaf)
    }
    return ($Path -match "my-[a-z-]+(\.config)?\.(md|toml)$")
}

# Preflight every destination before creating anything.
# state: new | linked (correct symlink) | copied (identical copy) | stale (changed copy; needs -Update)
$errors = New-Object System.Collections.Generic.List[string]
$state = @{}
for ($i = 0; $i -lt $destinations.Count; $i++) {
    $src = $sources[$i]; $dst = $destinations[$i]
    if (Test-Link $dst) {
        if (Same-Path (Get-LinkTarget $dst) $src) { $state[$dst] = "linked" }
        else { $errors.Add("Refusing to replace existing destination: $dst") }
    } elseif (Test-Path -LiteralPath $dst) {
        if (Test-SameContent $src $dst) { $state[$dst] = "copied" }
        elseif ($Update -and (Test-Updatable $dst)) {
            $state[$dst] = "stale"
        } else { $errors.Add("Refusing to replace existing destination: $dst") }
    } else {
        $parent = Split-Path $dst -Parent
        while ($parent -and -not (Test-Path -LiteralPath $parent)) { $parent = Split-Path $parent -Parent }
        if ($parent -and -not (Test-Path -LiteralPath $parent -PathType Container)) {
            $errors.Add("Destination parent is not a directory: $parent")
        }
        $state[$dst] = "new"
    }
}
if ($errors.Count -gt 0) {
    foreach ($e in $errors) { Write-Host "Error: $e" -ForegroundColor Red }
    exit 1
}

$copied = $false
for ($i = 0; $i -lt $destinations.Count; $i++) {
    $src = $sources[$i]; $dst = $destinations[$i]
    if ($state[$dst] -eq "linked") { Write-Host "Already linked: $dst"; continue }
    if ($state[$dst] -eq "copied") { Write-Host "Already installed (copy): $dst"; continue }
    $verb = if ($state[$dst] -eq "stale") { "update" } else { "link" }
    if ($DryRun) { Write-Host "Would ${verb}: $dst -> $src"; continue }

    New-Item -ItemType Directory -Force -Path (Split-Path $dst -Parent) | Out-Null
    if ($state[$dst] -eq "stale") { Remove-Item -LiteralPath $dst -Recurse -Force }
    $linked = $false
    if ($state[$dst] -ne "stale") {
        try {
            New-Item -ItemType SymbolicLink -Path $dst -Target $src -ErrorAction Stop | Out-Null
            $linked = $true
        } catch { $linked = $false }
    }
    if ($linked) { Write-Host "Linked: $dst -> $src" }
    else {
        Copy-Item -LiteralPath $src -Destination $dst -Recurse -Force
        $copied = $true
        Write-Host "Copied: $dst <- $src"
    }
}

if ($DryRun) { Write-Host "Dry run complete; nothing installed." }
else {
    Write-Host "Installed. Start a new host session to discover my-dev-team. No authentication or model settings changed."
    if ($copied) {
        Write-Host "Symlinks were not available, so files were copied. After changing this checkout, re-run ./install.ps1 -Update."
        Write-Host "(Turn on Windows Developer Mode to use links instead.)"
    }
}
