const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    // Open the file
    var file = try std.fs.cwd().openFile("day9.txt", .{});
    defer file.close();

    // Get the file size
    const file_size = try file.getEndPos();

    // Allocate a buffer to hold the file contents
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    // Read the file contents into the buffer
    _ = try file.readAll(buffer);

    // Data structures
    var file_system = std.ArrayList(?u32).init(allocator);
    defer file_system.deinit();

    var idx: u32 = 0;
    var empty_spaces: u32 = 0;
    var is_file = true;
    var file_id: u32 = 0;
    while (idx < buffer.len) : (idx += 1) {
        const char = buffer[idx];
        if (char < '0' or char > '9')
            continue;

        const num = char - '0';

        var idx2: u32 = 0;
        while (idx2 < num) : (idx2 += 1) {
            try file_system.append(if (is_file) file_id else null);

            if (!is_file)
                empty_spaces += 1;
        }

        if (is_file)
            file_id += 1;

        is_file = !is_file;
    }

    var curr_idx: u32 = 0;
    var tail_idx: usize = file_system.items.len - 1;
    while (empty_spaces > 0 and tail_idx > curr_idx) : (tail_idx -= 1) {
        const ffile = file_system.items[tail_idx];
        if (ffile) |file_no| {
            // Find the next spot to insert
            var insert_file: ?u32 = file_system.items[curr_idx];
            while (insert_file != null and curr_idx < file_system.items.len - 1) : (curr_idx += 1) {
                insert_file = file_system.items[curr_idx];
            }

            if (curr_idx < file_system.items.len)
                file_system.items[curr_idx] = file_no;

            empty_spaces -= 1;
        }
    }

    var checksum: u64 = 0;
    var c_idx: u32 = 0;
    while (c_idx < file_system.items.len) : (c_idx += 1) {
        if (file_system.items[c_idx]) |file_no|
            checksum += c_idx * file_no;
    }

    std.debug.print("Day 9 Part 1 final answer: {}\n", .{checksum});
}
