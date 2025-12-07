const std = @import("std");

const Range = struct {
    start: usize,
    end: usize,
};

const Op = enum { add, mul };

fn calc(numbers: []u64, op: Op) u64 {
    var result: u64 = switch (op) {
        .add => 0,
        .mul => 1,
    };

    for (numbers) |num| {
        switch (op) {
            .add => result += num,
            .mul => result *= num,
        }
    }

    return result;
}

pub fn main() !void {
    var stdin = std.fs.File.stdin();
    var readBuf: [1 << 15]u8 = undefined;
    var reader = stdin.reader(&readBuf);

    const allocator = std.heap.page_allocator;

    var lines = try std.ArrayList([]u8).initCapacity(allocator, 10);
    defer lines.deinit(allocator);

    while (try reader.interface.takeDelimiter('\n')) |slice| {
        const line = try allocator.dupe(u8, slice);
        try lines.append(allocator, line);
    }

    std.debug.assert(lines.items.len > 0);
    const width = lines.items[0].len;

    var ranges = try std.ArrayList(Range).initCapacity(allocator, 10);
    defer ranges.deinit(allocator);

    var inside = false;
    var start: usize = 0;

    for (0..width) |col| {
        var hasOneDigit = false;
        for (lines.items[0 .. lines.items.len - 1]) |line| {
            if (col < line.len and line[col] != ' ') {
                hasOneDigit = true;
                break;
            }
        }

        if (hasOneDigit and !inside) {
            start = col;
            inside = true;
        } else if (!hasOneDigit and inside) {
            try ranges.append(allocator, .{ .start = start, .end = col });
            inside = false;
        }
    }

    if (inside) {
        try ranges.append(allocator, .{ .start = start, .end = width });
    }

    var grandTotal1: u64 = 0;
    var grandTotal2: u64 = 0;

    var numbers1 = try std.ArrayList(u64).initCapacity(allocator, lines.items.len - 1);
    defer numbers1.deinit(allocator);

    var numbers2 = try std.ArrayList(u64).initCapacity(allocator, lines.items.len - 1);
    defer numbers2.deinit(allocator);

    for (ranges.items) |range| {
        numbers1.clearRetainingCapacity();
        numbers2.clearRetainingCapacity();

        var op: Op = .add;
        const opRow = lines.items[lines.items.len - 1];
        const opValue = std.mem.trim(u8, opRow[range.start..range.end], " ");
        op = switch (opValue[0]) {
            '*' => .mul,
            '+' => .add,
            else => unreachable,
        };

        for (lines.items[0 .. lines.items.len - 1]) |line| {
            const value = std.mem.trim(u8, line[range.start..range.end], " ");
            const num = try std.fmt.parseInt(u64, value, 10);
            try numbers1.append(allocator, num);
        }

        var c: usize = @min(range.end, width);
        while (c > range.start) {
            c -= 1;

            var numBuf: [20]u8 = undefined;
            var numLen: usize = 0;

            for (lines.items[0 .. lines.items.len - 1]) |line| {
                if (c < line.len and line[c] != ' ') {
                    numBuf[numLen] = line[c];
                    numLen += 1;
                }
            }

            if (numLen > 0) {
                const num = try std.fmt.parseInt(u64, numBuf[0..numLen], 10);
                try numbers2.append(allocator, num);
            }
        }

        grandTotal1 += calc(numbers1.items, op);
        grandTotal2 += calc(numbers2.items, op);
    }

    std.debug.print("{d}\n", .{grandTotal1});
    std.debug.print("{d}\n", .{grandTotal2});
}
