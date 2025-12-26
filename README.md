# HighlighterApp

HighlighterApp is an iOS prototype for collecting text highlights via the Share Sheet. It includes a Share Extension that saves shared text into a Core Data store shared with the main app.

## Key Features
- Share text from any app into HighlighterApp.
- View and edit highlights with basic tag support.
- Pull to refresh to merge shared changes.

## Project Setup
- Open `HighlighterApp/HighlighterApp.xcodeproj` in Xcode.
- Run the `HighlighterApp` target in a simulator.
- Run the Share Extension target once to register it.

## Development Notes
- Core Data uses an App Group store: `group.com.andytrinh.HighlighterApp`.
- Pull‑to‑refresh merges persistent history to surface new highlights.
