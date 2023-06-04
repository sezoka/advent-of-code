const std = @import("std");
const aoc = @import("aoc.zig");
const run_solution = aoc.run_solution;

fn day1(_: std.mem.Allocator, input: []const u8) void {
    var top_1: u32 = 0;
    var top_2: u32 = 0;
    var top_3: u32 = 0;

    var callories_iter = std.mem.split(u8, input[0 .. input.len - 1], "\n\n");
    while (callories_iter.next()) |callories| {
        var elf_sum: u32 = 0;
        var lines_iter = std.mem.split(u8, callories, "\n");
        while (lines_iter.next()) |line| {
            const num = std.fmt.parseInt(u32, line, 10) catch return;
            elf_sum += num;
        }
        if (top_1 < elf_sum) {
            top_3 = top_2;
            top_2 = top_1;
            top_1 = elf_sum;
        } else if (top_2 < elf_sum) {
            top_3 = top_2;
            top_2 = elf_sum;
        } else if (top_3 < elf_sum) {
            top_3 = elf_sum;
        }
    }

    aoc.part_1("{d}", top_1);
    aoc.part_2("{d}", top_1 + top_2 + top_3);
}

fn day2(_: std.mem.Allocator, input: []const u8) void {
    const combinations = [9]u32{ 4, 8, 3, 1, 5, 9, 7, 2, 6 };
    const combinations2 = [9]u32{ 3, 4, 8, 1, 5, 9, 2, 6, 7 };

    var lines = std.mem.split(u8, input[0 .. input.len - 1], "\n");
    var score: u32 = 0;
    var score2: u32 = 0;

    while (lines.next()) |line| {
        const opp = line[0];
        const me = line[2];
        const idx = 3 * (opp - 'A') + (me - 'X');
        score += combinations[idx];
        score2 += combinations2[idx];
    }

    aoc.part_1("{d}", score);
    aoc.part_2("{d}", score2);
}

pub fn main() !void {
    aoc.start();
    defer aoc.finish();

    run_solution("day1.txt", day1);
    run_solution("day2.txt", day2);
}

test "simple test" {}
