# GamersCommunity.AgentKit

Shared **engineering standards**, **agent guidelines**, and **Cursor rules** for every GamersCommunity repository.

Consumed as a **Git submodule** at `AgentKit/` in each product repo. Optional per-repo overrides stay outside the submodule (`AGENTS.override.md`).

## Contents

| Path | Role |
|------|------|
| `ENGINEERING_STANDARDS.md` | Canonical engineering conditions |
| `AGENTS.base.md` | Shared agent checklist |
| `POLICY.md` | Precedence / overrides |
| `cursor/rules/` | Shared Cursor `.mdc` rules |
| `templates/` | Skeletons for thin root `AGENTS.md` / overrides / feature specs |
| `scripts/Sync-CursorRules.ps1` | Copy shared rules into the host repo’s `.cursor/rules` |

## Add to a product repo

```powershell
cd <product-repo>
git submodule add https://github.com/Bari77/GamersCommunity.AgentKit.git AgentKit
git submodule update --init --recursive
./AgentKit/scripts/Sync-CursorRules.ps1
```

Replace the fat root `AGENTS.md` with the thin template in `templates/AGENTS.repo.md` (fill `<RepoName>` and any short repo-specific bullets).

Clone with submodules:

```powershell
git clone --recurse-submodules https://github.com/Bari77/<product-repo>.git
# or after a normal clone:
git submodule update --init --recursive
```

## Override model

1. Current chat instruction  
2. Repo `AGENTS.override.md`  
3. Repo thin `AGENTS.md`  
4. This module (`AGENTS.base.md` + standards + Cursor rules)

See `POLICY.md`.

## Related (orchestration, not in this repo)

- Tech pause / evolution roadmaps live in **GamersCommunity.Local** (`docs/SPEC_TECH_*.md`, `docs/SPEC_AGENTKIT.md`).
- Package release / federation how-to stay in **GamersCommunity.DevKit** docs.
