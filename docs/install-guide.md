# copilot-obsidian: Install Guide

**GitHub Copilot CLI + Obsidian Knowledge Companion**
Version 1.1.0 · forked from [github.com/AgriciDaniel/claude-obsidian](https://github.com/AgriciDaniel/claude-obsidian) v1.9.2 (MIT)

> **Optional: DragonScale Memory extension.** If you want flat extractive log folds, deterministic page addresses, semantic tiling lint, and boundary-first autoresearch topic selection, run `bash bin/setup-dragonscale.sh` after the base install. Extra prerequisites beyond the base: `flock` (standard on Linux; available via `util-linux` on macOS via `brew install util-linux`) and `python3` (for the tiling and boundary helpers). Optional: `ollama` with `nomic-embed-text` pulled if you want the semantic tiling lint (Mechanism 3 only; it no-ops gracefully when ollama or the model is unavailable). The boundary-first scorer (Mechanism 4) needs only `python3`, no ollama.

---

## What is copilot-obsidian?

copilot-obsidian is a GitHub Copilot CLI plugin + Obsidian vault that builds and maintains a persistent, compounding knowledge base. Every source you add gets processed into cross-referenced wiki pages. Every question you ask pulls from everything that has been read. Knowledge compounds like interest.

Built on [Andrej Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f).

---

## Prerequisites

| Tool | How to get it | Notes |
|------|--------------|-------|
| **GitHub CLI** | [cli.github.com](https://cli.github.com/) | Required to install Copilot CLI |
| **GitHub Copilot CLI** | `gh extension install github/gh-copilot` and enable the agentic CLI | See [Copilot CLI docs](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-in-the-cli) |
| **Obsidian** | [obsidian.md](https://obsidian.md) | v1.9.10+ |
| **Git** | Pre-installed on most systems | |
| **WSL2** | Windows users only | Native Windows not supported — see [`architecture/windows-and-multi-user.md`](architecture/windows-and-multi-user.md) |

---

## Installation

### Option 1 — direct from GitHub (recommended)

```bash
copilot plugin install brudnypiotr/copilot-obsidian
```

### Option 2 — local clone (development or pinned commit)

```bash
git clone https://github.com/brudnypiotr/copilot-obsidian
cd copilot-obsidian
copilot plugin install ./
```

Verify:

```bash
copilot plugin list                  # should show copilot-obsidian (v1.1.0)
```

### Option 3 — add to an existing vault

If you already have an Obsidian vault and just want the skills available there, install the plugin as above, then open a Copilot CLI session in your vault directory and type `/wiki`. The skill will detect the existing structure and offer to scaffold the missing pieces.

---

## First-time vault bootstrap

Run once inside the directory that will hold your Obsidian vault:

```bash
bash bin/setup-vault.sh              # creates .raw/, _templates/, _attachments/, .obsidian config
copilot                              # launch a Copilot CLI session
# inside the session:
/wiki                                # scaffold from a one-sentence description
```

Then in Obsidian: **File → Open vault → select the same directory**.

---

## Refreshing after a plugin update

Copilot CLI direct-installs are a frozen tarball cache at `~/.copilot/installed-plugins/_direct/<name>/`. Running `git pull` on the source repo does NOT refresh what Copilot serves. After every release (or local commit you want to test):

```bash
bash bin/refresh-install.sh                      # uses $PWD as the source
# or, with an explicit path:
bash bin/refresh-install.sh /path/to/copilot-obsidian
```

---

## First steps

### 1. Scaffold the vault

Type `/wiki` in Copilot CLI. The agent will:
- Detect your vault mode (website, GitHub, business, personal, research, or book/course)
- Create the folder structure and core wiki pages
- Set up `wiki/index.md`, `wiki/hot.md`, `wiki/log.md`, and `wiki/overview.md`

### 2. Drop your first source

Put any document into `.raw/`:
- PDFs, markdown files, transcripts, articles, URLs

Tell the agent: `ingest [filename]`. It reads the source and creates 8–15 cross-referenced wiki pages.

### 3. Ask questions

```
what do you know about [topic]?
```

The agent reads the hot cache, scans the index, drills into relevant pages, and gives a synthesized answer citing specific wiki pages — not training data.

---

## Commands reference

| Command | What the agent does |
|---------|---------------------|
| `/wiki` | Setup check, scaffold, or continue where you left off |
| `ingest [file]` | Read source, create 8–15 wiki pages, update index and log |
| `ingest all of these` | Batch process multiple sources, then cross-reference |
| `what do you know about X?` | Read index → relevant pages → synthesize answer |
| `/save` | File the current conversation as a wiki note |
| `/save [name]` | Save with a specific title |
| `/autoresearch [topic]` | Autonomous research loop: search, fetch, synthesize, file |
| `/canvas` | Open or create a visual canvas |
| `/canvas add image [path]` | Add an image to the canvas |
| `/canvas add text [content]` | Add a markdown text card |
| `/canvas add pdf [path]` | Add a PDF document |
| `/canvas add note [page]` | Pin a wiki page as a linked card |
| `lint the wiki` | Health check: orphans, dead links, gaps |
| `update hot cache` | Refresh `hot.md` with latest context summary |

---

## Optional features

Each is a separate one-time installer:

```bash
bash bin/setup-retrieve.sh           # /wiki-retrieve: BM25 + cosine rerank + contextual prefix
bash bin/setup-mode.sh               # methodology modes (LYT / PARA / Zettelkasten / Generic)
bash bin/setup-dragonscale.sh        # DragonScale Memory: folds, addresses, tiling, boundary scoring
```

The retrieval pipeline includes an opt-in contextual-prefix generator that calls the Anthropic API. It is off by default; you must pass `--allow-egress` to enable network calls (see [`../PRIVACY.md`](../PRIVACY.md)).

---

## Obsidian plugins

Pre-installed (enable in **Settings → Community Plugins** after first launch):

| Plugin | Purpose |
|--------|---------|
| **Calendar** | Right-sidebar calendar with word count and task dots |
| **Thino** | Quick memo capture panel |
| **Excalidraw** | Freehand drawing, image annotation |
| **Banners** | Header images via `banner:` frontmatter |

Also install from Community Plugins:

| Plugin | Purpose |
|--------|---------|
| **Dataview** | Powers the dashboard queries |
| **Templater** | Auto-fills frontmatter from templates |
| **Obsidian Git** | Auto-commits vault every 15 minutes |

---

## CSS snippets

Three snippets are auto-enabled by `setup-vault.sh`:

| Snippet | Effect |
|---------|--------|
| `vault-colors` | Color-codes wiki folders in the file explorer |
| `ITS-Dataview-Cards` | Turns Dataview queries into visual card grids |
| `ITS-Image-Adjustments` | Fine-grained image sizing; append `\|100` to embeds |

---

## Six wiki modes

| Mode | Use when |
|------|----------|
| **A: Website** | Sitemap, content audit, SEO wiki |
| **B: GitHub** | Codebase map, architecture wiki |
| **C: Business** | Project wiki, competitive intelligence |
| **D: Personal** | Second brain, goals, journal synthesis |
| **E: Research** | Papers, concepts, thesis |
| **F: Book/Course** | Chapter tracker, course notes |

Modes can be combined. The opt-in `/wiki-mode` skill (`bash bin/setup-mode.sh`) layers a methodology on top (LYT / PARA / Zettelkasten / Generic) for how new pages are routed.

---

## MCP setup (optional)

MCP lets the agent read and write vault notes directly without filesystem shelling.

**Option A — Obsidian REST API**

1. Install the **Local REST API** plugin in Obsidian
2. Copy your API key
3. Register the MCP server with Copilot CLI. The exact registration syntax depends on your Copilot CLI version — check the Copilot CLI docs for the current `mcp` command. The server payload is:

```json
{
  "type": "stdio",
  "command": "uvx",
  "args": ["mcp-obsidian"],
  "env": {
    "OBSIDIAN_API_KEY": "your-key",
    "OBSIDIAN_HOST": "127.0.0.1",
    "OBSIDIAN_PORT": "27124",
    "NODE_TLS_REJECT_UNAUTHORIZED": "0"
  }
}
```

**Option B — Filesystem (no Obsidian plugin needed)**

```json
{
  "type": "stdio",
  "command": "npx",
  "args": ["-y", "@bitbonsai/mcpvault@latest", "/path/to/your/vault"]
}
```

Note: the `claude mcp add-json` command in the upstream is Claude-CLI-specific. See `skills/wiki/references/mcp-setup.md` for the disclaimer; consult Copilot CLI docs for the equivalent registration syntax.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `/wiki` says "not found" | Make sure `copilot-obsidian` is installed: `copilot plugin list`. If recently updated, run `bash bin/refresh-install.sh` |
| Old behavior persists after `git pull` | Copilot serves a frozen tarball. Run `bash bin/refresh-install.sh` to reinstall |
| Graph colors reset after closing Obsidian | Open Graph view → gear → Color groups → re-add once. Permanent after that |
| Excalidraw not loading | Run `bash bin/setup-vault.sh` to download `main.js` (8 MB, not in git) |
| Dashboard shows no results | Install the **Dataview** plugin from Community Plugins |
| Hot cache not loading at session start | The COPILOT.md standing instructions should trigger it. If the agent skipped, say `read wiki/hot.md to restore context` (see [`../MANUAL.md`](../MANUAL.md) §2) |
| `flock: command not found` on macOS | `brew install util-linux` then ensure `flock` is on `PATH` |
| `ModuleNotFoundError: fcntl` on Windows | You are on native Windows. Run Copilot CLI inside WSL2 instead; see [`architecture/windows-and-multi-user.md`](architecture/windows-and-multi-user.md) |
| Two writers conflict over OneDrive | Not supported. Use the SWMR topology — one WSL2 writer, others as Obsidian readers ([`architecture/windows-and-multi-user.md`](architecture/windows-and-multi-user.md)) |

---

## Cross-project power move

Point any Copilot CLI project at this vault. Add to that project's `COPILOT.md` (or `AGENTS.md`):

```markdown
## Wiki Knowledge Base
Path: ~/path/to/copilot-obsidian

When you need context not in this project:
1. Read wiki/hot.md first (recent context cache)
2. If not enough, read wiki/index.md
3. If you need domain details, read the relevant wiki page

Do NOT read the wiki for general coding questions.
```

Your assistant, coding projects, and content workflows all draw from the same knowledge base.

---

## Support

- **Repository**: [github.com/brudnypiotr/copilot-obsidian](https://github.com/brudnypiotr/copilot-obsidian)
- **Issues**: [github.com/brudnypiotr/copilot-obsidian/issues](https://github.com/brudnypiotr/copilot-obsidian/issues)
- **Security**: see [`../SECURITY.md`](../SECURITY.md)
- **Upstream (multi-agent)**: [github.com/AgriciDaniel/claude-obsidian](https://github.com/AgriciDaniel/claude-obsidian)

---

*Fork of [AgriciDaniel/claude-obsidian](https://github.com/AgriciDaniel/claude-obsidian) v1.9.2 (MIT). Based on Andrej Karpathy's LLM Wiki pattern.*
