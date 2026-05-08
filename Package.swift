// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SwiftUIPermissionKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "SwiftUIPermissionKit",
            targets: ["SwiftUIPermissionKit"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftUIPermissionKit"
        ),
        .testTarget(
            name: "SwiftUIPermissionKitTests",
            dependencies: ["SwiftUIPermissionKit"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
