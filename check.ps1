# Windows (and PowerShell 7 anywhere) counterpart of check.sh.
# Read-only repo checks; installer tests use temporary directories.
[CmdletBinding()]
param([switch]$Help)
$ErrorActionPreference = "Stop"
$RepoDir = $PSScriptRoot

if ($Help) {
    Write-Host "Usage: ./check.ps1 (validate bundle and test the installers in temporary directories)"
    exit 0
}

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
function Fail([string]$Message) { Write-Host "FAIL: $Message" -ForegroundColor Red; exit 1 }

$python = Find-Python
if (-not $python) { Fail "Python 3 is required" }
$pyArgs = @($python | Select-Object -Skip 1)

# Syntax-check both PowerShell scripts.
foreach ($name in "install.ps1", "check.ps1") {
    $errs = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile((Join-Path $RepoDir $name), [ref]$null, [ref]$errs)
    if ($errs -and $errs.Count -gt 0) { Fail "$name has syntax errors: $($errs[0].Message)" }
}

& $python[0] @pyArgs -B (Join-Path $RepoDir "scripts/validate.py")
if ($LASTEXITCODE -ne 0) { exit 1 }

# install.sh tests need bash and symlinks; run them where both exist (macOS, Linux).
$bash = Get-Command bash -ErrorAction SilentlyContinue
$onWindows = ($PSVersionTable.PSEdition -eq "Desktop") -or ($IsWindows -eq $true)
if ($bash -and -not $onWindows) {
    & $python[0] @pyArgs -B (Join-Path $RepoDir "tests/test_install.py")
    if ($LASTEXITCODE -ne 0) { exit 1 }
} else {
    Write-Host "Skipping tests/test_install.py (needs bash and symlinks; not run on Windows)."
}

# install.ps1 end to end in a temporary home: dry run, install, repeat, conflict.
$temp = Join-Path ([System.IO.Path]::GetTempPath()) ("my-dev-team-test-" + [guid]::NewGuid().ToString("N"))
$fakeHome = Join-Path $temp "home with spaces"
New-Item -ItemType Directory -Force -Path $fakeHome | Out-Null
$saved = @{ HOME = $env:HOME; USERPROFILE = $env:USERPROFILE; CODEX_HOME = $env:CODEX_HOME; XDG = $env:XDG_CONFIG_HOME }
try {
    $env:HOME = $fakeHome; $env:USERPROFILE = $fakeHome
    $env:CODEX_HOME = $null; $env:XDG_CONFIG_HOME = $null
    $installer = Join-Path $RepoDir "install.ps1"

    # install.ps1 calls exit, so run it in a child process that inherits the temporary home.
    $shell = (Get-Process -Id $PID).Path
    function Run-Install([string[]]$Arguments) {
        $out = & $shell -NoProfile -File $installer @Arguments 2>&1 | Out-String
        return @{ Code = $LASTEXITCODE; Out = [string]$out }
    }

    $r = Run-Install @("-Target", "all", "-DryRun")
    if ($r.Code -ne 0) { Fail "install.ps1 dry run failed:`n$($r.Out)" }
    if (Test-Path -LiteralPath (Join-Path $fakeHome ".claude")) { Fail "dry run created files" }

    $r = Run-Install @("-Target", "claude,codex,opencode")
    if ($r.Code -ne 0) { Fail "install.ps1 install failed:`n$($r.Out)" }
    $expected = @(
        ".claude/skills/my-dev-team/SKILL.md", ".claude/commands/my-po.md", ".claude/commands/my-dev-team.md",
        ".codex/skills/my-dev-team/SKILL.md", ".codex/skills/my-security/SKILL.md", ".codex/my-tech-lead.config.toml",
        ".config/opencode/skills/my-dev-team/SKILL.md", ".config/opencode/agents/my-qa-lead.md", ".config/opencode/commands/my-po.md"
    )
    foreach ($e in $expected) {
        if (-not (Test-Path -LiteralPath (Join-Path $fakeHome $e) -PathType Leaf)) { Fail "install.ps1 did not create $e" }
    }

    $r = Run-Install @("-Target", "claude")
    if ($r.Code -ne 0) { Fail "re-running install.ps1 should be safe:`n$($r.Out)" }

    $conflict = Join-Path $fakeHome ".claude/commands/my-po.md"
    Set-Content -LiteralPath $conflict -Value "someone else's file"
    $r = Run-Install @("-Target", "claude")
    if ($r.Code -eq 0 -or $r.Out -notmatch "Refusing to replace") { Fail "install.ps1 must refuse to replace unrelated files" }
    if ((Get-Content -LiteralPath $conflict -Raw) -notmatch "someone else") { Fail "install.ps1 overwrote an unrelated file" }
} finally {
    $env:HOME = $saved.HOME; $env:USERPROFILE = $saved.USERPROFILE
    $env:CODEX_HOME = $saved.CODEX_HOME; $env:XDG_CONFIG_HOME = $saved.XDG
    Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "All checks passed. These checks do not prove agent behavior or external CLI availability."
exit 0
