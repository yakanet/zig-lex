const std = @import("std");
const alpha = @import("./alpha.zig");

pub const TokenType = enum {
    EOF,
    ILLEGAL,
    LSQUAREBRACE,
    RSQUAREBRACE,
    LPARENTHESIS,
    RPARENTHESIS,
    IDENTIFIER,
    NUMBER,
    COMMA,
    SEMICOLUMN,
    ADD,
    SUB,
    MUL,
    DIV,
    ASSIGN,
    LET,
    FUNCTION,
};

pub const Token = struct {
    token: TokenType,
    identifier: []const u8 = undefined,
};

fn is_keyword(word: []const u8) ?TokenType {
    if (std.mem.eql(u8, word, "let")) {
        return .LET;
    }
    if (std.mem.eql(u8, word, "fn")) {
        return .FUNCTION;
    }
    return null;
}

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
            '(' => .{ .token = .LPARENTHESIS },
            ')' => .{ .token = .RPARENTHESIS },
            '{' => .{ .token = .LSQUAREBRACE },
            '}' => .{ .token = .RSQUAREBRACE },
            ',' => .{ .token = .COMMA },
            ';' => .{ .token = .SEMICOLUMN },
            '+' => .{ .token = .ADD },
            '-' => .{ .token = .SUB },
            '*' => .{ .token = .MUL },
            '/' => .{ .token = .DIV },
            '=' => .{ .token = .ASSIGN },

            else => blk: {
                if (alpha.is_digit(char)) {
                    return .{ .token = .NUMBER, .identifier = self.parse_number() };
                }
                if (alpha.is_alpha_num(char)) {
                    const identifier = self.parse_identifier();
                    if (is_keyword(identifier)) |keyword| {
                        return .{ .token = keyword, .identifier = identifier };
                    }
                    return .{ .token = .IDENTIFIER, .identifier = identifier };
                }

                break :blk .{ .token = .ILLEGAL, .identifier = &[_]u8{} };
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
        .{ .token = .LPARENTHESIS },
        .{ .token = .RPARENTHESIS },
        .{ .token = .LSQUAREBRACE },
        .{ .token = .RSQUAREBRACE },
        .{ .token = .SEMICOLUMN },
        .{ .token = .COMMA },
        .{ .token = .ADD },
        .{ .token = .SUB },
        .{ .token = .MUL },
        .{ .token = .DIV },
        .{ .token = .ASSIGN },
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
        .{ .token = .LET, .identifier = "let" },
        .{ .token = .IDENTIFIER, .identifier = "test" },
        .{ .token = .ASSIGN },
        .{ .token = .NUMBER, .identifier = "5" },
        .{ .token = .SEMICOLUMN },

        .{ .token = .LET, .identifier = "let" },
        .{ .token = .IDENTIFIER, .identifier = "test2" },
        .{ .token = .ASSIGN },
        .{ .token = .NUMBER, .identifier = "2" },
        .{ .token = .ADD },
        .{ .token = .NUMBER, .identifier = "4" },
        .{ .token = .SEMICOLUMN },

        .{ .token = .FUNCTION, .identifier = "fn" },
        .{ .token = .IDENTIFIER, .identifier = "demo" },
        .{ .token = .LPARENTHESIS },
        .{ .token = .RPARENTHESIS },
        .{ .token = .LSQUAREBRACE },
        .{ .token = .NUMBER, .identifier = "2" },
        .{ .token = .ADD },
        .{ .token = .NUMBER, .identifier = "3" },
        .{ .token = .SEMICOLUMN },
        .{ .token = .RSQUAREBRACE },
    };
    for (tokens) |token| {
        try expectEqualDeep(token, lexer.next_token().?);
    }
}
