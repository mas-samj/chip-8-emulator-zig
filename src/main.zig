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
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    _ = allocator;

    //TODO: move this elsewhere and pass in allocator
    // var main_stack = std.ArrayList(u16).init(allocator);
    // _ = main_stack.append(69); //temp so no error...

    //initialize memory. now pub main_memory is ready to be used?
    chip_eight_memory.initalizeMem();

    var display = try chip_eight_display.Display.init("Chip-8", 10);
    defer display.deinit();

    var pixels = [_]bool{false} ** (chip_eight_display.CHIP8_WIDTH * chip_eight_display.CHIP8_HEIGHT);
    var i: usize = 0;
    while (i < pixels.len) : (i += 2) pixels[i] = true;

    var event: SDL2.SDL_Event = undefined;
    while (true) {
        while (SDL2.SDL_PollEvent(&event) != 0) {
            if (event.type == SDL2.SDL_QUIT) return;
        }
        try display.draw(&pixels);
    }

    std.debug.print("bye...\n", .{});
}
