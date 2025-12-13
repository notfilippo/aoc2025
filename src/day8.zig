const std = @import("std");

const Vec2 = [2]i64;

const Area = struct {
    a: Vec2,
    b: Vec2,
    area: u64,
    fn lessThan(_: void, left: @This(), right: @This()) bool {
        return left.area > right.area;
    }
    fn valid(self: @This(), ranges: std.AutoHashMap(i64, Vec2)) bool {
        const minX = @min(self.a[0], self.b[0]);
        const maxX = @max(self.a[0], self.b[0]);

        const minY = @min(self.a[1], self.b[1]);
        const maxY = @max(self.a[1], self.b[1]);

        var y = minY;
        while (y <= maxY) : (y += 1) {
            const range = ranges.get(y) orelse return false;
            if (minX < range[0] or maxX > range[1]) return false;
        }

        return true;
    }
};

fn scan(y: i64, poly: []Vec2) ?Vec2 {
    var min_x: ?i64 = null;
    var max_x: ?i64 = null;

    for (poly, 0..) |v1, i| {
        const v2 = poly[(i + 1) % poly.len];

        if (v1[1] == y and v2[1] == y) {
            const local_min_x = @min(v1[0], v2[0]);
            const local_max_x = @max(v1[0], v2[0]);
            min_x = if (min_x) |x| @min(x, local_min_x) else local_min_x;
            max_x = if (max_x) |x| @max(x, local_max_x) else local_max_x;
        }

        const local_min_y = @min(v1[1], v2[1]);
        const local_max_y = @max(v1[1], v2[1]);

        if (local_min_y <= y and y <= local_max_y) {
            const local_x = v1[0]; // same as v2[0]
            min_x = if (min_x) |x| @min(x, local_x) else local_x;
            max_x = if (max_x) |x| @max(x, local_x) else local_x;
        }
    }

    if (min_x != null and max_x != null) return .{ min_x.?, max_x.? };
    return null;
}

pub fn main() !void {
    var stdin = std.fs.File.stdin();
    var readBuf: [1 << 10]u8 = undefined;
    var reader = stdin.reader(&readBuf);

    const allocator = std.heap.page_allocator;

    var points = try std.ArrayList(Vec2).initCapacity(allocator, 500);
    defer points.deinit(allocator);

    var minY, var maxY = [_]i64{ std.math.maxInt(i64), std.math.minInt(i64) };

    while (try reader.interface.takeDelimiter('\n')) |slice| {
        var iter = std.mem.splitScalar(u8, slice, ',');
        const x = try std.fmt.parseInt(i64, iter.next().?, 10);
        const y = try std.fmt.parseInt(i64, iter.next().?, 10);
        try points.append(allocator, .{ x, y });

        minY = @min(minY, y);
        maxY = @max(maxY, y);
    }

    const combinations = (points.items.len * (points.items.len - 1)) / 2;

    var areas = try std.ArrayList(Area).initCapacity(allocator, combinations);
    defer areas.deinit(allocator);

    for (points.items, 0..) |a, i| {
        for (points.items[i + 1 ..]) |b| {
            const area = (@abs(a[0] - b[0]) + 1) * (@abs(a[1] - b[1]) + 1);
            try areas.append(allocator, .{ .a = a, .b = b, .area = area });
        }
    }

    std.sort.pdq(Area, areas.items, {}, Area.lessThan);

    std.debug.print("{d}\n", .{areas.items[0].area});

    var ranges = std.AutoHashMap(i64, Vec2).init(allocator);
    defer ranges.deinit();

    var y = minY;
    while (y <= maxY) : (y += 1) {
        if (scan(y, points.items)) |range| {
            try ranges.put(y, range);
        }
    }

    for (areas.items) |area| {
        if (area.valid(ranges)) {
            std.debug.print("{d}\n", .{area.area});
            break;
        }
    }
}
