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

fn isSafe(list: std.ArrayList(i32)) bool {
    var idx: u32 = 0;
    var allIncreasing = true;
    var allDecreasing = true;
    var goodDiffs = true;

    for (list.items) |item| {
        if (idx == list.items.len - 1)
            break;

        const item2 = list.items[idx + 1];
        const diff = item2 - item;

        if (diff > 0)
            allDecreasing = false;
        if (diff < 0)
            allIncreasing = false;

        if (!allDecreasing and !allIncreasing)
            break;

        const absDiff = abs(i32, diff);

        if (absDiff < 1 or absDiff > 3) {
            goodDiffs = false;
            break;
        }
        idx += 1;
    }

    return (allIncreasing or allDecreasing) and goodDiffs;
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

        //std.debug.print("Line: {s}\n", .{line});

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
        if (isSafe(list))
            numSafe += 1;
    }

    std.debug.print("Day 2 Part 1 final answer: {}\n", .{numSafe});

    var numSafe2: u32 = 0;
    outer: for (lists.items) |list| {
        var idx: u32 = 0;
        var slice = try allocator.alloc(i32, list.items.len - 1);
        while (idx < list.items.len) : (idx += 1) {
            std.mem.copyForwards(i32, slice[0..idx], list.items[0..idx]);
            std.mem.copyForwards(i32, slice[idx..], list.items[idx + 1 ..]);
            var array_list = std.ArrayList(i32).init(allocator);
            defer array_list.deinit();

            for (@as([]i32, slice)) |item| {
                try array_list.append(item);
            }

            if (isSafe(array_list)) {
                numSafe2 += 1;
                continue :outer;
            }
        }
    }

    std.debug.print("Day 2 Part 2 final answer: {}\n", .{numSafe2});
}
