const std = @import("std");
const WebView = @import("webview").WebView;
pub const Handlers = struct {
    pub fn increment(id: [:0]const u8, req: [:0]const u8, ctx: ?*anyopaque) void {
        var webview: *const WebView = @ptrCast(@alignCast(ctx));
        const num_str = std.mem.trim(u8, req, "[\"\"]");
        var num = std.fmt.parseInt(i32, num_str, 10) catch {
            std.debug.print("cant not parse int.\n", .{});
            unreachable;
        };
        num += 1;
        var buf: [10]u8 = undefined;
        const result = std.fmt.bufPrintZ(&buf, "{d}", .{num}) catch {
            std.debug.print("cant not copy to result.\n", .{});
            unreachable;
        };
        webview.ret(id, 0, result) catch {
            std.debug.print("cant not return from increment function.\n", .{});
            unreachable;
        };
        std.debug.print("req: {s}, result: {s}\n", .{ req, result });
    }

    pub fn expnent(id: [:0]const u8, req: [:0]const u8, ctx: ?*anyopaque) void {
        var webview: *const WebView = @ptrCast(@alignCast(ctx));
        const num_str = std.mem.trim(u8, req, "[\"\"]");
        var num = std.fmt.parseInt(u32, num_str, 10) catch {
            std.debug.print("cant not parse int.\n", .{});
            unreachable;
        };

        if (num == 1) num += 1;
        if (num > 99999) num = 1;
        num = std.math.powi(u32, num, num) catch 1;
        if (num > 99999) num = 1;

        var buf: [10]u8 = undefined;
        const result = std.fmt.bufPrintZ(&buf, "{d}", .{num}) catch {
            std.debug.print("cant not copy to result.\n", .{});
            unreachable;
        };
        webview.ret(id, 0, result) catch {
            std.debug.print("cant not return from increment function.\n", .{});
            unreachable;
        };
        std.debug.print("req: {s}, result: {s}\n", .{ req, result });
    }
};
