// load file into an array of characters.
// build an array of pointers to each instruction

const std = @import("std");

const Operation = enum(u6) { mov = 0b100010 };
const Mode = enum(u2) { register = 0b11 };

const Instruction = packed struct(u16) {
    w: bool,
    d: bool,
    operation: Operation,
    operand: u3,
    register: u3,
    mode: Mode,
};

pub fn main() !void {
  // create general purpose allocator
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  defer _ = gpa.deinit();
  const allocator = gpa.allocator();
  // get command line arguments and put them into buffer
  const args = try std.process.argsAlloc(allocator);
  // must call argsFree when using argsAlloc
  defer std.process.argsFree(allocator, args);

  // Skip executable
  //the first item in args is the program path itself.
  std.debug.print("File path: {s}\n", .{args[1]});

  // current working directory
  const cwd = std.fs.cwd();
  const file = cwd.openFile(args[1], .{ .mode = .read_only}) catch {
    return;
  };
  defer file.close();

  // get file size
  const file_size = (try file.stat()).size;

  std.debug.print("{d} bytes\n", .{file_size});

  // Read entire file, use file size to determent max buffer size
  const file_content = try file.readToEndAlloc(allocator, file_size);
  defer allocator.free(file_content);

  std.debug.print("{b}\n", .{file_content});

  for (file_content) |entry| {
    std.debug.print("{d}\n", .{entry});
  }
  // const allocator = std.heap.page_allocator;

  // const file_path = "listing_0037_single_register_mov";

  // const content = try readFile(file_path, allocator);
  // defer allocator.free(content);

  // const stdout = std.io.getStdOut().writer();
  // try stdout.print("File Content: {s}", .{content});
    // Allocate a fixed amount of data. We're doing 4 KB. 
    // We use u8 because 1 byte = 8 bits.
    // var buffer: [100]u8 = undefined;
    // // Initialize with a FixedBufferAllocator
    // var fba = std.heap.FixedBufferAllocator.init(&buffer);
    // // Take the allocator pointer so we can allocate some data
    // var allocator = &fba.allocator();
    // // At the end of this method, free the buffer
    // defer allocator.free(buffer);

    // Allocate our 2KB buffer using our fixed amount
    // var memory = try allocator.alloc(8);
    // defer allocator.free(memory);

    // Open the file from the current working directory
    // var file = std.fs.cwd().openFile("file.bin", .{ .mode = .read_only});
    // defer file.close();

    // Read into the buffer. Stops at file end or when buffer is full.
    // Amount of bytes read is returned.
    // var read_bytes = file.readAll(memory);

    // Read the 32-bit floats into an ArrayList. Allocate the ArrayList
    // memory using page allocation. This calls the OS to create 
    // new memory pages when required. This is slower than a 
    // fixed buffer allocated at the beginning of the program. Assume we 
    // know there are 800 32-bit float weights.
    // var weights = 
    //     try std.ArrayList(f32).initCapacity(std.heap.page_allocator, 800);

    // while (true) {
    //     // Provide a slice (like a pointer, setting values to 32-bit float)
    //     const slice = std.mem.bytesAsSlice(f32, memory[..read_bytes]);
    //     // Copy the floats from the buffer to the weights ArrayList.
    //     // Align the slice to 4 bytes (since f32 is 4 bytes each)
    //     weights.appendSliceAssumeCapacity(@alignCast(4, slice));
    //     read_bytes = file.readAll(memory);
    //     if (read_bytes == 0) {
    //         break;
    //     }
    // }

}

fn readFile(file_path: []const u8) ![]u8 {
  // current working directory
  const cwd = std.fs.cwd();
  const handle = cwd.openFile(file_path, .{ .mode = .read_only}) catch {
    return;
  };
  // const file = try std.fs.cwd().openFile(file_path, std.fs.File.OpenFlags.isRead);
  defer handle.close();
  
  //read into buffer
  var buffer: [64]u8 = undefined;
  const bytes_read = handle.readAll(&buffer) catch unreachable;

  // if bytes_read is smaller than buffer.len, then EOF was reached
  try std.testing.expectEqual(@as(usize, 6), bytes_read);

  // const file_size = try file.getEndPos();

  // const buffer = try allocator.alloc(u8, file_size);

  // try file.readAll(buffer);

  return buffer;
}
