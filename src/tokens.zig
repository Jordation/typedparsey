const std = @import("std");
const print = std.debug.print;

pub const Token = union(enum) {
    Word: []const u8,
    Integer: i64,
    Float: f64,
    Positional: Positional,

    Score: []const u8,

    BREAK,
    END,
    UNKNOWN,
};

const Positional = struct {
    Position: i64,
    Suffix: []const u8,
};
