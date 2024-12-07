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

    try aoc.run(ally, "../input/day1", day1.solution);
    try aoc.run(ally, "../input/day2", day2.solution);
    try aoc.run(ally, "../input/day3", day3.solution);
    try aoc.run(ally, "../input/day4", day4.solution);
    try aoc.run(ally, "../input/day5", day5.solution);
    try aoc.run(ally, "../input/day6", day6.solution);
    try aoc.run(ally, "../input/day7", day7.solution);
}

fn concat_nums(T: type, a: T, b: T) T {
    var tens: T = 1;
    var tmp = b;
    while (tmp != 0) {
        tens *= 10;
        tmp /= 10;
    }
    return a * tens + b;
}

const day7 = struct {
    fn check_recursive(items: []u32, expect: u64, result: u64) u8 {
        if (items.len == 0) return @intFromBool(result == expect);
        const plus_res = check_recursive(items[1..], expect, result + items[0]);
        if (plus_res != 0) return plus_res;
        const mult_res = check_recursive(items[1..], expect, result * items[0]);
        if (mult_res != 0) return mult_res;
        const concat = concat_nums(u64, result, items[0]);
        if (check_recursive(items[1..], expect, concat) != 0)
            return 2;
        return 0;
    }

    pub fn solution(ally: mem.Allocator, input: []const u8) !void {
        var lines_iter = mem.splitScalar(u8, input[0 .. input.len - 1], '\n');
        var part1_res: u64 = 0;
        var part2_res: u64 = 0;
        while (lines_iter.next()) |line| {
            var colon_idx: u32 = 0;
            while (line[colon_idx] != ':') colon_idx += 1;
            const equation_result_str = line[0..colon_idx];
            const equation_result = try fmt.parseInt(u64, equation_result_str, 10);
            var numbers_iter = mem.splitScalar(u8, line[colon_idx + 2 .. line.len], ' ');
            var nums = std.ArrayList(u32).init(ally);
            while (numbers_iter.next()) |num_str| {
                const num = try fmt.parseInt(u16, num_str, 10);
                try nums.append(num);
            }

            const res = check_recursive(nums.items, equation_result, 0);
            if (res == 1) {
                part1_res += equation_result;
                part2_res += equation_result;
            } else if (res == 2) {
                part2_res += equation_result;
            }
        }

        try stdout.print("part1: {d}, part2: {d}\n", .{ part1_res, part2_res });
    }
};

fn remove_whitespaces(ally: mem.Allocator, input: []const u8) ![]u8 {
    var result = std.ArrayList(u8).init(ally);
    for (input) |c| {
        if (c != '\n') {
            try result.append(c);
        }
    }
    return result.items;
}

fn line_length(input: []const u8) usize {
    for (input, 0..) |c, i| {
        if (c == '\n') return i;
    }
    return input.len;
}

const day6 = struct {
    fn get_cell(field: []const u8, w: usize, x: usize, y: usize) u8 {
        if (x < 0 or w <= x or y < 0 or field.len / w <= y) {
            return 0;
        }
        return field[y * w + x];
    }

    fn solution(ally: mem.Allocator, input: []const u8) !void {
        const orig_field = try remove_whitespaces(ally, input);
        const field_width = line_length(input);
        const field_height = orig_field.len / field_width;
        var guard_start_x: usize = 0;
        var guard_start_y: usize = 0;
        for (orig_field, 0..) |c, i| {
            if (c == '^') {
                guard_start_x = i % field_width;
                guard_start_y = i / field_width;
                break;
            }
        }

        var part1_res: u32 = 0;
        var part2_res: u32 = 0;
        const field = try ally.alloc(u8, orig_field.len);
        var is_first_part = true;
        var obstacle_pos: usize = 0;
        obstacle_placement: while (obstacle_pos < orig_field.len) : (obstacle_pos += 1) {
            if (orig_field[obstacle_pos] != '.') continue;
            @memcpy(field, orig_field);
            field[obstacle_pos] = '#';
            var guard_x = guard_start_x;
            var guard_y = guard_start_y;

            var guard_dir = get_cell(field, field_width, guard_x, guard_y);
            while (0 < guard_x and guard_x < field_width and 0 < guard_y and guard_y < field_height) {
                if (!is_first_part) {
                    if (field[guard_x + guard_y * field_width] == guard_dir and
                        guard_start_x != guard_x and
                        guard_start_y != guard_y)
                    {
                        part2_res += 1;
                        continue :obstacle_placement;
                    }
                }

                if (field[guard_x + guard_y * field_width] == '.') {
                    field[guard_x + guard_y * field_width] = guard_dir;
                }
                var next_pos_x = guard_x;
                var next_pos_y = guard_y;
                switch (guard_dir) {
                    '^' => next_pos_y = guard_y - 1,
                    'v' => next_pos_y = guard_y + 1,
                    '<' => next_pos_x = guard_x - 1,
                    '>' => next_pos_x = guard_x + 1,
                    else => unreachable,
                }
                const next_pos_cell = get_cell(field, field_width, next_pos_x, next_pos_y);
                switch (next_pos_cell) {
                    '#' => {
                        switch (guard_dir) {
                            '^' => guard_dir = '>',
                            'v' => guard_dir = '<',
                            '<' => guard_dir = '^',
                            '>' => guard_dir = 'v',
                            else => unreachable,
                        }
                    },
                    0 => {
                        break;
                    },
                    else => {
                        guard_x = next_pos_x;
                        guard_y = next_pos_y;
                    },
                }
            }
            field[guard_x + guard_y * field_width] = guard_dir;

            if (is_first_part) {
                for (field) |c| {
                    if (c != '.' and c != '#') part1_res += 1;
                }
                is_first_part = false;
            }
        }

        try stdout.print("part1: {d}, part2: {d}\n", .{ part1_res, part2_res });
    }
};

