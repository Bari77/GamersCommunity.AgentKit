# GamersCommunity — Engineering standards

Canonical **technical conditions** for building and evolving this platform.  
Audience: human engineers and AI coding agents. Prefer this document over improvisation when repository-local `AGENTS.md` files do not cover a topic.

This file is the shared **AgentKit** module copy (repo `GamersCommunity.AgentKit`).  
Per-repo thin `AGENTS.md` files remain the operational entrypoint; **`AGENTS.override.md`** may narrow rules for one repo.

---

## 1. Product shape

GamersCommunity is a **multi-game community platform**:

| Layer | Role |
|-------|------|
| **Platform** | Shell (auth, friends, whispers, staff, game switcher), Module Federation host |
| **Gateway** | HTTP → RabbitMQ RPC routing (`Public` / `Private` actions) |
| **Game remotes** | One Angular remote + .NET Consumer + SQL Database per game (e.g. LoL, WoW) |
| **Core** | Shared .NET libraries (RPC, hosting, seeds, realtime, Platform clients) |
| **DevKit** | Shared Angular packages (`@bari77/gc-*`), CLI, DevGateway image, docs |

**Domain asymmetry is allowed.** Team ≠ Guild; Characters may exist only in WoW. Do **not** force a single domain model across games. Extract **structural twins** (HTTP base, membership, walls, media shells, Consumer host) into Core / DevKit instead.

---

## 2. Non-negotiable operating rules

These apply to every AI session and every contributor:

1. **Do not start long-lived servers** (`dotnet run`, `npm start`, `ng serve`, app Docker Compose stacks). The developer owns terminals. One-shot `dotnet build` / `npm test` / `npm ci` are fine.
2. **Do not commit or push** unless the developer explicitly asks.
3. **Do not invent shortcuts** that violate packaging, migrations, i18n, or federation DI (see below).
4. Prefer **small, reviewable changes** that match existing patterns over greenfield rewrites.
5. **No big-bang rewrites.** Incremental extraction only; preserve product behaviour unless a ticket says otherwise.

User-facing chat with the developer may be in French; **all engineering docs and `AGENTS.md` stay in English.** User-facing product strings default to **English** (i18n).

---

## 3. Repository map and ownership

| Concern | Belongs in |
|---------|------------|
| Generic .NET (Rabbit RPC, Consumer host, seed framework, UTC JSON, realtime publish, Platform RPC clients) | **GamersCommunity.Core** |
| Shared Angular UI / widgets / SDK / MSW / playground helpers | **GamersCommunity.DevKit** (`@bari77/gc-ui`, `gc-widgets`, `gc-sdk`, …) |
| Scaffold for every new game | **GamersCommunity.Games.Template** |
| HTTP routing tables, Public/Private scopes | **GamersCommunity.Gateway** |
| Shell Front + Platform Consumer / Database | **GamersCommunity.Platform** |
| Game-specific domain, UI, Consumer services, seeds | **GamersCommunity.Games.\*** |
| Local infra (Authentik, Rabbit, SQL) | **GamersCommunity.Local** |

### Placement rules

- **Game pillar change** (Consumer `Program.cs`, migrate/seed pipeline, federation bootstrap, compose fundamentals) → update **Template** in the same change set when it should apply to every new game.
- **Truly shared** logic → **Core** (backend) or **DevKit** (frontend). Do not copy into every game and let copies drift.
- **Game-only** domain stays in the game repo. Do not dump LoL/WoW specifics into Core.

---

## 4. Backend (.NET)

### 4.1 Consumer host

Every Consumer (`Platform`, games, Template) boots through Core’s host helper (`GamersCommunityConsumerHost` / equivalent), not a hand-rolled twin of Serilog + Rabbit + EF + Scrutor + Worker.

Game `Program.cs` must stay **thin**: bind game options, register game-specific DI (whispers, authZ, bus scan), and pass an `afterMigrate` seed delegate. Shared plumbing lives in Core.

### 4.2 Messaging and Platform clients

- Prefer Core **`IRabbitRpcClient` / `CallAsync`** — no private Gateway/game `RabbitRpcClient` twins.
- Sanctions, Conversations, Friends clients live in Core and are registered via `AddPlatformRpcClients()` (or the current Core extension).
- Realtime publish and queue name constants live in Core (`IRealtimeEventPublisher`, `RealtimeQueues`).
- Shared JSON date handling uses Core’s UTC converter.

