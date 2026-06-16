# Windows + WSL2 + multi-user posture

This document captures the project's official stance on cross-platform operation and multi-user setups. It is the answer to "can I run this on Windows / on a shared OneDrive / with three teammates?" Short answer: yes, but only in the Single Writer, Multiple Readers (SWMR) shape described below. Multi-writer over a network share is not supported and will silently corrupt the vault.

## 1. Supported topology — Single Writer, Multiple Readers (SWMR)

```
┌──────────────────────┐       sync (OneDrive / SMB / git pull)        ┌──────────────────────┐
│  Writer host (one)   │  ────────────────────────────────────────►    │  Reader hosts (N)    │
│  Linux / macOS /     │                                                │  any OS, Obsidian    │
│  WSL2                │                                                │  no Copilot mutation │
│  • runs Copilot CLI  │                                                │  • read-only         │
│  • holds the locks   │                                                │  • opens vault in    │
│  • runs `wiki-ingest`│                                                │    Obsidian          │
│  • `wiki-fold`, etc. │                                                │  • manual notes OK   │
└──────────────────────┘                                                └──────────────────────┘
```

- **Exactly one host** is the writer. That host is the only place where Copilot CLI invokes mutating skills (`wiki-ingest`, `save`, `wiki-fold`, `autoresearch`, `wiki-mode`, the BM25 index rebuild, the DragonScale tiling rebuild).
- **The writer is Linux, macOS, or WSL2 on Windows.** Native Windows Copilot CLI is out of scope — see §5.
- **Reader hosts run Obsidian only.** They can be any OS. They open the same directory (synced via OneDrive / SMB / Dropbox / Git pull) and read freely. They must NOT run Copilot CLI against the vault, and must NOT invoke mutating skills.
- **Manual reader edits** (typing notes directly in Obsidian) are allowed but bypass the lock layer. Conflict resolution is the user's problem.

## 2. Why multi-writer over a network share is unsafe

Three Unix-isms in the lock and retrieval layers break in cross-host or cloud-sync scenarios:

### 2.1 `flock` semantics break over SMB

`scripts/wiki-lock.sh:118` and `scripts/allocate-address.sh:36` use `flock -x -w 5 9` for atomic exclusive locking. `flock` is a kernel-level advisory lock on the local POSIX filesystem. Over SMB on Windows it behaves unpredictably; over OneDrive / Dropbox / Google Drive sync clients it does not propagate at all — two hosts can each acquire the "same" lock and both write, producing a "Conflicted Copy" file on the cloud side.

### 2.2 PID-based liveness checks compare PIDs across machines

`scripts/wiki-lock.sh:112` does `kill -0 "$1"` against the PID stored in the lock file to test "is the holder still alive?" When the holder is on a different machine, that PID belongs to someone else's process (or no one) on the local host. The check returns a meaningless result, and stale-lock detection produces ghost results.

### 2.3 File-mtime stale detection breaks under clock skew

Stale-lock reaping uses the lock file's `mtime` against the wall clock (default max-age: 60s, configurable up to 3600s). If host A's clock is 2 minutes ahead of host B's, host B sees a "future-dated" lock and either over-reaps locks A is still holding or refuses to reap locks that are genuinely abandoned.

### 2.4 `fcntl` is Unix-only Python

`scripts/rerank.py:155`, `scripts/bm25-index.py:103`, and `scripts/tiling-check.py:167` import `fcntl` for `LOCK_EX | LOCK_NB` flocking of cache files. On native Windows Python (CPython without WSL2), `import fcntl` raises `ModuleNotFoundError` at module load. The retrieval pipeline and DragonScale tiling will not run at all on native Windows.

### 2.5 Conditional auto-commit races

Each mutating skill ends with an inline bash block that does `git add -- wiki/ .raw/ .vault-meta/` + `git commit -m "wiki: $(date '+%Y-%m-%d %H:%M')"`. If two writers commit concurrently against a shared remote, the second push is rejected and one writer's work goes uncommitted until manually resolved. SWMR eliminates this by definition.

