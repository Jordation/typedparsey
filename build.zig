const std = @import("std");

// Declaratively constructs a build graph for external execution
pub fn build(b: *std.Build) void {
    // Allow user to choose build target via `zig build`
    const target = b.standardTargetOptions(.{});

    // Allow user to select optimization level
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "parsey",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Install library to standard location
    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "parsey",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Install executable to standard location
    b.installArtifact(exe);

    // add some args to the exe check

    const exe_check = b.addExecutable(.{
        .name = "parsey",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const check = b.step("check", "Check if the program compiles");
    check.dependOn(&exe_check.step);

    // Create and configure run step
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    // Support command-line arguments: `zig build run -- arg1 arg2`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // Add run step to `zig build --help` menu
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Setup unit tests
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    // Add test step to `zig build --help` menu
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}
