const std = @import("std");

// 4096 byes large
// p.c. 12 bits
// all mem is considered writable

pub const Memory = struct {
    main_memory: [4096]u8,
    program_counter: u12,
    index_register: u16,
    //TODO: make the 16 8-bit gp registers

    const font_set: [80]u8 = [_]u8{
        0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
        0x20, 0x60, 0x20, 0x20, 0x70, // 1
        0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
        0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
        0x90, 0x90, 0xF0, 0x10, 0x10, // 4
        0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
        0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
        0xF0, 0x10, 0x20, 0x40, 0x40, // 7
        0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
        0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
        0xF0, 0x90, 0xF0, 0x90, 0x90, // A
        0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
        0xF0, 0x80, 0x80, 0x80, 0xF0, // C
        0xE0, 0x90, 0x90, 0x90, 0xE0, // D
        0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
        0xF0, 0x80, 0xF0, 0x80, 0x80, // F
    };

    pub const font_start_index: u12 = 0x50;

    pub fn initMemory() Memory {
        var main_memory: [4096]u8 = [_]u8{0} ** 4096;
        const program_counter: u12 = 0; //todo: initial location of pc should be after loading?
        const index_register: u16 = 0;

        var mem_index: u12 = font_start_index;
        for (font_set) |font| {
            main_memory[mem_index] = font;
            mem_index += 1;
        }

        return Memory{
            .main_memory = main_memory,
            .program_counter = program_counter,
            .index_register = index_register,
        };
    }

    pub fn fetchInstruction(self: *Memory) u16 {
        const first_byte = self.main_memory[self.program_counter];
        self.program_counter += 1;
        const second_byte = self.main_memory[self.program_counter];
        self.program_counter += 1;
        return first_byte | (second_byte << 8);
    }

    pub fn updateProgramCounterLocation(self: *Memory, location: u12) void {
        self.program_counter = location;
    }
};
