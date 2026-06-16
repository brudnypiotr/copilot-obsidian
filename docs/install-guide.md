# Install guide — copilot-obsidian

GitHub Copilot CLI plugin. Forked from [`AgriciDaniel/claude-obsidian`](https://github.com/AgriciDaniel/claude-obsidian) v1.9.2. Both share MIT and the same core architecture.

## Prerequisites

- [GitHub CLI](https://cli.github.com/) (`gh`) authenticated against your account
- [GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-in-the-cli) extension installed (`gh extension install github/gh-copilot` then enable the CLI agent)
- [Obsidian v1.9.10+](https://obsidian.md/) on the host where the vault lives
- macOS, Linux, or Windows with WSL2 (native Windows is not supported — see [`architecture/windows-and-multi-user.md`](architecture/windows-and-multi-user.md))

## Install

### Option 1 — direct from GitHub

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
copilot plugin list                  # should show copilot-obsidian
```

## First-time vault bootstrap

Run once inside the directory that will hold your Obsidian vault:

```bash
bash bin/setup-vault.sh              # creates .raw/, wiki/, _templates/, _attachments/
copilot                              # launch a Copilot CLI session
# inside the session:
/wiki                                # scaffold from a one-sentence description
```

Then in Obsidian: File → Open vault → select the same directory.

## Refreshing after an update

Direct-installs are a frozen tarball cache at `~/.copilot/installed-plugins/_direct/<name>/`. `git pull` on the source repo does NOT refresh what Copilot serves. After every release (or local commit you want to test):

```bash
bash bin/refresh-install.sh                      # uses $PWD as the source
# or, with an explicit path:
bash bin/refresh-install.sh /path/to/copilot-obsidian
```

## Optional features

Each is a separate one-time installer:

```bash
bash bin/setup-retrieve.sh           # /wiki-retrieve: BM25 + cosine rerank + contextual prefix
bash bin/setup-mode.sh               # methodology modes (LYT / PARA / Zettelkasten / Generic)
bash bin/setup-dragonscale.sh        # DragonScale Memory: folds, addresses, tiling, boundary scoring
```

The retrieval pipeline includes an opt-in contextual-prefix generator that calls the Anthropic API. It is off by default; you must pass `--allow-egress` to enable network calls (see [`../PRIVACY.md`](../PRIVACY.md)).

## Verify the install end-to-end

```bash
copilot plugin list                  # 1. plugin present
make test                            # 2. all hermetic suites pass (~1 min)
# in a fresh empty dir:
copilot                              # 3. start a session
/wiki                                # 4. scaffold; expect a COPILOT.md (not CLAUDE.md) in the vault root
```

## Upstream

For the multi-agent (Claude Code / Codex CLI / OpenCode) version with hooks intact, install [`AgriciDaniel/claude-obsidian`](https://github.com/AgriciDaniel/claude-obsidian) directly. This fork is Copilot CLI only.
