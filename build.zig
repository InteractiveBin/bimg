const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const bx_lib = b.lazyDependency("bx", .{ .target = target, .optimize = optimize }).?.artifact("bx");
    const bimg_lib = b.addStaticLibrary(.{
        .name = "bimg",
        .target = target,
        .optimize = optimize,
    });
    const bimg_mod = bimg_lib.root_module;
    bimg_mod.addCSourceFiles(.{ .files = &src_files });
    bimg_mod.link_libcpp = true;
    bimg_mod.addCMacro("BX_CONFIG_DEBUG", "0"); // Release
    bimg_mod.addIncludePath(b.path("include"));
    bimg_mod.addIncludePath(b.path("3rdparty"));
    bimg_mod.addIncludePath(b.path("3rdparty/astc-encoder/include"));
    bimg_mod.addIncludePath(b.path("3rdparty/iqa/include"));
    bimg_mod.addIncludePath(b.path("3rdparty/tinyexr/deps/miniz"));
    bimg_mod.linkLibrary(bx_lib);

    bimg_lib.installHeadersDirectory(b.path("include"), ".", .{
        .include_extensions = &.{ ".h", ".inl" },
    });
    b.installArtifact(bimg_lib);
}

const src_files = [_][]const u8{
    "src/image_decode.cpp",
    "src/image.cpp",
    "src/image_encode.cpp",
    "src/image_gnf.cpp",
    "src/image_cubemap_filter.cpp",
};
