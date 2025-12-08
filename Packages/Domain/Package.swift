// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Domain",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "Domain",
            targets: ["Domain"]),
        .library(
            name: "DomainTestingUtils",
            targets: ["DomainTestingUtils"]),
    ],
    targets: [
        .target(
            name: "Domain",
        ),
        .target(
            name: "DomainTestingUtils",
            dependencies: ["Domain"],
        ),
        .testTarget(
            name: "DomainTests",
            dependencies: [
                "Domain",
                "DomainTestingUtils"
            ]),
    ]
)
