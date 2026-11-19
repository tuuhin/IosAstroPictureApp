# AGENTS.md — AstroPicturesApp

Single-target iOS app (SwiftUI + SwiftData) for browsing NASA's Astronomy Picture of the Day (APOD). Buildable only via Xcode (no SPM package, no workspace).

## Build & Run

```bash
# App target only
xcodebuild build -project AstroPicturesApp.xcodeproj -scheme AstroPicturesApp \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' -configuration Debug

# Available simulators: check with `xcodebuild -list`
```

- Deployment target: iOS **26.6** (app), 27.0 (project).
- Swift version: **5.0**, with `SWIFT_APPROACHABLE_CONCURRENCY = YES` and `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`.

### Post-build: format

After every build (and before committing), run swift-format over the whole repo:

```bash
xcrun swift-format format --in-place --recursive --parallel .
```

- This is the same tool the pre-commit hook runs, but repo-wide instead of only staged files, so every file stays compliant.
- Style is defined by `.swift-format` at the repo root (4-space indent, 100 col limit); `.editorconfig` mirrors the indent/width for Xcode's editor. `swift-format` itself does **not** read `.editorconfig`.
- `swift-format` ships inside the Xcode toolchain, so use `xcrun swift-format` (currently 6.4.4 on Xcode 27.2); nothing to install with Homebrew.
- The repo was migrated off Nick Lockwood's `swiftformat` (CLI + pre-commit hook). Do not reintroduce it — the two formatters disagree and will fight over the same files.
- `xcrun swift-format dump-configuration` prints every available option and rule; the `.swift-format` file only lists the overrides, and the rest fall back to those defaults.

## No test target

There is no test target. Swift Testing (Swift 6.4.2 on this toolchain) crashes on every `async` test function (`Runner._applyScopingTraits`). If you add tests, prefer **XCTest** over `@Test async` until the toolchain is updated.

## Architecture

```
AstroPicturesApp/
├── Core/
│   ├── Local/           — SwiftData persistence layer
│   │   ├── Api/         — protocol + errors
│   │   ├── Impl/        — data source + container config
│   │   └── Schemas/     — `LocalSchemaV1` (APODEntity)
│   ├── Remote/          — NASA API client
│   │   ├── Api/         — protocol
│   │   ├── Impl/        — data source, interceptor, networking config
│   │   └── Response/    — `APODResponse` DTO
│   ├── DI/              — `AppDependencyContainer` (singleton, @MainActor)
│   ├── Extensions/      — model mapping (entity ↔ domain)
│   └── Design/          — shared UI components (`AstroImage`, glass effects)
├── Features/
│   ├── APOD/            — fully wired: Data → Domain → Presentation
│   ├── Explore/         — presentation only
│   ├── Favourites/      — presentation only
│   └── NasaSearch/      — presentation only
└── App/                 — entrypoint (`AstroPicturesApp` struct), `ContentView`
```

Only `Features/APOD` has all three layers (Data/Domain/Presentation) wired. The other features exist as stubs.

## DI wiring

`AppDependencyContainer.shared` (at `Core/DI/`) creates everything:

```
APIClientImpl (URLSession + APIKey interceptor → science.nasa.gov)
  └→ AstroPictureRemoteDataSourceImpl
LocalDbConfig.dbModelContainer (persistent SwiftData store)
  └→ AstroPictureLocalDataSourceImpl
        └→ APODRepositoryImpl(remoteDataSource:, localDataSource:)
```

The container is `@MainActor`. `ModelContainer.mainContext` is main-actor-isolated.

## API key

Set `NASA_OPEN_API_KEY` in `Config.xcconfig` (gitignored). `Config.example.xcconfig` has the default `DEMO_KEY`. The project loads the config via Xcode build settings (`xcconfig` file at repo root).

## Code style

- Pre-commit hook runs **`xcrun swift-format format --in-place`** on staged `.swift` files (configured via `core.hooksPath = scripts`).
- Run `xcrun swift-format format --in-place --recursive --parallel .` after builds/changes to format the whole repo (see **Post-build: format** above).
- Install: nothing to install (bundled with Xcode 16+); just run `bash scripts/setup-hooks.sh` to wire up the hook.
- Formatting: `.swift-format` is authoritative — 4-space indent, 100 col limit.
- `.swift-format` lists 9 rule names swift-format does not implement (`NoImplicitSelf`, `OrganizeDeclarations`, `BlankLineBetweenMembers`, `GroupExtensionKeywords`, `NoAbstractMethodCalls`, `NoCasesWithOnlyDefault`, `NeverUseForceCast`, `CaseIndentLevelEqualsSwitch`, `FullyAnnotatedNumberLiterals`). The tool prints an `unrecognized rule` warning for each and ignores it, so those behaviours are not actually enforced.
- Xcode uses the same `.swift-format`: **Editor ▸ Structure ▸ Format File with 'swift-format'** (⌃⇧I), optionally bound to ⌘S for format-on-save.

## Key domain types

| Type | Notes |
|---|---|
| `AstroPictureModel` | `Sendable` domain model. Default `init` is **not** auto-generated; parameter order matters. |
| `APODMediaType` | `.image` / `.video`. Maps from API string `"video"` → `.video`, everything else → `.image`. |
| `LocalDbErrors` | `Error & Equatable`. Cases: `.entryAbsent`. |
| `APODEntity` | SwiftData `@Model`. Attributed `@Attribute(.unique) postId: Int64`. |

## Local DB quirks

- `AstroPictureLocalDataSourceImpl` uses **two** observer dicts (entity list + latest). `publishChanges()` re-fetches the full sorted table on every mutation.
- `fetchTodays()` builds a UTC-midnight day range. The API decodes `yyyy-MM-dd` as UTC midnight via `NetworkingConfiguration.dateFormatter`.
- The private `LocalMigrationPlan` inside `LocalDbConfig` is inaccessible from test targets without changing its access level.

## Remote API quirks

- Base URL: `https://science.nasa.gov`
- Endpoint: `wp-json/wp/v2/apod-basic`. Supported query params are only `page`, `per_page` (max 25), `date_from`, `date_to`.
- JSON decoder uses explicit snake_case `CodingKeys` (post_id, media_type, hdurl, ...) with **no** `.convertFromSnakeCase`, plus a UTC `yyyy-MM-dd` date formatter.
- Date filters need the legacy APOD `yyMMdd` code (e.g. `261118`), not `yyyy-MM-dd`.
- `APIKeyInterceptor` appends `api_key` query param to every request.
- Timeouts: request 30s, resource 60s.