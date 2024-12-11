const std = @import("std");

pub fn main() !void 
{
    const allocator = std.heap.page_allocator;

    // Open the file
    var file = try std.fs.cwd().openFile("day6.txt", .{});
    defer file.close();

    // Get the file size
    const file_size = try file.getEndPos();

    // Allocate a buffer to hold the file contents
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    // Read the file contents into the buffer
    _ = try file.readAll(buffer);

    // Data structures
    var grid_arr = std.ArrayList([]u8).init(allocator);
    defer grid_arr.deinit();

    var lines_iter = std.mem.split(u8, buffer, "\n");
    while (lines_iter.next()) |line| 
    {
        if (line.len == 0) 
            continue;
        try grid_arr.append(@as([]u8, @constCast(line)));
    }
    
    var start_x: u32 = 0;
    var start_y: u32 = 0;
    const grid: [][]u8 = grid_arr.items;
    var y_idx: u32 = 0;
    while (y_idx < grid.len) : (y_idx += 1) 
    {
        var x_idx: u32 = 0;
        while (x_idx < grid[y_idx].len) : (x_idx += 1) 
        {
            const char = grid[y_idx][x_idx];
            if (char == '^')
            {
                start_x = x_idx;
                start_y = y_idx;
            }
        }
    }

    var total_steps: u32 = 0;
    var next_x: i32 = start_x;
    var next_y: i32 = start_y;
    var current_dir: u32 = 0;
    while (true) 
    {
        // Check end condition
        if (next_y < 0 or next_y >= grid.len
            or next_x < 0 or next_x >= grid[next_y].len)
            break;

        const dy: i32 = switch (current_dir) 
        {
            0 => -1, 
            1 => 0, 
            2 => 1,
            3 => 0,
            else => unreachable,
        };

        const dx: i32 = switch (current_dir)
        {
            0 => 0,
            1 => 1,
            2 => 0,
            3 => -1,
            else => unreachable,
        };

        const x: i32 = @as(i32, @intCast(next_x)) + dx;
        const y: i32 = @as(i32, @intCast(next_y)) + dy;

        // Check if block ahead
        if (y >= 0 and x >= 0)
        {
            const ux: u32 = @as(u32, @intCast(x));
            const uy: u32 = @as(u32, @intCast(y));
            if (uy < grid.len and x < grid[ux].len)
            {
                const char = grid[uy][ux];
                if (char == '#')
                {
                    current_dir += 1;
                    current_dir %= 4;
                }
            } 
        }

        next_x = x;
        next_y = y;
        total_steps += 1;
    }

    std.debug.print("Day 6 Part 1 final answer: {}\n", .{total_steps});
}