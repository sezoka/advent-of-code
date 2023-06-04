const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
const stdout_writer = std.io.getStdOut().writer();

var start_time: i128 = 0;
var solution_start_time: i128 = 0;

var current_file_name: []const u8 = undefined;

pub fn start() void {
    start_time = std.time.milliTimestamp();
}

pub fn finish() void {
    const finish_time = std.time.milliTimestamp();
    const elapsed = finish_time - start_time;
    stdout_writer.print("Total runtime: {d}ms\n", .{elapsed}) catch {};
    _ = gpa.deinit();
}

fn part(n: u8, comptime format: []const u8, data: anytype) void {
    const elapsed = std.time.milliTimestamp() - solution_start_time;
    stdout_writer.print("{s} (part {}): ", .{ current_file_name, n }) catch {};
    stdout_writer.print(format, .{data}) catch {};
    stdout_writer.print(". runtime: {d}ms\n", .{elapsed}) catch {};
    solution_start_time = std.time.milliTimestamp();
}

pub fn part_1(comptime format: []const u8, data: anytype) void {
    part(1, format, data);
}

pub fn part_2(comptime format: []const u8, data: anytype) void {
    part(2, format, data);
    stdout_writer.writeByte('\n') catch {};
}

pub fn run_solution(comptime file_name: []const u8, comptime solution: fn (std.mem.Allocator, []const u8) void) void {
    current_file_name = file_name;
    const path = "./input/" ++ file_name;
    const input = std.fs.cwd().readFileAlloc(allocator, path, 102400) catch |err| {
        std.debug.print("Can't read a file with path '{s}', reason: '{}'\n", .{ path, err });
        return;
    };
    solution_start_time = std.time.milliTimestamp();
    solution(allocator, input);
    allocator.free(input);
}
