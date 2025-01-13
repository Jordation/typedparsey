const std = @import("std");
const tokens = @import("tokens.zig");

const Parser = @This();

tokens: []tokens.Token = undefined,

pub fn init(tokens: []tokens.Token) Parser {
    return .{
        .tokens = tokens,
    };
}
