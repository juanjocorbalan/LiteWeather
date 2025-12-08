// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Data",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "Data",
            targets: ["Data"]),
        .library(
            name: "DataTestingUtils",
            targets: ["DataTestingUtils"]),
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
        .target(
            name: "DataTestingUtils",
            dependencies: [
                .product(name: "Domain", package: "Domain")
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "DataTests",
            dependencies: [
                "Data",
                "DataTestingUtils",
                .product(name: "DomainTestingUtils", package: "Domain")
            ]
        ),
    ]
)
