# MANUAL.md — What runs by hand under Copilot CLI

This fork does not ship Claude Code hooks (they were stripped during the v1.0.0 rebrand because Copilot CLI does not document equivalent hook event names). Their behavior is reproduced via:

- **Standing instructions in [`COPILOT.md`](./COPILOT.md)** (passive — Copilot loads it as session context)
- **Inline `bash` in mutating skills** `save`, `wiki-ingest`, `wiki-fold`, `autoresearch` (active — runs as part of the skill)

This leaves a short list of 3 things that remain user-initiated. Most users hit none of them in a normal session.

## 1. Lock cleanup after a crashed session

If a Copilot CLI session crashed mid-write, advisory locks in `.vault-meta/locks/` may not have released. The next session would refuse to acquire them until they age out (default: 60s) or you reap them.

**When**: only after a known crash. Not part of normal flow.

**How**:
```bash
bash scripts/wiki-lock.sh clear-stale --max-age 3600
```

The `COPILOT.md` standing instruction #4 asks the agent to run this on session start when `.vault-meta/locks/` is non-empty, so in practice you rarely do it by hand. Do it explicitly only if the agent skipped the instruction.

## 2. Forced hot-cache reload after a long pause

`COPILOT.md` instructs the agent to read `wiki/hot.md` on session start to restore recent context. If the agent ignored the standing instruction (it can happen when there's a strong opening prompt that pulls attention elsewhere), the agent will be missing recent context.

**When**: you notice the agent doesn't seem to know something from your last few sessions.

**How**: tell the agent explicitly:
```
read wiki/hot.md to restore context
```

## 3. Hot-cache update at end of day or session

The upstream Claude Code `Stop` hook printed a `WIKI_CHANGED` reminder when `wiki/` was modified this session. Copilot CLI has no equivalent. The `COPILOT.md` standing instruction #3 asks the agent to prompt you before session end, but if the session ended abruptly (you closed the terminal, `Ctrl+C`, etc.), the reminder never fired.

**When**: at the end of a productive day, or whenever you realize `wiki/hot.md` is stale relative to recent work.

**How**: open Copilot and say:
```
update wiki/hot.md to reflect the last N days of work
```

The agent reads recent git log + the current `wiki/hot.md`, then overwrites with a fresh summary (under 500 words, factual, not a journal).

## 4. Refreshing the plugin after a release

Copilot CLI direct-installs are stored as a frozen tarball under `~/.copilot/installed-plugins/_direct/copilot-obsidian-fork/`. Running `git pull` on the source clone does NOT update that copy — Copilot keeps serving whatever was installed.

**When**: after every `copilot-obsidian` release you want to pick up, or after a local commit you want to test in-session.

**How**:
```bash
bash bin/refresh-install.sh                # uses $PWD as the source
# or, with an explicit path:
bash bin/refresh-install.sh /path/to/copilot-obsidian
```

Verify:
```bash
copilot plugin list                        # should show the new version
```

This script is a 5-line wrapper around `copilot plugin uninstall copilot-obsidian && copilot plugin install <path>`. Read it before running.

## Operating environment

This fork is natively POSIX (Linux / macOS / WSL2). On Windows, run Copilot CLI inside WSL2 — the bash scripts in `scripts/` and the `fcntl`-based Python locks in the retrieval / DragonScale layers are Unix-only. Multi-user setups follow a **Single Writer, Multiple Readers** topology: see [`docs/architecture/windows-and-multi-user.md`](docs/architecture/windows-and-multi-user.md).

## Everything else runs automatically

Specifically, **`git commit` after wiki writes is not on this list**. Each mutating skill (`save`, `wiki-ingest`, `wiki-fold`, `autoresearch`) embeds a `git add + git commit` bash block at the end of its body. You don't need to remember to commit.

The full mapping from upstream hook → fork mechanism:

| Upstream hook | Behavior | Fork replacement |
|---------------|----------|------------------|
| `SessionStart` (cat hot.md) | Load hot cache | COPILOT.md standing instruction #1 |
| `SessionStart` (clear-stale) | Reap stale locks | COPILOT.md standing instruction #4 + MANUAL.md #1 fallback |
| `PostCompact` | Re-read hot.md after compaction | COPILOT.md standing instruction #2 |
| `PostToolUse` (Write/Edit matcher) | Auto-commit wiki/ | Inline bash in 4 mutating skills |
| `Stop` (WIKI_CHANGED reminder) | Prompt hot.md update | COPILOT.md standing instruction #3 + MANUAL.md #3 fallback |
