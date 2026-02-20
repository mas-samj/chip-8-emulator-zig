const std = @import("std");
const time = std.time;

const decrement_frequency: u8 = 60; //Hz
const decrement_us: i64 = 1000000 / decrement_frequency; //us

pub const DelayTimer = struct {
    time_value: u8,
    running: bool,
    start_time: i64,

    pub fn initTimer(initialValue: u8) DelayTimer {
        return DelayTimer{
            .time_value = initialValue,
            .running = false,
            .start_time = 0,
        };
    }

    pub fn start(self: *DelayTimer) void {
        if (self.running) return;
        self.running = true;
        self.start_time = time.microTimestamp();
    }
    pub fn getTimerValue(self: *DelayTimer) u8 {
        const cur_time = time.microTimestamp();
        const ticks = (cur_time - self.start_time) / decrement_us;
        if (ticks < self.time_value) {
            self.time_value = self.time_value - ticks;
            self.start_time = cur_time;
            return self.time_value;
        } else {
            self.time_value = 0;
            self.running = false;
        }
        return self.time_value;
    }
};
