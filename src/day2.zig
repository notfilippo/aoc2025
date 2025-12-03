const std = @import("std");

pub fn maxima(slice: []u8) usize {
    var max: u8 = slice[0] - '0';
    var idx: usize = 0;

    for (slice, 0..) |c, i| {
        const value = c - '0';
        if (value > max) {
            max = value;
            idx = i;
        }
    }

    return idx;
}

pub fn calc(slice: []u8, depth: u64) u64 {
    var start: usize = 0;
    var value: u64 = 0;

    for (0..depth) |i| {
        const end = slice.len - depth + i + 1;
        const search = slice[start..end];
        start = start + maxima(search);
        value += @as(u64, slice[start] - '0') * std.math.pow(u64, 10, depth - 1 - i);
        start += 1;
    }

    return value;
}

pub fn main() !void {
    var stdin = std.fs.File.stdin();
    var readBuf: [1 << 10]u8 = undefined;
    var reader = stdin.reader(&readBuf);

    var jolts2: u64 = 0;
    var jolts12: u64 = 0;

    while (try reader.interface.takeDelimiter('\n')) |slice| {
        jolts2 += calc(slice, 2);
        jolts12 += calc(slice, 12);
    }

    std.debug.print("{d}\n", .{jolts2});
    std.debug.print("{d}\n", .{jolts12});
}
