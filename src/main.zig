const std = @import("std");

// Import day files--unfortunately no way to refactor this :(
// See: https://github.com/ziglang/zig/issues/2206
const day1 = @import("day1.zig");
const day2 = @import("day2.zig");
const day3 = @import("day3.zig");
const day4 = @import("day4.zig");
const day5 = @import("day5.zig");
const day6 = @import("day6.zig");
const day11 = @import("day11.zig");

pub fn main() !void {
    try day1.main();
    try day2.main();
    try day3.main();
    try day4.main();
    try day5.main();
    try day6.main();
    try day11.main();
}
