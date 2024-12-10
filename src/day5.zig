const std = @import("std");

fn containsValue(list: std.ArrayList(u32), value: u32) bool
{
    for (list.items) |item| 
    {
        if (item == value)
            return true;
    }
    return false;
}

pub fn main() !void 
{
    const allocator = std.heap.page_allocator;

    // Open the file
    var file = try std.fs.cwd().openFile("day5.txt", .{});
    defer file.close();

    // Get the file size
    const file_size = try file.getEndPos();

    // Allocate a buffer to hold the file contents
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    // Read the file contents into the buffer
    _ = try file.readAll(buffer);

    // Data structures
    var rule_map = std.AutoHashMap(u32, std.ArrayList(u32)).init(allocator);
    defer rule_map.deinit();
    
    var updates = std.ArrayList(std.ArrayList(u32)).init(allocator);
    defer updates.deinit();

    var rule_mode = true;
    var lines_iter = std.mem.split(u8, buffer, "\n");
    while (lines_iter.next()) |line| 
    {
        if (line.len == 0) 
        {
            rule_mode = false;
            continue;
        }

        if (rule_mode) 
        {
            const num1 = try std.fmt.parseInt(u32, line[0..2], 10);
            const num2 = try std.fmt.parseInt(u32, line[3..5], 10);
            
            if (rule_map.get(num1)) |pages| 
            {
                var pages_mut = pages;
                try pages_mut.append(num2);
                try rule_map.put(num1, pages_mut);
            }
            else
            {
                var pages = std.ArrayList(u32).init(allocator);
                try pages.append(num2);
                try rule_map.put(num1, pages);
            }            
        } 
        else 
        {
            var split_iter = std.mem.split(u8, line, ",");
            var update = std.ArrayList(u32).init(allocator);
            while (split_iter.next()) |num| {
                try update.append(try std.fmt.parseInt(u32, num, 10));
            }
            try updates.append(update);
        }

        //std.debug.print("Line: {s} {}\n", .{line, rule_mode});
    }

    var pageSum: u32 = 0;
    for (updates.items) |update| 
    {
        var correctly_sorted = true;
        var idx1: u32 = 0;
        while (idx1 < update.items.len) : (idx1 += 1)
        {
            const page1 = update.items[idx1];
            var idx2 = idx1 + 1;
            while (idx2 < update.items.len) : (idx2 += 1)
            {
                // Check for a rule violation, so get in reverse
                const page2 = update.items[idx2];
                if (rule_map.get(page2)) |pages|
                {
                    if (containsValue(pages, page1))
                        correctly_sorted = false;
                }
            }
        }

        if (correctly_sorted)
            pageSum += update.items[update.items.len / 2];
    }

    std.debug.print("Day 5 Part 1 final answer: {}\n", .{pageSum});
}