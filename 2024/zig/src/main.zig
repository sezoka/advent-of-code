const std = @import("std");
const mem = std.mem;
const fmt = std.fmt;
const sort = std.sort;
const math = std.math;
const simd = std.simd;
const ascii = std.ascii;

const debug = std.debug;
const io = std.io;

const aoc = @import("aoc.zig");

const stdout = io.getStdOut().writer();

var stoudbuff = io.BufferedWriter(20480, @TypeOf(stdout)){ .unbuffered_writer = stdout };
const buffwriter = stoudbuff.writer();

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
    try aoc.run(ally, "../input/day8", day8.solution);
    try aoc.run(ally, "../input/day9", day9.solution);
    try aoc.run(ally, "../input/day10", day10.solution);
    try aoc.run(ally, "../input/day11", day11.solution);
    try aoc.run(ally, "../input/day12", day12.solution);
    try aoc.run(ally, "../input/day13", day13.solution);
}

const day13 = struct {
    fn calculate_cost_in_tokens(
        a_x: i64,
        a_y: i64,
        b_x: i64,
        b_y: i64,
        prize_x: i64,
        prize_y: i64,
    ) i64 {
        const det = (a_x * b_y - b_x * a_y);
        const a = @divTrunc((b_y * prize_x - b_x * prize_y), det);
        const b = @divTrunc((a_x * prize_y - a_y * prize_x), det);
        if (a_x * a + b_x * b == prize_x and a_y * a + b_y * b == prize_y)
            return a * 3 + b;
        return 0;
    }

    fn solution(_: mem.Allocator, input: []const u8) !void {
        var lines_iter = mem.splitScalar(u8, input[0 .. input.len - 1], '\n');
        var part1_res: i64 = 0;
        var part2_res: i64 = 0;
        while (true) {
            var line = lines_iter.next() orelse break;
            const btn_a_x = int_from_slice(i64, line[12..14]);
            const btn_a_y = int_from_slice(i64, line[18..]);
            line = lines_iter.next().?;
            const btn_b_x = int_from_slice(i64, line[12..14]);
            const btn_b_y = int_from_slice(i64, line[18..]);
            line = lines_iter.next().?;
            const prize_x = int_from_slice(i64, line[9..14]);
            const prize_y = int_from_slice(i64, line[15..]);

            part1_res += calculate_cost_in_tokens(btn_a_x, btn_a_y, btn_b_x, btn_b_y, prize_x, prize_y);
            part2_res += calculate_cost_in_tokens(btn_a_x, btn_a_y, btn_b_x, btn_b_y, prize_x + 10000000000000, prize_y + 10000000000000);

            _ = lines_iter.next();
        }

        debug.assert(part1_res == 33427);
        debug.assert(part2_res == 91649162972270);

        try stdout.print("part1: {d}, part2: {d}\n", .{ part1_res, part2_res });
    }
};

fn int_from_slice(T: type, slice: []const u8) T {
    debug.assert(slice.len != 0);
    var start: usize = 0;
    var end: usize = slice.len - 1;
    while (!ascii.isDigit(slice[start])) start += 1;
    while (!ascii.isDigit(slice[end])) end -= 1;
    return fmt.parseInt(T, slice[start .. end + 1], 10) catch unreachable;
}

const Direction = enum {
    up,
    right,
    down,
    left,
};

fn turn_left(dir: Direction) Direction {
    return switch (dir) {
        .up => .left,
        .left => .down,
        .down => .right,
        .right => .up,
    };
}

fn turn_right(dir: Direction) Direction {
    return switch (dir) {
        .up => .right,
        .right => .down,
        .down => .left,
        .left => .up,
    };
}

const Vec2 = struct {
    x: isize,
    y: isize,
};

fn next_coord_by_dir(dir: Direction, x: isize, y: isize) Vec2 {
    var new_x: isize = x;
    var new_y: isize = y;
    switch (dir) {
        .left => new_x -= 1,
        .right => new_x += 1,
        .up => new_y -= 1,
        .down => new_y += 1,
    }
    return .{ .x = new_x, .y = new_y };
}