## 3. Reader posture

- Open the vault directory in Obsidian. Treat it as read-only with the understanding that any manual notes typed in Obsidian land in the synced folder.
- Do NOT install Copilot CLI plugins against this vault. Do NOT run `bin/setup-vault.sh` or any `bin/setup-*` installer.
- Document risk: a manual Obsidian note typed during a writer's mutation could race the writer's `git add`. The lock layer does not protect against Obsidian — only against other Copilot CLI invocations. Treat manual notes as best-effort.

## 4. Writer posture

- One host runs WSL2 (Windows users) or native Linux/macOS.
- Install Copilot CLI inside the WSL2 distribution, not under Windows. `~/.copilot/installed-plugins/` should be on the ext4 side.
- The vault directory should live on the local disk of the writer, NOT on a network share. Sync direction: writer's local disk → cloud → readers. Push outward.
- Cadence: commit + push from the writer host on every mutating skill (this is automatic). Readers pull (or accept cloud sync) at their own cadence.

## 5. Out of scope: native Windows writer

A native Windows writer is not supported. The work to make it supportable, captured here so it isn't accidentally lost:

- Rewrite `scripts/wiki-lock.sh`, `scripts/allocate-address.sh`, and `scripts/detect-transport.sh` in Python (or PowerShell). ~400 LOC.
- Swap `fcntl` for `msvcrt.locking` in `scripts/rerank.py`, `scripts/bm25-index.py`, and `scripts/tiling-check.py`. ~50 LOC each. Note that `msvcrt.locking` has byte-range semantics, not file-scoped, so the file-level intent needs explicit emulation.
- Replace `pgrep` / `kill -0` with Windows-API equivalents (`tasklist`, `OpenProcess`). The PID-liveness check at `scripts/wiki-lock.sh:112` needs a non-portable substitute.
- The inline auto-commit bash blocks in `skills/save/SKILL.md`, `skills/wiki-ingest/SKILL.md`, `skills/wiki-fold/SKILL.md`, `skills/autoresearch/SKILL.md` need bash → PowerShell duplicates (or a shared launcher that dispatches per-OS).
- Hermetic test coverage on Windows runners (currently `make test` is bash-only).

Total: a multi-week port. Not on the roadmap. If you need this, open an issue and we can discuss whether to upstream the port to `AgriciDaniel/claude-obsidian` so both projects benefit.

## 6. Quick checklist

> If you're on Windows native and three teammates want to write to a shared vault on OneDrive: **no, not safely.** See §2 for why. The supported alternative is one WSL2 writer + the teammates as readers (§1).

| Scenario | Supported? | Notes |
|----------|-----------|-------|
| One Linux/macOS user, local disk | ✅ | Reference setup |
| One WSL2 user on Windows, local ext4 | ✅ | Recommended for Windows users |
| One WSL2 writer + N Obsidian readers on OneDrive | ✅ | SWMR — supported topology |
| One WSL2 writer + N Obsidian readers via SMB share | ✅ | SWMR — supported |
| Native Windows Copilot CLI writer | ❌ | `fcntl` blocks at import time |
| Two writers on the same OneDrive folder | ❌ | `flock` does not cross machines |
| Two writers on the same SMB share | ❌ | PID + clock-skew issues |
| Reader who also runs Copilot CLI mutating skills | ❌ | Same as two writers |

## References

- Source analysis: `/Users/niumfi/.gemini/antigravity-ide/brain/.../windows_compatibility_analysis.md` (private)
- Lock implementation: `scripts/wiki-lock.sh`
- Retrieval flocks: `scripts/rerank.py:155`, `scripts/bm25-index.py:103`, `scripts/tiling-check.py:167`
- Auto-commit blocks: `skills/{save,wiki-ingest,wiki-fold,autoresearch}/SKILL.md`
