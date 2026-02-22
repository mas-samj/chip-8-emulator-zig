const std = @import("std");
const time = std.time;

pub const DelayTimer = struct {
    time_value: u8,
    running: bool,
    start_time: i64,

    const decrement_frequency: u8 = 60; //Hz
    const decrement_us: i64 = 1000000 / decrement_frequency; //us

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

pub const ClockTimer = struct {
    clock_speed: u16,
    prev_time: i64,

    pub fn getCyclesToMicroSec(freq: u16) i64 {
        return 1000000 / freq;
    }

    pub fn init(clock_speed: u16) !ClockTimer {
        if (clock_speed < 1) {
            return error.InvalidClockSpeed;
        } else {
            return ClockTimer{
                .clock_speed = clock_speed,
                .prev_time = std.time.microTimestamp(),
            };
        }
    }

    pub fn start(self: *ClockTimer) void {
        self.prev_time = std.time.microTimestamp();
    }

    pub fn getClockStatus(self: *ClockTimer) bool {
        const cur_time = std.time.microTimestamp();
        const ticks = (cur_time - self.prev_time) / getCyclesToMicroSec(self.clock_speed);
        if (ticks < 1) {
            return false;
        } else {
            self.prev_time = cur_time;
            return true;
        }
    }
};
