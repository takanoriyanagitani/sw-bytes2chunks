// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "ChunksToIntegerStrings",
  dependencies: [
    .package(
      url: "https://github.com/apple/swift-async-algorithms",
      from: "1.0.0"
    ),
    .package(url: "https://github.com/realm/SwiftLint", from: "0.55.1"),
    .package(path: "../../.."),
  ],
  targets: [
    .executableTarget(
      name: "ChunksToIntegerStrings",
      dependencies: [
        .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
        "Bytes2Chunks",
      ]
    )
  ]
)
