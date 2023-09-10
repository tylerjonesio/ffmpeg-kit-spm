// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v5.1.2.5"

let frameworks = ["ffmpegkit": "e1427a9d5af2ceacd138b4f373ab6b9add33f35eef767728d375215af317ee88", "libavcodec": "f0badf0353496f64b5df1e6ed902014d290f80c3adfa76378683b760fe2bbd4b", "libavdevice": "9b5c5bdfb9b4d41f1be3c2786fb1525e6727e1a2c7556a0ca266daf848fefc4b", "libavfilter": "7574eaa06d04310c5f529c6d9b64164ed8a762c5a1a718aac760082367443db1", "libavformat": "b72f17ff286dd33defa03add9d5602cbc0e96950b39b20b6011000cb92b770e4", "libavutil": "23c4496d4b85d2bb4ba941b0d4c235d5469155d7cb76749613e94a126145de7d", "libswresample": "e54e7c5679106d337c6d4144359185e7ee094cc390be30de2be09f9c9833b4c0", "libswscale": "e265ef3f5607cd670f35222ae86dbae2f8ef2a3ab21fd23708eccf96ce7bbcf7"]

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
