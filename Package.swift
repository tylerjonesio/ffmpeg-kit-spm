// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v5.1.1"

let frameworks = ["ffmpegkit": "69e1ebce712698722bd72e38f5cd6b97209b767c045958484af10c0d5f769532", "libavcodec": "2c3d3133fc57487382cc486bfd14f0552b2261447efcfe68ea648d80ecdd877c", "libavdevice": "f9a1d46029f4ff603325119686b445cea581b3e678682ac284d036967b9e6e24", "libavfilter": "985209d3ca5dec0dfb82d47d1b2cf49c35c17f6fe0def7ccda50b69d19b13dfc", "libavformat": "aaf8ad482f1887a5f08fe6fd8f24b2b02801571b0e96fbb7a7f18546f2d69880", "libavutil": "c1f04b391a874674a380e99464f11631ea62dd51fa9dcc0789c4cc3d56ab5198", "libswresample": "35ccf3b51dd35ddc70ae0a49049f192ecf273cc14c05ae849a3a07dffffec865", "libswscale": "b1af830516c5f99bad5f352ade94cbff748ff2515e4887495109dc6c044c4fdb"]

func xcframework(_ package: Dictionary<String, String>.Element) -> Target {
//    let url = "https://github.com/tylerjonesio/ffmpeg-kit-spm/releases/download/\(release)/\(package.key).xcframework.zip"
//    return .binaryTarget(name: package.key, url: url, checksum: package.value)
    return .binaryTarget(name: package.key, path: ".tmp/ffmpeg-kit/prebuilt/bundle-apple-xcframework/\(package.key).xcframework")
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
    ],
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
