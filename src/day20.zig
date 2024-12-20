const std = @import("std");

const Vec2 = struct {
    x: u32,
    y: u32,
};

fn create2DArr(comptime T: type, allocator: *const std.mem.Allocator, height: usize, width: usize) ![][]T {
    var grid: [][]T = try allocator.*.alloc([]T, height);

    var grid_idx: usize = 0;
    while (grid_idx < height) : (grid_idx += 1) {
        grid[grid_idx] = try allocator.*.alloc(T, width);
    }

    return grid;
}

fn init2DBoolArr(grid: [][]bool) void {
    var y: usize = 0;
    while (y < grid.len) : (y += 1) {
        var x: usize = 0;
        while (x < grid[y].len) : (x += 1) {
            grid[y][x] = false;
        }
    }
}

const State = struct {
    xy: Vec2,
    path_length: u32,
};

fn dijkstra(allocator: *const std.mem.Allocator, grid: [][]bool, seen: [][]bool, start_pos: Vec2, end_pos: Vec2) !i32 {
    var q = std.ArrayList(State).init(allocator.*);
    defer q.deinit();

    try q.append(State{ .xy = start_pos, .path_length = 0 });

    const WIDTH = grid[0].len;
    const HEIGHT = grid.len;

    while (q.items.len > 0) {
        const state: State = q.pop();
        if (seen[state.xy.y][state.xy.x])
            continue;

        seen[state.xy.y][state.xy.x] = true;

        if (state.xy.x == end_pos.x and state.xy.y == end_pos.y)
            return @as(i32, @intCast(state.path_length));

        var dir_idx: u32 = 0;
        while (dir_idx < 4) : (dir_idx += 1) {
            const x = switch (dir_idx) {
                0 => state.xy.x + 1,
                2 => state.xy.x -% 1,
                1, 3 => state.xy.x,
                else => unreachable,
            };

            const y = switch (dir_idx) {
                0, 2 => state.xy.y,
                1 => state.xy.y + 1,
                3 => state.xy.y -% 1,
                else => unreachable,
            };

            if (x >= WIDTH or y >= HEIGHT)
                continue;

            const grid_pos = grid[y][x];
            if (grid_pos)
                continue;

            try q.insert(0, State{ .xy = Vec2{ .x = x, .y = y }, .path_length = state.path_length + 1 });
        }
    }

    return -1;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // Open the file
    var file = try std.fs.cwd().openFile("day20.txt", .{});
    defer file.close();

    // Get the file size
    const file_size = try file.getEndPos();

    // Allocate a buffer to hold the file contents
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    // Read the file contents into the buffer
    _ = try file.readAll(buffer);

    var positions = std.ArrayList(Vec2).init(allocator);
    defer positions.deinit();

    var start_pos: Vec2 = undefined;
    var end_pos: Vec2 = undefined;

    var WIDTH: usize = 0;

    var lines_iter = std.mem.split(u8, buffer, "\n");
    var y: u32 = 0;
    while (lines_iter.next()) |line| : (y += 1) {
        if (line.len == 0)
            continue;

        if (WIDTH == 0)
            WIDTH = line.len;

        var x: u32 = 0;
        while (x < line.len) : (x += 1) {
            const char = line[x];
            const pos = Vec2{ .x = x, .y = y };
            if (char == '#')
                try positions.append(pos);

            if (char == 'S')
                start_pos = pos;

            if (char == 'E')
                end_pos = pos;
        }
    }

    const HEIGHT = y;

    //std.debug.print("WIDTH={}, HEIGHT={}, start_pos={},{}, end_pos={},{}\n", .{ WIDTH, HEIGHT, start_pos.x, start_pos.y, end_pos.x, end_pos.y });

    // Grid memory management and logic
    var grid = try create2DArr(bool, &allocator, HEIGHT, WIDTH);
    init2DBoolArr(grid);

    // Fill the grid in with the positons
    var pos_idx: usize = 0;
    while (pos_idx < positions.items.len) : (pos_idx += 1) {
        const pos = positions.items[pos_idx];
        grid[pos.y][pos.x] = true;
    }

    // Seen array
    const seen = try create2DArr(bool, &allocator, HEIGHT, WIDTH);

    const baseline = try dijkstra(&allocator, grid, seen, start_pos, end_pos);
    std.debug.print("baseline={}\n", .{baseline});

    // Now consider all the possible 2-length cheats
    var soln_p1: u32 = 0;

    var cheat_y: u32 = 0;
    while (cheat_y < grid.len) : (cheat_y += 1) {
        var cheat_x: u32 = 0;
        while (cheat_x < grid[0].len) : (cheat_x += 1) {
            var dir: u32 = 0;
            while (dir < 4) : (dir += 1) {
                const cheat2_x = switch (dir) {
                    0 => cheat_x + 1,
                    2 => cheat_x -% 1,
                    1, 3 => cheat_x,
                    else => unreachable,
                };

                const cheat2_y = switch (dir) {
                    0, 2 => cheat_y,
                    1 => cheat_y + 1,
                    3 => cheat_y -% 1,
                    else => unreachable,
                };

                // Skip invalid paths
                if (cheat2_x >= WIDTH or cheat2_y >= HEIGHT)
                    continue;

                // Can only start cheat on an open space
                if (grid[cheat_y][cheat_x])
                    continue;

                const prev_1 = grid[cheat_y][cheat_x];
                const prev_2 = grid[cheat2_y][cheat2_x];
                grid[cheat_y][cheat_x] = false;
                grid[cheat2_y][cheat2_x] = false;
                defer grid[cheat_y][cheat_x] = prev_1;
                defer grid[cheat2_y][cheat2_x] = prev_2;

                init2DBoolArr(seen);
                const segment1 = try dijkstra(&allocator, grid, seen, start_pos, Vec2{ .x = cheat_x, .y = cheat_y });
                init2DBoolArr(seen);
                const segment2 = try dijkstra(&allocator, grid, seen, Vec2{ .x = cheat2_x, .y = cheat2_y }, end_pos);
                if (segment1 < 0 or segment2 < 0)
                    continue;

                const saving = baseline - (segment1 + segment2 - 1);
                if (saving > 0)
                    std.debug.print("{}\n", .{saving});

                if (saving >= 100)
                    soln_p1 += 1;
            }
        }
    }

    std.debug.print("Day 20 Part 1 final answer: {}\n", .{soln_p1});
}
