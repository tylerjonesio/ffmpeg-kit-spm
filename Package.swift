// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v5.1.2.5"

let frameworks = ["ffmpegkit": "e891de83cb6bc2b800bc5c3b540d67bd48897de5a7161b347b017fa586351e9e", "libavcodec": "fe34ad31192af03f68cfc86b6368e1fe77d09b77511b1d3e8c6b5da7427c42cf", "libavdevice": "d457381c288b58641aeb1b8104c231ebdbc837e4a8c960280a9e444e7aad05fc", "libavfilter": "6267955018ec0192295dc0fa7edef60eb7d1afec5a28fe969c690f11b79184aa", "libavformat": "375257b3d3904d9af34105b55199d0289ef16e73abe4b418ef270242b9f88e78", "libavutil": "5da8b504b0ba0a6b1391734f61a9fcef3f41e3dd8795f0e0a69a41bf163c6b99", "libswresample": "89733380d4fcda520a7584f22d6b189ff74acd066b70c3e301d94ea39ad3a5d2", "libswscale": "9c0eeeda3428ca3752d00c85f143a6fd4a1236793b4845fa69057944df7e75f1"]

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
