// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v5.1.2.5"

let frameworks = ["ffmpegkit": "2c2c4d6ad5afff71daa110064ef8942cdbaeb7a201309d25cd4bcee04218dd8e", "libavcodec": "04d08ae5b2ee63dbfa0bb8ddcf3684eb582739cebf5a0cb0c5b1201c187333ac", "libavdevice": "11dfd0a6b98236b560e7e5e10b98bda8e11738968a79d0ce866e1a71dfd38abe", "libavfilter": "b12a2f8e974797d08d1d269be02c5a71a39a028a51541fc01a2773208d5b7bcf", "libavformat": "046248096e9eccc8e8dab2dd6c819490bd78e5bf5ea2606f4577fe899aa31165", "libavutil": "f68d068159a07c8916e78f7bc05984a33b92b4601091fca1fbd45b52239e1f89", "libswresample": "568664f7a251e4db54d78306b4988823bec0222aa14749aa84c1beb3c52787b7", "libswscale": "b874ef24023388e4401d5cd8fb359c79b3ab47bb3c95f90552984c3845e051a8"]

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