const day12 = struct {
    const Plant = struct { name: u8, area: u32, perimeter: u32, sides: u32 };

    const Visited = std.AutoHashMap(struct { x: isize, y: isize }, void);

    fn check_is_corner(field: []u8, w: usize, x: isize, y: isize, plant: u8) u32 {
        const top_left = get_cell(field, w, x - 1, y - 1) == plant;
        const top = get_cell(field, w, x, y - 1) == plant;
        const top_right = get_cell(field, w, x + 1, y - 1) == plant;
        const left = get_cell(field, w, x - 1, y) == plant;
        const right = get_cell(field, w, x + 1, y) == plant;
        const bottom_left = get_cell(field, w, x - 1, y + 1) == plant;
        const bottom = get_cell(field, w, x, y + 1) == plant;
        const bottom_right = get_cell(field, w, x + 1, y + 1) == plant;

        var corners: u32 = 0;
        if (left and top and !top_left) corners += 1;
        if (left and bottom and !bottom_left) corners += 1;
        if (top and right and !top_right) corners += 1;
        if (right and bottom and !bottom_right) corners += 1;
        if (!top and !right) corners += 1;
        if (!right and !bottom) corners += 1;
        if (!bottom and !left) corners += 1;
        if (!left and !top) corners += 1;

        return corners;
    }

    fn measure_garden(
        visited: *Visited,
        plant: *Plant,
        field: []u8,
        w: usize,
        x: isize,
        y: isize,
    ) !void {
        const is_outside_of_field = get_cell(field, w, x, y) != plant.name;
        if (is_outside_of_field) {
            plant.sides += check_is_corner(field, w, x, y, plant.name);
            plant.perimeter += 1;
        }
        if (is_outside_of_field or visited.contains(.{ .x = x, .y = y })) {
            return;
        }

        try visited.put(.{ .x = x, .y = y }, {});
        plant.area += 1;

        try measure_garden(visited, plant, field, w, x - 1, y);
        try measure_garden(visited, plant, field, w, x + 1, y);
        try measure_garden(visited, plant, field, w, x, y - 1);
        try measure_garden(visited, plant, field, w, x, y + 1);
    }

    fn solution(ally: mem.Allocator, input: []const u8) !void {
        const field = try remove_whitespaces(ally, input);
        const field_width: isize = @intCast(get_line_len(input));

        var visited = Visited.init(ally);
        var plants = std.ArrayList(Plant).init(ally);

        for (field, 0..) |plant_name, i| {
            const x = @rem(@as(isize, @intCast(i)), field_width);
            const y = @divTrunc(@as(isize, @intCast(i)), field_width);
            if (visited.contains(.{ .x = x, .y = y })) {
                continue;
            }

            var plant: Plant = .{
                .name = plant_name,
                .perimeter = 0,
                .area = 0,
                .sides = 0,
            };

            try measure_garden(&visited, &plant, field, @intCast(field_width), x, y);
            try plants.append(plant);
        }

        var part1_res: u32 = 0;
        var part2_res: u32 = 0;
        for (plants.items) |p| {
            part1_res += p.area * p.perimeter;
            part2_res += p.area * p.sides;
        }

        debug.assert(part1_res == 1402544);
        debug.assert(part2_res == 862486);

        try stdout.print("part1: {d}, part2: {d}\n", .{ part1_res, part2_res });
    }
};

fn set_cell(field: []u8, w: isize, x: isize, y: isize, val: u8) void {
    if (x < 0 or w <= x or y < 0 or @divTrunc(@as(isize, @intCast(field.len)), w) <= y) {
        return;
    }
    const cell = &field[@intCast(y * w + x)];
    cell.* = val;
}

fn count_digits(T: type, v: T) u16 {
    var tmp = v;
    var res: u16 = 0;
    while (tmp != 0) {
        tmp /= 10;
        res += 1;
    }
    return res;
}

