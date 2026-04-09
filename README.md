<div align="center">

# 🗺️ GeoQuest

### *Find caches. Earn points. Explore.*

A location-based treasure-hunting iOS app built with SwiftUI and MapKit.

![Platform](https://img.shields.io/badge/platform-iOS%2018%2B-lightgrey?style=flat-square)
![Swift](https://img.shields.io/badge/Swift-5.9-orange?style=flat-square&logo=swift)
![Xcode](https://img.shields.io/badge/Xcode-16-blue?style=flat-square&logo=xcode)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5-green?style=flat-square)

**Kingston University — Mobile Application Development**

</div>

---

## 📖 About

GeoQuest is a geocaching-style iOS application that turns the real world into a treasure-hunt playground. Players join hunting events, navigate to hidden caches using a live map and compass, and log finds when they're close enough to claim the points. Event organisers can create their own hunts, drop caches at chosen coordinates, and watch participants climb the leaderboard.

The app was developed as coursework for the Mobile Application Development module at Kingston University, demonstrating the use of native iOS frameworks, RESTful API integration, location services, and the MVC architectural pattern in a real-world SwiftUI application.

---

## ✨ Features

- **🗺️ Interactive Map** — Live MapKit view showing all available caches with custom annotations and the user's current location
- **📍 Proximity Detection** — Uses CoreLocation to detect when a player is within 30 metres of a cache and unlocks it for collection
- **🧭 Compass Bearing** — Real-time directional arrow points toward the selected cache using device heading
- **🏆 Events & Leaderboards** — Join public or private hunting events and compete with other players for points
- **📸 Find Logging** — Capture a photo when you discover a cache to record your find
- **👤 User Profiles** — Register, log in, and manage your account with persistent sessions
- **🌗 Light & Dark Mode** — Full appearance support including a custom dark-mode app icon
- **📡 RESTful Backend** — All data is synchronised with the GeoQuest API hosted at `mark0s.com`

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Language** | Swift 5.9 |
| **UI Framework** | SwiftUI |
| **Mapping** | MapKit |
| **Location & Compass** | CoreLocation |
| **Networking** | URLSession (async/await) |
| **Concurrency** | Swift Concurrency (`async`/`await`, `@MainActor`) |
| **Architecture** | Model–View–Controller (MVC) |
| **Persistence** | UserDefaults (session storage) |
| **Backend** | GeoQuest REST API |

---

## 🏛️ Architecture

The project follows a classic **MVC** structure, with clear separation between data, presentation, and business logic.

```
Treasure-Hunt_Application/
├── Model/                  # Data models & API layer
│   ├── Models.swift        # User, Event, Cache, Player, Find, Status
│   ├── GeoQuestAPIManager.swift
│   └── SessionManager.swift
│
├── Controller/             # ObservableObject controllers
│   ├── AuthController.swift
│   ├── EventController.swift
│   └── MapController.swift
│
├── View/                   # SwiftUI screens
│   ├── Auth/               # Login & registration
│   ├── Map/                # Main map interface
│   ├── Cache/              # Cache details, creation, camera
│   └── Shared/             # Reusable components
│
├── Services/               # System wrappers
│   ├── LocationService.swift
│   └── PedometerService.swift
│
└── Utilities/
    └── Extensions.swift    # Bearing calculations & helpers
```

**Controllers** are `@MainActor` classes conforming to `ObservableObject`, exposing `@Published` state that views observe reactively. **Views** remain stateless where possible and delegate all logic to controllers. **Models** are `Codable` structs that map directly to the GeoQuest API's JSON schema.

---

## 🚀 Getting Started

### Requirements

- macOS Sonoma or later
- **Xcode 16+**
- **iOS 18+** (deployment target)
- An Apple Developer account (free or paid) for code signing
- Physical iPhone recommended for full GPS / compass / camera testing

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/<your-username>/iOS-Treasure-Hunt-Application.git
   cd iOS-Treasure-Hunt-Application
   ```

2. **Open the project in Xcode**
   ```bash
   open Treasure-Hunt_Application/GeoQuest.xcodeproj
   ```

3. **Configure code signing**
   - Select the `GeoQuest` target → **Signing & Capabilities**
   - Set your development **Team**
   - Change the **Bundle Identifier** to something unique (e.g. `com.yourname.GeoQuest`)

4. **Set the API key**
   - Open `Model/GeoQuestAPIManager.swift`
   - Replace the `apiKey` value with your team's key issued by the module leader

5. **Build & run** (`⌘R`) on a simulator or connected device

> **Note:** Location and camera features require running on a physical device for full functionality. The simulator can simulate GPS coordinates via *Features → Location → Custom Location*.

---

## 📱 Permissions

GeoQuest requests the following permissions on first launch:

- **Location (When In Use)** — required to display your position on the map and detect cache proximity
- **Camera** — required to photograph caches when logging a find
- **Motion & Fitness** — used by the pedometer service for activity tracking

---

## 🔌 API

The app communicates with the GeoQuest REST API hosted at `https://mark0s.com/geoquest/v1/api`. All requests are authenticated with a query-parameter API key. Endpoints used include:

| Method | Endpoint | Purpose |
|---|---|---|
| `GET` | `/users` | List or look up users |
| `POST` | `/users` | Register a new user |
| `PUT` | `/users/{id}` | Update user profile or location |
| `GET` | `/events` | List all hunting events |
| `POST` | `/events` | Create a new event |
| `GET` | `/caches` | List all caches |
| `GET` | `/caches/events/{id}` | List caches for a specific event |
| `POST` | `/caches` | Place a new cache |
| `POST` | `/players` | Join an event as a player |
| `POST` | `/finds` | Log a cache find |

All payloads are JSON. The API returns IDs as integers, which are decoded into a custom `FlexibleID` wrapper that accepts both `Int` and `String` forms.

---

## 👥 Authors

| Name | Role |
|---|---|
| **Abdullah Sajid** | iOS Development — Models, API layer, Authentication |
| **Reda Ejhani** | iOS Development — Map, Location services, Cache views |

---

## 📄 Licence

This project was created for academic purposes as part of the Mobile Application Development module at Kingston University. It is not licensed for commercial use.

---

<div align="center">

*Built with ☕ and SwiftUI at Kingston University*

</div>
