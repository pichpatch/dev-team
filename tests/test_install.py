#!/usr/bin/env python3
"""Installer behavior tests. All destinations are inside temporary directories."""

import os
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "skills/my-dev-team"
ROLE_SKILLS = ("my-po", "my-design-lead", "my-tech-lead", "my-qa-lead")
COMMANDS = ("my-dev-team",) + ROLE_SKILLS


class InstallerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="my-dev-team-test-")
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name) / "home with spaces"
        self.home.mkdir()
        self.env = dict(os.environ, HOME=str(self.home))
        self.env.pop("CODEX_HOME", None)
        self.env.pop("XDG_CONFIG_HOME", None)

    def run_install(self, *args, success=True):
        result = subprocess.run(
            ["bash", str(ROOT / "install.sh"), *map(str, args)],
            env=self.env, cwd=self.home, text=True, capture_output=True,
        )
        if success:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        else:
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def assert_skill_link(self, path):
        self.assertTrue(path.is_symlink(), str(path))
        self.assertEqual(path.resolve(), SOURCE)

    def assert_role_skills(self, skills_dir):
        for name in ROLE_SKILLS:
            link = skills_dir / name
            self.assertTrue(link.is_symlink(), str(link))
            self.assertEqual(link.resolve(), ROOT / "skills" / name)
            # The role skill finds the team skill through the sibling link.
            self.assertTrue((link / "../my-dev-team/SKILL.md").is_file())

    def assert_commands(self, commands_dir, host):
        for name in COMMANDS:
            command = commands_dir / f"{name}.md"
            self.assertTrue(command.is_symlink(), str(command))
            self.assertEqual(command.resolve(), ROOT / "commands" / host / f"{name}.md")

    def assert_links(self, directory, source_dir, suffix):
        for name in ROLE_SKILLS:
            link = directory / f"{name}{suffix}"
            self.assertTrue(link.is_symlink(), str(link))
            self.assertEqual(link.resolve(), ROOT / source_dir / f"{name}{suffix}")

    def test_custom_directory_and_idempotence(self):
        dest = self.home / "custom skills"
        self.run_install("--skills-dir", dest)
        link = dest / "my-dev-team"
        self.assert_skill_link(link)
        self.assert_role_skills(dest)
        before = link.lstat().st_ino
        self.run_install("--skills-dir", dest)
        self.assertEqual(link.lstat().st_ino, before)

    def test_dry_run_makes_no_directories(self):
        self.run_install("--target", "all", "--dry-run")
        self.assertEqual(list(self.home.iterdir()), [])

    def test_all_targets_and_claude_command(self):
        self.run_install("--target", "all", "--target", "codex")
        for relative in (
            ".codex/skills/my-dev-team", ".claude/skills/my-dev-team",
            ".gemini/config/skills/my-dev-team", ".config/opencode/skills/my-dev-team",
        ):
            self.assert_skill_link(self.home / relative)
        # Claude and OpenCode have command files; Codex and Antigravity call a
        # skill by name, so they get the role skills and no command files.
        self.assert_commands(self.home / ".claude/commands", "claude")
        self.assert_commands(self.home / ".config/opencode/commands", "opencode")
        # Each host's role-to-model binding: OpenCode agents and Codex profiles.
        self.assert_links(self.home / ".config/opencode/agents", "agents/opencode", ".md")
        self.assert_links(self.home / ".codex", "profiles/codex", ".config.toml")
        self.assert_role_skills(self.home / ".codex/skills")
        self.assert_role_skills(self.home / ".gemini/config/skills")
        for name in ROLE_SKILLS:
            self.assertFalse((self.home / ".claude/skills" / name).exists())
            self.assertFalse((self.home / ".config/opencode/skills" / name).exists())
        self.run_install("--target", "all")

    def test_antigravity_aliases(self):
        for alias in ("agy", "antigravity", "gemini"):
            with self.subTest(alias=alias):
                self.run_install("--target", alias)
                self.assert_skill_link(self.home / ".gemini/config/skills/my-dev-team")
                self.assert_role_skills(self.home / ".gemini/config/skills")
        self.assertFalse((self.home / ".codex").exists())

    def test_auto_detect_only_existing_hosts(self):
        (self.home / ".codex").mkdir()
        self.run_install()
        self.assert_skill_link(self.home / ".codex/skills/my-dev-team")
        self.assertFalse((self.home / ".claude").exists())
        self.assertFalse((self.home / ".gemini").exists())
        self.assertFalse((self.home / ".config").exists())

    def test_no_detected_hosts(self):
        self.run_install(success=False)
        self.assertEqual(list(self.home.iterdir()), [])

    def test_environment_paths(self):
        codex = self.home / "configured codex"
        config = self.home / "configured xdg"
        codex.mkdir()
        (config / "opencode").mkdir(parents=True)
        self.env.update(CODEX_HOME=str(codex), XDG_CONFIG_HOME=str(config))
        self.run_install()
        self.assert_skill_link(codex / "skills/my-dev-team")
        self.assert_skill_link(config / "opencode/skills/my-dev-team")
        self.assertFalse((self.home / ".codex").exists())

    def test_conflict_prevents_all_links(self):
        conflict = self.home / ".claude/skills/my-dev-team"
        conflict.mkdir(parents=True)
        marker = conflict / "user-file"
        marker.write_text("keep", encoding="utf-8")
        self.run_install("--target", "all", success=False)
        self.assertEqual(marker.read_text(encoding="utf-8"), "keep")
        self.assertFalse((self.home / ".codex").exists())
        self.assertFalse((self.home / ".claude/commands").exists())

    def test_file_and_foreign_symlink_conflicts(self):
        for kind in ("file", "link", "dangling-link"):
            with self.subTest(kind=kind):
                directory = self.home / kind
                directory.mkdir()
                conflict = directory / "my-dev-team"
                if kind == "file":
                    conflict.write_text("keep", encoding="utf-8")
                else:
                    target = directory / "elsewhere"
                    if kind == "link":
                        target.mkdir()
                    conflict.symlink_to(target)
                self.run_install("--skills-dir", directory, success=False)
                if kind == "file":
                    self.assertEqual(conflict.read_text(encoding="utf-8"), "keep")
                else:
                    self.assertEqual(os.readlink(conflict), str(target))

    def test_non_directory_parent(self):
        parent = self.home / "blocked"
        parent.write_text("keep", encoding="utf-8")
        self.run_install("--skills-dir", parent / "skills", success=False)
        self.assertEqual(parent.read_text(encoding="utf-8"), "keep")

    def test_shell_characters_are_literal(self):
        directory = self.home / "literal $(touch INJECTED) `touch ALSO_INJECTED`"
        self.run_install("--skills-dir", directory)
        self.assert_skill_link(directory / "my-dev-team")
        self.assertFalse((self.home / "INJECTED").exists())
        self.assertFalse((self.home / "ALSO_INJECTED").exists())

    def test_argument_errors_do_not_install(self):
        for args in (
            ("--target",), ("--target", "unknown"), ("--skills-dir",),
            ("--unknown",), ("--target", "codex", "--skills-dir", "skills"),
        ):
            with self.subTest(args=args):
                self.run_install(*args, success=False)
                self.assertEqual(list(self.home.iterdir()), [])

    def test_help_is_read_only(self):
        self.run_install("--help")
        self.assertEqual(list(self.home.iterdir()), [])


if __name__ == "__main__":
    unittest.main(verbosity=2)
