// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v5.1.2.1"

let frameworks = ["ffmpegkit": "ef61a9f2ad0856296ebc4e83d8ca303e61675df6fefcad0f192fab496d6dadef", "libavcodec": "3b45430906015c27bc81b6cfcd5d6e299348367bc460689c48f3d6a2524289d8", "libavdevice": "856f1e81c8d19eeb21f6c9125eab5a7b7505bb4921b5738f73aa76bb2298322d", "libavfilter": "c7a4e96a988efdba25c1665b192894f599c6100f14da411c769ac3db8a4596e3", "libavformat": "0c0fc6ecd9922e7fce1171589c85ff9e2866f5705b95a83da86ec9cb6312ba0d", "libavutil": "dccb0c70d0c6d439d2651ceafcf95056a9f6a2015a8303afb1f8b165a7ac588c", "libswresample": "5afb02aa64db8618c669ed80c102c06c36bdded6ee4251be2a0f5031b2002540", "libswscale": "02038df4b6e5d63488bb5d8ce177651eebefde89689475f5f974328bbe92441e"]

func xcframework(_ package: Dictionary<String, String>.Element) -> Target {
    let url = "https://github.com/tylerjonesio/ffmpeg-kit-spm/releases/download/\(release)/\(package.key).xcframework.zip"
    return .binaryTarget(name: package.key, url: url, checksum: package.value)
}

let linkerSettings: [LinkerSetting] = [
    .linkedFramework("AudioToolbox", .when(platforms: [.macOS, .iOS, .macCatalyst, .tvOS])),
    .linkedFramework("AVFoundation", .when(platforms: [.macOS, .iOS, .macCatalyst])),
    .linkedFramework("CoreMedia", .when(platforms: [.macOS])),
    .linkedFramework("OpenGL", .when(platforms: [.macOS])),
    .linkedFramework("VideoToolbox", .when(platforms: [.macOS, .iOS, .macCatalyst, .tvOS])),
    .linkedLibrary("z"),
    .linkedLibrary("lzma"),
    .linkedLibrary("bz2"),
    .linkedLibrary("iconv")
]

let libAVFrameworks = frameworks.filter({ $0.key != "ffmpegkit" })

let package = Package(
    name: "ffmpeg-kit-spm",
    platforms: [.iOS(.v12), .macOS(.v10_15), .tvOS(.v11), .watchOS(.v9)],
    products: [
        .library(
            name: "FFmpeg-Kit",
            type: .dynamic,
            targets: ["FFmpeg-Kit", "ffmpegkit"]),
        .library(
            name: "FFmpeg",
            type: .dynamic,
            targets: ["FFmpeg"] + libAVFrameworks.map { $0.key }),
    ] + libAVFrameworks.map { .library(name: $0.key, targets: [$0.key]) },
    dependencies: [],
    targets: [
        .target(
            name: "FFmpeg-Kit",
            dependencies: frameworks.map { .byName(name: $0.key) },
            linkerSettings: linkerSettings),
        .target(
            name: "FFmpeg",
            dependencies: libAVFrameworks.map { .byName(name: $0.key) },
            linkerSettings: linkerSettings),
    ] + frameworks.map { xcframework($0) }
)