const day11 = struct {
    const Counter = std.AutoHashMap(u64, u64);

    fn blink(stones: *Counter, new_stones: *Counter) !void {
        var stone_iter = stones.iterator();
        while (stone_iter.next()) |entry| {
            const stone = entry.key_ptr.*;
            const count = entry.value_ptr.*;
            if (stone == 0) {
                (try new_stones.getOrPutValue(1, 0)).value_ptr.* += count;
                continue;
            }

            const digits = count_digits(u64, stone);
            if (digits % 2 == 0) {
                const base = math.pow(u64, 10, digits / 2);
                const left = stone / base;
                (try new_stones.getOrPutValue(left, 0)).value_ptr.* += count;
                const right = stone % base;
                (try new_stones.getOrPutValue(right, 0)).value_ptr.* += count;
            } else {
                (try new_stones.getOrPutValue(stone * 2024, 0)).value_ptr.* += count;
            }
        }
    }

    pub fn solution(ally: mem.Allocator, input: []const u8) !void {
        var part1_res: u64 = 0;
        var part2_res: u64 = 0;

        var nums_iter = mem.splitScalar(u8, input[0 .. input.len - 1], ' ');

        var stones = Counter.init(ally);
        var new_stones = Counter.init(ally);
        while (nums_iter.next()) |num_str| {
            (try stones.getOrPutValue(try fmt.parseInt(u64, num_str, 10), 0)).value_ptr.* += 1;
        }

        for (0..75) |i| {
            if (i == 25) {
                var stones_iter = stones.valueIterator();
                while (stones_iter.next()) |stone| {
                    part1_res += stone.*;
                }
            }
            try blink(&stones, &new_stones);
            const temp = new_stones;
            stones.clearRetainingCapacity();
            new_stones = stones;
            stones = temp;
        }

        var stones_iter = stones.valueIterator();
        while (stones_iter.next()) |stone| {
            part2_res += stone.*;
        }

        debug.assert(part1_res == 193269);
        debug.assert(part2_res == 228449040027793);
        try stdout.print("part1: {d}, part2: {d}\n", .{ part1_res, part2_res });
    }
};

const day10 = struct {
    const Point = struct { x: i16, y: i16 };

    fn dfs(field: []u8, w: usize, x: i16, y: i16, visited: *std.AutoHashMap(Point, void), is_part2: bool) !u8 {
        if (!visited.contains(.{ .x = x, .y = y })) {
            try visited.put(.{ .x = x, .y = y }, {});
            const center = get_cell_u16(field, w, x, y);
            if (center == '9') {
                return 1;
            }
            var result: u8 = 0;
            if (get_cell_u16(field, w, x, y - 1) - center == 1)
                result += try dfs(field, w, @intCast(x), @intCast(y - 1), visited, is_part2);
            if (is_part2) visited.clearRetainingCapacity();
            if (get_cell_u16(field, w, x + 1, y) - center == 1)
                result += try dfs(field, w, @intCast(x + 1), @intCast(y), visited, is_part2);
            if (is_part2) visited.clearRetainingCapacity();
            if (get_cell_u16(field, w, x, y + 1) - center == 1)
                result += try dfs(field, w, @intCast(x), @intCast(y + 1), visited, is_part2);
            if (is_part2) visited.clearRetainingCapacity();
            if (get_cell_u16(field, w, x - 1, y) - center == 1)
                result += try dfs(field, w, @intCast(x - 1), @intCast(y), visited, is_part2);
            if (is_part2) visited.clearRetainingCapacity();
            return result;
        }
        return 0;
    }

    fn is_cell_exists(field: []const u8, w: usize, x: i16, y: i16) bool {
        return !(x < 0 or w <= x or y < 0 or field.len / w <= y);
    }

    fn get_cell_u16(field: []const u8, w: usize, x: i16, y: i16) i8 {
        if (!is_cell_exists(field, w, x, y)) {
            return -1;
        }
        return @intCast(field[@as(usize, @intCast(x)) + @as(usize, @intCast(y)) * w]);
    }

    pub fn solution(ally: mem.Allocator, input: []const u8) !void {
        const field = try remove_whitespaces(ally, input);
        const field_width = get_line_len(input);

        var visited_nodes = std.AutoHashMap(Point, void).init(ally);
        var part1_res: usize = 0;
        var part2_res: usize = 0;
        for (field, 0..) |cell, i| {
            if (cell == '0') {
                const x = i % field_width;
                const y = i / field_width;
                part1_res += try dfs(field, field_width, @intCast(x), @intCast(y), &visited_nodes, false);
                visited_nodes.clearRetainingCapacity();
                part2_res += try dfs(field, field_width, @intCast(x), @intCast(y), &visited_nodes, true);
                visited_nodes.clearRetainingCapacity();
            }
        }

        debug.assert(part1_res == 531);
        debug.assert(part2_res == 1210);

        try stdout.print("part1: {d}, part2: {d}\n", .{ part1_res, part2_res });
    }
};

