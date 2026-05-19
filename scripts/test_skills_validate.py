#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = ["pytest"]
# ///
"""Tests for the skills-validate harness.

Run with: uv run pytest scripts/test_skills_validate.py -v
"""
from __future__ import annotations

import importlib.machinery
import importlib.util
import subprocess
import sys
from pathlib import Path
from unittest.mock import patch

import pytest

# ---------------------------------------------------------------------------
# Import the harness (no .py extension)
# ---------------------------------------------------------------------------

_HARNESS_PATH = Path(__file__).resolve().parent / "skills-validate"


def _import_harness():
    """Import the skills-validate script as a module (no .py extension).

    Must register in sys.modules before exec so dataclasses can resolve
    the module's __dict__ during class creation.
    """
    loader = importlib.machinery.SourceFileLoader("skills_validate", str(_HARNESS_PATH))
    spec = importlib.util.spec_from_loader("skills_validate", loader, origin=str(_HARNESS_PATH))
    mod = importlib.util.module_from_spec(spec)
    mod.__file__ = str(_HARNESS_PATH)
    sys.modules["skills_validate"] = mod
    spec.loader.exec_module(mod)
    return mod


sv = _import_harness()


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def make_skill(tmp_path: Path, name: str = "test-skill", frontmatter: str | None = None, body: str = "") -> sv.SkillInfo:
    """Build a synthetic SKILL.md and parse it."""
    skill_dir = tmp_path / name
    skill_dir.mkdir(parents=True, exist_ok=True)

    if frontmatter is not None:
        content = f"---\n{frontmatter}\n---\n{body}"
    else:
        content = body

    skill_md = skill_dir / "SKILL.md"
    skill_md.write_text(content, encoding="utf-8")
    return sv.parse_skill_file(skill_md)


# ---------------------------------------------------------------------------
# Frontmatter checker
# ---------------------------------------------------------------------------

class TestFrontmatter:
    def test_valid_skill(self, tmp_path):
        skill = make_skill(tmp_path, frontmatter='name: my-skill\ndescription: A valid skill')
        findings = sv.check_frontmatter(skill)
        assert not any(f.severity == sv.Severity.FAIL for f in findings)

    def test_missing_frontmatter(self, tmp_path):
        skill = make_skill(tmp_path, frontmatter=None, body="# Just a body\nNo frontmatter here.")
        findings = sv.check_frontmatter(skill)
        assert any(f.severity == sv.Severity.FAIL and "No frontmatter" in f.message for f in findings)

    def test_missing_name(self, tmp_path):
        skill = make_skill(tmp_path, frontmatter='description: Has desc but no name')
        findings = sv.check_frontmatter(skill)
        assert any(f.severity == sv.Severity.FAIL and "name" in f.message.lower() for f in findings)

    def test_missing_description(self, tmp_path):
        skill = make_skill(tmp_path, frontmatter='name: my-skill')
        findings = sv.check_frontmatter(skill)
        assert any(f.severity == sv.Severity.FAIL and "description" in f.message.lower() for f in findings)

    def test_non_kebab_name(self, tmp_path):
        skill = make_skill(tmp_path, frontmatter='name: MySkill\ndescription: A skill')
        findings = sv.check_frontmatter(skill)
        assert any(f.severity == sv.Severity.WARN and "kebab" in f.message.lower() for f in findings)

    def test_kebab_name_no_warn(self, tmp_path):
        skill = make_skill(tmp_path, frontmatter='name: my-valid-skill\ndescription: A skill')
        findings = sv.check_frontmatter(skill)
        assert not any(f.severity == sv.Severity.WARN for f in findings)

    def test_empty_name_is_fail(self, tmp_path):
        skill = make_skill(tmp_path, frontmatter='name: \ndescription: A skill')
        findings = sv.check_frontmatter(skill)
        assert any(f.severity == sv.Severity.FAIL and "name" in f.message.lower() for f in findings)


