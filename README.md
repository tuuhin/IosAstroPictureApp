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
- [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) for pre-commit hook (optional)

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
brew install swiftformat
bash scripts/setup-hooks.sh
```

This runs `swiftformat` on staged `.swift` files before every commit.

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

- SwiftFormat (`swiftformat`) via pre-commit hook (optional; run `scripts/setup-hooks.sh`).
- 4-space indentation, 120-column line limit (`.editorconfig`).
- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` — the project is fully `@MainActor` by default.

---

## License

This project is for educational and personal use. NASA's APOD images are public domain, but the API requires a free key.