const day9 = struct {
    pub fn solution(ally: mem.Allocator, input: []const u8) !void {
        var disk = std.ArrayList(isize).init(ally);

        var is_free_space = false;
        for (0..input.len - 1) |block_id| {
            const file_id = block_id / 2;
            const file_size = try fmt.parseInt(u8, input[block_id .. block_id + 1], 10);
            if (is_free_space) {
                for (0..file_size) |_| {
                    try disk.append(-69);
                }
            } else {
                for (0..file_size) |_| {
                    try disk.append(@intCast(file_id));
                }
            }
            is_free_space = !is_free_space;
        }

        var file_block_idx: isize = @as(isize, @intCast(disk.items.len)) - 1;
        var db_cnt: u32 = 0;
        outer: while (true) {
            while (0 < file_block_idx and disk.items[@intCast(file_block_idx)] < 0) file_block_idx -= 1;
            if (file_block_idx < 0) break;
            const file_id = disk.items[@intCast(file_block_idx)];
            var file_size: isize = 0;
            while (0 < file_block_idx - file_size and
                file_id == disk.items[@intCast(file_block_idx - file_size)]) file_size += 1;
            if (file_block_idx - file_size < 0) break;

            var empty_block_idx: isize = 0;
            while (true) {
                db_cnt += 1;
                while (0 <= disk.items[@intCast(empty_block_idx)]) empty_block_idx += 1;
                var empty_block_size: isize = 0;
                while (empty_block_idx + empty_block_size < disk.items.len and
                    disk.items[@intCast(empty_block_idx + empty_block_size)] < 0) empty_block_size += 1;
                if (disk.items.len < empty_block_idx + empty_block_size) {
                    while (disk.items[@intCast(file_block_idx)] == file_id) file_block_idx -= 1;
                    continue :outer;
                }

                if (file_block_idx < empty_block_idx) {
                    while (0 <= file_block_idx and disk.items[@intCast(file_block_idx)] == file_id) file_block_idx -= 1;
                    continue :outer;
                }
                if (file_size <= empty_block_size) {
                    for (disk.items[@intCast(empty_block_idx)..@intCast(empty_block_idx + file_size)]) |*item| {
                        item.* = file_id;
                    }
                    for (disk.items[@intCast(file_block_idx - file_size + 1)..@intCast(file_block_idx + 1)]) |*item| {
                        item.* = -69;
                    }
                    break;
                } else {
                    empty_block_idx += 1;
                    continue;
                }
            }
        }

        var part1_res: usize = 0;
        for (disk.items, 0..) |id, pos|
            if (0 <= id) {
                part1_res += @as(usize, @intCast(id)) * pos;
            };

        try stdout.print("part1: {d}, part2: {d}\n", .{ part1_res, part1_res });
    }
};

const day8 = struct {
    const Pos = struct {
        x: i32,
        y: i32,
    };

    fn set_node(field: []u8, w: i32, x: i32, y: i32, antena: u8, val: u8, is_part_2: bool) void {
        if (x < 0 or w <= x or y < 0 or @divTrunc(@as(i32, @intCast(field.len)), w) <= y) {
            return;
        }
        const cell = &field[@intCast(y * w + x)];
        if (cell.* == antena and !is_part_2) return;
        cell.* = val;
    }

    pub fn solution(ally: mem.Allocator, input: []const u8) !void {
        const field_width = get_line_len(input);
        const part1_field = try remove_whitespaces(ally, input);
        const part2_field = try ally.dupe(u8, part1_field);
        var antenna_to_position = std.AutoHashMap(u8, std.ArrayList(Pos)).init(ally);
        for (0..part1_field.len) |i| {
            const antenna = part1_field[i];
            if (antenna == '.') continue;
            const x = i % field_width;
            const y = i / field_width;
            const gop = try antenna_to_position.getOrPut(antenna);
            if (!gop.found_existing) {
                gop.value_ptr.* = std.ArrayList(Pos).init(ally);
            }
            try gop.value_ptr.append(.{ .x = @intCast(x), .y = @intCast(y) });
        }

        var antenas_iter = antenna_to_position.iterator();
        while (antenas_iter.next()) |antena| {
            const positions = antena.value_ptr;
            for (positions.items) |a_pos| {
                for (positions.items) |b_pos| {
                    const x_distance = b_pos.x - a_pos.x;
                    const y_distance = b_pos.y - a_pos.y;
                    var antinode_x = b_pos.x;
                    var antinode_y = b_pos.y;
                    set_node(
                        part1_field,
                        @intCast(field_width),
                        antinode_x + x_distance,
                        antinode_y + y_distance,
                        antena.key_ptr.*,
                        '#',
                        false,
                    );
                    if (x_distance < 1 and y_distance < 1) continue;

                    while ((0 <= antinode_x and 0 <= antinode_y) and
                        (antinode_x <= field_width and antinode_y <= field_width))
                    {
                        antinode_x -= x_distance;
                        antinode_y -= y_distance;
                    }

                    antinode_x += x_distance;
                    antinode_y += y_distance;

                    while ((0 <= antinode_x and 0 <= antinode_y) and
                        (antinode_x <= field_width and antinode_y <= field_width))
                    {
                        set_node(part2_field, @intCast(field_width), antinode_x, antinode_y, antena.key_ptr.*, '#', true);
                        antinode_x += x_distance;
                        antinode_y += y_distance;
                    }
                }
            }
        }

        var part1_res: u32 = 0;
        var part2_res: u32 = 0;

        for (part1_field, part2_field) |part1_cell, part2_cell| {
            if (part1_cell == '#') part1_res += 1;
            if (part2_cell == '#') part2_res += 1;
        }

        try stdout.print("part1: {d}, part2: {d}\n", .{ part1_res, part2_res });
    }
};