# ---------------------------------------------------------------------------
# Binary checker
# ---------------------------------------------------------------------------

class TestBinaries:
    def test_known_binary_exists(self, tmp_path):
        """Skill referencing a known binary that IS on PATH -> no FAIL."""
        skill = make_skill(tmp_path, frontmatter='name: a-skill\ndescription: x', body="Run `uv run pytest` to test.")
        with patch("shutil.which", return_value="/usr/bin/uv"):
            findings = sv.check_binaries(skill)
        assert not any(f.severity == sv.Severity.FAIL for f in findings)

    def test_fabricated_binary_fails(self, tmp_path):
        """Skill referencing a known binary not on PATH -> FAIL."""
        skill = make_skill(tmp_path, frontmatter='name: a-skill\ndescription: x', body="Run `khora launch` to test.")
        with patch("shutil.which", return_value=None):
            findings = sv.check_binaries(skill)
        assert any(f.severity == sv.Severity.FAIL and "khora" in f.message for f in findings)

    def test_bare_prose_not_detected(self, tmp_path):
        """Warframe name in prose (not backticks) -> not checked."""
        skill = make_skill(tmp_path, frontmatter='name: a-skill\ndescription: x', body="This skill uses khora for testing.")
        findings = sv.check_binaries(skill)
        assert not any(f.severity == sv.Severity.FAIL for f in findings)

    def test_fenced_code_block(self, tmp_path):
        """Binary in fenced code block is detected."""
        body = "Example:\n```bash\nlimbo status done\n```"
        skill = make_skill(tmp_path, frontmatter='name: a-skill\ndescription: x', body=body)
        with patch("shutil.which", return_value=None):
            findings = sv.check_binaries(skill)
        assert any(f.severity == sv.Severity.FAIL and "limbo" in f.message for f in findings)

    def test_non_known_binary_ignored(self, tmp_path):
        """Binary not in KNOWN_BINARIES set is ignored."""
        skill = make_skill(tmp_path, frontmatter='name: a-skill\ndescription: x', body="Run `curl https://example.com`")
        findings = sv.check_binaries(skill)
        assert not any(f.severity == sv.Severity.FAIL for f in findings)


# ---------------------------------------------------------------------------
# Path checker
# ---------------------------------------------------------------------------

class TestPaths:
    def test_real_path_no_fail(self, tmp_path):
        """Skill citing a resource path that exists -> no FAIL."""
        skill_dir = tmp_path / "path-skill"
        skill_dir.mkdir()
        ref_dir = skill_dir / "reference"
        ref_dir.mkdir()
        (ref_dir / "guide.md").write_text("content")

        body = "See `reference/guide.md` for details."
        skill_md = skill_dir / "SKILL.md"
        skill_md.write_text(f"---\nname: path-skill\ndescription: x\n---\n{body}")

        skill = sv.parse_skill_file(skill_md)
        findings = sv.check_paths(skill)
        assert not any(f.severity == sv.Severity.FAIL for f in findings)

    def test_nonexistent_path_fails(self, tmp_path):
        """Skill citing a nonexistent resource path -> FAIL."""
        skill_dir = tmp_path / "path-skill"
        skill_dir.mkdir()

        body = "See `reference/missing-file.md` for details."
        skill_md = skill_dir / "SKILL.md"
        skill_md.write_text(f"---\nname: path-skill\ndescription: x\n---\n{body}")

        skill = sv.parse_skill_file(skill_md)
        with patch.object(sv, "_repo_root", tmp_path):
            findings = sv.check_paths(skill)
        assert any(f.severity == sv.Severity.FAIL and "missing-file.md" in f.message for f in findings)

    def test_placeholder_angle_brackets_skipped(self, tmp_path):
        """Path with <name> placeholder -> skipped."""
        body = "See `reference/<name>.md` for the template."
        skill = make_skill(tmp_path, frontmatter='name: x\ndescription: x', body=body)
        findings = sv.check_paths(skill)
        assert not any(f.severity == sv.Severity.FAIL for f in findings)

    def test_placeholder_braces_skipped(self, tmp_path):
        """Path with {var} placeholder -> skipped."""
        body = "See `templates/{project}.md` for config."
        skill = make_skill(tmp_path, frontmatter='name: x\ndescription: x', body=body)
        findings = sv.check_paths(skill)
        assert not any(f.severity == sv.Severity.FAIL for f in findings)

    def test_glob_skipped(self, tmp_path):
        """Path with glob wildcard -> skipped."""
        body = "Match `reference/*.md` files."
        skill = make_skill(tmp_path, frontmatter='name: x\ndescription: x', body=body)
        findings = sv.check_paths(skill)
        assert not any(f.severity == sv.Severity.FAIL for f in findings)

    def test_non_resource_path_ignored(self, tmp_path):
        """Path not starting with a resource prefix -> ignored."""
        body = "See `docs/something.md` for info."
        skill = make_skill(tmp_path, frontmatter='name: x\ndescription: x', body=body)
        findings = sv.check_paths(skill)
        assert not any(f.severity == sv.Severity.FAIL for f in findings)


