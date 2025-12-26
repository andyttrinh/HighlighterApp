# Initial Plan

## Scope (Prototype)
- Capture shared text from any app via iOS Share Sheet.
- Store highlights locally with basic metadata (source app, date).
- Allow tagging and simple sorting/filtering.

## Frameworks and Tools
- Language: Swift 5.9+
- UI: SwiftUI
- App lifecycle: SwiftUI App
- Sharing: Share Extension (NSExtension) + `UIActivityViewController` handoff
- Storage: Core Data (local only), lightweight model
- Build/Test: Xcode, XCTest for unit tests (later)
- Lint/Format: SwiftFormat or SwiftLint (to be chosen)

## Architecture Overview
- App target: `HighlighterApp`
- Share Extension target: `HighlighterShareExtension`
- Shared model: `Shared/` module or group for Core Data model and DTOs
- Data flow:
  - Share Extension reads shared text.
  - Saves to Core Data via shared app group container.
  - App reads highlights from Core Data and displays them.
- UI layers:
  - `HighlightsListView` (list, sort, filter)
  - `HighlightDetailView` (content + tags)
  - `TagEditorView` (basic tag management)
- Services:
  - `HighlightStore` (Core Data stack)
  - `TagStore` (tag CRUD)

## Initial Milestones
1. Create Xcode project with app + share extension.
2. Implement Core Data model and app group container.
3. Save shared text from extension.
4. Display list of highlights in app.
5. Add tagging and basic sorting.

## Resolved Decisions
- iOS target: iOS 17.5 (latest stable at time of writing).
- Highlights: editable.
- Sync/export: none for prototype.
- Lint/format: optional; keep it simple, start without one.
- Project name: HighlighterApp.
- Bundle identifier prefix: `com.andytrinh` (for App Group: `group.com.andytrinh.HighlighterApp`).
