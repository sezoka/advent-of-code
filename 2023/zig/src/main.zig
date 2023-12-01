const std = @import("std");
const aoc = @import("aoc");

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const ally = gpa.allocator();
    _ = ally;
}
