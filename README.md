# copilot-obsidian: Self-Organizing AI Second Brain for Obsidian + GitHub Copilot CLI

> 🍴 **Forked from [`AgriciDaniel/claude-obsidian`](https://github.com/AgriciDaniel/claude-obsidian)** v1.9.2 (MIT). The upstream targets Claude Code natively. This fork is **rebranded and stripped for [GitHub Copilot CLI](https://docs.github.com/en/copilot/concepts/agents/copilot-cli/about-cli-plugins)**. Both share the same MIT license and the same core architecture.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![GitHub Copilot CLI](https://img.shields.io/badge/GitHub_Copilot_CLI-plugin-181717)](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-plugin-reference)
[![Obsidian](https://img.shields.io/badge/Obsidian-v1.9.10%2B-7c3aed)](https://obsidian.md)
[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-Compatible-blue)](https://agentskills.io)

Copilot CLI + Obsidian knowledge companion. A running AI notetaker that builds and maintains a persistent, compounding wiki vault. Every source you add gets integrated. Every question you ask pulls from everything that has been read. Knowledge compounds like interest.

Based on [Andrej Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f). **15 skills**, multi-writer safe (per-file advisory locking), first-class methodology modes (LYT / PARA / Zettelkasten / Generic), hybrid retrieval (BM25 + cosine rerank), and the 10-principle thinking framework.

---

## Contents

- [What It Does](#what-it-does)
- [Install (GitHub Copilot CLI)](#install-github-copilot-cli)
- [Hooks: replaced by standing instructions](#hooks-replaced-by-standing-instructions)
- [Manual workflow (3 things)](#manual-workflow-3-things)
- [Skills](#skills)
- [Vault Structure](#vault-structure)
- [Optional Features](#optional-features)
- [Cross-Project Access](#cross-project-access)
- [Tests](#tests)
- [Forked from upstream](#forked-from-upstream)
- [License](#license)

## What It Does

Drop a source file into `.raw/`, then tell Copilot: "ingest [filename]". The agent reads it, extracts entities and concepts, files them as wiki pages with frontmatter and cross-references, updates the index, and logs the operation. Ask any question — the agent reads `wiki/hot.md` first, then drills into relevant pages.

The wiki is the product. Chat is the interface. Knowledge persists across sessions and compounds across sources.

## Install (GitHub Copilot CLI)

Prerequisites: [`gh` CLI](https://cli.github.com/), [GitHub Copilot CLI extension](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-in-the-cli), and [Obsidian v1.9.10+](https://obsidian.md/).

**Option 1 — direct install from GitHub:**
```bash
copilot plugin install brudnypiotr/copilot-obsidian
```

**Option 2 — local clone install (for development or pinning a specific commit):**
```bash
git clone https://github.com/brudnypiotr/copilot-obsidian
cd copilot-obsidian
copilot plugin install ./
```

Verify the plugin loaded:
```bash
copilot plugin list                  # should show copilot-obsidian
```

First-time vault bootstrap (run once in the directory that will hold your Obsidian vault):
```bash
bash bin/setup-vault.sh              # creates .raw/, wiki/, _templates/, _attachments/
copilot                              # launch a session
# inside the session:
/wiki                                # scaffold the wiki structure from a one-sentence description
```

Open the directory in Obsidian (File → Open vault → select this directory).

## Hooks: replaced by standing instructions

The upstream `claude-obsidian` shipped 4 Claude Code hooks (`SessionStart`, `PostCompact`, `PostToolUse`, `Stop`) that automated context restoration, auto-commits, and hot-cache prompts. Copilot CLI does not document equivalent hook event names, so this fork **strips them** and replaces their behavior in two ways:

1. **Passive behaviors → standing instructions in [`COPILOT.md`](COPILOT.md)** (loaded by Copilot as session context). Hot-cache load on session start, re-load after compaction, prompt to update hot-cache at session end, stale-lock reaper.
2. **Active behavior (auto-commit after wiki writes) → inline `bash` in 4 mutating skills** (`save`, `wiki-ingest`, `wiki-fold`, `autoresearch`). Each runs `wiki-lock acquire → git add+commit → release` at the end of its body.

You never need to remember to `git commit` after the agent updates the wiki.

## Manual workflow (3 things)

A short list of things that remain user-initiated even with the standing instructions. Most users hit none in a normal session. Full details in [`MANUAL.md`](MANUAL.md).

1. **Lock cleanup after a crashed session** — `bash scripts/wiki-lock.sh clear-stale --max-age 3600`
2. **Forced hot-cache reload if the agent ignored the standing instruction** — say "read wiki/hot.md to restore context"
3. **End-of-day hot-cache update if the session ended abruptly** — say "update wiki/hot.md to reflect today's work"

## Skills

| Skill | Trigger |
|-------|---------|
| `/wiki` | Setup, scaffold, route to sub-skills |
| `ingest [source]` | Single or batch source ingestion |
| `query: [question]` | Answer from wiki content |
| `lint the wiki` | Health check (orphans, dead links, stale claims) |
| `/save` | File the current conversation as a structured wiki note |
| `/autoresearch [topic]` | Autonomous research loop: search, fetch, synthesize, file |
| `/canvas` | Visual layer: add images, PDFs, notes to Obsidian canvas |
| `/wiki-cli` | Obsidian CLI transport wrapper (Obsidian 1.12+) |
| `/wiki-retrieve` | Hybrid contextual + BM25 + cosine-rerank retrieval (opt-in) |
| `/wiki-mode` | Methodology modes (LYT / PARA / Zettelkasten / Generic) |
| `/wiki-fold` | Extractive log rollup into meta-pages (DragonScale Mechanism 1) |
| `/think` | The 10-principle thinking loop |
| `/defuddle` | Strip clutter from web pages before ingest |
| `obsidian-markdown` | Write correct Obsidian Flavored Markdown |
| `obsidian-bases` | Create and edit Obsidian Bases (.base files) |

## Vault Structure

```
.raw/             source documents — immutable, the agent reads but never modifies
wiki/             agent-generated knowledge base
  hot.md          ~500-word recent-context cache (loaded on session start)
  index.md        canonical index of all pages
  log.md          chronological operation log
_templates/       Obsidian Templater templates
_attachments/     images and PDFs referenced by wiki pages
agents/           subagents (verifier, wiki-ingest, wiki-lint)
skills/           15 skills, one per directory
commands/         4 slash-command aliases
scripts/          12 internal scripts (retrieval, locking, transport, modes)
bin/              5 user-facing setup scripts
tests/            9 hermetic test suites
```

## Optional Features

These are opt-in. Run the corresponding installer once when you want them.

| Feature | Installer | What it adds |
|---------|-----------|--------------|
| Hybrid retrieval (BM25 + cosine rerank + contextual prefix per [Anthropic Sept 2024 research](https://www.anthropic.com/news/contextual-retrieval)) | `bash bin/setup-retrieve.sh` | `/wiki-retrieve` skill, ~35-49% retrieval-failure reduction in the upstream's 50-query benchmark |
| Methodology modes | `bash bin/setup-mode.sh` | LYT / PARA / Zettelkasten / Generic; `wiki-ingest` / `save` / `autoresearch` consult `.vault-meta/mode.json` for filing paths |
| DragonScale Memory | `bash bin/setup-dragonscale.sh` | Log folds, deterministic page addresses, semantic tiling lint, boundary-first autoresearch |

## Cross-Project Access

To reference this wiki from another Copilot CLI project, add to that project's [`COPILOT.md`](COPILOT.md) (or `AGENTS.md`):

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

## Tests

```bash
make test                            # 9 hermetic suites; no ollama or network dependency
```

Individual suites:
```bash
make test-address                    # scripts/allocate-address.sh (DragonScale M2)
make test-tiling                     # scripts/tiling-check.py (DragonScale M3)
make test-boundary                   # scripts/boundary-score.py (DragonScale M4)
make test-bm25                       # scripts/bm25-index.py
make test-retrieve                   # scripts/retrieve.py + rerank.py
make test-lock                       # scripts/wiki-lock.sh
make test-concurrent                 # multi-writer concurrency
make test-mode                       # scripts/wiki-mode.py
make test-contextual                 # scripts/contextual-prefix.py
```

## Forked from upstream

This fork inherits the MIT license and credits [`AgriciDaniel/claude-obsidian`](https://github.com/AgriciDaniel/claude-obsidian) v1.9.2 as the canonical original. See [`ATTRIBUTION.md`](ATTRIBUTION.md) for full upstream attribution, and [`CHANGELOG.md`](CHANGELOG.md) `[1.0.0]` for the exact strip + rebrand diff applied by this fork.

For all changes prior to the fork (v1.0.0 through v1.9.2 of `claude-obsidian`), see the upstream's [CHANGELOG.md](https://github.com/AgriciDaniel/claude-obsidian/blob/main/CHANGELOG.md).

If you want the **Claude Code native** version with all 4 hooks intact and the multi-vendor (Cursor, Windsurf, OpenCode) installer, install the upstream directly.

## License

MIT — see [LICENSE](LICENSE).
