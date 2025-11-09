# InfiniteScrollView

A SwiftUI package that provides a fully programmatic, infinitely scrolling stack (vertical or horizontal) with smart prefetching, recycling, and optional pull-to-refresh support. Includes an example calendar demo to showcase usage.

> Repository: https://github.com/itsmeRonjie/InfiniteScrollView

## Features

- Infinite scrolling in any direction using arbitrary index types.
- Center-locking behavior with callbacks when the centered index changes.
- Smart window management with prefetch/recycle distances tuned to keep memory in check.
- Optional pull-to-refresh (iOS 15+) and programmatic jump-to-index support.
- Demo app (`Examples/InfiniteScrollViewDemo`) that renders an infinite calendar.

## Requirements

- Swift 5.9+
- iOS 15 / macOS 12 / tvOS 15 / watchOS 8

## Installation

### Xcode

1. `File > Add Packages…`
2. Enter `https://github.com/itsmeRonjie/InfiniteScrollView`.
3. Choose the `InfiniteScrollView` product for your target.

### Swift Package Manifest
```swift
// In Package.swift
let package = Package(
    dependencies: [
        .package(url: "https://github.com/itsmeRonjie/InfiniteScrollView.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "YourApp",
            dependencies: [
                .product(name: "InfiniteScrollView", package: "InfiniteScrollView")
            ]
        )
    ]
)
```

## Quick Start

```swift
import SwiftUI
import InfiniteScrollView

struct MonthIndex: Equatable, Hashable { var offset: Int }

struct InfiniteCalendar: View {
    @State private var selected = MonthIndex(offset: 0)
    @State private var updateFlag = false
    private let calendar = Calendar(identifier: .gregorian)
    private let baseDate = Date()

    var body: some View {
        InfiniteScrollView(
            spacing: 24,
            changeIndex: selected,
            contentMultiplier: 3,
            updateBinding: $updateFlag,
            orientation: .vertical,
            refreshAction: nil,
            increaseIndexAction: { MonthIndex(offset: $0.offset + 1) },
            decreaseIndexAction: { MonthIndex(offset: $0.offset - 1) },
            onCenteredIndexChanged: { selected = $0 }
        ) { index in
            MonthCard(index: index)
        }
        .padding(.vertical, 32)
    }
}

struct MonthCard: View {
    let index: MonthIndex
    var body: some View { Text("Month \(index.offset)") }
}
```

### Key Parameters
- `changeIndex`: Source-of-truth for the currently centered item. Update it to jump programmatically.
- `increaseIndexAction` / `decreaseIndexAction`: Provide the next/previous indices (return `nil` to stop extending in that direction).
- `contentMultiplier`: Adjusts how many items stay in memory around the viewport (must be ≥ 3; odd values feel best).
- `updateBinding`: Toggle this binding to force a rebuild/center on the current `changeIndex`.
- `refreshAction`: Enables `refreshable` (iOS 15+) handling when provided.
- `onCenteredIndexChanged`: Called whenever the view deems a new index centered; use it to update external state.

## Demo App

1. Open `Package.swift` in Xcode (or open `InfiniteScrollView.xcodeproj` if you prefer the project file).
2. Select the `InfiniteScrollViewDemo` scheme and run on any iOS 15+ simulator.
3. Scroll vertically or horizontally to watch the calendar recycling logic in action; tap “Go to Current Month” to see programmatic centering.

## Example Video


https://github.com/user-attachments/assets/b0819058-28bf-4f1b-834d-65a10bc60c77


https://github.com/user-attachments/assets/952e5c22-f342-49ef-b21b-7800ec4a3197



## License
MIT (see [LICENSE](LICENSE) once added to the repository).
