// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v5.1.2.2"

let frameworks = ["ffmpegkit": "c712115350f8bf4a635aee3333b5fac082b0373444d85cbbb532780acff10b25", "libavcodec": "2a6905aa26bc5d189f628b0b04eba4651a63a86f2178e369b79c8e1098a0dbd4", "libavdevice": "986168304ceba89bfd579a1f1425ef1ecc2b10aa94aeb5d5af388e6cbdaad3e9", "libavfilter": "d22fdbf0d2f9f8067f98f559045affb99ecadab1ad25e1dd6c05f1dadeead485", "libavformat": "c765a96e572e0a2cd4ecf72b8ef3c20626052d4cc17ab446c6c5bfd7fc8b84b5", "libavutil": "37f2116842a8e4302ebc769dc301bcdf0a3dace5cb5ec3fab8875d085389ab9a", "libswresample": "cba6692e830ea5d814e09daca7efd3ccae53d7897975b2c1fd30d20041d10c3b", "libswscale": "01a0e7b667793b58e48cf50a0493e4fb1da7c767395f31106e32dd3b8a853907"]

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
