const std = @import("std");

const Problem = struct { ans: u64, nums: std.ArrayList(u64) };

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
    var problems = std.ArrayList(Problem).init(allocator);
    defer problems.deinit();

    var lines_iter = std.mem.split(u8, buffer, "\n");
    while (lines_iter.next()) |line| {
        if (line.len == 0)
            continue;

        var colon_iter = std.mem.split(u8, line, ": ");
        const ans = try std.fmt.parseInt(u64, colon_iter.next().?, 10);
        const nums_text = colon_iter.next().?;

        var nums = std.ArrayList(u64).init(allocator);
        var space_iter = std.mem.split(u8, nums_text, " ");
        while (space_iter.next()) |num| {
            try nums.append(try std.fmt.parseInt(u64, num, 10));
        }

        try problems.append(Problem{ .ans = ans, .nums = nums });
    }

    var calibration: u64 = 0;
    outer: for (problems.items) |problem| {
        const nums = problem.nums;
        const ans = problem.ans;
        var op_idx: usize = 0;
        while (op_idx < (@as(usize, 1) << (nums.items.len - 1))) : (op_idx += 1) {
            var idx: usize = 0;
            var cand: u64 = nums.items[0];
            while (idx < nums.items.len - 1) : (idx += 1) {
                const bitslice = (@as(usize, 1) << idx) & op_idx;
                const next_item = nums.items[idx + 1];
                if (bitslice == 0) {
                    cand += next_item;
                } else {
                    cand *= next_item;
                }
            }

            if (cand == ans) {
                calibration += ans;
                continue :outer;
            }
        }
    }

    std.debug.print("Day 7 Part 1 final answer: {}", .{calibration});
}
