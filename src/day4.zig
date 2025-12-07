const std = @import("std");

const Range = struct {
    start: u64,
    end: u64,
    fn isLessThan(_: void, lhs: Range, rhs: Range) bool {
        return lhs.start < rhs.start;
    }
    fn compare(value: u64, range: Range) std.math.Order {
        if (value < range.start) {
            return .lt;
        } else if (value > range.end) {
            return .gt;
        } else {
            return .eq;
        }
    }
};

pub fn main() !void {
    var stdin = std.fs.File.stdin();
    var readBuf: [1 << 10]u8 = undefined;
    var reader = stdin.reader(&readBuf);

    const allocator = std.heap.page_allocator;

    var ranges = try std.ArrayList(Range).initCapacity(allocator, 100);
    defer ranges.deinit(allocator);

    while (try reader.interface.takeDelimiter('\n')) |slice| {
        if (slice.len == 0) break;
        var iter = std.mem.splitScalar(u8, slice, '-');
        const start = try std.fmt.parseInt(u64, iter.next().?, 10);
        const end = try std.fmt.parseInt(u64, iter.next().?, 10);
        try ranges.append(allocator, .{ .start = start, .end = end });
    }

    std.sort.pdq(Range, ranges.items, {}, Range.isLessThan);

    var compactedRanges = try std.ArrayList(Range).initCapacity(allocator, ranges.items.len);

    var current: usize = 0;
    while (current < ranges.items.len) {
        var currentRange = ranges.items[current];

        var next: usize = current + 1;
        while (next < ranges.items.len) : (next += 1) {
            const nextRange = ranges.items[next];

            if (currentRange.end >= nextRange.start) {
                currentRange.end = @max(nextRange.end, currentRange.end);
            } else {
                break;
            }
        }

        try compactedRanges.append(allocator, currentRange);
        current = next;
    }

    var fresh: u64 = 0;
    while (try reader.interface.takeDelimiter('\n')) |slice| {
        if (slice.len == 0) break;
        const value = try std.fmt.parseInt(u64, slice, 10);

        const index = std.sort.binarySearch(Range, compactedRanges.items, value, Range.compare);
        fresh += if (index != null) 1 else 0;
    }

    var ingredients: u64 = 0;
    for (compactedRanges.items) |range| {
        ingredients += range.end - range.start + 1;
    }

    std.debug.print("{d}\n", .{fresh});
    std.debug.print("{d}\n", .{ingredients});
}
