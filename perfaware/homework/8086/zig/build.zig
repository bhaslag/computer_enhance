const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "dissasemble",
        .root_source_file = b.path("src/dissasemble.zig"),
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
    });

    b.installArtifact(exe);

    // Get assembly output of build
    exe.emit_asm = .emit;
}
