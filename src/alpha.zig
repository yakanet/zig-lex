const assert = @import("std").testing;

/// Return true if the value is between '0' and '9'
pub fn is_digit(value: u8) bool {
    return switch (value) {
        '0'...'9' => true,
        else => false,
    };
}

test "is_digit" {
    try assert.expect(is_digit('0'));
    try assert.expect(is_digit('1'));
    try assert.expect(is_digit('9'));
    try assert.expect(!is_digit('a'));
}

/// Return true if the value is between 'a' and 'z' (lower, upper) or is a '_'
pub fn is_alpha(value: u8) bool {
    return switch (value) {
        'a'...'z' => true,
        'A'...'Z' => true,
        '_' => true,
        else => false,
    };
}

test "is_alpha" {
    try assert.expect(is_alpha('a'));
    try assert.expect(is_alpha('_'));
    try assert.expect(is_alpha('z'));
    try assert.expect(!is_alpha('2'));
}

pub fn is_alpha_num(value: u8) bool {
    return is_digit(value) or is_alpha(value);
}

/// List of whitespace characters
const whitespace = [_]u8{ ' ', '\t', '\n', '\r' };

/// Return true if the value is a whitespace character
pub fn is_whitespace(value: u8) bool {
    return inline for (whitespace) |w| {
        if (value == w)
            break true;
    } else false;
}

test "is_whitespace" {
    try assert.expect(is_whitespace(' '));
    try assert.expect(is_whitespace('\t'));
    try assert.expect(is_whitespace('\r'));
    try assert.expect(!is_whitespace('a'));
}
