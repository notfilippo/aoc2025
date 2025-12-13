const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const DAYS = 8;

    inline for (0..DAYS) |day| {
        const name = std.fmt.comptimePrint("day{d}", .{day});
        const file = std.fmt.comptimePrint("src/{s}.zig", .{name});

        const exe = b.addExecutable(.{
            .name = name,
            .root_module = b.createModule(.{
                .root_source_file = b.path(file),
                .target = target,
                .optimize = optimize,
            }),
        });

        b.installArtifact(exe);

        const run_step = b.step(name, name);

        const run_cmd = b.addRunArtifact(exe);
        run_step.dependOn(&run_cmd.step);

        run_cmd.step.dependOn(b.getInstallStep());

        if (b.args) |args| {
            run_cmd.addArgs(args);
        }
    }
}
