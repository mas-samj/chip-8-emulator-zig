const std = @import("std");
const chip_eight_emulator = @import("chip_eight_emulator");
//graphics
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

const chip_eight_memory = @import("chip_eight_memory.zig");

pub fn main() !void {
    //Start up a general purpose allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    //TODO: move this elsewhere and pass in allocator
    //ITS THA STACK
    var main_stack = std.ArrayList(u16).init(allocator);
    _ = main_stack.append(69); //temp so no error...

    //initialize memory. now pub main_memory is ready to be used?
    chip_eight_memory.initalizeMem();

    if (!initVidSDL())
        sdlComplainAndExit();
    defer c.SDL_Quit();

    const window = c.SDL_CreateWindow("Zig SDL Surface Example", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, 640, 480, c.SDL_WINDOW_SHOWN) orelse sdlComplainAndExit();
    defer c.SDL_DestroyWindow(window);

    std.debug.print("{}...{}\n", .{ chip_eight_memory.main_memory.len, chip_eight_memory.main_memory[0x53] });

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

fn sdlComplainAndExit() noreturn {
    std.debug.print("Problem: {s}\n", .{c.SDL_GetError()});
    std.process.exit(1);
}
