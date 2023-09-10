// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v5.1.2.5"

let frameworks = ["ffmpegkit": "ee1abb931da3d16e09c17416495c0b66a7b4ce379773fb991f77976f2ba42bd6", "libavcodec": "3bcff5b091955e6ddc00238d18995f6cdfd917ca634100fcc8867fb712804630", "libavdevice": "3a03dad2dc5c7053d683beeeafd2102a32fab92c4478d6f1f51f4cb2153087a2", "libavfilter": "8a9e08f09c7418b0375e466de423e06ee9ada79acd53623926536a57c1ea7d7a", "libavformat": "4529e9bfa50c060ea036e8365a076f8d9f76ca49491295d0238d1154a8d4b48d", "libavutil": "f7966f28bf37102bbf3afbc2486257bde3dc5461ce76be41cf632ce4e326a0dd", "libswresample": "387e22ee69d7a6a371a2c4d66cc569f018dcd5820f8e34f5c9485bace57958ef", "libswscale": "b56f5766b562e570f901cf0414fd4183487f723ff26627c366e165137a2e3cba"]

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
    platforms: [.iOS(.v12), .macOS(.v10_15), .tvOS(.v11), .watchOS(.v7)],
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
