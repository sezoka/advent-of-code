const std = @import("std");

pub fn read_input(ally: std.mem.Allocator, comptime name: []const u8) ?[]const u8 {
    return std.fs.cwd().readFileAlloc(ally, "../input/" ++ name, 4096) catch |err| {
        switch (err) {
            error.FileTooBig => std.debug.print("Input file with path ../input/\n" ++ name ++ " is too big", .{}),
            else => std.debug.print("Can't find input file using path ../input/\n" ++ name, .{}),
        }
        return null;
    };
}
