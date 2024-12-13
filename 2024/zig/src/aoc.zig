const std = @import("std");
const process = std.process;
const mem = std.mem;
const heap = std.heap;
const fs = std.fs;
const log = std.log;
const io = std.io;
const time = std.time;

pub fn read_input(ally: mem.Allocator, file_path: []const u8) []const u8 {
    const file_size_limit = 4024000;
    return fs.cwd().readFileAlloc(ally, file_path, file_size_limit) catch |err| {
        switch (err) {
            error.OutOfMemory => log.err("Just buy more ram", .{}),
            error.FileNotFound => log.err("File '{s}' not found", .{file_path}),
            error.FileTooBig => log.err("File '{s}' is too large", .{file_path}),
            else => log.err("Failed to read file '{s}. Error: {}", .{ file_path, err }),
        }
        process.exit(1);
    };
}

const Solution = fn (ally: mem.Allocator, file: []const u8) anyerror!void;

pub fn run(ally: mem.Allocator, file_path: []const u8, comptime solution: Solution) !void {
    var arena = heap.ArenaAllocator.init(ally);
    defer arena.deinit();
    const arena_ally = arena.allocator();
    const file = read_input(arena_ally, file_path);
    const stdout = io.getStdOut().writer();
    try stdout.print("@=== {s}\n| ", .{file_path});
    const start_time = time.nanoTimestamp();
    try solution(arena_ally, file);
    const elapsed = time.nanoTimestamp() - start_time;
    try stdout.print("| time: {d}ns, {d}ms\n", .{ elapsed, (@as(f64, @floatFromInt(elapsed)) / 1000000) });
}
