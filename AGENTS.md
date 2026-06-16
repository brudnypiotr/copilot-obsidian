# copilot-obsidian: Agent Instructions

This fork supports **GitHub Copilot CLI only**. The skills, agents, and commands are loaded by Copilot via the manifest at `plugin.json`; no other agent ecosystem is tested or supported here.

For Claude Code, Codex CLI, OpenCode, or other Agent Skills compatible agents, use the upstream: [`AgriciDaniel/claude-obsidian`](https://github.com/AgriciDaniel/claude-obsidian). Its `AGENTS.md` documents the symlink layout for those tools.

The Copilot-side standing instructions for this fork live in [`COPILOT.md`](COPILOT.md). Start there for session bootstrap, hot-cache rules, and the inline-commit pattern that replaces the upstream's hook layer.

## Reference

- Plugin homepage: https://github.com/brudnypiotr/copilot-obsidian
- Upstream (multi-agent): https://github.com/AgriciDaniel/claude-obsidian
- LLM Wiki pattern (Karpathy): https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
