const std = @import("std");
const aoc = @import("aoc.zig");
const mem = std.mem;
const io = std.io;
const fmt = std.fmt;
const sort = std.sort;
const math = std.math;
const simd = std.simd;

const stdout = io.getStdOut().writer();

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const ally = gpa.allocator();

    try aoc.run(ally, "../input/day1", day1);
    try aoc.run(ally, "../input/day2", day2);
    try aoc.run(ally, "../input/day3", day3);
    try aoc.run(ally, "../input/day4", day4);
    try aoc.run(ally, "../input/day5", day5);
}

fn day5(ally: mem.Allocator, input: []const u8) !void {
    const helpers = struct {
        pub fn compare(context: std.AutoHashMap(u8, std.ArrayList(u8)), lhs: u8, rhs: u8) bool {
            return mem.indexOfScalar(u8, context.get(rhs).?.items, lhs) != null;
        }
    };

    var ordering_rules = std.AutoHashMap(u8, std.ArrayList(u8)).init(ally);
    var lines_iter = mem.splitScalar(u8, input[0 .. input.len - 1], '\n');
    while (lines_iter.next()) |line| {
        if (line.len == 0) break;
        const before = try fmt.parseInt(u8, line[0..2], 10);
        const after = try fmt.parseInt(u8, line[3..], 10);
        var before_entry = try ordering_rules.getOrPutValue(before, std.ArrayList(u8).init(ally));
        try before_entry.value_ptr.append(after);
    }

    var part1_res: u32 = 0;
    var part2_res: u32 = 0;
    main_loop: while (lines_iter.next()) |line| {
        var nums = std.ArrayList(u8).init(ally);
        var nums_iter = mem.splitScalar(u8, line, ',');
        while (nums_iter.next()) |num_str| {
            const num = try fmt.parseInt(u8, num_str, 10);
            try nums.append(num);
        }

        for (nums.items, 0..) |num, i| {
            const num_rules = ordering_rules.get(num).?;
            for (nums.items[i + 1 ..]) |num_with_lower_priority| {
                const is_before = std.mem.indexOfScalar(u8, num_rules.items, num_with_lower_priority) != null;
                if (!is_before) {
                    mem.sortUnstable(u8, nums.items, ordering_rules, helpers.compare);
                    const middle = nums.items[nums.items.len / 2];
                    part2_res += middle;
                    continue :main_loop;
                }
            }
        }
        const middle = nums.items[nums.items.len / 2];
        part1_res += middle;
    }

    try stdout.print("part1: {d}, part2: {d}\n", .{ part1_res, part2_res });
}

fn day4(ally: mem.Allocator, input: []const u8) !void {
    const helper = struct {
        pub fn get_char(in: []const u8, w: i32, x: i32, y: i32) u8 {
            const idx = y * w + x;
            if (x < 0 or y < 0 or w <= x or @divTrunc(@as(i32, @intCast(in.len)), w) <= y) return 0;
            return in[@intCast(idx)];
        }

        const xmas = "XMAS";
        pub fn check_xmas(in: []const u8, w: i32, x: i32, y: i32, xit: i32, yit: i32) bool {
            var xx = x;
            var yy = y;
            for (xmas) |c| {
                if (get_char(in, w, xx, yy) != c) {
                    return false;
                }
                xx += xit;
                yy += yit;
            }
            return true;
        }

        pub fn check_mas(in: []const u8, w: i32, x: i32, y: i32) bool {
            if (get_char(in, w, x, y) != 'A') {
                return false;
            }

            const left_up = get_char(in, w, x - 1, y - 1);
            const left_down = get_char(in, w, x - 1, y + 1);
            const right_up = get_char(in, w, x + 1, y - 1);
            const right_down = get_char(in, w, x + 1, y + 1);
            if ((left_up != 'M' and left_up != 'S') or
                (left_down != 'M' and left_down != 'S'))
                return false;
            if (left_up == 'M' and right_down != 'S') return false;
            if (left_up == 'S' and right_down != 'M') return false;
            if (left_down == 'M' and right_up != 'S') return false;
            if (left_down == 'S' and right_up != 'M') return false;
            return true;
        }
    };

    var width: i32 = 0;
    while (input[@intCast(width)] != '\n') width += 1;
    var buff = std.ArrayList(u8).init(ally);
    for (input) |c| {
        if (c != '\n') try buff.append(c);
    }

    var part1_res: i32 = 0;
    var part2_res: i32 = 0;
    for (0..input.len) |i| {
        const x = @rem(@as(i32, @intCast(i)), width);
        const y = @divTrunc(@as(i32, @intCast(i)), width);
        if (helper.check_xmas(buff.items, width, x, y, 0, -1)) part1_res += 1;
        if (helper.check_xmas(buff.items, width, x, y, 1, -1)) part1_res += 1;
        if (helper.check_xmas(buff.items, width, x, y, 1, 0)) part1_res += 1;
        if (helper.check_xmas(buff.items, width, x, y, 1, 1)) part1_res += 1;
        if (helper.check_xmas(buff.items, width, x, y, 0, 1)) part1_res += 1;
        if (helper.check_xmas(buff.items, width, x, y, -1, 1)) part1_res += 1;
        if (helper.check_xmas(buff.items, width, x, y, -1, 0)) part1_res += 1;
        if (helper.check_xmas(buff.items, width, x, y, -1, -1)) part1_res += 1;
        if (helper.check_mas(buff.items, width, x, y)) {
            part2_res += 1;
        }
    }

    try stdout.print("part1: {d}, part2: {d}\n", .{ part1_res, part2_res });
}

