const std = @import("std");
const chip_eight_emulator = @import("chip_eight_emulator");
//graphics
const SDL2 = @cImport({
    @cInclude("SDL2/SDL.h");
});

pub const CHIP8_WIDTH = 64;
pub const CHIP8_HEIGHT = 32;

pub const Display = struct {
    window: *SDL2.SDL_Window,
    renderer: *SDL2.SDL_Renderer,
    texture: *SDL2.SDL_Texture,
    scale: i32,

    pub fn init(title: [:0]const u8, scale: i32) !Display {
        if (SDL2.SDL_Init(SDL2.SDL_INIT_VIDEO) < 0) return error.SDLInitFailed;
        errdefer SDL2.SDL_Quit();

        const window = SDL2.SDL_CreateWindow(
            title,
            SDL2.SDL_WINDOWPOS_CENTERED,
            SDL2.SDL_WINDOWPOS_CENTERED,
            CHIP8_WIDTH * scale,
            CHIP8_HEIGHT * scale,
            SDL2.SDL_WINDOW_SHOWN,
        ) orelse return error.WindowCreationFailed;
        errdefer SDL2.SDL_DestroyWindow(window);

        const renderer = SDL2.SDL_CreateRenderer(
            window,
            -1,
            SDL2.SDL_RENDERER_ACCELERATED | SDL2.SDL_RENDERER_PRESENTVSYNC,
        ) orelse return error.RendererCreationFailed;
        errdefer SDL2.SDL_DestroyRenderer(renderer);

        // We store one u32 ARGB value per Chip-8 pixel.
        // SDL scales this 64x32 texture up to the full window for us.
        const texture = SDL2.SDL_CreateTexture(
            renderer,
            SDL2.SDL_PIXELFORMAT_ARGB8888,
            SDL2.SDL_TEXTUREACCESS_STREAMING,
            CHIP8_WIDTH,
            CHIP8_HEIGHT,
        ) orelse return error.TextureCreationFailed;

        return Display{
            .window = window,
            .renderer = renderer,
            .texture = texture,
            .scale = scale,
        };
    }

    pub fn deinit(self: *Display) void {
        SDL2.SDL_DestroyTexture(self.texture);
        SDL2.SDL_DestroyRenderer(self.renderer);
        SDL2.SDL_DestroyWindow(self.window);
        SDL2.SDL_Quit();
    }

    pub fn draw(self: *Display, pixels: []const bool) !void {
        std.debug.assert(pixels.len == CHIP8_WIDTH * CHIP8_HEIGHT);

        // Lock texture to get a direct pointer into its pixel buffer
        var raw_pixels: ?*anyopaque = null;
        var pitch: c_int = 0;
        if (SDL2.SDL_LockTexture(self.texture, null, &raw_pixels, &pitch) < 0)
            return error.TextureLockFailed;

        const buf = @as([*]u32, @ptrCast(@alignCast(raw_pixels.?)));
        for (pixels, 0..) |on, i| {
            buf[i] = if (on) 0xFFFFFFFF else 0xFF000000; // white or black, full alpha
        }

        SDL2.SDL_UnlockTexture(self.texture);

        // Clear, copy scaled texture to window, present
        _ = SDL2.SDL_RenderClear(self.renderer);
        _ = SDL2.SDL_RenderCopy(self.renderer, self.texture, null, null);
        SDL2.SDL_RenderPresent(self.renderer);
    }
};