### 4.3 Bus scan and Gateway routing

- Scrutor registers `IBusService` implementations **except** those marked **`[BusInternal]`** (catalog / seed / FK-only helpers that must never become Gateway resources).
- Every other scannable CRUD/action service must have a matching Gateway route, **or** stay deliberately bus-only and be documented (e.g. Gateway `docs/ROUTING.md`).
- Keep each game’s `contracts/federation.contract.json` aligned with the Gateway microservice block for that game.
- Do **not** register a `template` microservice on the main production Gateway (Template uses DevGateway).

### 4.4 Database: migrations

- Generate EF migrations **only** via the Database project’s **`Add-Migration.ps1`**.
- Never hand-write migration classes, invent raw `Up`/`Down` SQL files, or call `dotnet ef migrations add` ad hoc unless that script does it.
- **Never** put seed rows in migrations (`HasData` / `InsertData`). Historical exceptions must be commented as such; new reference data goes to seed classes.

```powershell
cd <Project>.Database
./Add-Migration.ps1 -Name MeaningfulName
```

### 4.5 Database: seeds

- Reference / catalog data = **class-based seeds** under `Seed/`.
- Framework types (`IReferenceTableSeed`, `KeyTableSeed`, discovery, totals) live in **Core**.
- Each Database project keeps a thin `ReferenceDataSeed` + **one class per table (or clear table concern)**.
- No ad-hoc SQL seed scripts as a substitute for that pattern.

### 4.6 NuGet versions

Consumers pin **`GamersCommunity.Core`** (and Logging) to the same published version. After a Core release, bump Gateway, Platform, games, Template, and DevGateway together when they need the change.

---

## 5. Frontend (Angular)

### 5.1 Design system

- Stay within **Nebular** (or closely match it). Prefer Nebular components and existing game/Platform patterns.
- Reusable UI used by more than one Front belongs in **DevKit**, not copy-paste across remotes.
- Player / guild / team **sheets must use a workspace grid** (editable layout + widgets). Do not ship a fixed one-off layout for those surfaces.
- Platform user profile is a **shell** surface: no game-style workspace grid requirement.

### 5.2 Internationalization (i18n)

- Default locale: **English**.
- No hardcoded user-facing strings in templates or TypeScript.
- Use Angular **`$localize` / `i18n`**. Catalog codes use the existing `gameTerm` (or equivalent) pipe/helper.
- Keep locale extract/build pipelines aligned across games (see WoW / LoL `angular.json` + `src/locale`).

### 5.3 Packaging — published only

- **`package.json` must never** depend on a local `dist`, `file:`, or path dependency for `@bari77/*` (or similar shared packages).
- Flow: **change DevKit → publish lockstep version → bump consumers** to that version from the registry (GitHub Packages).
- **`@bari77/gc-*` packages are lockstep SemVer** (same version across the kit, Angular-style). Consumers must keep all `@bari77/*` entries on the **same** version; mixing `gc-ui@1.0.2` with `gc-sdk@1.0.1` is unsupported.
- **Never** add `postinstall` (or similar) scripts that rewrite another package’s `package.json` or patch `node_modules`. If a dependency is too fragile, abandon that approach (fork, DevKit package, different library).

### 5.4 Module Federation and DI (critical)

The Platform shell loads **remote routes only**. It does **not** run the remote `bootstrap` / `app.config`.

Therefore:

1. Call **`provideGameRemoteKernel(...)`** in the remote **`app.config.ts`** (standalone playground) **and** on the parent **`providers`** of the exported federation routes.
2. Do **not** use `providedIn: "root"` for game or SDK services that need `GC_ENVIRONMENT` / membership tokens — they would resolve against the **host** root injector and fail (`NG0201`) under federation.
3. Register game HTTP services (`PlayersService`, guilds/teams, LFG, …) on that same route `providers` array (and on `app.config` when the playground root injects membership).
4. Keep `node_modules/@bari77/gc-sdk/src/**/*.ts` in `tsconfig.app.json` `include` when consuming the source package; add `@bari77/gc-sdk` (and similar) to the Native Federation **`skip`** list so DI metadata is not broken by the federation bundler.

### 5.5 Shared shells vs remote adapters

