// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ETDataDrivenViewKit",
    platforms: [.iOS(.v9), .watchOS(.v2), .tvOS(.v9)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "ETDataDrivenViewKit",
            targets: ["ETDataDrivenViewKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxDataSources", from: "5.0.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ETDataDrivenViewKit",
            dependencies: ["Differentiator"],
            path: "Sources"
        ),
        .testTarget(
            name: "ETDataDrivenViewKitTests",
            dependencies: ["ETDataDrivenViewKit"]),
    ]
)
