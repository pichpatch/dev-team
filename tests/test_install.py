#!/usr/bin/env python3
"""Installer behavior tests. All destinations are inside temporary directories."""

import os
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "skills/dev-team"


class InstallerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="dev-team-test-")
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

    def test_custom_directory_and_idempotence(self):
        dest = self.home / "custom skills"
        self.run_install("--skills-dir", dest)
        link = dest / "dev-team"
        self.assert_skill_link(link)
        before = link.lstat().st_ino
        self.run_install("--skills-dir", dest)
        self.assertEqual(link.lstat().st_ino, before)

    def test_dry_run_makes_no_directories(self):
        self.run_install("--target", "all", "--dry-run")
        self.assertEqual(list(self.home.iterdir()), [])

    def test_all_targets_and_claude_command(self):
        self.run_install("--target", "all", "--target", "codex")
        for relative in (
            ".codex/skills/dev-team", ".claude/skills/dev-team",
            ".gemini/config/skills/dev-team", ".config/opencode/skills/dev-team",
        ):
            self.assert_skill_link(self.home / relative)
        for name in ("dev-team.md", "po.md", "design-lead.md", "tech-lead.md", "qa-lead.md"):
            command = self.home / ".claude/commands" / name
            self.assertTrue(command.is_symlink())
            self.assertEqual(command.resolve(), ROOT / "commands" / name)
        self.run_install("--target", "all")

    def test_auto_detect_only_existing_hosts(self):
        (self.home / ".codex").mkdir()
        self.run_install()
        self.assert_skill_link(self.home / ".codex/skills/dev-team")
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
        self.assert_skill_link(codex / "skills/dev-team")
        self.assert_skill_link(config / "opencode/skills/dev-team")
        self.assertFalse((self.home / ".codex").exists())

    def test_conflict_prevents_all_links(self):
        conflict = self.home / ".claude/skills/dev-team"
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
                conflict = directory / "dev-team"
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
        self.assert_skill_link(directory / "dev-team")
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
