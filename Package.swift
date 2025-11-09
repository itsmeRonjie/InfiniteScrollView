// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "InfiniteScrollView",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "InfiniteScrollView",
            targets: ["InfiniteScrollView"]
        )
    ],
    targets: [
        .target(
            name: "InfiniteScrollView",
            path: "Sources/InfiniteScrollView"
        )
    ]
)
