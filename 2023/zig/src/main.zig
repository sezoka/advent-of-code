const std = @import("std");
const aoc = @import("aoc");

const day_1 = @import("day_1.zig").day_1;
const day_4 = @import("day_4.zig").day_4;
const day_5 = @import("day_5.zig").day_5;
const day_6 = @import("day_6.zig").day_6;

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const ally = gpa.allocator();

    day_6(ally);
}
