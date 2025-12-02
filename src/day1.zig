const std = @import("std");

pub fn main() !void {
    var stdin = std.fs.File.stdin();
    var readBuf: [1 << 10]u8 = undefined;
    var reader = stdin.reader(&readBuf);

    const allocator = std.heap.page_allocator;

    var printBuf: [20]u8 = undefined;

    var invalid2Symmetry: u64 = 0;
    var invalid: u64 = 0;

    while (try reader.interface.takeDelimiter(',')) |slice| {
        var it = std.mem.splitScalar(u8, slice, '-');
        const start = it.next().?;
        const end = it.next().?;

        const startValue = try std.fmt.parseInt(u64, start, 10);
        const endValue = try std.fmt.parseInt(u64, end, 10);

        const maxSymmetry = end.len;

        var seen = std.AutoHashMap(u64, void).init(allocator);

        for (2..maxSymmetry + 1) |symmetry| {
            const slen = if (start.len % symmetry == 0) start.len / symmetry else start.len / symmetry + 1;
            const elen = if (end.len % symmetry == 0) end.len / symmetry else end.len / symmetry + 1;

            for (slen..elen + 1) |len| {
                const min = std.math.pow(usize, 10, len - 1);
                const max = std.math.pow(usize, 10, len);

                for (min..max) |i| {
                    var index: usize = 0;

                    for (0..symmetry) |_| {
                        const written = try std.fmt.bufPrint(printBuf[index..], "{d}", .{i});
                        index += written.len;
                    }

                    const value = try std.fmt.parseInt(u64, printBuf[0..index], 10);

                    if (startValue <= value and value <= endValue) {
                        if (symmetry == 2) {
                            invalid2Symmetry += value;
                        }

                        if (!seen.contains(value)) {
                            invalid += value;
                            try seen.put(value, {});
                        }
                    }
                }
            }
        }

        seen.deinit();
    }

    std.debug.print("{d}\n", .{invalid2Symmetry});
    std.debug.print("{d}\n", .{invalid});
}