# ---------------------------------------------------------------------------
# Trigger checker
# ---------------------------------------------------------------------------

class TestTriggers:
    def _make_described_skill(self, tmp_path, desc: str, name: str = "test-skill"):
        return make_skill(tmp_path, name=name, frontmatter=f'name: {name}\ndescription: {desc}')

    def test_cached_fixture_keyword_match(self, tmp_path):
        """Cached fixture contains a trigger keyword -> no mismatch WARN."""
        skill = self._make_described_skill(tmp_path, "Test web apps. Use when user mentions testing.", name="web-tester")
        cache = {"web-tester": "I need help testing my web app"}
        with patch.object(sv, "_fixture_cache", cache):
            findings = sv.check_triggers(skill)
        assert not any(f.severity == sv.Severity.WARN and "mismatch" in f.message.lower() for f in findings)

    def test_cached_fixture_no_match(self, tmp_path):
        """Cached fixture exists but no keyword match -> WARN mismatch."""
        skill = self._make_described_skill(tmp_path, "Deploy infrastructure. Use when user mentions terraform.", name="deploy-tool")
        cache = {"deploy-tool": "please help me write a poem about cats"}
        with patch.object(sv, "_fixture_cache", cache):
            findings = sv.check_triggers(skill)
        assert any(f.severity == sv.Severity.WARN and "mismatch" in f.message.lower() for f in findings)

    def test_no_fixture_warns(self, tmp_path):
        """No cached fixture for skill -> WARN about no nyx fixture."""
        skill = self._make_described_skill(tmp_path, "Do things. Use when user mentions stuff.", name="no-hist")
        cache = {}
        with patch.object(sv, "_fixture_cache", cache), \
             patch.object(sv, "_query_nyx", return_value=None):
            findings = sv.check_triggers(skill)
        assert any(f.severity == sv.Severity.WARN and "no nyx fixture" in f.message.lower() for f in findings)

    def test_no_description_skips(self, tmp_path):
        """Skill with no description -> returns empty (frontmatter checker handles it)."""
        skill = make_skill(tmp_path, frontmatter='name: test-skill')
        with patch.object(sv, "_fixture_cache", {}):
            findings = sv.check_triggers(skill)
        assert len(findings) == 0


# ---------------------------------------------------------------------------
# CLI integration
# ---------------------------------------------------------------------------

