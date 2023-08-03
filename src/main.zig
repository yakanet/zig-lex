const std = @import("std");
const alpha = @import("./alpha.zig");
const builtin = @import("builtin");

const Token = union(enum) {
    EOF,
    ILLEGAL,
    LSQUAREBRACE,
    RSQUAREBRACE,
    LPARENTHESIS,
    RPARENTHESIS,
    IDENTIFIER: []const u8,
    NUMBER: []const u8,
    COMMA,
    SEMICOLUMN,
    ADD,
    SUB,
    MUL,
    DIV,
    ASSIGN,
    LET,
    FUNCTION,

    fn is_keyword(word: []const u8) ?Token {
        if (std.mem.eql(u8, word, "let")) {
            return .LET;
        }
        if (std.mem.eql(u8, word, "fn")) {
            return .FUNCTION;
        }
        return null;
    }
};

const Lexer = struct {
    /// Current cursor in input (next item to read)
    read_position: usize,
    /// Current char to read
    char: u8,
    position: usize,
    input: []const u8,

    fn from_input(input: []const u8) Lexer {
        var lexer = Lexer{
            .input = input,
            .char = 0,
            .position = 0,
            .read_position = 0,
        };
        read_char(&lexer);
        return lexer;
    }
};

fn read_char(lexer: *Lexer) void {
    if (lexer.read_position >= lexer.input.len) {
        lexer.char = 0;
    } else {
        lexer.char = lexer.input[lexer.read_position];
    }
    lexer.position = lexer.read_position;
    lexer.read_position += 1;
}

fn parse_identifier(lexer: *Lexer) []const u8 {
    var start = lexer.position;
    while (alpha.is_alpha_num(lexer.char)) {
        read_char(lexer);
    }
    return lexer.input[start..lexer.position];
}

fn parse_number(lexer: *Lexer) []const u8 {
    var start = lexer.position;
    while (alpha.is_digit(lexer.char)) {
        read_char(lexer);
    }
    return lexer.input[start..lexer.position];
}

fn eat_whitespace(lexer: *Lexer) void {
    while (alpha.is_whitespace(lexer.char)) {
        read_char(lexer);
    }
}

fn next_token(lexer: *Lexer) Token {
    eat_whitespace(lexer);
    const char = lexer.char;
    const token: Token = switch (char) {
        0 => .EOF,
        '(' => .LPARENTHESIS,
        ')' => .RPARENTHESIS,
        '{' => .LSQUAREBRACE,
        '}' => .RSQUAREBRACE,
        ',' => .COMMA,
        ';' => .SEMICOLUMN,
        '+' => .ADD,
        '-' => .SUB,
        '*' => .MUL,
        '/' => .DIV,
        '=' => .ASSIGN,

        else => blk: {
            if (alpha.is_digit(char)) {
                return .{ .NUMBER = parse_number(lexer) };
            }
            if (alpha.is_alpha_num(char)) {
                const identifier = parse_identifier(lexer);
                if (Token.is_keyword(identifier)) |keyword| {
                    return keyword;
                }
                return .{ .IDENTIFIER = identifier };
            }

            break :blk .ILLEGAL;
        },
    };
    read_char(lexer);
    return token;
}

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
    std.debug.print("coucou {} {s} {s}\n", .{ a, b, map.get("coucou").? });
}

test "[Lexer] simple chars" {
    const expectEqualDeep = std.testing.expectEqualDeep;
    var lexer = Lexer.from_input("(){};,+-*/=");
    const tokens = [_]Token{
        .LPARENTHESIS,
        .RPARENTHESIS,
        .LSQUAREBRACE,
        .RSQUAREBRACE,
        .SEMICOLUMN,
        .COMMA,
        .ADD,
        .SUB,
        .MUL,
        .DIV,
        .ASSIGN,
        .EOF,
    };

    for (tokens) |token| {
        const actual = next_token(&lexer);
        try expectEqualDeep(token, actual);
    }
}

test "[Lexer] simple code" {
    const expectEqualDeep = std.testing.expectEqualDeep;

    var code =
        \\ let test = 5;
        \\ let test2 = 2 + 4;
        \\
        \\ fn demo() {
        \\   2 + 3;
        \\}
    ;
    var lexer = Lexer.from_input(code);

    var tokens = [_]Token{
        .LET,
        .{ .IDENTIFIER = "test" },
        .ASSIGN,
        .{ .NUMBER = "5" },
        .SEMICOLUMN,

        .LET,
        .{ .IDENTIFIER = "test2" },
        .ASSIGN,
        .{ .NUMBER = "2" },
        .ADD,
        .{ .NUMBER = "4" },
        .SEMICOLUMN,

        .FUNCTION,
        .{ .IDENTIFIER = "demo" },
        .LPARENTHESIS,
        .RPARENTHESIS,
        .LSQUAREBRACE,
        .{ .NUMBER = "2" },
        .ADD,
        .{ .NUMBER = "3" },
        .SEMICOLUMN,
        .RSQUAREBRACE,
        .EOF,
    };
    for (tokens) |token| {
        try expectEqualDeep(token, next_token(&lexer));
    }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);

    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