Prefer DevKit shells for structural UI:

| Concern | Package / pattern |
|---------|-------------------|
| HTTP base, membership, session, media stores | `@bari77/gc-sdk` + `provideGameRemoteKernel` |
| Entity rows / walls, LFG chat presentation | `@bari77/gc-ui` / `@bari77/gc-widgets` |
| Theme | `@bari77/gc-theme` |

Remotes keep **thin adapters**: `$localize` labels, game DTOs/models, SignalR hubs, route wiring. Do not re-implement the shell in each game.

### 5.6 Playground (standalone remotes)

Standalone ports (e.g. `:4201` / `:4202`) use MSW when `useMocks: true`. Platform RPC used by the kernel (e.g. `Users.Touch`) must be mocked like other Gateway calls. Prefer aligning playground chrome (banner, session chip, context bar) across games; extract to DevKit when twins appear.

---

## 6. Specs and documentation

- Product / feature specs live under each Front’s `docs/` with **clear filenames** (`SPEC_TEAMS.md`, `SPEC_PLAYER_SHEET.md`, …).
- Milestone titles must be **descriptive** (`C1 — Team governance`), not bare letters alone.
- Architecture / release docs for shared tooling live in DevKit (`docs/ARCHITECTURE.md`, `RELEASE.md`, `FEDERATION.md`).
- Cross-repo hardening plan: Local `docs/SPEC_TECH_PAUSE.md`.
- Keep specs consistent with shipped behaviour (e.g. do not document a removed board page as current).

---

## 7. Quality bar for AI-assisted development

When proposing or writing code, an agent (or human) must:

1. **Search existing patterns** in Template, sibling games, Core, and DevKit before inventing a new one.
2. **Refuse duplication** of known twins — extract or reuse instead of copying LoL↔WoW↔Template files.
3. **Respect layer boundaries** (no game domain in Core; no Platform shell hacks inside a game remote for shared UI).
4. **Preserve behaviour** unless the task explicitly changes product behaviour; tech hardening must not silently alter mute, whispers, sheets, or routing scopes.
5. **Name things for operators** — migrations, commits, and specs describe intent (`TeamGovernance`, not `Fix1`).
6. **Leave the tree clean** — no drive-by refactors, no unrelated files, no secrets in commits.
7. **Ask before** commit/push, publishing a DevKit/Core tag, or deleting public Gateway routes.

### Definition of done (typical feature)

- [ ] Gateway route (Public/Private) updated if a new bus action is exposed over HTTP  
- [ ] `federation.contract.json` updated when remotes call a new resource/action  
- [ ] Template updated if the change is a game pillar  
- [ ] Core/DevKit used if the change is generic; published version bumped in consumers  
- [ ] Seeds via classes; migrations via `Add-Migration.ps1` only  
- [ ] i18n English strings via `$localize` / `i18n`  
- [ ] Federation-safe providers (no `providedIn: "root"` for kernel-dependent services)  
- [ ] Specs / AGENTS touched only when behaviour or rules change  

---

## 8. Explicit non-goals

Do **not** treat these as “cleanup” during normal hardening unless product asks:

- Unifying Team and Guild domain models  
- Rewriting Gateway routing tables from scratch  
- Migrating historical WoW `InsertData` guild ranks out of old migrations (document only)  
- Platform profile workspace grid  
- Shipping unfinished Events / scrims product as “tech debt fixes”

---

## 9. Related documents

| Document | Location |
|----------|----------|
| This module README / policy | `README.md`, `POLICY.md`, `AGENTS.base.md` |
| Agent checklists (thin) | Each repo `AGENTS.md` + optional `AGENTS.override.md` |
| Tech pause / evolution | `GamersCommunity.Local/docs/SPEC_TECH_*.md` |
| AgentKit adoption spec | `GamersCommunity.Local/docs/SPEC_AGENTKIT.md` |
| DevKit architecture / federation / release | `GamersCommunity.DevKit/docs/` |
| Gateway routing notes | `GamersCommunity.Gateway/docs/ROUTING.md` |
| Game product specs | `<Game>.Front/docs/SPEC_*.md` |

---

*This document is the source of truth for engineering conditions. If a local `AGENTS.md` conflicts on a narrow repo detail, follow that repo’s `AGENTS.md` for the checklist item, then update this file when the rule is cross-cutting.*
