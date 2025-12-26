# HighlighterApp Design & Architecture Guide

## Overview
HighlighterApp is a SwiftUI iOS app with a Share Extension that captures text from other apps and stores it locally. The main app reads the same store and displays highlights. The prototype focuses on local storage, basic editing, and manual refresh with Core Data history merging.

## High-Level Architecture
- **App target**: SwiftUI app that lists and edits highlights.
- **Share Extension**: Reads shared text from the iOS Share Sheet and saves it.
- **Shared storage**: Core Data SQLite store in an App Group container so both targets access the same data.

```
Share Sheet -> Share Extension -> Core Data (App Group) -> App UI
```

## Data Model
Core Data entity: `Highlight`
- `id` (UUID, required)
- `text` (String, required)
- `createdAt` (Date, required)
- `updatedAt` (Date, optional)
- `tags` (String, optional, comma-separated)
- `sourceApp` (String, optional, currently unused)

Model files:
- `HighlighterApp/HighlighterApp/HighlighterApp.xcdatamodeld`
- `HighlighterApp/HighlighterShareExtension/HighlighterApp.xcdatamodeld`

## Persistence Layer
`PersistenceController` builds the Core Data stack and points it to the App Group container:
- App Group ID: `group.com.andytrinh.HighlighterApp`
- Store URL: `HighlighterApp.sqlite`
- File: `HighlighterApp/HighlighterApp/Persistence.swift`

This enables the extension to write and the app to read the same store.

## UI Layer (SwiftUI)
Main list view:
- `ContentView` fetches `Highlight` records and renders the list.
- Pull‑to‑refresh merges persistent history and refreshes objects so new highlights from the extension appear without relaunching.
- File: `HighlighterApp/HighlighterApp/ContentView.swift`

Editor:
- `HighlightEditorView` edits text and tags, saving changes to Core Data.
- File: `HighlighterApp/HighlighterApp/HighlightEditorView.swift`

## Share Extension Flow
File: `HighlighterApp/HighlighterShareExtension/ShareViewController.swift`
1. Read shared items from `NSExtensionContext`.
2. Prefer plain text; fall back to URL.
3. Insert a new `Highlight` into the shared Core Data store.
4. Complete the extension request to return control to the host app.

## Build & Run (Simulator)
1. Open `HighlighterApp/HighlighterApp.xcodeproj`.
2. Select a simulator device.
3. Run the app target (Cmd+R).
4. Run the Share Extension target once to register it.

## Common Pitfalls
- **Missing App Group**: Both targets must include the App Group capability.
- **Stale data**: Use pull‑to‑refresh to merge external changes written by the Share Extension.
- **Model mismatch**: App and extension must use the same Core Data model.

## iOS Development Reference (Prototype Level)
- **Project setup**: Use SwiftUI App lifecycle for small prototypes.
- **Extensions**: Use Share Extensions to receive data from other apps.
- **Core Data**: Use `NSPersistentContainer` with a shared App Group URL.
- **UI updates**: Use `@FetchRequest` for list data, and `Form` for editing.
- **Testing**: Add XCTest for model logic once behavior stabilizes.

## Future Evolution Ideas
- Separate tags into a related entity instead of a comma string.
- Add sorting/filtering controls in the list UI.
- Support export or iCloud sync after the prototype proves useful.
