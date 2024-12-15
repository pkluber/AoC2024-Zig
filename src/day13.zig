const std = @import("std");

const State = struct {
    x: u32,
    y: u32,
    tokens: u32,

    pub fn cmp(context: u32, a: State, b: State) std.math.Order {
        _ = context;
        // Return b < a to prioritize lower number of tokens
        return std.math.order(b.tokens, a.tokens);
    }
};

const Vec2 = struct {
    x: u32,
    y: u32,
};

const ProblemState = struct { a: Vec2, b: Vec2, prize: Vec2 };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // Open the file
    var file = try std.fs.cwd().openFile("day13.txt", .{});
    defer file.close();

    // Get the file size
    const file_size = try file.getEndPos();

    // Allocate a buffer to hold the file contents
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    // Read the file contents into the buffer
    _ = try file.readAll(buffer);

    // Parse input
    var problems = std.ArrayList(ProblemState).init(allocator);
    var sections_iter = std.mem.split(u8, buffer, "\n\n");
    while (sections_iter.next()) |section| {
        if (section.len == 0)
            continue;

        var ps: ProblemState = undefined;

        var line_iter = std.mem.split(u8, section, "\n");
        while (line_iter.next()) |line| {
            if (line.len == 0)
                continue;

            var state: Vec2 = undefined;
            var token_iter = std.mem.split(u8, line, " ");
            while (token_iter.next()) |token| {
                if (std.mem.startsWith(u8, token, "X")) {
                    state.x = try std.fmt.parseInt(u32, token[2 .. token.len - 1], 10);
                } else if (std.mem.startsWith(u8, token, "Y")) {
                    state.y = try std.fmt.parseInt(u32, token[2..], 10);
                }
            }

            if (std.mem.startsWith(u8, line, "Button A")) {
                ps.a = state;
            } else if (std.mem.startsWith(u8, line, "Button B")) {
                ps.b = state;
            } else {
                ps.prize = state;
            }
        }

        try problems.append(ps);
    }

    var total_tokens: u64 = 0;
    for (problems.items) |problem| {
        //std.debug.print("Problem:\nA: {},{}\nB: {},{}\nPrize: {},{}\n", .{ problem.a.x, problem.a.y, problem.b.x, problem.b.y, problem.prize.x, problem.prize.y });

        // Brute force solution
        var solution_found = false;
        var min_tokens: u64 = std.math.maxInt(u64);
        var num_a: u64 = 0;
        while (num_a < 100) : (num_a += 1) {
            var num_b: u64 = 0;
            while (num_b < 100) : (num_b += 1) {
                const x = problem.a.x * num_a + problem.b.x * num_b;
                const y = problem.a.y * num_a + problem.b.y * num_b;
                const num_tokens = 3 * num_a + num_b;
                if (x == problem.prize.x and y == problem.prize.y) {
                    solution_found = true;
                    min_tokens = if (num_tokens < min_tokens) num_tokens else min_tokens;
                }
            }
        }

        if (solution_found)
            total_tokens += min_tokens;
    }

    std.debug.print("Day 13 Part 1 final answer: {}\n", .{total_tokens});

    var total_tokens_p2: u64 = 0;
    for (problems.items) |problem| {
        const new_prize_x: u64 = 10000000000000 + @as(u64, @intCast(problem.prize.x));
        const new_prize_y: u64 = 10000000000000 + @as(u64, @intCast(problem.prize.y));

        const det: i64 = @as(i64, @intCast(problem.a.x * problem.b.y)) - @as(i64, @intCast(problem.a.y * problem.b.x));
        if (det == 0)
            continue;

        const raw_a: i64 = @divTrunc(@as(i64, @intCast(new_prize_x * problem.b.y)) - @as(i64, @intCast(new_prize_y * problem.b.x)), det);
        const raw_b: i64 = @divTrunc(@as(i64, @intCast(new_prize_y * problem.a.x)) - @as(i64, @intCast(new_prize_x * problem.a.y)), det);

        // Validate solution
        if (raw_a < 0 or raw_b < 0)
            continue;

        const a: u64 = @as(u64, @intCast(raw_a));
        const b: u64 = @as(u64, @intCast(raw_b));
        const xp: u64 = @as(u64, @intCast(a * problem.a.x + b * problem.b.x));
        const yp: u64 = @as(u64, @intCast(a * problem.a.y + b * problem.b.y));
        if (xp == new_prize_x and yp == new_prize_y) {
            // Have found solution!
            total_tokens_p2 += 3 * a + b;
        }
    }

    std.debug.print("Day 13 Part 2 final answer: {}\n", .{total_tokens_p2});
}
