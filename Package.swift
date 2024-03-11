// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DiiaAuthorization",
    defaultLocalization: "uk",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DiiaAuthorization",
            targets: ["DiiaAuthorization"]),
        .library(
            name: "DiiaAuthorizationMethods",
            targets: ["DiiaAuthorizationMethods"]),
        .library(
            name: "DiiaAuthorizationPinCode",
            targets: ["DiiaAuthorizationPinCode"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/DeclarativeHub/ReactiveKit.git", from: "3.16.2"),
        .package(url: "https://github.com/diia-open-source/ios-mvpmodule.git", .upToNextMinor(from: Version(1, 0, 0))),
        .package(url: "https://github.com/diia-open-source/ios-network.git", .upToNextMinor(from: Version(1, 0, 0))),
        .package(url: "https://github.com/diia-open-source/ios-commontypes.git", .upToNextMinor(from: Version(1, 0, 0))),
        .package(url: "https://github.com/diia-open-source/ios-commonservices.git", .upToNextMinor(from: Version(1, 0, 0))),
        .package(url: "https://github.com/diia-open-source/ios-uicomponents.git", .upToNextMinor(from: Version(1, 0, 0))),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DiiaAuthorization",
            dependencies: [
                .product(name: "DiiaMVPModule", package: "ios-mvpmodule"),
                .product(name: "DiiaNetwork", package: "ios-network"),
                .product(name: "DiiaCommonTypes", package: "ios-commontypes"),
                .product(name: "DiiaUIComponents", package: "ios-uicomponents"),
                .product(name: "DiiaCommonServices", package: "ios-commonservices"),
                "ReactiveKit",
        	],
        	path: "Sources/Authorization"
        ),
        .target(
            name: "DiiaAuthorizationMethods",
            dependencies: [
                .product(name: "DiiaMVPModule", package: "ios-mvpmodule"),
                .product(name: "DiiaNetwork", package: "ios-network"),
                .product(name: "DiiaUIComponents", package: "ios-uicomponents"),
                .product(name: "DiiaCommonTypes", package: "ios-commontypes"),
                .product(name: "DiiaCommonServices", package: "ios-commonservices"),
                "DiiaAuthorization",
            ],
            path: "Sources/AuthorizationMethods"
        ),
        .target(
            name: "DiiaAuthorizationPinCode",
            dependencies: [
                .product(name: "DiiaMVPModule", package: "ios-mvpmodule"),
                .product(name: "DiiaNetwork", package: "ios-network"),
                .product(name: "DiiaUIComponents", package: "ios-uicomponents"),
                .product(name: "DiiaCommonTypes", package: "ios-commontypes"),
                "DiiaAuthorization",
            ],
            path: "Sources/PinCode"
        ),
        .testTarget(
            name: "AuthorizationTests",
            dependencies: ["DiiaAuthorization"]),
        .testTarget(
            name: "AuthorizationMethodsTests",
            dependencies: ["DiiaAuthorizationMethods","DiiaAuthorization"]),
        .testTarget(
            name: "PinCodeTests",
            dependencies: ["DiiaAuthorizationPinCode"]),
    ]
)
