# Agent guidelines — AgentKit

You are editing the **shared** engineering / agent module itself.

- Prefer updating `ENGINEERING_STANDARDS.md`, `AGENTS.base.md`, `POLICY.md`, or `cursor/rules/` here rather than duplicating rules in product repos.
- Product repos consume this tree as submodule `AgentKit/`.
- After meaningful changes: bump awareness in Local `docs/SPEC_AGENTKIT.md` / changelog if needed; product repos `git submodule update --remote AgentKit`.
- Never start servers; commit/push only when asked.
