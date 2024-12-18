const std = @import("std");

const Vec2 = struct {
    x: u32,
    y: u32,
};

fn initGrid(grid: [][]bool) void {
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

    pub fn cmp(context: u32, a: State, b: State) std.math.Order {
        _ = context;
        return std.math.order(a.path_length, b.path_length);
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // Open the file
    var file = try std.fs.cwd().openFile("day18.txt", .{});
    defer file.close();

    // Get the file size
    const file_size = try file.getEndPos();

    // Allocate a buffer to hold the file contents
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    // Read the file contents into the buffer
    _ = try file.readAll(buffer);

    // Data structures
    var positions = std.ArrayList(Vec2).init(allocator);
    defer positions.deinit();

    var lines_iter = std.mem.split(u8, buffer, "\n");
    while (lines_iter.next()) |line| {
        if (line.len == 0)
            continue;

        var coord_iter = std.mem.split(u8, line, ",");
        const raw_x = coord_iter.next().?;
        const raw_y = coord_iter.next().?;
        const x = try std.fmt.parseInt(u32, raw_x, 10);
        const y = try std.fmt.parseInt(u32, raw_y, 10);
        const pos = Vec2{ .x = x, .y = y };
        try positions.append(pos);
    }

    //const WIDTH = 71;
    //const HEIGHT = 71;
    const WIDTH = 7;
    const HEIGHT = 7;

    // Grid memory management and logic
    var grid: [][]bool = try allocator.alloc([]bool, HEIGHT);
    defer allocator.free(grid);

    var grid_idx: usize = 0;
    while (grid_idx < HEIGHT) : (grid_idx += 1) {
        grid[grid_idx] = try allocator.alloc(bool, WIDTH);
    }

    initGrid(grid);

    // Fill the grid in with the positons
    //const SIZE_P1 = 1024;
    const SIZE_P1 = 12;
    var pos_idx: usize = 0;
    while (pos_idx < SIZE_P1) : (pos_idx += 1) {
        const pos = positions.items[pos_idx];
        grid[pos.y][pos.x] = true;
    }

    // Implement Dijkstra's algorithm
    var pq = std.PriorityQueue(State, u32, State.cmp).init(allocator, 0);
    defer pq.deinit();

    try pq.add(State{ .xy = Vec2{ .x = 0, .y = 0 }, .path_length = 0 });

    var soln_p1: u32 = 0;
    while (pq.items.len > 0) {
        const state = pq.remove();
        std.debug.print("{}", .{state.path_length});
        if (state.xy.x == WIDTH - 1 and state.xy.y == HEIGHT - 1) {
            soln_p1 = state.path_length;
            break;
        }

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

            try pq.add(State{ .xy = Vec2{ .x = x, .y = y }, .path_length = state.path_length + 1 });
        }
    }

    std.debug.print("Day 18 Part 1 solution: {}\n", .{soln_p1});
}