fn get_cell(field: []const u8, w: usize, x: isize, y: isize) u8 {
    @setRuntimeSafety(false);
    if (x < 0 or w <= x or y < 0 or field.len / w <= y) {
        return 0;
    }
    return field[@as(usize, @intCast(x)) + @as(usize, @intCast(y)) * w];
}

fn get_cell_by_pos(field: []const u8, w: usize, pos: Vec2) u8 {
    return get_cell(field, w, pos.x, pos.y);
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
    fn check(items: []u32, expect: u64, result: u64, is_part2: bool) bool {
        if (items.len == 0) return expect == result;
        if (check(items[1..], expect, result + items[0], is_part2)) return true;
        if (check(items[1..], expect, result * items[0], is_part2)) return true;
        if (is_part2) {
            if (check(items[1..], expect, concat_nums(u64, result, items[0]), is_part2))
                return true;
        }
        return false;
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

            if (check(nums.items, equation_result, 0, false)) {
                part1_res += equation_result;
            }
            if (check(nums.items, equation_result, 0, true)) {
                part2_res += equation_result;
            }
        }

        debug.assert(part1_res == 1298103531759);
        debug.assert(part2_res == 140575048428831);
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

fn get_line_len(input: []const u8) usize {
    for (input, 0..) |c, i| {
        if (c == '\n') return i;
    }
    return input.len;
}

const day6 = struct {
    fn solution(ally: mem.Allocator, input: []const u8) !void {
        const orig_field = try remove_whitespaces(ally, input);
        const field_width = get_line_len(input);
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

            var guard_dir = get_cell(field, field_width, @intCast(guard_x), @intCast(guard_y));
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
                const next_pos_cell = get_cell(field, field_width, @intCast(next_pos_x), @intCast(next_pos_y));
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

        debug.assert(part1_res == 4776);
        debug.assert(part2_res == 1586);
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

        debug.assert(part1_res == 6242);
        debug.assert(part2_res == 5169);
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

        debug.assert(part1_res == 2642);
        debug.assert(part2_res == 1974);
        try stdout.print("part1: {d}, part2: {d}\n", .{ part1_res, part2_res });
    }
};

const day3 = struct {
    pub fn solution(_: mem.Allocator, input: []const u8) !void {
        var part1_res: usize = 0;
        var part2_res: usize = 0;
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
                part1_res += sum;
                if (enabled) {
                    part2_res += sum;
                }
            }
        }
        debug.assert(part1_res == 187194524);
        debug.assert(part2_res == 127092535);
        try stdout.print("part1: {d}, part2: {d}\n", .{ part1_res, part2_res });
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
        const part1_res = safe_reports;
        const part2_res = safe_reports + reports_that_can_be_fixed;
        debug.assert(part1_res == 686);
        debug.assert(part2_res == 717);
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
        debug.assert(part1_res == 1889772);
        debug.assert(part2_res == 23228917);
        try stdout.print("part1: {d}, part2: {d}\n", .{ part1_res, part2_res });
    }
};
