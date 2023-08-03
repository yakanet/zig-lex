pub fn isDigit(value: u8) bool {
    return value >= '0' and value <= '9';
}

pub fn isAlpha(value: u8) bool {
    return (value >= 'a' and value <= 'z') or (value >= 'A' and value <= 'Z') or value == '_';
}

pub fn isAlphaNum(value: u8) bool {
    return isDigit(value) or isAlpha(value);
}

pub fn isWhitespace(value: u8) bool {
    return value == ' ' or value == '\t' or value == '\n' or value == '\r';
}
