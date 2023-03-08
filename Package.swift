// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v5.1.2.3"

let frameworks = ["ffmpegkit": "b26745b97ca70ada27db04de085dceaddf03cc4d506df4d3f5e6c57cf6502681", "libavcodec": "0ddc241a8b997c07ea8dc25e4aa596584e4e278236d5e11e183ed6ce7f486647", "libavdevice": "54cb9f5bb0658e2ab31eaa43421c5e5c161d3349087987b408b5c805b98d6118", "libavfilter": "2664fde87e94bef034c2b092a6ce56ad6e712db9626743f2e40df8d1bd970cf2", "libavformat": "3d905603adaf8866a6d8df03914ef1c73ba3afb930221234894704e2f0ba7fe8", "libavutil": "283af892fb2d07125a719dc16dbf12c96ce8fcdf4de7ecd3e83ddbf2c3faefa5", "libswresample": "d1df6a014d96fab1b6ee766123a059baa8f0f79ea5765f4f1e7722bb612c586c", "libswscale": "af3e6a0f5da52267854c2509a7fbc145895119edae199e76843f04191e2e4be0"]

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
