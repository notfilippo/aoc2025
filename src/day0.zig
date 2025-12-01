const std = @import("std");

pub fn main() !void {
    var stdin = std.fs.File.stdin();
    var readBuf: [1 << 10]u8 = undefined;
    var reader = stdin.reader(&readBuf);

    var state: i16 = 50;
    var atZero: i16 = 0;
    var passZero: i16 = 0;

    while (try reader.interface.takeDelimiter('\n')) |slice| {
        const dir = slice[0];
        const amount = try std.fmt.parseInt(i16, slice[1..], 10);
        const sign: i16 = if (dir == 'L') -1 else 1;

        const start = if (sign < 0 and state != 0) 100 - state else state;
        const end = start + amount;

        passZero += @divTrunc(end, 100);

        state = @mod(state + amount * sign, 100);

        if (state == 0) {
            atZero += 1;
        }
    }

    std.debug.print("{d}\n", .{atZero});
    std.debug.print("{d}\n", .{passZero});
}
