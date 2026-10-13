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
- **SemVer (DevKit / Core)** → patch = fix only; minor = additive rétrocompatible; major = breaking. Lockstep tag follows the most severe change. See ENGINEERING_STANDARDS §5.3.
- **Cross-game UX** → same player job = same interaction model across LoL / WoW / Template (search the sibling before inventing; Nebular/`@bari77/*` already used on that surface wins; port twin UX in the same change set). See `cursor/rules/cross-game-ux-consistency.mdc`.
- **Shared code** → Core (generic .NET) or DevKit (generic Angular). Game pillars → also update **Games.Template**.
- **Federation** → `provideGameRemoteKernel` on remote `app.config` **and** exported route `providers`; no `providedIn: "root"` for kernel-dependent services.
- **Authorization** → Platform Nebular ACL = shell only (`accessControlGlobal`); game remotes own ranks/capabilities; never add per-game security matrices into Platform. See ENGINEERING_STANDARDS §5.7.

## Chat language

Replies to the developer may be in **French** when that is the workspace convention. This module and all `AGENTS*` / standards stay in **English**.
