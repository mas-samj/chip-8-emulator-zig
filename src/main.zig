const std = @import("std");
const chip_eight_emulator = @import("chip_eight_emulator");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

pub fn main() !void {
    if (!initVidSDL())
        std.process.exit(1); //TODO change before implementing

    defer c.SDL_Quit();

    c.SDL_Quit();

    std.debug.print("bye...\n", .{});
}

pub fn initVidSDL() bool {
    std.debug.print("Initializing SDL.\n", .{});

    if (c.SDL_Init(c.SDL_INIT_VIDEO) < 0) {
        std.debug.print("Could not initialize SDL: {s}.\n", .{c.SDL_GetError()});
        return false;
    }

    std.debug.print("SDL initialized.\n", .{});
    return true;
}
