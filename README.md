# My Places

An iPhone and iPad app built with SwiftUI and SwiftData to record and organize interesting places.

## Features

- **Organize with Lists:** Group your points of interest into custom lists (e.g., "Vacation Ideas," "Local Favorites").
- **Categorization:** Assign types to your places with custom emojis (e.g., 🍴 Restaurant, 🌳 Park, 🛍️ Shop).
- **Interactive Map:** View your saved places on an interactive map using MapKit.
- **Detailed Records:** Store names, types, locations, photos, last visited dates, and personal notes for every place.
- **Add from Map:** Long-press anywhere on the map to quickly create a new point of interest at that specific coordinate.
- **Navigation:** Easily get directions to any of your saved places via integration with Apple Maps.
- **Modern UI:** Responsive design using `NavigationSplitView`, optimized for iPhone and iPad.

## Technical Stack

- **SwiftUI:** Modern declarative UI framework.
- **SwiftData:** For robust local data persistence and model management.
- **MapKit:** Interactive maps and location services.
- **CoreLocation:** Precise coordinate handling.

## Requirements

- iOS 17.0+ / iPadOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Architecture

The project follows a modern SwiftUI architecture:
- **Models:** SwiftData models (`PointOfInterest`, `PlaceList`, `PlaceType`) define the data schema.
- **Views:** Composable SwiftUI views (e.g., `POIMapView`, `POIDetailView`) handle the presentation layer.
- **SwiftData Integration:** Uses `@Query` for efficient data fetching and `@Environment(\.modelContext)` for data mutations.

## Getting Started

1. Clone the repository.
2. Open `My Places.xcodeproj` in Xcode.
3. Select a target device (iPhone or iPad running iOS 17+).
4. Build and Run.
