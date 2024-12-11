const std = @import("std");
const BigInt = std.math.big.int.Managed;

fn numDigits(x: BigInt, allocator: std.mem.Allocator) !u32 {
    var ten = try BigInt.init(allocator);
    defer ten.deinit();
    try ten.set(10);

    // Setup gunk for division
    var quotient = try x.clone();
    defer quotient.deinit();

    var remainder = try BigInt.init(allocator);
    defer remainder.deinit();

    var num_digits: u32 = 0;
    while (!quotient.eqlZero()) : (num_digits += 1) {
        var quot_clone = try quotient.clone();
        defer quot_clone.deinit();
        try quotient.divTrunc(&remainder, &quot_clone, &ten);
    }

    return num_digits;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // Open the file
    var file = try std.fs.cwd().openFile("day11.txt", .{});
    defer file.close();

    // Get the file size
    const file_size = try file.getEndPos();

    // Allocate a buffer to hold the file contents
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    // Read the file contents into the buffer
    _ = try file.readAll(buffer);

    // Data structures
    var rocks = std.ArrayList(BigInt).init(allocator);
    defer rocks.deinit();

    var lines_iter = std.mem.split(u8, buffer, " ");
    while (lines_iter.next()) |line| {
        if (line.len == 0)
            continue;

        const rock_input = std.fmt.parseInt(i32, line, 10) catch -1;
        if (rock_input == -1)
            continue;

        var rock_num = try BigInt.init(allocator);
        try rock_num.set(rock_input);
        try rocks.append(rock_num);
    }

    const num_blinks = 25;
    var blink: u32 = 0;
    while (blink < num_blinks) : (blink += 1) {
        // Iterate backwards through the list to avoid rocks that just split
        var idx: i32 = @as(i32, @intCast(rocks.items.len)) - 1;
        while (idx >= 0) : (idx -= 1) {
            var rock = &rocks.items[@as(u32, @intCast(idx))];
            // Check if Rule 1 applies, if so apply it then continue
            if (rock.eqlZero()) {
                try rock.set(1);
                continue;
            }

            // Otherwise, calculate the number of digits for Rule 2
            const num_digits = try numDigits(rock.*, allocator);
            if (num_digits % 2 == 0) {
                // Split in half
                var div = try BigInt.init(allocator);
                defer div.deinit();
                try div.set(10);

                // Div is 10^(num_digits / 2)
                var ten = try div.clone();
                defer ten.deinit();
                try div.pow(&ten, num_digits / 2);

                // Right half will be the division result
                var right_half = try BigInt.init(allocator);

                // Left half will be the remainder
                var left_half = try BigInt.init(allocator);
                try left_half.divTrunc(&right_half, rock, &div);

                var old_rock = rocks.swapRemove(@as(u32, @intCast(idx)));
                old_rock.deinit();
                try rocks.append(left_half);
                try rocks.append(right_half);
                continue;
            }

            // Otherwise, apply Rule 3
            var mul = try BigInt.init(allocator);
            defer mul.deinit();
            try mul.set(2024);

            try rock.mul(rock, &mul);
        }

        std.debug.print("Blink {}: ", .{blink + 1});
        for (rocks.items) |rock| {
            std.debug.print("{s} ", .{try rock.toString(allocator, 10, std.fmt.Case.lower)});
        }
        std.debug.print("\n", .{});
    }

    std.debug.print("Day 11 Part 1 final answer: {}\n", .{rocks.items.len});
}
