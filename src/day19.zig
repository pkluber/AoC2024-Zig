const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // Open the file
    var file = try std.fs.cwd().openFile("day19.txt", .{});
    defer file.close();

    // Get the file size
    const file_size = try file.getEndPos();

    // Allocate a buffer to hold the file contents
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    // Read the file contents into the buffer
    _ = try file.readAll(buffer);

    var lines_iter = std.mem.split(u8, buffer, "\n");

    const words_raw = lines_iter.next().?;
    var words_iter = std.mem.split(u8, words_raw, ", ");
    var words = std.ArrayList([]const u8).init(allocator);
    defer words.deinit();
    while (words_iter.next()) |word| {
        try words.append(word);
    }

    _ = lines_iter.next().?;

    var patterns = std.ArrayList([]const u8).init(allocator);
    defer patterns.deinit();
    while (lines_iter.next()) |pattern| {
        try patterns.append(pattern);
    }

    // Now the algorithm
    var num_possible: u32 = 0;

    var stack = std.ArrayList([]u8).init(allocator);
    defer stack.deinit();
    for (patterns.items) |pattern| {
        defer stack.clearAndFree();
        try stack.append(@constCast(pattern));

        var found_soln = false;

        while (stack.items.len > 0) {
            std.debug.print("{}\n", .{stack.items.len});
            const subpattern = stack.pop();

            if (subpattern.len == 0) {
                found_soln = true;
                break;
            }

            for (words.items) |word| {
                if (std.mem.startsWith(u8, subpattern, word)) {
                    try stack.append(subpattern[word.len..]);
                }
            }
        }

        if (found_soln)
            num_possible += 1;
    }

    std.debug.print("Day 19 Part 1 final answer: {}\n", .{num_possible});
}
