const std = @import("std");
const print = std.debug.print;
const Tokenizer = @import("tokenizer.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const reader = std.io.getStdIn().reader();

    while (true) {
        const input = try reader.readUntilDelimiterAlloc(allocator, '\n', 1024);
        defer allocator.free(input);
        if (std.mem.eql(u8, input[0..4], "exit")) {
            break;
        }

        var tokenizer = try Tokenizer.init(input);
        while (tokenizer.token) |tok| : (tokenizer = tokenizer.next()) {
            switch (tok) {
                .Word => {
                    print("{s}\n", .{tok.Word});
                },
                .Integer => {
                    print("{d}\n", .{tok.Integer});
                },
                .Float => {
                    print("{d}\n", .{tok.Float});
                },
                .Positional => {
                    print("{d}:{s}\n", .{ tok.Positional.Position, tok.Positional.Suffix });
                },
                else => {
                    print("{}\n", .{tok});
                },
            }
        }
    }
}
