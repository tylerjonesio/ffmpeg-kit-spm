// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v5.1"

let frameworks = ["ffmpegkit": "4c62d6a9d0f1661ae73497e7618fcd19b42671adb92fc1629d817b087568ea9b", "libavcodec": "9ba28f61bd25dddec796ad184a75bba1dc3db4163d652d42ab5df905cc004b5e", "libavdevice": "459f5d123dcbe498c064e1de60edef31c562aee96b9d2e987b1d15c7a76d25e4", "libavfilter": "f6ff7414f3d0e765ec9b4e36f7cf9e2334cada33490d1dfea1844c1ea8642999", "libavformat": "e1e7ced2c19cddae55a5c723816162a329af47c17111c3ee92c2d40e287765cd", "libavutil": "9fbfc78b4b570b85c9c900fa72e7882f4e702e8b20bb59cb058f8b2ea29e388f", "libswresample": "1850f5b9e4296c831326cad6b03bc44ffd4212e1ca89b124aaaeefaca86e2977", "libswscale": "11b7e863e8967cf48a0e1766cedc2afe68e7899c17c02043743f376922dc512d"]

func xcframework(_ package: Dictionary<String, String>.Element) -> Target {
//    let url = "https://github.com/tylerjonesio/ffmpeg-kit-spm/releases/download/\(release)/\(package.key).xcframework.zip"
//    return .binaryTarget(name: package.key, url: url, checksum: package.value)
    return .binaryTarget(name: package.key, path: ".tmp/ffmpeg-kit/prebuilt/bundle-apple-xcframework/\(package.key).xcframework.zip")
}

let linkerSettings: [LinkerSetting] = [
    .linkedFramework("AudioToolbox"),
    .linkedFramework("AVFoundation", .when(platforms: [.macOS, .iOS, .macCatalyst])),
    .linkedFramework("CoreMedia", .when(platforms: [.macOS])),
    .linkedFramework("OpenGL", .when(platforms: [.macOS])),
    .linkedFramework("VideoToolbox"),
    .linkedLibrary("z"),
    .linkedLibrary("lzma"),
    .linkedLibrary("bz2"),
    .linkedLibrary("iconv")
]

let libAVFrameworks = frameworks.filter({ $0.key != "ffmpegkit" })

let package = Package(
    name: "ffmpeg-kit-spm",
    platforms: [.iOS(.v12), .macOS(.v10_15), .tvOS(.v11)],
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
