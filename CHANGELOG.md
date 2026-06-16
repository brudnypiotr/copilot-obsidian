# Changelog

All notable changes to copilot-obsidian. Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versioning: [SemVer](https://semver.org/).

## [1.0.1] - 2026-06-16

Post-install audit patch. The v1.0.0 prose audit caught Claude-Code identity strings but missed two upstream community-marketing artifacts that surfaced when scaffolding the first real vault under Copilot CLI.

### Removed

- `skills/wiki/SKILL.md` "Community Footer" section (the agricidaniel / skool.com promo banner the scaffold operation was instructed to append after major operations). The footer was emitted verbatim at the end of the live vault scaffold test, which is not the fork's brand.

### Fixed

- `skills/wiki/SKILL.md` step 4 of SCAFFOLD: tightened "Create domain pages + `_index.md` sub-indexes" → "Create per-domain `wiki/<domain>/_index.md` sub-indexes (one per domain folder; do NOT create a top-level `wiki/_index/` dir)". The original wording was ambiguous enough that Copilot speculatively created a stray empty `wiki/_index/` directory alongside the correct per-domain `_index.md` files during the live test scaffold.

## [1.0.0] - 2026-06-15 (initial Copilot CLI fork)

Forked from [`AgriciDaniel/claude-obsidian`](https://github.com/AgriciDaniel/claude-obsidian) v1.9.2 (2026-05-27, MIT). This is a rebrand and strip targeting GitHub Copilot CLI compatibility. The 15-skill knowledge-base architecture, the hybrid retrieval pipeline (BM25 + cosine rerank + contextual prefix), the methodology modes (LYT / PARA / Zettelkasten / Generic), the multi-writer per-file advisory locking, the DragonScale Memory extension, and the 10-principle thinking framework are inherited unchanged.

### Rebranded

- Plugin name `claude-obsidian` → `copilot-obsidian`. Manifest moved from `.claude-plugin/plugin.json` to `plugin.json` at the repository root (Copilot CLI preferred discovery location). Version restarted at `1.0.0` (fresh semver for the fork; upstream continues independently).
- Author / homepage / repository: `brudnypiotr/copilot-obsidian`. License: MIT (inherited).
- Agent files renamed `agents/*.md` → `agents/*.agent.md` per Copilot CLI's documented convention.
- ~25 lines of prose across `skills/` and `commands/` neutralized from Claude-Code-specific language to agent-agnostic phrasing (e.g. "Claude's `Write` tool" → "the agent's `Write` tool", "Any Claude Code project" → "Any Copilot CLI project"). Citations (Anthropic Sept 2024 contextual retrieval), retrieval-pipeline tier names ("Anthropic API tier 1"), and competitive-positioning prose ("no other Claude+Obsidian competitor ships...") retained as factual references.

### Stripped (Claude-Code-specific scaffolding)

- `hooks/` — the 4 Claude Code hooks (`SessionStart`, `PostCompact`, `PostToolUse`, `Stop`) had event names that Copilot CLI does not document. Replaced by:
  - **Standing instructions in [`COPILOT.md`](COPILOT.md)** for passive behaviors (hot-cache load on session start, re-load after compaction, prompt for hot-cache update at session end, stale-lock reaper).
  - **Inline `bash` blocks in 4 mutating skills** (`save`, `wiki-ingest`, `wiki-fold`, `autoresearch`) for the active behavior (auto-commit after wiki writes). Each runs `wiki-lock acquire → git add+commit → release` as part of its own flow.
- `CLAUDE.md`, `GEMINI.md`, `.cursor/`, `.windsurf/`, `.claude-plugin/` — vendor mirrors for other agent ecosystems, out of scope for this fork.
- `bin/setup-multi-agent.sh` — multi-vendor installer (Cursor, Windsurf, OpenCode, codex paths), unnecessary when targeting Copilot CLI specifically.
- `.claude-plugin/marketplace.json` — Anthropic marketplace schema. Copilot CLI direct install (`copilot plugin install OWNER/REPO`) does not require it.

### Added

- [`COPILOT.md`](COPILOT.md) at repo root — standing session instructions, skills registry, commit-pattern explanation, cross-project access guide.
- [`MANUAL.md`](MANUAL.md) at repo root — explicit list of 3 user-initiated steps that remain even with COPILOT.md standing instructions (stale-lock cleanup after crash, forced hot-cache reload, end-of-day hot-cache update). Plus the full hook → fork-replacement mapping table.
- Inline commit-pattern section appended to `skills/save/SKILL.md`, `skills/wiki-ingest/SKILL.md`, `skills/wiki-fold/SKILL.md`, `skills/autoresearch/SKILL.md`.
- MCP-setup disclaimer at top of `skills/wiki/references/mcp-setup.md` noting the retained `claude mcp ...` commands are Claude-CLI-specific and Copilot CLI users should consult Copilot docs for the equivalent registration syntax.
- This fork's `references` block in [`CITATION.cff`](CITATION.cff) pointing to upstream.

### Unchanged (core IP inherited as-is)

- `skills/` (all 15), `agents/*` body (3), `commands/` (4), `scripts/` (12), `bin/setup-{vault,dragonscale,mode,retrieve}.sh`, `tests/` (9 hermetic suites), `Makefile`, `wiki/`, `.raw/`, `_templates/`, `_attachments/`, `assets/`, `docs/`, `LICENSE`, `SECURITY.md`, `PRIVACY.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `CODEOWNERS`, `WIKI.md`.

### Known limitations

- Copilot CLI hook event names are not publicly documented; hooks are intentionally stripped rather than guessed. Auto-commit lives in 4 skill bodies instead. See [`MANUAL.md`](MANUAL.md) for the 3 fallback scenarios.
- `commands/` directory is retained because Copilot CLI's manifest supports the `commands` field, but the file format inside is the upstream's Claude Code slash-command convention. End-to-end verification under Copilot CLI is required and documented in the README install section.
- Native Copilot CLI hook layer, CI smoke test under GitHub Actions, custom Copilot-compatible `marketplace.json`, and a `gh copilot` tier in `scripts/contextual-prefix.py` are all explicitly deferred (see `Out of scope` in the fork plan).

### Upstream history

For all changes prior to this fork (v1.0.0 through v1.9.2 of `claude-obsidian`), see the upstream changelog at [`AgriciDaniel/claude-obsidian/CHANGELOG.md`](https://github.com/AgriciDaniel/claude-obsidian/blob/main/CHANGELOG.md).
