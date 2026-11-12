# CLAUDE.md

Claude Code reads this file at the start of every session.

All project rules live in **[AGENTS.md](AGENTS.md)** so that every AI tool, and every
human, follows the same source of truth. Read it first.

@AGENTS.md

## Claude Code specifics
- Start each session by reading `docs/PROGRESS.md` and continuing from **Next up**.
- Use plan mode for any task that touches more than one module.
- At the end of a session, update `docs/PROGRESS.md`, commit, and push, so the next
  session (or another developer) can continue without context.
