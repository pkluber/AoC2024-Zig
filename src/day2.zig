const std = @import("std");

fn abs(comptime T: type, x: T) T {
    return if (x < 0) -x else x; 
}

fn identical(comptime T: type, arr1: std.ArrayList(T), arr2: std.ArrayList(T)) bool {
    var idx: u32 = 0;
    for (arr1.items) |item| {
        if (item != arr2.items[idx])
            return false;
        idx += 1;
    }
    return arr1.items.len == arr2.items.len;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    // Open the file
    var file = try std.fs.cwd().openFile("day2.txt", .{});
    defer file.close();

    // Get the file size
    const file_size = try file.getEndPos();

    // Allocate a buffer to hold the file contents
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    // Read the file contents into the buffer
    _ = try file.readAll(buffer);

    var lists = std.ArrayList(std.ArrayList(i32)).init(allocator);
    defer lists.deinit();

    var lines = std.mem.split(u8, buffer, "\n");
    while (lines.next()) |line| {
        if (line.len == 0)
            continue;
        
        std.debug.print("Line: {s}\n", .{line});

        var columns = std.mem.split(u8, line, " ");
        var list = std.ArrayList(i32).init(allocator);
        while (columns.next()) |part| {
            const num: i32 = std.fmt.parseInt(i32, part, 10) catch -1;

            if (num == -1)
                continue;

            try list.append(num);
        }

        try lists.append(list);
    }

    var numSafe: u32 = 0;
    for (lists.items) |list| {
        var idx: u32 = 0;
        var allIncreasing = true;
        var allDecreasing = true;
        var goodDiffs = true;

        for (list.items) |item| {
            if (idx == list.items.len - 1)
                break;
            
            const item2 = list.items[idx+1];
            const diff = item2 - item;

            if (diff > 0)
                allDecreasing = false;
            if (diff < 0)
                allIncreasing = false;
            
            if (!allDecreasing and !allIncreasing)
                break;

            const absDiff = abs(i32, diff);

            if (absDiff < 1 or absDiff > 3)
            {
                goodDiffs = false;
                break;
            }
            idx += 1;
        }

        if ((allIncreasing or allDecreasing) and goodDiffs)
            numSafe += 1;
    }

    std.debug.print("Part 1 final answer: {}\n", .{numSafe});

    //TODO: make the first number skippable
    var numSafe2: u32 = 0;
    for (lists.items) |list| {
        var idx: u32 = 0;
        var allIncreasing = true;
        var allDecreasing = true;
        var goodDiffs = true;
        var canSkip = true;
        var justSkipped = false;

        for (list.items) |item| {
            if (idx == list.items.len - 1)
                break;
            
            const item1 = if (justSkipped) list.items[idx-1] else item;
            const item2 = list.items[idx+1];
            const diff = item2 - item1;

            if (diff > 0)
            {
                allDecreasing = false;
                if (!allDecreasing and !allIncreasing and canSkip)
                {
                    allDecreasing = true;
                    canSkip = false;
                    idx += 1;
                    justSkipped = true;
                    continue;
                }
            }
            if (diff < 0)
            {
                allIncreasing = false;
                if (!allDecreasing and !allIncreasing and canSkip)
                {
                    allIncreasing = true;
                    canSkip = false;
                    idx += 1;
                    justSkipped = true;
                    continue;
                }
            }
            
            if (!allDecreasing and !allIncreasing and !canSkip)
                break;

            const absDiff = abs(i32, diff);

            if (absDiff < 1 or absDiff > 3)
            {
                goodDiffs = false;
                if (canSkip) {
                    goodDiffs = true;
                    canSkip = false;
                    idx += 1;
                    justSkipped = true;
                    continue;
                }
            }
            idx += 1;
            justSkipped = false;
        }

        if ((allIncreasing or allDecreasing) and goodDiffs)
            numSafe2 += 1;
    }

    std.debug.print("Part 2 final answer: {}\n", .{numSafe2});
}