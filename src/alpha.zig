const assert = @import("std").testing;

/// Return true if the value is between '0' and '9'
pub fn isDigit(value: u8) bool {
    return switch (value) {
        '0'...'9' => true,
        else => false,
    };
}

test "isDigit" {
    try assert.expect(isDigit('0'));
    try assert.expect(isDigit('1'));
    try assert.expect(isDigit('9'));
    try assert.expect(!isDigit('a'));
}

/// Return true if the value is between 'a' and 'z' (lower, upper) or is a '_'
pub fn isAlpha(value: u8) bool {
    return switch (value) {
        'a'...'z' => true,
        'A'...'Z' => true,
        '_' => true,
        else => false,
    };
}

test "isAlpha" {
    try assert.expect(isAlpha('a'));
    try assert.expect(isAlpha('_'));
    try assert.expect(isAlpha('z'));
    try assert.expect(!isAlpha('2'));
}

pub fn isAlphaNum(value: u8) bool {
    return isDigit(value) or isAlpha(value);
}

/// List of whitespace characters
const whitespace = [_]u8{ ' ', '\t', '\n', '\r' };

/// Return true if the value is a whitespace character
pub fn isWhitespace(value: u8) bool {
    return inline for (whitespace) |w| {
        if (value == w)
            break true;
    } else false;
}

test "isWhitespace" {
    try assert.expect(isWhitespace(' '));
    try assert.expect(isWhitespace('\t'));
    try assert.expect(isWhitespace('\r'));
    try assert.expect(!isWhitespace('a'));
}
