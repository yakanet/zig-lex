const std = @import("std");
const alpha = @import("./alpha.zig");
const builtin = @import("builtin");
const Lexer = @import("./lexer.zig").Lexer;
const Token = @import("./lexer.zig").Token;

pub fn main() !void {
    // std lib
    std.log.debug("OS = {}", .{builtin.target.os.tag});
    std.log.debug("Builtin = {}", .{builtin.target.os.getVersionRange()});
    std.log.debug("Time = {}", .{std.time.milliTimestamp()});

    // HashMap + heap
    var map = std.StringHashMap([]const u8).init(std.heap.page_allocator);
    defer map.deinit();
    try map.put("coucou", "world");
    std.log.debug("{any}\n", .{map});

    // Variables
    const a = 32;
    var b = "coucou";
    std.debug.print(">> {} {s} {s}\n", .{ a, b, map.get("coucou").? });

    // Lexer
    var lexer = Lexer.from_input(
        \\ let test = 5;
        \\ let test2 = 2 + 4;
        \\
        \\ fn demo() {
        \\   2 + 3;
        \\}
    );
    while (lexer.next_token()) |token| {
        std.log.info("{any}", .{token});
    }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);

    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
