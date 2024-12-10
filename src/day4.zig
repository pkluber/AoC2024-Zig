const std = @import("std");

fn safeGet(arr: []u8, idx: u32) u8 {
    if (idx < 0 or idx >= arr.len)
        return 0;
    
    return arr[idx];
}

fn countChar(arr: []u8, char: u8) u32 {
    var count: u32 = 0;
    for (arr) |item| {
        if (item == char)
            count += 1;
    }

    return count;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    // Open the file
    var file = try std.fs.cwd().openFile("day4.txt", .{});
    defer file.close();

    // Get the file size
    const file_size = try file.getEndPos();

    // Allocate a buffer to hold the file contents
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    // Read the file contents into the buffer
    _ = try file.readAll(buffer);

    const line_count = countChar(buffer, '\n');
    std.debug.print("{} lines\n", .{line_count});
}