fn day3(_: mem.Allocator, input: []const u8) !void {
    var part_1_res: usize = 0;
    var part_2_res: usize = 0;
    var i: usize = 0;
    var enabled = true;
    while (i < input.len) : (i += 1) {
        if (input.len <= i + 7) break;
        const prev_i = i;

        if (mem.eql(u8, "don't()", input[i .. i + 7])) {
            enabled = false;
            continue;
        }

        if (mem.eql(u8, "do()", input[i .. i + 4])) {
            enabled = true;
            continue;
        }

        if (mem.eql(u8, "mul(", input[i .. i + 4])) {
            i += 4;
            var start = i;
            while ('0' <= input[i] and input[i] <= '9') {
                i += 1;
            }
            const x = input[start..i];
            if (input[i] != ',') {
                i = prev_i;
                continue;
            }
            i += 1;
            start = i;
            while ('0' <= input[i] and input[i] <= '9') {
                i += 1;
            }
            const y = input[start..i];
            if (input[i] != ')') {
                i = prev_i;
                continue;
            }
            const sum = try fmt.parseInt(usize, x, 10) * try fmt.parseInt(usize, y, 10);
            part_1_res += sum;
            if (enabled) {
                part_2_res += sum;
            }
        }
    }
    try stdout.print("part1: {d}, part2: {d}\n", .{ part_1_res, part_2_res });
}

fn day2(_: mem.Allocator, input: []const u8) !void {
    const helper = struct {
        pub fn day_2_is_safe(nums: []i16) bool {
            const is_ascending = nums[0] < nums[1];
            for (0..nums.len - 1) |num_idx| {
                const x = if (is_ascending)
                    nums[num_idx + 1] - nums[num_idx]
                else
                    nums[num_idx] - nums[num_idx + 1];
                const is_safe = 1 <= x and x <= 3;
                if (!is_safe) return false;
            }
            return true;
        }
    };

    var lines_iter = mem.splitScalar(u8, input[0 .. input.len - 1], '\n');
    var safe_reports: u32 = 0;
    var reports_that_can_be_fixed: u32 = 0;
    while (lines_iter.next()) |line| {
        var nums: [10]i16 = @splat(0);
        var nums_len: usize = 0;
        var nums_iter = mem.splitScalar(u8, line, ' ');
        while (nums_iter.next()) |num_str| {
            const num = try fmt.parseInt(i16, num_str, 10);
            nums[nums_len] = num;
            nums_len += 1;
        }

        if (helper.day_2_is_safe(nums[0..nums_len])) {
            safe_reports += 1;
            continue;
        }
        for (0..nums_len) |i| {
            var nums_with_removed_item: [32]i16 = undefined;
            var insert_idx: usize = 0;
            for (0..nums_len) |j| {
                if (i == j) continue;
                nums_with_removed_item[insert_idx] = nums[j];
                insert_idx += 1;
            }
            if (helper.day_2_is_safe(nums_with_removed_item[0 .. nums_len - 1])) {
                reports_that_can_be_fixed += 1;
                break;
            }
        }
    }
    try stdout.print("part1: {d}, part2: {d}\n", .{ safe_reports, safe_reports + reports_that_can_be_fixed });
}

var day1_cnt_map: [99999]u8 = @splat(0);
fn day1(_: mem.Allocator, input: []const u8) !void {
    @setRuntimeSafety(false);
    const input_lines_cnt = 1000;
    const line_width = 14;
    var left_list: [input_lines_cnt]i32 = undefined;
    var right_list: [input_lines_cnt]i32 = undefined;
    var line_start: usize = 0;
    var i: usize = 0;
    while (line_start < input.len) : ({
        line_start += line_width;
        i += 1;
    }) {
        const line = input[line_start .. line_start + line_width];
        const left_num = try fmt.parseInt(i32, line[0..5], 10);
        const right_num = try fmt.parseInt(i32, line[8..13], 10);
        left_list[i] = left_num;
        right_list[i] = right_num;
    }
    mem.sortUnstable(i32, &left_list, {}, sort.asc(i32));
    mem.sortUnstable(i32, &right_list, {}, sort.asc(i32));
    const Vec1024i32 = @Vector(1000, i32);
    const left_vec: Vec1024i32 = left_list;
    const right_vec: Vec1024i32 = right_list;
    const part1_res = @reduce(.Add, @abs(left_vec - right_vec));
    for (right_list) |num| day1_cnt_map[@intCast(num)] += 1;
    var part2_res: i32 = 0;
    for (left_list) |num| part2_res += num * day1_cnt_map[@intCast(num)];
    try stdout.print("part1: {d}, part2: {d}\n", .{ part1_res, part2_res });
}
