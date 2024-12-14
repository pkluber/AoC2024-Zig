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
                if (std.mem.startsWith(u8, token, "X+")) {
                    state.x = try std.fmt.parseInt(u32, token[2 .. token.len - 1], 10);
                } else if (std.mem.startsWith(u8, token, "Y+")) {
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

            try problems.append(ps);
        }
    }

    var total_tokens: u32 = 0;
    for (problems.items) |problem| {
        var pq = std.PriorityQueue(State, u32, State.cmp).init(allocator, 0);
        defer pq.deinit();

        try pq.add(State{ .tokens = 0, .x = 0, .y = 0 });
        while (pq.items.len > 0) {
            const state = pq.remove();
            if (state.x == problem.prize.x and state.y == problem.prize.y) {
                // Found solution!
                total_tokens += state.tokens;
                break;
            }

            const option1 = State{ .x = state.x + problem.a.x, .y = state.y + problem.a.y, .tokens = state.tokens + 3 };
            const option2 = State{ .x = state.x + problem.b.x, .y = state.y + problem.b.y, .tokens = state.tokens + 1 };
            if (option1.x <= problem.prize.x and option1.y <= problem.prize.y)
                try pq.add(option1);
            if (option2.x <= problem.prize.x and option2.y <= problem.prize.y)
                try pq.add(option2);
        }
    }

    std.debug.print("Day 13 Part 1 final answer: {}\n", .{total_tokens});
}
