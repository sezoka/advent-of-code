const std = @import("std");
const aoc = @import("aoc");

const day_1 = @import("day_1.zig").day_1;
const day_4 = @import("day_4.zig").day_4;

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const ally = gpa.allocator();

    day_4(ally);
}
