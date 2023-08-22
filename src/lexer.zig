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
    identifier: []const u8,
};

fn isKeyword(word: []const u8) ?TokenType {
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

    pub fn fromInput(input: []const u8) Lexer {
        var lexer = Lexer{
            .input = input,
            .char = 0,
            .position = 0,
            .read_position = 0,
        };
        lexer.readChar();
        return lexer;
    }

    fn readChar(self: *Lexer) void {
        if (self.read_position >= self.input.len) {
            self.char = 0;
        } else {
            self.char = self.input[self.read_position];
        }
        self.position = self.read_position;
        self.read_position += 1;
    }

    fn parseIdentifier(self: *Lexer) []const u8 {
        var start = self.position;
        while (alpha.isAlphaNum(self.char)) {
            self.readChar();
        }
        return self.input[start..self.position];
    }

    fn parseNumber(self: *Lexer) []const u8 {
        var start = self.position;
        while (alpha.isDigit(self.char)) {
            self.readChar();
        }
        return self.input[start..self.position];
    }

    fn eatWhitespace(self: *Lexer) void {
        while (alpha.isWhitespace(self.char)) {
            self.readChar();
        }
    }

    pub fn nextToken(self: *Lexer) ?Token {
        self.eatWhitespace();
        const char = self.char;
        const token: Token = switch (char) {
            0 => return null,
            '(' => .{ .token = .LPARENTHESIS, .identifier = "(" },
            ')' => .{ .token = .RPARENTHESIS, .identifier = ")" },
            '{' => .{ .token = .LSQUAREBRACE, .identifier = "{" },
            '}' => .{ .token = .RSQUAREBRACE, .identifier = "}" },
            ',' => .{ .token = .COMMA, .identifier = "," },
            ';' => .{ .token = .SEMICOLUMN, .identifier = ";" },
            '+' => .{ .token = .ADD, .identifier = "+" },
            '-' => .{ .token = .SUB, .identifier = "-" },
            '*' => .{ .token = .MUL, .identifier = "*" },
            '/' => .{ .token = .DIV, .identifier = "/" },
            '=' => .{ .token = .ASSIGN, .identifier = "=" },

            else => blk: {
                if (alpha.isDigit(char)) {
                    return .{ .token = .NUMBER, .identifier = self.parseNumber() };
                }
                if (alpha.isAlphaNum(char)) {
                    const identifier = self.parseIdentifier();
                    if (isKeyword(identifier)) |keyword| {
                        return .{ .token = keyword, .identifier = identifier };
                    }
                    return .{ .token = .IDENTIFIER, .identifier = identifier };
                }

                break :blk .{ .token = .ILLEGAL, .identifier = &[_]u8{} };
            },
        };
        self.readChar();
        return token;
    }
};

test "[Lexer] simple chars" {
    const expectEqualDeep = std.testing.expectEqualDeep;
    var lexer = Lexer.fromInput("(){};,+-*/=");
    const tokens = [_]Token{
        .{ .token = .LPARENTHESIS, .identifier = "(" },
        .{ .token = .RPARENTHESIS, .identifier = ")" },
        .{ .token = .LSQUAREBRACE, .identifier = "{" },
        .{ .token = .RSQUAREBRACE, .identifier = "}" },
        .{ .token = .SEMICOLUMN, .identifier = ";" },
        .{ .token = .COMMA, .identifier = "," },
        .{ .token = .ADD, .identifier = "+" },
        .{ .token = .SUB, .identifier = "-" },
        .{ .token = .MUL, .identifier = "*" },
        .{ .token = .DIV, .identifier = "/" },
        .{ .token = .ASSIGN, .identifier = "=" },
    };

    for (tokens) |token| {
        const actual = lexer.nextToken().?;
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
    var lexer = Lexer.fromInput(code);

    var tokens = [_]Token{
        .{ .token = .LET, .identifier = "let" },
        .{ .token = .IDENTIFIER, .identifier = "test" },
        .{ .token = .ASSIGN, .identifier = "=" },
        .{ .token = .NUMBER, .identifier = "5" },
        .{ .token = .SEMICOLUMN, .identifier = ";" },

        .{ .token = .LET, .identifier = "let" },
        .{ .token = .IDENTIFIER, .identifier = "test2" },
        .{ .token = .ASSIGN, .identifier = "=" },
        .{ .token = .NUMBER, .identifier = "2" },
        .{ .token = .ADD, .identifier = "+" },
        .{ .token = .NUMBER, .identifier = "4" },
        .{ .token = .SEMICOLUMN, .identifier = ";" },

        .{ .token = .FUNCTION, .identifier = "fn" },
        .{ .token = .IDENTIFIER, .identifier = "demo" },
        .{ .token = .LPARENTHESIS, .identifier = "(" },
        .{ .token = .RPARENTHESIS, .identifier = ")" },
        .{ .token = .LSQUAREBRACE, .identifier = "{" },
        .{ .token = .NUMBER, .identifier = "2" },
        .{ .token = .ADD, .identifier = "+" },
        .{ .token = .NUMBER, .identifier = "3" },
        .{ .token = .SEMICOLUMN, .identifier = ";" },
        .{ .token = .RSQUAREBRACE, .identifier = "}" },
    };
    _ = std.log.defaultLogEnabled(std.log.Level.debug);
    for (tokens) |token| {
        std.log.debug("{}\n", .{token});
        try expectEqualDeep(token, lexer.nextToken().?);
    }
}
