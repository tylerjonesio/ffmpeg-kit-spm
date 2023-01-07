// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v5.1"

let frameworks = ["ffmpegkit": "99d8f15a4932c21893974a03bbf0448d375ffe80573dac7298d2344abd06002a", "libavcodec": "65efa7e6a7100454de91e7fee38c2f1d5b6b7c727b0ab90e02aae3a8aebea931", "libavdevice": "c72f9159be50f35c069d816b7813ca0c56b25e18e0dcf15655c498208c21b32d", "libavfilter": "e0928ee131c0ae6da001be3ae074d9b39531fa3cb1ae50339770137720823d2d", "libavformat": "610e8a97c1e2e14651544f4b4eef8466131912ed8981ac00d4771b5d1e4ee313", "libavutil": "469ff3d407e1614bc800a4ab839c40fb8dc4133208868298fb819dbdca396d76", "libswresample": "3310bcf219cdeda47e722355961b711daabecdb639672661e9cad6b7969fd934", "libswscale": "3d05c0f6d81fd03237563f56c35db3fb4ff4aea0f3bca05eea4f01e686f61228"]

func xcframework(_ package: Dictionary<String, String>.Element) -> Target {
    let url = "https://github.com/tylerjonesio/ffmpeg-kit-spm/releases/download/\(release)/\(package.key).xcframework.zip"
    return .binaryTarget(name: package.key, url: url, checksum: package.value)
}

let package = Package(
    name: "ffmpeg-kit-spm",
    platforms: [.iOS(.v12), .macOS(.v10_15), .tvOS(.v11)],
    products: [
        .library(
            name: "ffmpegkit",
            type: .dynamic,
            targets: ["ffmpeg", "ffmpegkit"]),
        .library(
            name: "ffmpeg",
            type: .dynamic,
            targets: ["ffmpeg"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ffmpeg",
            dependencies: frameworks.map { .byName(name: $0.key) },
            linkerSettings: [
                .linkedFramework("AudioToolbox"),
                .linkedFramework("AVFoundation", .when(platforms: [.macOS, .iOS, .macCatalyst])),
                .linkedFramework("CoreMedia", .when(platforms: [.macOS])),
                .linkedFramework("OpenGL", .when(platforms: [.macOS])),
                .linkedFramework("VideoToolbox"),
                .linkedLibrary("z"),
                .linkedLibrary("bz2"),
                .linkedLibrary("iconv")
            ]),
    ] + frameworks.map { xcframework($0) }
)
