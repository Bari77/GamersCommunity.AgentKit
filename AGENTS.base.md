# Agent guidelines — shared base (AgentKit)

English. Product repos keep a **thin** root `AGENTS.md` that points here and may add `AGENTS.override.md`.

## Always

- **Never start servers** (`dotnet run`, `npm start`, `ng serve`, app Compose stacks). The developer owns terminals. One-shot builds/tests are OK.
- **Never commit/push** unless the developer explicitly asks.
- Follow **`ENGINEERING_STANDARDS.md`** in this module for architecture, packaging, federation DI, migrations, and seeds.
- Prefer each repo’s thin `AGENTS.md` + overrides for repo-only details; do not fork this file for one-off exceptions — use `AGENTS.override.md`.

## Cross-cutting

- **Migrations** → Database project `Add-Migration.ps1` only; **no** seed rows in migrations.
- **Seeds** → class-based under `Seed/`; framework in **Core**.
- **Front** → Nebular; English `$localize` / `i18n`; **published** `@bari77/*` only (lockstep versions); no `postinstall` package hacks; workspace grids on player/guild/team sheets.
- **Shared code** → Core (generic .NET) or DevKit (generic Angular). Game pillars → also update **Games.Template**.
- **Federation** → `provideGameRemoteKernel` on remote `app.config` **and** exported route `providers`; no `providedIn: "root"` for kernel-dependent services.

## Chat language

Replies to the developer may be in **French** when that is the workspace convention. This module and all `AGENTS*` / standards stay in **English**.
