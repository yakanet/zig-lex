pub fn is_digit(value: u8) bool {
    return switch (value) {
        '0'...'9' => true,
        else => false,
    };
}

pub fn is_alpha(value: u8) bool {
    return switch (value) {
        'a'...'z' => true,
        'A'...'Z' => true,
        '_' => true,
        else => false,
    };
}

pub fn is_alpha_num(value: u8) bool {
    return is_digit(value) or is_alpha(value);
}

const whitespace = [_]u8{ ' ', '\t', '\n', '\r' };

pub fn is_whitespace(value: u8) bool {
    return inline for (whitespace) |w| {
        if (value == w)
            break true;
    } else false;
}

const assert = @import("std").testing;
test "Is digit" {
    try assert.expect(is_digit('0'));
    try assert.expect(is_digit('1'));
    try assert.expect(is_digit('9'));
    try assert.expect(!is_digit('a'));
}

test "Is alpha" {
    try assert.expect(is_alpha('a'));
    try assert.expect(is_alpha('_'));
    try assert.expect(is_alpha('z'));
    try assert.expect(!is_alpha('2'));
}

test "Is whitespace" {
    try assert.expect(is_whitespace(' '));
    try assert.expect(is_whitespace('\t'));
    try assert.expect(is_whitespace('\r'));
    try assert.expect(!is_whitespace('a'));
}
