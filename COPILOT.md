# copilot-obsidian — GitHub Copilot CLI + Obsidian Wiki Vault

This folder is both a GitHub Copilot CLI plugin and an Obsidian vault.

**Plugin name:** `copilot-obsidian` (v1.1.0)
**Skills:** 15 (see registry below)
**Vault path:** This directory (open in Obsidian directly)
**Forked from:** [`AgriciDaniel/claude-obsidian`](https://github.com/AgriciDaniel/claude-obsidian) v1.9.2 (MIT)

## What This Vault Is For

This vault implements the LLM Wiki pattern — a persistent, compounding knowledge base for Copilot CLI + Obsidian. Drop any source, ask any question, and the wiki grows richer with every session.

## Vault Structure

```
.raw/           source documents — immutable, the agent reads but never modifies
wiki/           agent-generated knowledge base
_templates/     Obsidian Templater templates
_attachments/   images and PDFs referenced by wiki pages
```

## How to Use

Drop a source file into `.raw/`, then tell the agent: "ingest [filename]".

Ask any question. The agent reads the hot cache first, then drills into relevant pages.

Run `/wiki` to scaffold a new vault or check setup status.

Run "lint the wiki" every 10-15 ingests to catch orphans and gaps.

## Standing Session Instructions

Copilot CLI loads `COPILOT.md` as session context. The following four instructions reproduce the passive context-management behavior the upstream achieved via hooks. They are not auto-magic; Copilot follows them as it would any other instruction in the loaded prompt:

1. **Session start**: If `wiki/hot.md` exists in the current directory, read it silently to restore recent context. Do not announce the read.
2. **After a context compaction**: Re-read `wiki/hot.md` if it exists. Hook-injected context does not survive compaction; this instruction does.
3. **Before session end**: If `wiki/` was modified this session, ask the user whether `wiki/hot.md` needs updating to reflect the changes (under 500 words, factual, overwrite-not-journal).
4. **Stale lock cleanup on session start**: If `.vault-meta/locks/` contains files, run `bash scripts/wiki-lock.sh clear-stale --max-age 3600` once before the first mutation. Locks orphaned by a crashed prior session reap here.

See `MANUAL.md` for the 3 things that remain user-initiated even with these instructions.

## How Writes Commit

Auto-commit of `wiki/` changes after every write is the responsibility of each mutating skill (`save`, `wiki-ingest`, `wiki-fold`, `autoresearch`). Each ends with a bash block:

```bash
bash scripts/wiki-lock.sh acquire <page-path>
# ... write happens above via Write/Edit tools ...
git add -- wiki/ .raw/ .vault-meta/ 2>/dev/null
git diff --cached --quiet -- wiki/ .raw/ .vault-meta/ || \
  git commit -m "wiki: $(date '+%Y-%m-%d %H:%M')" -- wiki/ .raw/ .vault-meta/
bash scripts/wiki-lock.sh release <page-path>
```

Opt out: `touch .vault-meta/auto-commit.disabled`.

Read-only skills (`wiki-query`, `think`, `wiki-lint`, `defuddle`, `wiki-cli`, `wiki-mode`, `wiki-retrieve`, `obsidian-markdown`, `obsidian-bases`, `canvas`, `wiki`) don't carry the commit pattern — they don't mutate.

## Skills Registry (15)

| Skill | One-line trigger |
|-------|------------------|
| `/wiki` | Setup, scaffold, route to sub-skills |
| `ingest [source]` | Single or batch source ingestion |
| `query: [question]` | Answer from wiki content |
| `lint the wiki` | Health check |
| `/save` | File the current conversation as a structured wiki note |
| `/autoresearch [topic]` | Autonomous research loop: search, fetch, synthesize, file |
| `/canvas` | Visual layer: add images, PDFs, notes to Obsidian canvas |
| `/wiki-cli` | Obsidian CLI transport wrapper; default mutation path on desktop |
| `/wiki-retrieve` | Hybrid contextual + BM25 + cosine-rerank retrieval (opt-in via `bash bin/setup-retrieve.sh`) |
| `/wiki-mode` | Methodology modes (LYT / PARA / Zettelkasten / Generic). Set via `bash bin/setup-mode.sh` |
| `/wiki-fold` | Extractive log rollup into meta-pages (DragonScale Mechanism 1) |
| `/think` | The 10-principle thinking loop (OBSERVE-OBSERVE-LISTEN-THINK-CONNECT-CONNECT-FEEL-ACCEPT-CREATE-GROW) |
| `/defuddle` | Strip clutter from web pages before ingest |
| `obsidian-markdown` | Write correct Obsidian Flavored Markdown (wikilinks, embeds, callouts) |
| `obsidian-bases` | Create and edit Obsidian Bases (.base database files) |

## Cross-Project Access

To reference this wiki from another Copilot CLI project, add to that project's `COPILOT.md` (or `AGENTS.md`):

```markdown
## Wiki Knowledge Base
Path: /path/to/this/vault

When you need context not already in this project:
1. Read wiki/hot.md first (recent context, ~500 words)
2. If not enough, read wiki/index.md
3. If you need domain specifics, read wiki/<domain>/_index.md
4. Only then read individual wiki pages

Do NOT read the wiki for general coding questions or things already in this project.
```

## Transport (v1.7+ from upstream)

`scripts/detect-transport.sh` writes `.vault-meta/transport.json` on first run and refreshes weekly. Skills consult it before mutating the vault. Fallback chain: Obsidian CLI → mcp-obsidian → mcpvault → filesystem (always-available floor). Decision tree: [wiki/references/transport-fallback.md](wiki/references/transport-fallback.md).

Copilot CLI does not introduce a new Obsidian transport. The filesystem floor always works.

## Concurrency (v1.7+ from upstream)

`scripts/wiki-lock.sh` provides per-file advisory locks for safe multi-writer ingest. Every wiki page write is guarded by `wiki-lock acquire`/`release` (now inline in mutating skill bodies, since the PostToolUse hook is gone). Stale-after default is 60s; cross-process release allowed by design.

## Methodology Modes (v1.8+ from upstream)

Pick an organizational style for the vault via `bash bin/setup-mode.sh`. Four modes available: **generic** (no opinion), **LYT** (Linking Your Thinking — MOCs + atomic notes), **PARA** (Projects/Areas/Resources/Archives), **Zettelkasten** (timestamped IDs, flat, dense linking). The mode is written to `.vault-meta/mode.json`. `wiki-ingest`, `save`, and `autoresearch` consult `python3 scripts/wiki-mode.py route <type> "<name>"` before filing new pages.

## Pre-commit verifier (v1.7.1+ from upstream)

After staging changes for a non-trivial workstream but BEFORE running `git commit`, dispatch the `verifier` agent (`agents/verifier.agent.md`). It reads `git diff --cached`, applies the engineering kernel, and returns findings in four tiers (BLOCKER / HIGH / MEDIUM / LOW) with file:line citations. Read-only tools — advisory output.

## MCP (Optional)

If you configure an MCP server (e.g., Obsidian REST API or filesystem-backed), the agent can read and write vault notes directly. See `skills/wiki/references/mcp-setup.md`.
