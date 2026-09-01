// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "sqflite_darwin", path: "../.packages/sqflite_darwin-2.4.3"),
        .package(name: "share_plus", path: "../.packages/share_plus-13.3.0"),
        .package(name: "file_picker_darwin", path: "../.packages/file_picker_darwin-1.0.2"),
        .package(name: "FlutterFramework", path: "../.packages/FlutterFramework")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "sqflite-darwin", package: "sqflite_darwin"),
                .product(name: "share-plus", package: "share_plus"),
                .product(name: "file-picker-darwin", package: "file_picker_darwin"),
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
