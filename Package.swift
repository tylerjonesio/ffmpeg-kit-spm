// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v5.1.2.4"

let frameworks = ["ffmpegkit": "40771eff65426e20cb6cf918f83598948066a5a6ee1e5b0a77bb93bef5ba2576", "libavcodec": "d84aba273bcf388c9574c7d1935dad307d68c8640505d16a25ee6a6a9f5a3795", "libavdevice": "9660be860445d78261e48551453f3d94d7f3e8711cefb69f5e4188f5df9a60b5", "libavfilter": "3cf94014d25336a27cb3c1440ce6e31469304def901d219a37f3a078b4eed9bc", "libavformat": "28e80de0b7572aedfcbd18630c2f53da35e106e04397c6aa590cb84143007661", "libavutil": "2b19dcfde0434ce83300806db2b10e5af84d0962b8a28e9486563f1ea33bd293", "libswresample": "0afc21c9f0335edd6cdd6c3695b33d88233765a26fc1b3764857aab7e36b02d7", "libswscale": "4e9d8da69765cac804fe1b1ace7c87ba2236c2fb7b5ca9e76437ba2e3e7f8dcc"]

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
