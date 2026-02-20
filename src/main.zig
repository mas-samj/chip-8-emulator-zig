const std = @import("std");
const chip_eight_emulator = @import("chip_eight_emulator");
//graphics
const SDL2 = @cImport({
    @cInclude("SDL2/SDL.h");
});

const chip_eight_memory = @import("chip_eight_memory.zig");
const chip_eight_display = @import("chip_eight_display.zig");

pub fn main() !void {
    //Start up a general purpose allocator
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer std.debug.assert(gpa.deinit() == .ok);
    // const allocator = gpa.allocator();

    // _ = allocator;

    //initialize memory. now pub main_memory is ready to be used?
    chip_eight_memory.initalizeMem();

    var display = try chip_eight_display.Display.init("Chip-8", 10);
    defer display.deinit();

    var pixels = [_]bool{false} ** (chip_eight_display.CHIP8_WIDTH * chip_eight_display.CHIP8_HEIGHT);
    var i: usize = 0;
    while (i < pixels.len) : (i += 4) pixels[i] = true;

    var event: SDL2.SDL_Event = undefined;
    while (true) {
        while (SDL2.SDL_PollEvent(&event) != 0) {
            if (event.type == SDL2.SDL_QUIT) return;
        }
        try display.draw(&pixels);
    }

    std.debug.print("bye...\n", .{});
}

const time = std.time;

const decrement_frequency: u8 = 60; //Hz
const decrement_ms = 1000 / decrement_frequency;

pub const DelayTimer = struct {
    time_value: u8,
    running: bool,
    done: bool,
    start_time: i64,

    pub fn initTimer(initialValue: u8) !DelayTimer {
        return DelayTimer{
            .time_value = initialValue,
            .running = false,
            .done = false,
            .start_time = 0,
        };
    }

    pub fn start(self: *DelayTimer) void {
        if (self.running) return;
        self.running = true;
        self.start_time = time.milliTimestamp();
        while (!self.done) {
            const cur_time = time.milliTimestamp();
            if ((cur_time - self.start_time) >= decrement_ms) {
                self.time_value -= 1;
                if (self.time_value == 0)
                    self.done = true;
            }
        }
    }
};
