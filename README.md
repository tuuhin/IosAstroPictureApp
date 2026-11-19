# AstroPicturesApp

Browse NASA's **Astronomy Picture of the Day** (APOD) — a SwiftUI + SwiftData iOS app with offline caching, favourites, and exploration features.

> Built with Xcode 27, Swift 5.0, targeting iOS 26.6+.

---

## Features

- **Daily APOD** — loads the latest image from NASA and caches it locally.
- **Favourites** — mark images to save them persistently via SwiftData.
- **Search & Browse** — explore APOD archives by date range and pagination.
- **Offline** — previously fetched images are available without a network connection.
- **Share & Save** — share images or save them to your photo library.

---

## Requirements

- Xcode 27+
- iOS 26.6+ (simulator or device)
- [swift-format](https://github.com/swiftlang/swift-format) for the pre-commit hook — bundled with Xcode 16+, nothing to install

---

## Setup

1. **Clone the repo**

```bash
git clone <url>
cd AstroPicturesApp
```

2. **Configure your NASA API key**

```bash
cp Config.example.xcconfig Config.xcconfig
```

Edit `Config.xcconfig` and replace `DEMO_KEY` with a [real NASA API key](https://api.nasa.gov/). `Config.xcconfig` is gitignored.

3. **Open the project**

```bash
open AstroPicturesApp.xcodeproj
```

Select a simulator or device and run. There is no Swift Package Manager workspace — the project file is self-contained.

4. **Pre-commit hook (optional)**

```bash
bash scripts/setup-hooks.sh
```

This runs `xcrun swift-format format` on staged `.swift` files before every commit, using the repo's [`.swift-format`](.swift-format) configuration. `swift-format` ships inside the Xcode toolchain, so there is nothing to install.

---

## Build

```bash
xcodebuild build -project AstroPicturesApp.xcodeproj \
  -scheme AstroPicturesApp \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' \
  -configuration Debug
```

List available simulators with `xcodebuild -list`.

---

## Project Structure

```
AstroPicturesApp/
├── Core/
│   ├── Local/               SwiftData persistence (protocol, impl, schema)
│   ├── Remote/              NASA APOD API client (protocol, impl, DTO)
│   ├── DI/                  Dependency injection container
│   ├── Extensions/          Model mappers (entity ↔ domain)
│   └── Design/              Shared UI components
├── Features/
│   ├── APOD/                Main feature (Data → Domain → Presentation)
│   ├── Explore/             Archive browsing (stub)
│   ├── Favourites/          Saved items (stub)
│   └── NasaSearch/          Search (stub)
├── App/                     Entrypoint and ContentView
├── Resources/               Asset catalogs
└── Config.xcconfig          API key (gitignored)
```

### Architecture

The app follows a **layered clean architecture** within each feature:

- **Data** — `AstroPictureRemoteDataSourceImpl` (API) + `AstroPictureLocalDataSourceImpl` (SwiftData)
- **Domain** — `AstroPictureModel`, `APODRepository` protocol, `APODRepositoryImpl`
- **Presentation** — `APODScreenView`, `APODViewmodel` (ObservableObject)

Dependencies are wired in `AppDependencyContainer.shared` (a `@MainActor` singleton at `Core/DI/`).

---

## API

The app uses the [NASA APOD API](https://api.nasa.gov/). The base URL is `https://science.nasa.gov`. The `APIKeyInterceptor` appends your key as a query parameter to every request.

| Endpoint | Purpose |
|---|---|
| `planetary/apod?date=YYYY-MM-DD` | Single image |
| `planetary/apod?start_date=...&end_date=...` | Date-range query |
| `planetary/apod?count=n` | Random images |
| `planetary/apod?page=n&pageCount=n` | Paginated archive |

JSON decoding uses `convertFromSnakeCase` and a UTC `yyyy-MM-dd` date formatter.

---

## Local Storage

APOD data is stored in a local SwiftData store (`ModelContainer` with `SchemaV1`). The `APODEntity` model uses `@Attribute(.unique)` on `postId`, so duplicate saves are automatically upserted.

Offline favourites and caching require no additional setup.

---

## Code Style

- [swift-format](https://github.com/swiftlang/swift-format) (Apple) — style rules live in [`.swift-format`](.swift-format), enforced by the pre-commit hook (`scripts/setup-hooks.sh`).
- 4-space indentation, 100-column line limit.
- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` — the project is fully `@MainActor` by default.

### Formatting

```bash
# Whole repo
xcrun swift-format format --in-place --recursive --parallel .

# Single file
xcrun swift-format format --in-place path/to/File.swift

# Check without writing anything (what CI would run)
xcrun swift-format lint --recursive .
```

Xcode uses the same `.swift-format` file. To format the file you are editing, use **Editor ▸ Structure ▸ Format File with 'swift-format'** (⌃⇧I by default). To make it run on every save, bind that menu item to ⌘S — see [Xcode shortcut](#xcode-shortcut).

### Xcode shortcut

Xcode 16+ ships swift-format, and **Editor ▸ Structure ▸ Format File with 'swift-format'** (⌃⇧I) formats the active file using the `.swift-format` at the project root. Xcode autosaves continuously, so ⌘S is free to be repurposed as format-on-save:

1. **System Settings ▸ Keyboard ▸ Keyboard Shortcuts ▸ App Shortcuts** → **+**
2. Application: **Xcode**
3. Menu Title: `Format File with 'swift-format'`
4. Keyboard Shortcut: **⌘S** → **Done**
5. Relaunch Xcode.

The same thing from the terminal:

```bash
defaults write com.apple.dt.Xcode NSUserKeyEquivalents -dict-add "Format File with 'swift-format'" "@s"
```

This is a per-machine setting and is deliberately not stored in the repo. Undo with `defaults delete com.apple.dt.Xcode NSUserKeyEquivalents` and relaunch Xcode. If the shortcut appears to stop working after switching files, reopen the **Editor ▸ Structure** menu once — a long-standing Xcode bug with app shortcuts.

---

## License

This project is for educational and personal use. NASA's APOD images are public domain, but the API requires a free key.