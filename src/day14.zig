const std = @import("std");

const Vec2 = struct {
    x: i32,
    y: i32,
};

const ProblemState = struct { a: Vec2, b: Vec2, prize: Vec2 };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // Open the file
    var file = try std.fs.cwd().openFile("day14.txt", .{});
    defer file.close();

    // Get the file size
    const file_size = try file.getEndPos();

    // Allocate a buffer to hold the file contents
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    // Read the file contents into the buffer
    _ = try file.readAll(buffer);

    // Parse input
    var positions = std.ArrayList(Vec2).init(allocator);
    defer positions.deinit();

    var velocities = std.ArrayList(Vec2).init(allocator);
    defer velocities.deinit();

    var line_iter = std.mem.split(u8, buffer, "\n");
    while (line_iter.next()) |line| {
        if (line.len == 0)
            continue;

        var space_iter = std.mem.split(u8, line, " ");
        while (space_iter.next()) |part| {
            const xy = part[2..];
            //std.debug.print("{s}\n", .{xy});
            var token_iter = std.mem.split(u8, xy, ",");
            const x = try std.fmt.parseInt(i32, token_iter.next().?, 10);
            const y = try std.fmt.parseInt(i32, token_iter.next().?, 10);
            const vec = Vec2{ .x = x, .y = y };

            if (std.mem.startsWith(u8, part, "p=")) {
                try positions.append(vec);
            } else {
                try velocities.append(vec);
            }
        }
    }

    const WIDTH = 101;
    const HEIGHT = 103;

    var quad1_count: u32 = 0;
    var quad2_count: u32 = 0;
    var quad3_count: u32 = 0;
    var quad4_count: u32 = 0;
    var idx_p1: u32 = 0;
    while (idx_p1 < positions.items.len) : (idx_p1 += 1) {
        const pos = positions.items[idx_p1];
        const vel = velocities.items[idx_p1];

        const x = @mod(pos.x + 100 * vel.x, WIDTH);
        const y = @mod(pos.y + 100 * vel.y, HEIGHT);

        if (x < WIDTH / 2 and y < HEIGHT / 2)
            quad1_count += 1;
        if (x > WIDTH / 2 and y < HEIGHT / 2)
            quad2_count += 1;
        if (x < WIDTH / 2 and y > HEIGHT / 2)
            quad3_count += 1;
        if (x > WIDTH / 2 and y > HEIGHT / 2)
            quad4_count += 1;
    }

    const p1_ans = quad1_count * quad2_count * quad3_count * quad4_count;

    std.debug.print("Day 14 Part 1 final answer: {}\n", .{p1_ans});

    const TOTAL_NUM_ROBOTS = positions.items.len;
    var seconds: i32 = 0;
    while (true) : (seconds += 1) {
        var grid: [HEIGHT][WIDTH]bool = undefined;
        var idx_y: u32 = 0;
        while (idx_y < HEIGHT) : (idx_y += 1) {
            var idx_x: u32 = 0;
            while (idx_x < WIDTH) : (idx_x += 1) {
                grid[idx_y][idx_x] = false;
            }
        }

        var idx_p2: u32 = 0;
        while (idx_p2 < positions.items.len) : (idx_p2 += 1) {
            const pos = positions.items[idx_p2];
            const vel = velocities.items[idx_p2];

            const x = @as(u32, @intCast(@mod(pos.x + seconds * vel.x, WIDTH)));
            const y = @as(u32, @intCast(@mod(pos.y + seconds * vel.y, HEIGHT)));
            grid[y][x] = true;
        }

        // Only print the grid if the majority of the robots are in the middle
        var middle_count: u32 = 0;
        idx_y = 0;
        while (idx_y < HEIGHT) : (idx_y += 1) {
            var idx_x: u32 = 0;
            while (idx_x < WIDTH) : (idx_x += 1) {
                if (grid[idx_y][idx_x] and idx_x > WIDTH / 3 and idx_x < 2 * WIDTH / 3)
                    middle_count += 1;
            }
        }

        if (@as(f32, @floatFromInt(middle_count)) < 0.60 * @as(f32, @floatFromInt(TOTAL_NUM_ROBOTS)))
            continue;

        // Print the grid
        // std.debug.print("{} seconds:\n", .{seconds});
        // idx_y = 0;
        // while (idx_y < HEIGHT) : (idx_y += 1) {
        //     var idx_x: u32 = 0;
        //     while (idx_x < WIDTH) : (idx_x += 1) {
        //         std.debug.print("{s}", .{if (grid[idx_y][idx_x]) "X" else " "});
        //     }
        //     std.debug.print("\n", .{});
        // }
        break;
    }

    std.debug.print("Day 14 Part 2 final answer: {}\n", .{seconds});
}
