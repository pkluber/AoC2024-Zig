const std = @import("std");

fn safeGet(comptime T: type, arr: []const T, idx: u32) ?T {
    if (idx < 0 or idx >= arr.len)
        return null;

    return arr[idx];
}

fn checkXmas(comptime word: []const u8, arr: [][]const u8, line_idx: u32, char_idx: u32, dx: i32, dy: i32) bool {
    const xmas = word;
    var idx: u32 = 0;
    var is_xmas = true;
    while (idx < xmas.len) : (idx += 1) {
        const raw_y = @as(i32, @intCast(line_idx)) + @as(i32, @intCast(idx)) * dy;
        const raw_x = @as(i32, @intCast(char_idx)) + @as(i32, @intCast(idx)) * dx;

        if (raw_y < 0 or raw_x < 0) {
            is_xmas = false;
            break;
        }

        const y = @as(u32, @intCast(raw_y));
        const x = @as(u32, @intCast(raw_x));

        if (safeGet([]const u8, arr, y)) |line| {
            if (safeGet(u8, line, x)) |char| {
                if (char != xmas[idx]) {
                    is_xmas = false;
                    break;
                }
            } else {
                is_xmas = false;
                break;
            }
        } else {
            is_xmas = false;
            break;
        }
    }

    return is_xmas;
}

fn checkXMas(arr: [][]const u8, line_idx: u32, char_idx: u32) bool {
    if (safeGet([]const u8, arr, line_idx)) |line| {
        if (safeGet(u8, line, char_idx)) |char| {
            if (char == 'A') {
                // Now check the four corners
                var dx_m1: i32 = 0;
                var dy_m1: i32 = 0;
                var dx_m2: i32 = 0;
                var dy_m2: i32 = 0;
                var count_m: u32 = 0;
                var count_s: u32 = 0;
                var dx: i32 = -1;
                while (dx <= 1) : (dx += 2) {
                    var dy: i32 = -1;
                    while (dy <= 1) : (dy += 2) {
                        const raw_y = @as(i32, @intCast(line_idx)) + dy;
                        const raw_x = @as(i32, @intCast(char_idx)) + dx;

                        if (raw_x < 0 or raw_y < 0)
                            continue;

                        const y = @as(u32, @intCast(raw_y));
                        const x = @as(u32, @intCast(raw_x));

                        if (safeGet([]const u8, arr, y)) |subline| {
                            if (safeGet(u8, subline, x)) |subchar| {
                                if (subchar == 'M') {
                                    count_m += 1;
                                    if (dx_m1 == 0) {
                                        dx_m1 = dx;
                                        dy_m1 = dy;
                                    } else {
                                        dx_m2 = dx;
                                        dy_m2 = dy;
                                    }
                                }

                                if (subchar == 'S')
                                    count_s += 1;
                            }
                        }
                    }
                }

                if (count_m == 2 and count_s == 2 and !(dx_m1 != dx_m2 and dy_m1 != dy_m2))
                    return true;
            }
        }
    }
    return false;
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

    var lines = std.ArrayList([]const u8).init(allocator);
    defer lines.deinit();

    var lines_iter = std.mem.split(u8, buffer, "\n");
    while (lines_iter.next()) |line| {
        if (line.len == 0)
            continue;

        // std.debug.print("Line: {s}\n", .{line});
        try lines.append(line);
    }

    var xmas_count: u32 = 0;
    var line_idx: u32 = 0;
    while (line_idx < lines.items.len) : (line_idx += 1) {
        const line = lines.items[line_idx];
        var char_idx: u32 = 0;
        while (char_idx < line.len) : (char_idx += 1) {
            var dx: i32 = -1;
            while (dx <= 1) : (dx += 1) {
                var dy: i32 = -1;
                while (dy <= 1) : (dy += 1) {
                    if (dx == 0 and dy == 0)
                        continue;

                    const is_xmas = checkXmas("XMAS", lines.items, line_idx, char_idx, dx, dy);
                    if (is_xmas)
                        xmas_count += 1;
                }
            }
        }
    }

    std.debug.print("Day 4 Part 1 final answer: {}\n", .{xmas_count});

    var mas_count: u32 = 0;
    var line_idx2: u32 = 0;
    while (line_idx2 < lines.items.len) : (line_idx2 += 1) {
        const line = lines.items[line_idx2];
        var char_idx: u32 = 0;
        while (char_idx < line.len) : (char_idx += 1) {
            if (checkXMas(lines.items, line_idx2, char_idx))
                mas_count += 1;
        }
    }

    std.debug.print("Day 4 Part 2 final answer: {}\n", .{mas_count});
}
