const std = @import("std");

fn safeGet(arr: []u8, idx: u32) u8 {
    if (idx < 0 or idx >= arr.len)
        return 0;
    
    return arr[idx];
}

fn sliceNumber(arr: []u8, start_idx: u32, end_char: u8) i32 {
    var idx: u32 = start_idx;
    while (idx < arr.len) : (idx += 1) {
        const char = arr[idx];
        const is_num = char >= '0' and char <= '9';
        if (char == end_char or !is_num)
            break;
    }

    if (idx == start_idx or arr[idx] != end_char)
        return -1;

    return std.fmt.parseInt(i32, arr[start_idx..idx], 10) catch -1;
}

fn numDigits(num: i32) u32 {
    var num_digits: u32 = 0;
    var num_left = num;
    while (num_left > 0) 
    {
        num_left = @divTrunc(num_left, 10);
        num_digits += 1;
    }

    return num_digits;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    // Open the file
    var file = try std.fs.cwd().openFile("day3.txt", .{});
    defer file.close();

    // Get the file size
    const file_size = try file.getEndPos();

    // Allocate a buffer to hold the file contents
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    // Read the file contents into the buffer
    _ = try file.readAll(buffer);

    var idx: u32 = 0;
    var muls: i32 = 0;
    while (idx < buffer.len) : (idx += 1) {
        if (safeGet(buffer, idx) == 'm' 
            and safeGet(buffer, idx+1) == 'u' 
            and safeGet(buffer, idx+2) == 'l'
            and safeGet(buffer, idx+3) == '(')
        {
            // Try to get first number
            const num1 = sliceNumber(buffer, idx+4, ',');
            if (num1 == -1)
                continue;

            // Try and get second number now
            const num2 = sliceNumber(buffer, idx+4+numDigits(num1)+1, ')');
            if (num2 == -1)
                continue;
            
            muls += num1 * num2;

            std.debug.print("{} from {s}\n", .{num1*num2, buffer[idx..(idx+4+numDigits(num1)+1+numDigits(num2)+1)]});
        }
    }

    std.debug.print("Day 3 Part 1 final answer: {}\n", .{muls});
}