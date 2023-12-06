const std = @import("std");
const ascii = std.ascii;
const aoc = @import("aoc");

pub fn day_6(ally: std.mem.Allocator) void {
    const input = aoc.read_input(ally, "day6").?;
    defer ally.free(input);
    var lines = std.mem.splitScalar(u8, input, '\n');

    const time_line = lines.next().?[11..];
    const record_line = lines.next().?[11..];

    var time_iter = std.mem.splitScalar(u8, time_line, ' ');
    var record_iter = std.mem.splitScalar(u8, record_line, ' ');

    var result_1: u64 = 1;

    var part_2_time: u64 = 0;
    var part_2_record: u64 = 0;

    while (true) {
        var time_str = time_iter.next() orelse break;
        while (time_str.len == 0) time_str = time_iter.next().?;
        var record_str = record_iter.next().?;
        while (record_str.len == 0) record_str = record_iter.next().?;

        const time = std.fmt.parseInt(u64, time_str, 10) catch unreachable;
        const record = std.fmt.parseInt(u64, record_str, 10) catch unreachable;

        part_2_time = part_2_time * to_tens(time) + time;
        part_2_record = part_2_record * to_tens(record) + record;

        var win_cases_cnt: u64 = 0;

        for (1..time) |hold| {
            if (record < (time - hold) * hold) {
                win_cases_cnt += 1;
            }
        }

        result_1 *= win_cases_cnt;
    }

    std.debug.print("{d}\n", .{result_1});

    var result_2: u64 = 0;
    for (1..part_2_time) |hold| {
        if (part_2_record < (part_2_time - hold) * hold) {
            result_2 += 1;
        }
    }

    std.debug.print("{d}\n", .{result_2});
}

fn to_tens(num: u64) u64 {
    var result: u64 = if (num != 0) 1 else 0;
    var n = num;
    while (n != 0) {
        n /= 10;
        result *= 10;
    }
    return result;
}
