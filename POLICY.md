# AgentKit policy — precedence and overrides

## Precedence (highest first)

1. **Current chat** — explicit user instruction for this task only.
2. **`AGENTS.override.md`** at the product-repo root (optional).
3. **Thin root `AGENTS.md`** in the product repo.
4. **`AgentKit/AGENTS.base.md`**, **`AgentKit/ENGINEERING_STANDARDS.md`**, **`AgentKit/cursor/rules/*.mdc`**.

## Override rules

- Overrides **add** or **narrow** behaviour for one repo (extra forbidden paths, game-specific product constraints).
- Overrides must **not** disable safety rails from engineering standards (published packages only, no hand-written migrations, no federation `providedIn: "root"` for kernel services, no unsolicited commit/push/server start).
- If the same override appears in **two or more** repos, **promote** it into AgentKit and delete the duplicates.

## Language

All AgentKit documents and override files are written in **English**.