const day5 = struct {
    fn compare(context: std.AutoHashMap(u8, std.ArrayList(u8)), lhs: u8, rhs: u8) bool {
        return mem.indexOfScalar(u8, context.get(rhs).?.items, lhs) != null;
    }

    pub fn solution(ally: mem.Allocator, input: []const u8) !void {
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
                        mem.sortUnstable(u8, nums.items, ordering_rules, compare);
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
};

const day4 = struct {
    fn get_char(in: []const u8, w: i32, x: i32, y: i32) u8 {
        const idx = y * w + x;
        if (x < 0 or y < 0 or w <= x or @divTrunc(@as(i32, @intCast(in.len)), w) <= y) return 0;
        return in[@intCast(idx)];
    }

    const xmas = "XMAS";
    fn check_xmas(in: []const u8, w: i32, x: i32, y: i32, xit: i32, yit: i32) bool {
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

    fn check_mas(in: []const u8, w: i32, x: i32, y: i32) bool {
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

    pub fn solution(ally: mem.Allocator, input: []const u8) !void {
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
            if (check_xmas(buff.items, width, x, y, 0, -1)) part1_res += 1;
            if (check_xmas(buff.items, width, x, y, 1, -1)) part1_res += 1;
            if (check_xmas(buff.items, width, x, y, 1, 0)) part1_res += 1;
            if (check_xmas(buff.items, width, x, y, 1, 1)) part1_res += 1;
            if (check_xmas(buff.items, width, x, y, 0, 1)) part1_res += 1;
            if (check_xmas(buff.items, width, x, y, -1, 1)) part1_res += 1;
            if (check_xmas(buff.items, width, x, y, -1, 0)) part1_res += 1;
            if (check_xmas(buff.items, width, x, y, -1, -1)) part1_res += 1;
            if (check_mas(buff.items, width, x, y)) {
                part2_res += 1;
            }
        }

        try stdout.print("part1: {d}, part2: {d}\n", .{ part1_res, part2_res });
    }
};

const day3 = struct {
    pub fn solution(_: mem.Allocator, input: []const u8) !void {
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
};

const day2 = struct {
    fn check_is_safe(nums: []i16) bool {
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

    pub fn solution(_: mem.Allocator, input: []const u8) !void {
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

            if (check_is_safe(nums[0..nums_len])) {
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
                if (check_is_safe(nums_with_removed_item[0 .. nums_len - 1])) {
                    reports_that_can_be_fixed += 1;
                    break;
                }
            }
        }
        try stdout.print("part1: {d}, part2: {d}\n", .{ safe_reports, safe_reports + reports_that_can_be_fixed });
    }
};

const day1 = struct {
    var cnt_map: [99999]u8 = @splat(0);
    pub fn solution(_: mem.Allocator, input: []const u8) !void {
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
        for (right_list) |num| cnt_map[@intCast(num)] += 1;
        var part2_res: i32 = 0;
        for (left_list) |num| part2_res += num * cnt_map[@intCast(num)];
        try stdout.print("part1: {d}, part2: {d}\n", .{ part1_res, part2_res });
    }
};
