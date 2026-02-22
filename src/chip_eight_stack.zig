const std = @import("std");

pub const Stack = struct {
    arena: std.heap.ArenaAllocator,
    stack: std.ArrayListUnmanaged(u16),

    pub fn init() Stack {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        const stack = std.ArrayListUnmanaged(u16).initCapacity(arena.allocator(), usize);
        return Stack{
            .arena = arena,
            .stack = stack,
        };
    }

    pub fn deinit(self: *Stack) void {
        self.arena.deinit();
    }

    pub fn push(self: *Stack, item: u16) !void {
        try self.stack.append(item);
    }

    pub fn pop(self: *Stack) !u16 {
        if (self.stack.items.len == 0) return error.EmptyStack;
        return self.stack.pop();
    }
};
