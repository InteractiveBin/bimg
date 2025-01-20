const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("bimg", .{
        .target = target,
        .optimize = optimize,
    });
    const lib = b.addStaticLibrary(.{
        .name = "bimg",
        .root_module = mod,
    });

    const t = target.result;
    const is_debug = mod.optimize == .Debug;

    mod.addCSourceFiles(.{
        .flags = &cpp_flags,
        .files = &cpp_src,
    });
    mod.link_libcpp = true;

    mod.addCMacro("__STDC_LIMIT_MACROS", "");
    mod.addCMacro("__STDC_FORMAT_MACROS", "");
    mod.addCMacro("__STDC_CONSTANT_MACROS", "");
    mod.addCMacro(if (is_debug) "_DEBUG" else "NDEBUG", "");
    mod.addCMacro("BX_CONFIG_DEBUG", if (is_debug) "1" else "0");

    mod.addIncludePath(b.path("include"));
    mod.addIncludePath(b.path("3rdparty/astc-encoder/include"));
    mod.addIncludePath(b.path("3rdparty"));
    mod.addIncludePath(b.path("3rdparty/tinyexr/deps/miniz"));
    switch (t.os.tag) {
        .windows => {
            mod.addCMacro("WIN32", "1");
            switch (t.abi) {
                .gnu => {
                    mod.addCMacro("MINGW_HAS_SECURE_API", "1");
                },
                else => {},
            }
        },
        else => {},
    }

    for (deps) |dep|
        mod.linkLibrary(b.dependency(dep, .{}).artifact(dep));

    lib.installHeadersDirectory(b.path("include"), ".", .{
        .include_extensions = &.{ ".h", ".inl" },
    });
    b.installArtifact(lib);
}

const common_flags = [_][]const u8{
    "-fno-sanitize=undefined",
};
const c_flags = common_flags;
const cpp_flags = [_][]const u8{
    "-std=c++17",
} ++ common_flags;

const cpp_src = [_][]const u8{
    "3rdparty/astc-encoder/source/astcenc_averages_and_directions.cpp",
    "3rdparty/astc-encoder/source/astcenc_block_sizes.cpp",
    "3rdparty/astc-encoder/source/astcenc_color_quantize.cpp",
    "3rdparty/astc-encoder/source/astcenc_color_unquantize.cpp",
    "3rdparty/astc-encoder/source/astcenc_compress_symbolic.cpp",
    "3rdparty/astc-encoder/source/astcenc_compute_variance.cpp",
    "3rdparty/astc-encoder/source/astcenc_decompress_symbolic.cpp",
    "3rdparty/astc-encoder/source/astcenc_diagnostic_trace.cpp",
    "3rdparty/astc-encoder/source/astcenc_entry.cpp",
    "3rdparty/astc-encoder/source/astcenc_find_best_partitioning.cpp",
    "3rdparty/astc-encoder/source/astcenc_ideal_endpoints_and_weights.cpp",
    "3rdparty/astc-encoder/source/astcenc_image.cpp",
    "3rdparty/astc-encoder/source/astcenc_integer_sequence.cpp",
    "3rdparty/astc-encoder/source/astcenc_mathlib.cpp",
    "3rdparty/astc-encoder/source/astcenc_mathlib_softfloat.cpp",
    "3rdparty/astc-encoder/source/astcenc_partition_tables.cpp",
    "3rdparty/astc-encoder/source/astcenc_percentile_tables.cpp",
    "3rdparty/astc-encoder/source/astcenc_pick_best_endpoint_format.cpp",
    "3rdparty/astc-encoder/source/astcenc_quantization.cpp",
    "3rdparty/astc-encoder/source/astcenc_symbolic_physical.cpp",
    "3rdparty/astc-encoder/source/astcenc_weight_align.cpp",
    "3rdparty/astc-encoder/source/astcenc_weight_quant_xfer_tables.cpp",
    "src/image.cpp",
    "src/image_gnf.cpp",
    "src/image_decode.cpp",
};
const c_src = [_][]const u8{
    "3rdparty/tinyexr/deps/miniz/miniz.c",
};

const deps = [_][]const u8{
    "bx",
};
