# copilot-obsidian: Agent Instructions

This repo is a **GitHub Copilot CLI plugin** and an Obsidian vault that builds persistent, compounding knowledge bases using Andrej Karpathy's LLM Wiki pattern. The skills follow the cross-platform Agent Skills standard, so they also work with **any AI coding agent** that loads the spec — Codex CLI, OpenCode, and similar — via the symlink instructions below.

This is a fork of [`AgriciDaniel/claude-obsidian`](https://github.com/AgriciDaniel/claude-obsidian) v1.9.2 rebranded and stripped for Copilot CLI. The upstream targets Claude Code natively. See [`COPILOT.md`](COPILOT.md) for the Copilot-side standing instructions that replace the upstream's hook layer.

Skills use only `name` and `description` frontmatter (kepano convention). A few older skills still carry an optional `allowed-tools` field for backwards compatibility; agents that do not recognize it should ignore it.

## Skills Discovery

All skills live in `skills/<name>/SKILL.md`. Copilot CLI discovers them automatically via the manifest at `plugin.json` (root) when the plugin is installed.

For other Agent Skills compatible agents (Codex / OpenCode / etc.), symlink the directory:

```bash
# Codex CLI
ln -s "$(pwd)/skills" ~/.codex/skills/copilot-obsidian

# OpenCode
ln -s "$(pwd)/skills" ~/.opencode/skills/copilot-obsidian
```

## Available Skills

| Skill | Trigger phrases |
|---|---|
| `wiki` | `/wiki`, set up wiki, scaffold vault |
| `wiki-ingest` | ingest, ingest this url, ingest this image, batch ingest |
| `wiki-query` | query, what do you know about, query quick:, query deep: |
| `wiki-lint` | lint the wiki, health check, find orphans |
| `wiki-fold` | fold the log, run a fold, log rollup (DragonScale Mechanism 1, opt-in) |
| `wiki-retrieve` | hybrid retrieval, BM25, rerank, search the chunks |
| `wiki-mode` | set vault mode, switch to PARA, use LYT, what's my vault mode |
| `wiki-cli` | obsidian cli, obsidian read, obsidian write, daily note |
| `save` | /save, file this conversation |
| `autoresearch` | autoresearch, autonomous research loop |
| `canvas` | /canvas, add to canvas, create canvas |
| `defuddle` | clean this url, defuddle |
| `think` | think this through, /think, OBSERVE LISTEN THINK |
| `obsidian-markdown` | obsidian syntax, wikilink, callout |
| `obsidian-bases` | obsidian bases, .base file, dynamic table |

## Key Conventions

- **Vault root**: the directory containing `wiki/` and `.raw/`
- **Hot cache**: `wiki/hot.md` (read at session start, updated at session end — see COPILOT.md standing instructions)
- **Source documents**: `.raw/` (immutable: agents never modify these)
- **Generated knowledge**: `wiki/` (agent-owned, links to sources via wikilinks)
- **Manifest**: `.raw/.manifest.json` tracks ingested sources (delta tracking)

## Bootstrap

When the user opens this project for the first time:

1. Read this file (`AGENTS.md`) and the project [`COPILOT.md`](COPILOT.md) for full context
2. Read `skills/wiki/SKILL.md` for the orchestration pattern
3. If `wiki/hot.md` exists, read it silently to restore recent context (COPILOT.md standing instruction #1)
4. If the user types `/wiki` (or "set up wiki"), follow the wiki skill's scaffold workflow

## Reference

- Plugin homepage (this fork): https://github.com/niumfi/copilot-obsidian
- Upstream (Claude Code native): https://github.com/AgriciDaniel/claude-obsidian
- Pattern source: https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
- Cross-reference: https://github.com/kepano/obsidian-skills (authoritative Obsidian-specific skills)
