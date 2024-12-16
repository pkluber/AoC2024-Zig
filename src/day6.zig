const std = @import("std");

pub fn main() !void {
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
    while (lines_iter.next()) |line| {
        if (line.len == 0)
            continue;
        try grid_arr.append(@as([]u8, @constCast(line)));
    }

    var start_x: u32 = 0;
    var start_y: u32 = 0;
    const grid: [][]u8 = grid_arr.items;
    var y_idx: u32 = 0;
    while (y_idx < grid.len) : (y_idx += 1) {
        var x_idx: u32 = 0;
        while (x_idx < grid[y_idx].len) : (x_idx += 1) {
            const char = grid[y_idx][x_idx];
            if (char == '^') {
                start_x = x_idx;
                start_y = y_idx;
            }
        }
    }

    // Define new seen array
    const width = grid.len;
    const height = grid[0].len;
    var seen = try allocator.alloc(bool, width * height);
    defer allocator.free(seen);

    // Initialize seen
    var seen_idx: usize = 0;
    while (seen_idx < seen.len) : (seen_idx += 1) {
        seen[seen_idx] = false;
    }

    var total_steps: u32 = 0;
    var next_x: u32 = start_x;
    var next_y: u32 = start_y;
    var current_dir: u32 = 0;
    while (true) {
        // std.debug.print("{},{}\n", .{ next_x, next_y });
        // Check end condition
        if (next_y >= grid.len or next_x >= grid[next_y].len)
            break;

        if (!seen[next_y * width + next_x])
            total_steps += 1;

        seen[next_y * width + next_x] = true;

        const x = switch (current_dir) {
            0, 2 => next_x,
            1 => next_x + 1,
            3 => next_x -% 1,
            else => unreachable,
        };

        const y = switch (current_dir) {
            1, 3 => next_y,
            0 => next_y -% 1,
            2 => next_y + 1,
            else => unreachable,
        };

        // Check if obscruction ahead
        if (y < grid.len and x < grid[y].len) {
            const char = grid[y][x];
            if (char == '#') {
                current_dir += 1;
                current_dir %= 4;
            } else {
                next_x = x;
                next_y = y;
            }
        } else {
            next_x = x;
            next_y = y;
        }
    }

    std.debug.print("Day 6 Part 1 final answer: {}\n", .{total_steps});

    // Define new seen_dir array
    var seen_dir = try allocator.alloc(bool, width * height * 4);
    defer allocator.free(seen_dir);

    // Run with different obstruction positions
    var num_obstruction: u32 = 0;
    var oy: usize = 0;
    while (oy < grid.len) : (oy += 1) {
        var ox: usize = 0;
        while (ox < grid[oy].len) : (ox += 1) {
            if (grid[oy][ox] == '#')
                continue;

            grid[oy][ox] = '#';

            // Reinitialize seen_dir
            var seen_dir_idx: usize = 0;
            while (seen_dir_idx < seen_dir.len) : (seen_dir_idx += 1) {
                seen_dir[seen_dir_idx] = false;
            }

            next_x = start_x;
            next_y = start_y;
            current_dir = 0;
            var found_loop = false;
            while (true) {
                // Check end condition -- no loop
                if (next_y >= grid.len or next_x >= grid[next_y].len)
                    break;

                const idx = 4 * (next_y * width + next_x) + current_dir;

                if (seen_dir[idx]) {
                    found_loop = true;
                    break;
                }

                seen_dir[idx] = true;

                const x = switch (current_dir) {
                    0, 2 => next_x,
                    1 => next_x + 1,
                    3 => next_x -% 1,
                    else => unreachable,
                };

                const y = switch (current_dir) {
                    1, 3 => next_y,
                    0 => next_y -% 1,
                    2 => next_y + 1,
                    else => unreachable,
                };

                // Check if obscruction ahead
                if (y < grid.len and x < grid[y].len) {
                    const char = grid[y][x];
                    if (char == '#') {
                        current_dir += 1;
                        current_dir %= 4;
                    } else {
                        next_x = x;
                        next_y = y;
                    }
                } else {
                    next_x = x;
                    next_y = y;
                }
            }

            if (found_loop)
                num_obstruction += 1;

            grid[oy][ox] = '.';
        }
    }

    std.debug.print("Day 6 Part 2 final answer: {}\n", .{num_obstruction});
}
