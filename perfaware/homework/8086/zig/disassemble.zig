const std = @import("std");

const OpCode = enum(u6) { move = 0b100010, unknown };
const Mode = enum(u2) {
    mem = 0b00,
    mem_disp8 = 0b01,
    mem_disp16 = 0b10,
    register = 0b11,
};

const REG_byte = enum(u3) { al = 0b000, cl = 0b001, dl = 0b010, bl = 0b011, ah = 0b100, ch = 0b101, dh = 0b110, bh = 0b111 };
const REG_word = enum(u3) { ax = 0b000, cx = 0b001, dx = 0b010, bx = 0b011, sp = 0b100, bp = 0b101, si = 0b110, di = 0b111 };
const Word = enum(u1) { byte = 0b0, word = 0b1 };
const Instruction = packed struct(u16) {
    W: Word,
    D: enum(u1) { to = 0b0, from = 0b1 },
    OpCode: OpCode,
    RM: u3,
    Reg: u3,
    Mode: Mode,
};

const ContainsIterator = struct {
    strings: []const []const u8,
    needle: []const u8,
    index: usize = 0,
    fn next(self: *ContainsIterator) ?[]const u8 {
        const index = self.index;
        for (self.strings[index..]) |string| {
            self.index += 1;
            if (std.mem.indexOf(u8, string, self.needle)) |_| {
                return string;
            }
        }
        return null;
    }
};

pub fn main() !void {
    var args = std.process.args();
    _ = args.next();
    const filename = args.next() orelse {
        std.debug.print("usage: <zig-file> -- <filename>\n", .{});
        return;
    };
    // std.debug.print("{s}", .{filename});
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();
    
    // const filenameAsString: []const u8 = filename;

    // std.debug.print("{s}\n", .{filename});
 
    var filepath = std.mem.splitScalar(u8, filename, '/');
    std.debug.print("{s}\n", .{filepath.next()});
    // while (filepath.next()) |element| {
    //   std.debug.print("{s}\n", .{element});
    // }

    // _ = filepath.next();
    // std.debug.print("{any}\n", .{filepath.next()});

    // const name = 

    const newAsmFile = try std.fs.cwd().createFile(
      "test2.asm",
      .{ .read = true }
    );
    defer newAsmFile.close();

    const reader = file.reader();

    const stdout_file = std.io.getStdOut().writer();
    var buf_writer = std.io.bufferedWriter(stdout_file);
    const writer = buf_writer.writer();
    _ = try writer.print("; {s}\n\n", .{filename}); // comment w/ filename
    _ = try writer.print("bits 16\n\n", .{});
    _ = try newAsmFile.write("bits 16\n\n");

    while (reader.readStruct(Instruction)) |instruction| {
        _ = try writer.write(switch (instruction.OpCode) {
            .move => "mov ",
            else => unreachable,
        });
        _ = try newAsmFile.write(switch (instruction.OpCode) {
            .move => "mov ",
            else => unreachable,
        });
        _ = try writer.write(" ");
        _ = try newAsmFile.write(" ");
        _ = try writer.write(regAddr(instruction.W, instruction.Reg));
        _ = try newAsmFile.write(regAddr(instruction.W, instruction.Reg));
        _ = try writer.write(", ");
        _ = try newAsmFile.write(", ");
        _ = try writer.write(regRM(instruction.Mode, instruction.W, instruction.RM));
        _ = try newAsmFile.write(regRM(instruction.Mode, instruction.W, instruction.RM));
        _ = try writer.write("\n");
        _ = try newAsmFile.write("\n");
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => std.debug.print("Error reading instruction: {}\n", .{err}),
    }
    try buf_writer.flush();
}

fn regRM(mode: Mode, w: Word, address: u3) []const u8 {
    return switch (mode) {
        .register => regAddr(w, address),
        else => unreachable,
    };
}

fn regAddr(w: Word, address: u3) []const u8 {
    return switch (w) {
        .byte => switch (@as(REG_byte, @enumFromInt(address))) {
            inline else => |variant| @tagName(variant),
        },
        .word => switch (@as(REG_word, @enumFromInt(address))) {
            inline else => |variant| @tagName(variant),
        },
    };
}
