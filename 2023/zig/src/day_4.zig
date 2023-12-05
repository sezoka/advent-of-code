const std = @import("std");
const ascii = std.ascii;
const aoc = @import("aoc");

pub fn day_4(ally: std.mem.Allocator) void {
    const helpers = struct {
        pub fn process_part_2(wins_cnt: []u32, cache: []usize, start: usize) usize {
            if (start < cache.len and cache[start] != 0) return cache[start];
            // std.debug.print("{d}\n", .{start});
            if (start < wins_cnt.len and wins_cnt[start] != 0) {
                var sum: usize = 1;
                for (1..wins_cnt[start] + 1) |i| {
                    sum += process_part_2(wins_cnt, cache, start + i);
                }
                cache[start] = sum;
                return sum;
            }
            return 1;
        }
    };

    const input = aoc.read_input(ally, "day4").?;
    defer ally.free(input);
    var lines = std.mem.splitScalar(u8, input, '\n');

    var result_1: u32 = 0;

    var cards_wins_cnt = std.ArrayList(u32).init(ally);
    defer cards_wins_cnt.deinit();

    while (lines.next()) |line| {
        if (line.len == 0) break;
        var cards = std.mem.split(u8, line, " | ");
        var win_cards_temp = std.mem.split(u8, cards.next().?, ": ");
        const my_cards = cards.next().?;
        _ = win_cards_temp.next();
        const win_cards = win_cards_temp.next().?;

        var win_nums = std.ArrayList(u32).init(ally);
        defer win_nums.deinit();

        var win_nums_iter = std.mem.split(u8, win_cards, " ");
        while (win_nums_iter.next()) |num_str| {
            if (num_str.len == 0) continue;
            const num = std.fmt.parseInt(u32, num_str, 10) catch unreachable;
            win_nums.append(num) catch unreachable;
        }

        var my_nums = std.ArrayList(u32).init(ally);
        defer my_nums.deinit();

        var my_nums_iter = std.mem.split(u8, my_cards, " ");
        while (my_nums_iter.next()) |num_str| {
            if (num_str.len == 0) continue;
            const num = std.fmt.parseInt(u32, num_str, 10) catch unreachable;
            my_nums.append(num) catch unreachable;
        }

        var score: u32 = 0;
        var wins_cnt: u32 = 0;

        for (win_nums.items) |win_num| {
            for (my_nums.items) |my_num| {
                if (win_num == my_num) {
                    wins_cnt += 1;
                    if (score == 0) {
                        score = 1;
                    } else {
                        score *= 2;
                        break;
                    }
                }
            }
        }

        cards_wins_cnt.append(wins_cnt) catch unreachable;
        result_1 += score;
    }

    var cache = std.ArrayList(usize).init(ally);
    defer cache.deinit();

    while (cache.items.len != cards_wins_cnt.items.len) cache.append(0) catch unreachable;
    var result_2: usize = 0;

    for (0..cards_wins_cnt.items.len) |i| {
        const tmp = helpers.process_part_2(cards_wins_cnt.items, cache.items, i);
        result_2 += tmp;
        std.debug.print("{d}\n", .{tmp});
    }

    // std.debug.print("{d}\n", .{result_1});
    std.debug.print("{d}\n", .{result_2});
}

// const std = @import("std");
// const ascii = std.ascii;
// const aoc = @import("aoc");

// pub fn day_4(ally: std.mem.Allocator) void {
//     const helpers = struct {
//         pub fn process_part_2(wins_cnt: []u32, cache: []usize, start: usize) void {
//             cache[start] += 1;
//             if (start < wins_cnt.len and wins_cnt[start] != 0) {
//                 for (1..wins_cnt[start] + 1) |i| {
//                     process_part_2(wins_cnt, cache, start + i);
//                 }
//             }
//         }
//     };

//     const input = aoc.read_input(ally, "day4").?;
//     defer ally.free(input);
//     var lines = std.mem.splitScalar(u8, input, '\n');

//     var result_1: u32 = 0;

//     var cards_wins_cnt = std.ArrayList(u32).init(ally);
//     defer cards_wins_cnt.deinit();

//     while (lines.next()) |line| {
//         if (line.len == 0) break;
//         var cards = std.mem.split(u8, line, " | ");
//         var win_cards_temp = std.mem.split(u8, cards.next().?, ": ");
//         const my_cards = cards.next().?;
//         _ = win_cards_temp.next();
//         const win_cards = win_cards_temp.next().?;

//         var win_nums = std.ArrayList(u32).init(ally);
//         defer win_nums.deinit();

//         var win_nums_iter = std.mem.split(u8, win_cards, " ");
//         while (win_nums_iter.next()) |num_str| {
//             if (num_str.len == 0) continue;
//             const num = std.fmt.parseInt(u32, num_str, 10) catch unreachable;
//             win_nums.append(num) catch unreachable;
//         }

//         var my_nums = std.ArrayList(u32).init(ally);
//         defer my_nums.deinit();

//         var my_nums_iter = std.mem.split(u8, my_cards, " ");
//         while (my_nums_iter.next()) |num_str| {
//             if (num_str.len == 0) continue;
//             const num = std.fmt.parseInt(u32, num_str, 10) catch unreachable;
//             my_nums.append(num) catch unreachable;
//         }

//         var score: u32 = 0;
//         var wins_cnt: u32 = 0;

//         for (win_nums.items) |win_num| {
//             for (my_nums.items) |my_num| {
//                 if (win_num == my_num) {
//                     wins_cnt += 1;
//                     if (score == 0) {
//                         score = 1;
//                     } else {
//                         score *= 2;
//                         break;
//                     }
//                 }
//             }
//         }

//         cards_wins_cnt.append(wins_cnt) catch unreachable;
//         result_1 += score;
//     }

//     var cache = std.ArrayList(usize).init(ally);
//     defer cache.deinit();

//     while (cache.items.len != cards_wins_cnt.items.len) cache.append(0) catch unreachable;
//     var result_2: usize = helpers.process_part_2(cards_wins_cnt.items, cache.items, 0);

//     for (0..cards_wins_cnt.items.len) |i| {
//         const tmp = helpers.process_part_2(cards_wins_cnt.items, cache.items, i);
//         result_2 += tmp;
//         std.debug.print("{d}\n", .{tmp});
//     }

//     // std.debug.print("{d}\n", .{result_1});
//     std.debug.print("{any}\n", .{cards_wins_cnt});
//     std.debug.print("{d}\n", .{cache.items});
// }