class TestCLI:
    """CLI integration tests.

    All tests mock _save_fixtures to prevent writing to the real fixtures file.
    """

    def test_clean_skill_exit_0(self, tmp_path):
        """Validating a clean skill returns exit 0."""
        skills_dir = tmp_path / "skills"
        skill_dir = skills_dir / "good-skill"
        skill_dir.mkdir(parents=True)
        (skill_dir / "SKILL.md").write_text(
            "---\nname: good-skill\ndescription: A perfectly valid skill\n---\n# Good Skill\nDoes good things.\n"
        )

        with patch.object(sv, "find_repo_root", return_value=tmp_path), \
             patch.object(sv, "_fixture_cache", {"good-skill": "good skill usage prompt"}), \
             patch.object(sv, "_save_fixtures"), \
             patch("sys.argv", ["skills-validate", "good-skill"]):
            with pytest.raises(SystemExit) as exc_info:
                sv.main()
            assert exc_info.value.code == 0

    def test_bad_skill_exit_1(self, tmp_path):
        """Validating a skill with FAIL findings returns exit 1."""
        skills_dir = tmp_path / "skills"
        skill_dir = skills_dir / "bad-skill"
        skill_dir.mkdir(parents=True)
        (skill_dir / "SKILL.md").write_text("# No frontmatter at all\nJust body.\n")

        with patch.object(sv, "find_repo_root", return_value=tmp_path), \
             patch.object(sv, "_fixture_cache", {}), \
             patch.object(sv, "_save_fixtures"), \
             patch("sys.argv", ["skills-validate", "bad-skill"]):
            with pytest.raises(SystemExit) as exc_info:
                sv.main()
            assert exc_info.value.code == 1

    def test_changed_filters_to_git_diff(self, tmp_path):
        """--changed uses git diff to filter skills."""
        skills_dir = tmp_path / "skills"
        for name in ("changed-skill", "unchanged-skill"):
            d = skills_dir / name
            d.mkdir(parents=True)
            (d / "SKILL.md").write_text(f"---\nname: {name}\ndescription: A skill\n---\n# Skill\n")

        def mock_run(cmd, **kwargs):
            result = subprocess.CompletedProcess(cmd, 0)
            if cmd[:3] == ["git", "diff", "--name-only"]:
                result.stdout = "skills/changed-skill/SKILL.md\n"
                result.stderr = ""
            elif cmd[:3] == ["git", "ls-files", "--others"]:
                result.stdout = ""
                result.stderr = ""
            elif cmd[:3] == ["git", "rev-parse", "--show-toplevel"]:
                result.stdout = str(tmp_path) + "\n"
                result.stderr = ""
            else:
                result.stdout = ""
                result.stderr = ""
            return result

        with patch.object(sv, "find_repo_root", return_value=tmp_path), \
             patch.object(sv, "_repo_root", tmp_path), \
             patch.object(sv, "_fixture_cache", {"changed-skill": "usage prompt"}), \
             patch.object(sv, "_save_fixtures"), \
             patch("subprocess.run", side_effect=mock_run), \
             patch("sys.argv", ["skills-validate", "--changed"]):
            with pytest.raises(SystemExit) as exc_info:
                sv.main()
            assert exc_info.value.code == 0

    def test_default_suppresses_warns(self, tmp_path, capsys):
        """Default output hides WARN findings — only ✓ shown for warn-only skills."""
        skills_dir = tmp_path / "skills"
        skill_dir = skills_dir / "warn-skill"
        skill_dir.mkdir(parents=True)
        (skill_dir / "SKILL.md").write_text(
            "---\nname: WarnSkill\ndescription: A skill with non-kebab name\n---\n# Warn\n"
        )

        with patch.object(sv, "find_repo_root", return_value=tmp_path), \
             patch.object(sv, "_fixture_cache", {"WarnSkill": "usage prompt"}), \
             patch.object(sv, "_save_fixtures"), \
             patch("sys.argv", ["skills-validate", "warn-skill"]):
            with pytest.raises(SystemExit) as exc_info:
                sv.main()
            assert exc_info.value.code == 0
        out = capsys.readouterr().out
        assert "✓ WarnSkill" in out
        assert "⚠" not in out

    def test_verbose_shows_warns(self, tmp_path, capsys):
        """Verbose output shows WARN findings inline and prints summary."""
        skills_dir = tmp_path / "skills"
        skill_dir = skills_dir / "warn-skill"
        skill_dir.mkdir(parents=True)
        (skill_dir / "SKILL.md").write_text(
            "---\nname: WarnSkill\ndescription: A skill with non-kebab name\n---\n# Warn\n"
        )

        with patch.object(sv, "find_repo_root", return_value=tmp_path), \
             patch.object(sv, "_fixture_cache", {"WarnSkill": "usage prompt"}), \
             patch.object(sv, "_save_fixtures"), \
             patch("sys.argv", ["skills-validate", "-v", "warn-skill"]):
            with pytest.raises(SystemExit) as exc_info:
                sv.main()
            assert exc_info.value.code == 0
        out = capsys.readouterr().out
        assert "⚠ WarnSkill" in out
        assert "kebab" in out.lower()
        assert "passed" in out
        assert "warnings" in out

    def test_verbose_exit_code_unaffected_by_warns(self, tmp_path):
        """WARNs do not change exit code — still 0 even with verbose."""
        skills_dir = tmp_path / "skills"
        skill_dir = skills_dir / "warn-skill"
        skill_dir.mkdir(parents=True)
        (skill_dir / "SKILL.md").write_text(
            "---\nname: WarnSkill\ndescription: A skill with non-kebab name\n---\n# Warn\n"
        )

        with patch.object(sv, "find_repo_root", return_value=tmp_path), \
             patch.object(sv, "_fixture_cache", {"WarnSkill": "usage prompt"}), \
             patch.object(sv, "_save_fixtures"), \
             patch("sys.argv", ["skills-validate", "--verbose", "warn-skill"]):
            with pytest.raises(SystemExit) as exc_info:
                sv.main()
            assert exc_info.value.code == 0

    def test_unknown_skill_exit_2(self, tmp_path):
        """Requesting a nonexistent skill returns exit 2."""
        skills_dir = tmp_path / "skills"
        skills_dir.mkdir(parents=True)

        with patch.object(sv, "find_repo_root", return_value=tmp_path), \
             patch.object(sv, "_save_fixtures"), \
             patch("sys.argv", ["skills-validate", "nonexistent"]):
            with pytest.raises(SystemExit) as exc_info:
                sv.main()
            assert exc_info.value.code == 2


