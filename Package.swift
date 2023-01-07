// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v5.1"

let frameworks = ["ffmpegkit": "e84db2001b1dce7366390a34384686f07a5c4d40023c15e63db6270c323c0afa", "libavcodec": "ebd0785e30472772cf0ed47d4ae78175b6a420994c93170e8622ccb4d0bce06d", "libavdevice": "a3aa4cbc1af9dcd13dabff502b972854256cb91a1dc4f444dc6d58abaca05b2a", "libavfilter": "026821377400236df4780301952fa397a25d4c13bfbabec1d8b6b552573e05f1", "libavformat": "e2e4ce59402b7b9519c8225fa6a79351ce7760ecc5adf4b87db92314f83fdb6e", "libavutil": "97c18e6e2cc8419249d9cebc28152d66ca59993de3ed4c1612f0233ee13d17a7", "libswresample": "3c2f30d55299faaccbc0daac7f065d458d45de819c94352b5ce873c9a6d7ca27", "libswscale": "784992e1bcd81343ee34e357e055db144168f33bf43e35419bf7ed8072ac3e04"]

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
