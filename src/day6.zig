const std = @import("std");

pub fn main() !void {
    var stdin = std.fs.File.stdin();
    var readBuf: [1 << 10]u8 = undefined;
    var reader = stdin.reader(&readBuf);

    const first = try reader.interface.takeDelimiter('\n');
    const startPos = std.mem.indexOfScalar(u8, first.?, 'S').?;
    var last: u160 = @as(u160, 1) << @intCast(startPos);

    var timelines = std.mem.zeroes([160]u64);
    timelines[startPos] = 1;

    var splits: usize = 0;
    while (try reader.interface.takeDelimiter('\n')) |slice| {
        std.debug.assert(slice.len <= 160);

        var current: u160 = 0;

        for (slice, 0..) |c, i| {
            switch (c) {
                '^' => current |= @as(u160, 1) << @intCast(i),
                else => {},
            }
        }

        if (current == 0) {
            continue;
        }

        var newTimelines = std.mem.zeroes([160]u64);
        for (slice, 0..) |c, i| {
            if (c == '^') {
                newTimelines[i - 1] += timelines[i];
                newTimelines[i + 1] += timelines[i];
            } else if (timelines[i] > 0) {
                newTimelines[i] += timelines[i];
            }
        }

        @memcpy(&timelines, &newTimelines);

        const hits = current & last;
        splits += @popCount(hits);
        last = (last & ~hits) | (hits << 1 | hits >> 1);
    }

    var timelinesTotal: u64 = 0;
    for (timelines) |count| {
        timelinesTotal += count;
    }

    std.debug.print("{d}\n", .{splits});
    std.debug.print("{d}\n", .{timelinesTotal});
}
