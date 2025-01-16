const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const bx_lib = b.dependency("bx", .{ .target = target, .optimize = optimize }).artifact("bx");
    const bimg_lib = b.addStaticLibrary(.{
        .name = "bimg",
        .target = target,
        .optimize = optimize,
    });
    bimg_lib.defineCMacro("BX_CONFIG_DEBUG", "0"); // Release
    bimg_lib.addCSourceFiles(.{ .files = &src_files });
    bimg_lib.linkLibCpp();
    bimg_lib.addIncludePath(b.path("include"));
    bimg_lib.addIncludePath(b.path("3rdparty"));
    bimg_lib.addIncludePath(b.path("3rdparty/astc-encoder/include"));
    bimg_lib.addIncludePath(b.path("3rdparty/iqa/include"));
    bimg_lib.addIncludePath(b.path("3rdparty/tinyexr/deps/miniz"));
    bimg_lib.installHeadersDirectory(b.path("include"), ".", .{
        .include_extensions = &.{ ".h", ".inl" },
    });
    bimg_lib.linkLibrary(bx_lib);

    b.installArtifact(bimg_lib);
}

const src_files = [_][]const u8{
    "src/image_decode.cpp",
    "src/image.cpp",
    "src/image_encode.cpp",
    "src/image_gnf.cpp",
    "src/image_cubemap_filter.cpp",
};
