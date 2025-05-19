const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // ------------- Zig wrapper dependency ----------------
    const zig_webview = b.dependency("webview", .{});
    // ------------------------------------------------------

    const exe = b.addExecutable(.{
        .name = "bind",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // 1. expose the Zig wrapper to main.zig
    exe.root_module.addImport("webview", zig_webview.module("webview"));

    // 2. compile the C++ implementation that lives in the wrapper repo
    exe.addIncludePath(zig_webview.path("core/include"));
    exe.addCSourceFile(.{
        .file = zig_webview.path("core/src/webview.cc"),
        .flags = &.{ "-std=c++17", "-DWEBVIEW_STATIC" },
    });
    exe.linkLibCpp();

    // 3. add **WebView2** SDK headers (downloaded in Step 1)
    exe.addIncludePath(b.path("thirdparty/Microsoft.Web.WebView2/include"));

    // 4. platform-specific system libs
    switch (exe.rootModuleTarget().os.tag) {
        .windows => {
            exe.linkSystemLibrary("ole32");
            exe.linkSystemLibrary("version");
            exe.linkSystemLibrary("shlwapi");
            // no import-lib needed when using WEBVIEW_STATIC
        },
        .macos => exe.linkFramework("WebKit"),
        .linux => {
            exe.linkSystemLibrary("gtk+-3.0");
            exe.linkSystemLibrary("webkit2gtk-4.1");
        },
        else => {},
    }

    // install + run steps (unchanged)
    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
