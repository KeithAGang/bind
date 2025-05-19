const std = @import("std");
const WebView = @import("webview").WebView;
const Handlers = @import("bind_namespace.zig").Handlers;

const html =
    \\ <main class="main">
    \\   <h1>WebView2 Bind Example</h1>    
    \\ <button id="increment">Click me</button>
    \\ <button id="inc">Click me Too!</button>
    \\ <div>You clicked Increment <span id="count">0</span> time(s).</div>
    \\ <div>You clicked Pow <span id="count2">0</span> time(s).</div>
    \\ </main>
    \\ <style>
    \\  main {
    \\   display: flex;
    \\   flex-direction: column;
    \\   align-items: center;
    \\   gap: 1.25rem;
    \\   justify-content: center;}
    \\  button {
    \\   padding: 10px 20px;
    \\   font-size: 16px;
    \\   cursor: pointer;
    \\   background-color: #007bff;
    \\   border-radius: 5px;
    \\   border: 1px solid #007bff;
    \\   color: white;
    \\   border: none;}
    \\  button:hover {
    \\   background-color: #0056b3;}
    \\  div {
    \\   margin-top: 20px;
    \\   font-size: 18px;}
    \\ </style>
    \\ <script>
    \\    document.addEventListener("DOMContentLoaded", () => {
    \\  const [incrementElement, countElement] = document.querySelectorAll("#increment, #count");
    \\  incrementElement.addEventListener("click", () => {
    \\    window.increment(countElement.innerText).then(result => {
    \\      countElement.textContent = result;
    \\    });
    \\  });
    \\
    \\  const [incrementElement2, countElement2] = document.querySelectorAll("#inc, #count2");
    \\  incrementElement2.addEventListener("click", () => {
    \\    window.expnent(countElement2.innerText).then(result => {
    \\      countElement2.textContent = result;
    \\    });
    \\  });
    \\});
    \\ </script>
;

fn bindAllFunctions(comptime T: type, w: *WebView) !void {
    const info = @typeInfo(T);
    if (info != .Struct) @compileError("Expected a struct type!");

    inline for (info.Struct.decls) |decl| {
        const func_name = decl.name;
        const func = @field(T, func_name);

        // Filter only functions
        if (@typeInfo(@TypeOf(func)) != .Fn) continue;

        const Ctx = WebView.CallbackContext(func); // this must be comptime-known
        const cb = Ctx.init(@ptrCast(w));
        try w.bind(func_name, &cb);
    }
}

pub fn main() !void {
    var w = WebView.create(true, null);
    try w.setTitle("Bind Example");
    try w.setSize(680, 520, .None);

    // const callback = WebView.CallbackContext(&increment).init(@ptrCast(&w));
    // const callback2 = WebView.CallbackContext(&expnent).init(@ptrCast(&w));

    // try w.bind("increment", &callback);
    // try w.bind("expnent", &callback2);

    // Try to bind all functions in Handlers
    try bindAllFunctions(Handlers, &w);

    try w.setHtml(html);
    try w.run();
    try w.destroy();
}
