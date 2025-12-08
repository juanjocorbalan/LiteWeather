// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Data",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "Data",
            targets: ["Data"])
    ],
    dependencies: [
        .package(name: "Domain", path: "../Domain")
    ],
    targets: [
        .target(
            name: "Data",
            dependencies: [
                .product(name: "Domain", package: "Domain")
            ]
        ),
        .testTarget(
            name: "DataTests",
            dependencies: [
                "Data"
            ]
        ),
    ]
)
