const std = @import("std");
const tokens = @import("tokens.zig");
const print = std.debug.print;

const Tokenizer = @This();

buf: []const u8 = undefined,
index: usize = 0,
peek_index: ?usize = 0,
token: ?tokens.Token = null,

pub fn init(data: []const u8) !Tokenizer {
    const p: Tokenizer = .{
        .buf = data,
    };

    return advance(p);
}

pub fn next(t: Tokenizer) Tokenizer {
    return advance(eatWhitespace(t));
}

fn advance(t: Tokenizer) Tokenizer {
    if (t.index >= t.buf.len) {
        return .{};
    }

    switch (t.buf[t.index]) {
        'A'...'Z', 'a'...'z', '\'' => {
            return readWord(t);
        },
        '0'...'9' => {
            return readNumber(t);
        },
        else => {
            return advance(.{
                .buf = t.buf,
                .index = t.index + 1,
                .peek_index = t.peek_index.? + 1,
                .token = t.token,
            });
        },
    }
}

pub fn deinit(t: *Tokenizer) void {
    t.buf = undefined;
    t.peek_index = null;
    t.token = null;
    t.index = 0;
}

fn eatWhitespace(t: Tokenizer) Tokenizer {
    if (t.index >= t.buf.len) {
        return .{};
    }

    switch (t.buf[t.index]) {
        ' ', '\n' => {
            var peek_index: ?usize = null;

            if (t.peek_index.? < t.buf.len) {
                peek_index = t.peek_index.? + 1;
            }

            return eatWhitespace(.{
                .buf = t.buf,
                .index = t.index + 1,
                .peek_index = peek_index,
                .token = t.token,
            });
        },
        else => {
            return t;
        },
    }
}

fn readWord(p: Tokenizer) Tokenizer {
    // the char at the start index is the one which triggered this function
    const start = p.index;
    var i = p.index + 1;

    while (i < p.buf.len) : (i += 1) {
        switch (p.buf[i]) {
            ' ', '\n' => {
                break;
            },
            else => {
                continue;
            },
        }
    }

    const word = p.buf[start..i];

    return .{
        .buf = p.buf,
        .index = i,
        .token = .{ .Word = word },
    };
}

fn readNumber(t: Tokenizer) Tokenizer {
    // the char at the start index is the one which triggered this function
    const start = t.index;
    var i = t.index + 1;

    var has_decimal = false;

    while (i < t.buf.len) : (i += 1) {
        switch (t.buf[i]) {
            '.' => {
                if (has_decimal) {
                    // otherwise we don't capture the previous number read
                    break;
                } else has_decimal = true;
            },
            '0'...'9' => continue,

            else => break,
        }
    }

    if (has_decimal) {
        const float_val = std.fmt.parseFloat(f64, t.buf[start..i]) catch |err| {
            print("Error parsing float: {} : input:'{s}'\n", .{ err, t.buf[start..i] });
            return .{};
        };

        return .{
            .buf = t.buf,
            .index = i,
            .token = .{ .Float = float_val },
            .peek_index = i + 1,
        };
    }

    const parsedInt = std.fmt.parseInt(i64, t.buf[start..i], 10) catch |err| {
        print("Error parsing integer: {} : input:'{s}'\n", .{ err, t.buf[start..i] });
        return .{};
    };

    return .{
        .buf = t.buf,
        .index = i,
        .token = .{ .Integer = parsedInt },
        .peek_index = i + 1,
    };
}
