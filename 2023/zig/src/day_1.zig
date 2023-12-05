const std = @import("std");
const ascii = std.ascii;
const aoc = @import("aoc");

pub fn day_1(ally: std.mem.Allocator) void {
    const helpers = struct {
        pub fn parse_digit(line: []const u8, read_letters: bool) std.meta.Tuple(&.{ u32, bool }) {
            if (ascii.isDigit(line[0])) return .{ line[0] - '0', true };

            if (!read_letters) return .{ 0, true };

            if (3 <= line.len) {
                if (std.mem.eql(u8, line[0..3], "one")) return .{ 1, false };
                if (std.mem.eql(u8, line[0..3], "two")) return .{ 2, false };
                if (std.mem.eql(u8, line[0..3], "six")) return .{ 6, false };
            }
            if (4 <= line.len) {
                if (std.mem.eql(u8, line[0..4], "four")) return .{ 4, false };
                if (std.mem.eql(u8, line[0..4], "five")) return .{ 5, false };
                if (std.mem.eql(u8, line[0..4], "nine")) return .{ 9, false };
            }
            if (5 <= line.len) {
                if (std.mem.eql(u8, line[0..5], "three")) return .{ 3, false };
                if (std.mem.eql(u8, line[0..5], "seven")) return .{ 7, false };
                if (std.mem.eql(u8, line[0..5], "eight")) return .{ 8, false };
            }

            return .{ 0, false };
        }
    };

    const input = aoc.read_input(ally, "day1").?;

    var lines = std.mem.splitScalar(u8, input, '\n');
    defer ally.free(input);

    var sum: u32 = 0;
    var sum_2: u32 = 0;

    while (lines.next()) |line| {
        var first_in_line: u32 = 0;
        var first_in_line_2: u32 = 0;
        var last_in_line: u32 = 0;
        var last_in_line_2: u32 = 0;

        for (0..line.len) |i| {
            const num: u32, const is_digit = helpers.parse_digit(line[i..], first_in_line_2 == 0);
            if (is_digit and first_in_line == 0) {
                first_in_line = num;
            }
            if (first_in_line_2 == 0) {
                first_in_line_2 = num;
            }
            if (first_in_line != 0 and first_in_line_2 != 0) break;
        }

        for (0..line.len) |i| {
            const num: u32, const is_digit = helpers.parse_digit(line[line.len - i - 1 ..], last_in_line_2 == 0);
            if (is_digit and last_in_line == 0) {
                last_in_line = num;
            }
            if (last_in_line_2 == 0) {
                last_in_line_2 = num;
            }
            if (last_in_line != 0 and last_in_line_2 != 0) break;
        }

        sum += first_in_line * 10 + last_in_line;
        sum_2 += first_in_line_2 * 10 + last_in_line_2;
    }

    std.debug.print("{d}\n", .{sum});
    std.debug.print("{d}\n", .{sum_2});
}
