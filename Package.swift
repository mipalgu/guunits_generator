// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if os(macOS) || os(Linux)
let deps: [Package.Dependency] = [.package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")]
#else
let deps: [Package.Dependency] = []
#endif

let package = Package(
    name: "guunits_generator",
    products: [
        .executable(name: "guunits_generator", targets: ["guunits_generator"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ] + deps,
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "GUUnitsGeneratorConversions"),
        .target(
            name: "guunits_generator",
            dependencies: ["GUUnitsGeneratorConversions"]),
        .testTarget(
            name: "GUUnitsGeneratorConversionsTests",
            dependencies: ["GUUnitsGeneratorConversions"]
        ),
        .testTarget(
            name: "guunits_generatorTests",
            dependencies: ["guunits_generator", "GUUnitsGeneratorConversions"]),
    ]
)
