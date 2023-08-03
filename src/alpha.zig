pub fn is_digit(value: u8) bool {
    return value >= '0' and value <= '9';
}

pub fn is_alpha(value: u8) bool {
    return (value >= 'a' and value <= 'z') or (value >= 'A' and value <= 'Z') or value == '_';
}

pub fn is_alpha_num(value: u8) bool {
    return is_digit(value) or is_alpha(value);
}

pub fn is_whitespace(value: u8) bool {
    return value == ' ' or value == '\t' or value == '\n' or value == '\r';
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
