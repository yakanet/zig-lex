const std = @import("std");
const alpha = @import("./alpha.zig");

pub const Token = union(enum) {
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

pub const Lexer = struct {
    /// Current cursor in input (next item to read)
    read_position: usize,
    /// Current char to read
    char: u8,
    position: usize,
    input: []const u8,

    pub fn from_input(input: []const u8) Lexer {
        var lexer = Lexer{
            .input = input,
            .char = 0,
            .position = 0,
            .read_position = 0,
        };
        lexer.read_char();
        return lexer;
    }

    fn read_char(self: *Lexer) void {
        if (self.read_position >= self.input.len) {
            self.char = 0;
        } else {
            self.char = self.input[self.read_position];
        }
        self.position = self.read_position;
        self.read_position += 1;
    }

    fn parse_identifier(self: *Lexer) []const u8 {
        var start = self.position;
        while (alpha.is_alpha_num(self.char)) {
            self.read_char();
        }
        return self.input[start..self.position];
    }

    fn parse_number(self: *Lexer) []const u8 {
        var start = self.position;
        while (alpha.is_digit(self.char)) {
            self.read_char();
        }
        return self.input[start..self.position];
    }

    fn eat_whitespace(self: *Lexer) void {
        while (alpha.is_whitespace(self.char)) {
            self.read_char();
        }
    }

    pub fn next_token(self: *Lexer) ?Token {
        self.eat_whitespace();
        const char = self.char;
        const token: Token = switch (char) {
            0 => return null,
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
                    return .{ .NUMBER = self.parse_number() };
                }
                if (alpha.is_alpha_num(char)) {
                    const identifier = self.parse_identifier();
                    if (Token.is_keyword(identifier)) |keyword| {
                        return keyword;
                    }
                    return .{ .IDENTIFIER = identifier };
                }

                break :blk .ILLEGAL;
            },
        };
        self.read_char();
        return token;
    }
};

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
    };

    for (tokens) |token| {
        const actual = lexer.next_token().?;
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
    };
    for (tokens) |token| {
        try expectEqualDeep(token, lexer.next_token().?);
    }
}
