const std = @import("std");

const Vec3 = [3]i64;

fn dist(left: Vec3, right: Vec3) f64 {
    var sum: f64 = 0;
    inline for (left, right) |l, r| {
        sum += std.math.pow(f64, @floatFromInt(l - r), 2);
    }
    return @sqrt(sum);
}

const Distance = struct {
    ai: usize,
    bi: usize,
    dist: f64,
    fn lessThan(_: void, left: @This(), right: @This()) bool {
        return left.dist < right.dist;
    }
};

pub fn main() !void {
    var stdin = std.fs.File.stdin();
    var readBuf: [1 << 10]u8 = undefined;
    var reader = stdin.reader(&readBuf);

    const allocator = std.heap.page_allocator;

    var circuits = try std.ArrayList(Vec3).initCapacity(allocator, 1000);
    defer circuits.deinit(allocator);

    while (try reader.interface.takeDelimiter('\n')) |slice| {
        var iter = std.mem.splitScalar(u8, slice, ',');
        const x = try std.fmt.parseInt(i64, iter.next().?, 10);
        const y = try std.fmt.parseInt(i64, iter.next().?, 10);
        const z = try std.fmt.parseInt(i64, iter.next().?, 10);
        try circuits.append(allocator, .{ x, y, z });
    }

    const combinations = (circuits.items.len * (circuits.items.len - 1)) / 2;
    var distances = try std.ArrayList(Distance).initCapacity(allocator, combinations);
    defer distances.deinit(allocator);

    for (circuits.items, 0..) |a, ai| {
        for (circuits.items[ai + 1 ..], ai + 1..) |b, bi| {
            try distances.append(allocator, .{ .ai = ai, .bi = bi, .dist = dist(a, b) });
        }
    }

    std.sort.pdq(Distance, distances.items, {}, Distance.lessThan);

    var id: usize = 0;
    var ids = try std.ArrayList(usize).initCapacity(allocator, circuits.items.len);
    defer ids.deinit(allocator);

    const indexes = try allocator.alloc(usize, circuits.items.len);
    defer allocator.free(indexes);
    @memset(indexes, 0);

    const counts = try allocator.alloc(usize, circuits.items.len);
    defer allocator.free(counts);

    const P1 = 1000;

    for (distances.items, 0..) |distance, i| {
        const as = &indexes[distance.ai];
        const bs = &indexes[distance.bi];

        if (as.* == 0 and bs.* == 0) {
            try ids.append(allocator, id);
            id += 1;
            const index = ids.items.len;
            as.* = index;
            bs.* = index;
        } else if (as.* == 0) {
            as.* = bs.*;
        } else if (bs.* == 0) {
            bs.* = as.*;
        } else if (ids.items[as.* - 1] != ids.items[bs.* - 1]) {
            const old_id = ids.items[bs.* - 1];
            const new_id = ids.items[as.* - 1];
            for (ids.items) |*group_id| {
                if (group_id.* == old_id) {
                    group_id.* = new_id;
                }
            }
        }

        var top3 = [_]usize{ 0, 0, 0 };

        @memset(counts, 0);
        for (indexes) |index| {
            if (index != 0) {
                counts[ids.items[index - 1]] += 1;
                const value = counts[ids.items[index - 1]];
                if (value > top3[0]) {
                    top3[2] = top3[1];
                    top3[1] = top3[0];
                    top3[0] = value;
                } else if (value > top3[1]) {
                    top3[2] = top3[1];
                    top3[1] = value;
                } else if (value > top3[2]) {
                    top3[2] = value;
                }
            }
        }

        if (i == P1 - 1) {
            std.debug.print("{d}\n", .{top3[0] * top3[1] * top3[2]});
        } else if (top3[0] == circuits.items.len) {
            const r = circuits.items[distance.ai][0] * circuits.items[distance.bi][0];
            std.debug.print("{d}\n", .{r});
            break;
        }
    }
}