# ---------------------------------------------------------------------------
# parse_skill_file
# ---------------------------------------------------------------------------

class TestParseSkillFile:
    def test_multiline_description(self, tmp_path):
        """Multi-line YAML value (>) is parsed correctly."""
        fm = 'name: my-skill\ndescription: >\n  A long description\n  that spans two lines'
        skill = make_skill(tmp_path, frontmatter=fm)
        assert "long description" in skill.frontmatter.get("description", "")

    def test_name_defaults_to_dir_name(self, tmp_path):
        """When frontmatter has no name field, SkillInfo.name defaults to dir name."""
        skill = make_skill(tmp_path, name="fallback-name", frontmatter='description: just a desc')
        assert skill.name == "fallback-name"


# ---------------------------------------------------------------------------
# _extract_trigger_keywords
# ---------------------------------------------------------------------------

class TestExtractTriggerKeywords:
    def test_extracts_skill_name_parts(self):
        kw = sv._extract_trigger_keywords("Some description", "khora-test-web")
        assert "khora" in kw
        assert "khora-test-web" in kw
        assert "test" in kw
        assert "web" in kw

    def test_extracts_after_trigger_phrase(self):
        kw = sv._extract_trigger_keywords("Deploy stuff. Use when user mentions terraform, docker.", "deploy")
        assert "terraform" in kw
        assert "docker" in kw

    def test_ignores_stop_words(self):
        kw = sv._extract_trigger_keywords("Use when the user wants to do things", "my-skill")
        assert "the" not in kw
        assert "to" not in kw


# ---------------------------------------------------------------------------
# Entry point for uv run pytest
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    sys.exit(pytest.main([__file__, "-v"]))
