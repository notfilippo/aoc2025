const std = @import("std");

fn keep4(input: []u64, output: []u64, size: usize) u64 {
    const kernel_size = 3;
    const pad: isize = @intCast(@divTrunc(kernel_size, 2));

    var sum: u64 = 0;
    for (0..size) |row| {
        for (0..size) |col| {
            var value: u64 = 0;

            inline for (0..kernel_size) |krow| {
                inline for (0..kernel_size) |kcol| {
                    const srow: isize = @as(isize, @intCast(row)) + @as(isize, @intCast(krow)) - pad;
                    const scol: isize = @as(isize, @intCast(col)) + @as(isize, @intCast(kcol)) - pad;

                    if (srow >= 0 and srow < size and scol >= 0 and scol < size) {
                        value += input[@as(usize, @intCast(srow)) * size + @as(usize, @intCast(scol))];
                    }
                }
            }

            output[row * size + col] *= if (value > 4) 1 else 0;
            sum += output[row * size + col];
        }
    }

    return sum;
}

pub fn main() !void {
    var stdin = std.fs.File.stdin();
    var readBuf: [1 << 10]u8 = undefined;
    var reader = stdin.reader(&readBuf);

    const allocator = std.heap.page_allocator;

    var input = try std.ArrayList(u64).initCapacity(allocator, 100);
    defer input.deinit(allocator);

    while (try reader.interface.takeDelimiter('\n')) |slice| {
        for (slice) |c| {
            try input.append(allocator, if (c == '@') 1 else 0);
        }
    }

    var start: u64 = 0;
    for (input.items) |value| {
        start += value;
    }

    const size = std.math.sqrt(input.items.len);

    var output = try input.clone(allocator);
    defer output.deinit(allocator);

    const first = keep4(input.items, output.items, size);

    var current: u64 = first;
    var last: u64 = 0;

    while (current != last) {
        @memcpy(input.items, output.items);
        last = current;
        current = keep4(input.items, output.items, size);
    }

    std.debug.print("{d}\n", .{start - first});
    std.debug.print("{d}\n", .{start - last});
}
