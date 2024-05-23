// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "Bytes2Chunks",
  products: [
    .library(
      name: "Bytes2Chunks",
      targets: ["Bytes2Chunks"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/apple/swift-async-algorithms",
      from: "1.0.0"
    ),
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0"),
    .package(url: "https://github.com/realm/SwiftLint", from: "0.55.1"),
  ],
  targets: [
    .target(
      name: "Bytes2Chunks",
      dependencies: [
        .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
      ]
    ),
    .testTarget(
      name: "Bytes2ChunksTests",
      dependencies: ["Bytes2Chunks"]),
  ]
)
