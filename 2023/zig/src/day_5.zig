const std = @import("std");
const ascii = std.ascii;
const aoc = @import("aoc");

pub fn day_5(ally: std.mem.Allocator) void {
    const Range = struct {
        to: u64,
        from: u64,
        len: u64,
    };

    const input = aoc.read_input(ally, "day5").?;
    defer ally.free(input);
    var lines = std.mem.splitScalar(u8, input, '\n');

    const seeds_line = lines.next().?[7..];
    var seeds_iter = std.mem.splitScalar(u8, seeds_line, ' ');

    var maps_ranges = std.ArrayList([]Range).init(ally);
    defer maps_ranges.deinit();

    var ranges = std.ArrayList(Range).init(ally);

    _ = lines.next();
    _ = lines.next();

    while (lines.next()) |line| {
        if (line.len == 0) {
            maps_ranges.append(ranges.toOwnedSlice() catch unreachable) catch unreachable;
            continue;
        }
        if (!ascii.isDigit(line[0])) continue;

        var vals_iter = std.mem.splitScalar(u8, line, ' ');
        const to = std.fmt.parseInt(u64, vals_iter.next().?, 10) catch unreachable;
        const from = std.fmt.parseInt(u64, vals_iter.next().?, 10) catch unreachable;
        const len = std.fmt.parseInt(u64, vals_iter.next().?, 10) catch unreachable;
        const range = Range{ .to = to, .from = from, .len = len };
        ranges.append(range) catch unreachable;
    }

    var lowest: u64 = std.math.maxInt(u64);
    var seeds = std.ArrayList(u64).init(ally);
    defer seeds.deinit();

    while (seeds_iter.next()) |seed_str| {
        const seed = std.fmt.parseInt(u64, seed_str, 10) catch unreachable;
        seeds.append(seed) catch unreachable;
    }

    for (seeds.items) |seed| {
        var val = seed;
        for (maps_ranges.items) |map_ranges| {
            for (map_ranges) |range| {
                if (range.from <= val and val <= range.from + range.len) {
                    val = val - range.from + range.to;
                    break;
                }
            }
        }
        if (val < lowest) {
            lowest = val;
        }
    }

    std.debug.print("{d}\n", .{lowest});

    lowest = std.math.maxInt(u64);

    for (0..seeds.items.len / 2) |i| {
        const seed_range_start = seeds.items[i * 2];
        const seed_range_len = seeds.items[i * 2 + 1];

        for (seed_range_start..seed_range_start + seed_range_len) |seed| {
            var val = seed;
            for (maps_ranges.items) |map_ranges| {
                for (map_ranges) |range| {
                    if (range.from <= val and val <= range.from + range.len) {
                        val = val - range.from + range.to;
                        break;
                    }
                }
            }
            if (val < lowest) {
                lowest = val;
            }
        }
    }

    std.debug.print("{d}\n", .{lowest - 1});

    for (maps_ranges.items) |mr| {
        ally.free(mr);
    }
}
