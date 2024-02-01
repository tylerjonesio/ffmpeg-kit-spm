// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v5.1.2.6"

let frameworks = ["ffmpegkit": "eb3fa0a08fa7477ab38a8c43af7061e257f623ee58818f397f2db9aba31ef335", "libavcodec": "10ff17871015a75a83e1d9572d159b3752d47d78a94561ad14805a67b2660684", "libavdevice": "3dad9b09ba13553e1be34df5ce266a7b2b69c193e15eae3e6f5d5403c34f465a", "libavfilter": "17159b2cc5a91e7a47b9650f55f55eded9943745b880c90a2a7c4c6ac901abb4", "libavformat": "ebc5e8ae76a4f5a47a3141abbad562a64a76c4d47d9460ecbcfab84f20487179", "libavutil": "3b9f6a744ea0c2a5c3b571afac3956616efddfada67b77229830ce0c1c8336d7", "libswresample": "514647ce7c334dbae57c8fa0892130d4d19bf11b26acac85d750c5842a54e2c7", "libswscale": "6a93db66a432f1daf38080a5eaff0de93eecc11ffa0d709e07637dc8804fd1f0"]

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
