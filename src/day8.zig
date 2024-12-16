const std = @import("std");

const Problem = struct { ans: u64, nums: std.ArrayList(u64) };

fn numDigits(num: u64) u32 {
    var num_digits: u32 = 0;
    var num_left = num;
    while (num_left > 0) {
        num_left = @divTrunc(num_left, 10);
        num_digits += 1;
    }

    return num_digits;
}

fn countAntinodes(antinodes: [][]bool) u32 {
    const height = antinodes.len;
    const width = antinodes[0].len;

    var antinode_count: u32 = 0;

    var y: usize = 0;
    while (y < height) : (y += 1) {
        var x: usize = 0;
        while (x < width) : (x += 1) {
            if (antinodes[y][x]) {
                //std.debug.print("Antinode at {},{}\n", .{ x, y });
                antinode_count += 1;
            }
        }
    }

    return antinode_count;
}

fn computeAntinodes(grid: [][]u8, antinodes: *[][]bool, num_dx: u32) void {
    const height = grid.len;
    const width = grid[0].len;
    var y: usize = 0;
    while (y < height) : (y += 1) {
        var x: usize = 0;
        while (x < width) : (x += 1) {
            const char = grid[y][x];
            if (char == '.' or char == '#')
                continue;

            if (num_dx > 1)
                antinodes.*[y][x] = true;

            // Iterate through grid again to find all matching chars
            var y2: usize = 0;
            while (y2 < height) : (y2 += 1) {
                var x2: usize = 0;
                while (x2 < width) : (x2 += 1) {
                    const char2 = grid[y2][x2];
                    if (char2 != char or x == x2 and y == y2)
                        continue;

                    // Found a matching char, now compute the two possible antinodes
                    const dx = @as(i32, @intCast(x)) - @as(i32, @intCast(x2));
                    const dy = @as(i32, @intCast(y)) - @as(i32, @intCast(y2));

                    var resonance: i32 = 1;
                    while (resonance <= num_dx) : (resonance += 1) {
                        const new_x_raw = @as(i32, @intCast(x)) + resonance * dx;
                        const new_y_raw = @as(i32, @intCast(y)) + resonance * dy;

                        if (new_x_raw >= 0 and new_y_raw >= 0) {
                            const new_x = @as(u32, @intCast(new_x_raw));
                            const new_y = @as(u32, @intCast(new_y_raw));
                            if (new_x < width and new_y < height)
                                antinodes.*[new_y][new_x] = true;
                        }
                    }
                }
            }
        }
    }
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    // Open the file
    var file = try std.fs.cwd().openFile("day8.txt", .{});
    defer file.close();

    // Get the file size
    const file_size = try file.getEndPos();

    // Allocate a buffer to hold the file contents
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    // Read the file contents into the buffer
    _ = try file.readAll(buffer);

    var lines = std.ArrayList([]u8).init(allocator);
    defer lines.deinit();

    var lines_iter = std.mem.split(u8, buffer, "\n");
    while (lines_iter.next()) |line| {
        try lines.append(@constCast(line));
    }

    const grid = lines.items;
    const height = grid.len;
    const width = grid[0].len;

    // Create the memory for the [][]bool of antinodes
    var antinodes: [][]bool = try allocator.alloc([]bool, height);
    defer allocator.free(antinodes);

    for (antinodes) |*row| {
        row.* = try allocator.alloc(bool, width);

        // Initialize the row
        for (row.*) |*item| {
            item.* = false;
        }
    }

    computeAntinodes(grid, &antinodes, 1);

    const antinode_count = countAntinodes(antinodes);

    std.debug.print("Day 8 Part 1 final answer: {}\n", .{antinode_count});

    // Clear antinodes array
    for (antinodes) |*row| {
        for (row.*) |*item| {
            item.* = false;
        }
    }

    computeAntinodes(grid, &antinodes, 100);
    std.debug.print("Day 8 Part 2 final answer: {}\n", .{countAntinodes(antinodes)});
}
