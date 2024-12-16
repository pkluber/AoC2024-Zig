const std = @import("std");

// Import day files--unfortunately no way to refactor this :(
// See: https://github.com/ziglang/zig/issues/2206
const day1 = @import("day1.zig");
const day2 = @import("day2.zig");
const day3 = @import("day3.zig");
const day4 = @import("day4.zig");
const day5 = @import("day5.zig");
const day6 = @import("day6.zig");
const day7 = @import("day7.zig");
const day8 = @import("day8.zig");
const day9 = @import("day9.zig");
const day11 = @import("day11.zig");
const day13 = @import("day13.zig");
const day14 = @import("day14.zig");

pub fn main() !void {
    try day1.main();
    try day2.main();
    try day3.main();
    try day4.main();
    try day5.main();
    //try day6.main();
    //try day7.main();
    try day8.main();
    try day9.main();
    // try day11.main();
    try day13.main();
    try day14.main();
}
