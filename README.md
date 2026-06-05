# Clever Mind

Clever Mind is a native mind-mapping app built with SwiftUI. Create a central topic, branch out ideas, attach notes to any node, and collapse branches to keep large maps readable. Your map is saved locally with Core Data and persists between launches.

Runs on **iOS** (iPhone and iPad) and **macOS**.

## Features

- **Central topic + branches** — Start with a central idea and add child nodes that orbit their parent
- **Nested nodes** — Select any node and add children beneath it to build deeper maps
- **Inline editing** — Rename nodes directly on the canvas
- **Notes per node** — Open the central ellipse or use *Edit notes* on child nodes for longer text
- **Collapse / expand** — Hide or show a node's descendants via the chevron badge, right-click menu, or long-press
- **Local persistence** — Node titles, notes, parent links, and collapse state are stored with Core Data
- **Multiplatform** — One codebase targets iOS and Mac

## Requirements

- Xcode 14 or later (Xcode 15+ recommended)
- **iOS 16.0+** for iPhone/iPad builds
- **macOS 13.0+** for Mac builds
- Apple Developer account (for device deployment and code signing)

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/criticalhc/clevermind.git
   cd clevermind
   ```

2. Open the project in Xcode:
   ```bash
   open Clever-Mind.xcodeproj
   ```

3. Select a run destination:
   - **My Mac** — run the macOS app
   - **iPhone / iPad simulator or device** — run the iOS app

4. Press **Run** (⌘R).

If macOS signing fails, open the **Clever-Mind** target → **Signing & Capabilities** and choose your development team.

### Command-line build (macOS)

```bash
xcodebuild -project Clever-Mind.xcodeproj -scheme Clever-Mind -destination 'platform=macOS' build
```

## How to Use

| Action | How |
|--------|-----|
| Add central topic | Tap **+** on an empty map |
| Add child node | Select a node (long-press a leaf, or right-click → *Select node*), then tap **+** |
| Add to center (nothing selected) | Tap **+** — new node attaches to the central topic |
| Rename a node | Click or tap the node title and type |
| Edit notes (center) | Click the mint ellipse |
| Edit notes (child) | Right-click → *Edit notes* |
| Select a node | Right-click → *Select node*, or long-press a node without children |
| Collapse / expand | Click the **▼ / ▶** badge on nodes with children, right-click → *Collapse children* / *Expand children*, or long-press the node |
| Clear the map | Toolbar trash icon → confirm *Delete All* |
| Pan the canvas | Scroll or drag in the scrollable map area |

Selected nodes show a blue highlight. Collapsed nodes display a badge with their direct child count.

## Project Structure

```
clevermind/
├── Clever-Mind/
│   ├── CleverMindApp.swift          # App entry point
│   ├── ContentView.swift            # Main screen, toolbar, add/clear logic
│   ├── MapNodeRenderer.swift        # Canvas layout, nodes, connectors, collapse UI
│   ├── MindNode.swift               # In-memory node model
│   ├── NodeDetail.swift             # Per-node notes editor
│   ├── AddNode.swift                # Floating + button
│   ├── DataController.swift         # Core Data stack
│   ├── NodeCoreDataRepository.swift   # Save / load nodes
│   └── MindMapModel.xcdatamodeld/   # Core Data schema
└── Clever-Mind.xcodeproj/
```

## Tech Stack

- **SwiftUI** — UI and navigation
- **Core Data** — Local persistence (`Node` entity: id, title, data, parentId, isCollapsed, etc.)
- **Combine** — Observable node model (`@Published` properties)

## License

No license file is included yet. Add one if you plan to open-source or distribute the app.
