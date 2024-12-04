const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    // Open the file
    var file = try std.fs.cwd().openFile("day1.txt", .{});
    defer file.close();

    // Get the file size
    const file_size = try file.getEndPos();

    // Allocate a buffer to hold the file contents
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    // Read the file contents into the buffer
    _ = try file.readAll(buffer);

    // Print the contents as a string
    try std.io.getStdOut().writer().print("{s}\n", .{buffer});

    var col1 = std.ArrayList(i32).init(allocator);
    var col2 = std.ArrayList(i32).init(allocator);
    defer col1.deinit();
    defer col2.deinit();

    var lines = std.mem.split(u8, buffer, "\n");
    while (lines.next()) |line| {
        std.debug.print("Line: {s}\n", .{line});

        var columns = std.mem.split(u8, line, "   ");
        var i: u16 = 0;
        while (columns.next()) |part| : (i += 1) {
            std.debug.print("Column {}:", .{i});
            std.debug.print("{s}\n", .{part});
            
            const num: i32 = std.fmt.parseInt(i32, part, 10) catch -1;

            if (num == -1)
                continue;

            if (i == 0) {
                try col1.append(num);
            } else {
                try col2.append(num);
            }
        }
    }

    for (col1.items) |item| {
        std.debug.print("Item: {}\n", .{item});
    }

    std.mem.sort(i32, col1.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, col2.items, {}, comptime std.sort.asc(i32));
    
    var idx: u32 = 0;
    var total: i32 = 0;
    for (col1.items) |item1| {
        const item2 = col2.items[idx];
        const diff = item1 - item2;
        total += if (diff < 0) -diff else diff;
        idx += 1;
    }

    std.debug.print("Final answer: {}\n", .{total});
}