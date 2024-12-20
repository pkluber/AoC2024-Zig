const std = @import("std");

const Vec2 = struct {
    x: u32,
    y: u32,
};

const Vec2i = struct {
    x: i32,
    y: i32,
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
    dir: Vec2i,
    score: u32,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // Open the file
    var file = try std.fs.cwd().openFile("day16.txt", .{});
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
    var y: usize = 0;
    while (lines_iter.next()) |line| : (y += 1) {
        if (line.len == 0)
            continue;

        if (WIDTH == 0)
            WIDTH = line.len;

        var x: usize = 0;
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

    // Grid memory management and logic
    var grid = try create2DArr(bool, &allocator, HEIGHT, WIDTH);
    init2DBoolArr(grid);

    // Fill the grid in with the positons
    var pos_idx: usize = 0;
    while (pos_idx < positions.items.len) : (pos_idx += 1) {
        const pos = positions.items[pos_idx];
        grid[pos.y][pos.x] = true;
    }

    // TODO: implement A*?
}
