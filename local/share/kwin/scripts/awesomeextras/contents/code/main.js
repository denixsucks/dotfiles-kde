var SCRATCH_CLASS = "scratchpad";

var previousDesktop = null;
workspace.currentDesktopChanged.connect(function (prev) {
    previousDesktop = prev;
});
registerShortcut("AwesomePreviousDesktop", "Awesome: Go back to previous desktop", "Meta+Tab", function () {
    if (previousDesktop)
        workspace.currentDesktop = previousDesktop;
});

var minimizedStack = [];
function trackMinimize(w) {
    w.minimizedChanged.connect(function () {
        var i = minimizedStack.indexOf(w);
        if (i >= 0)
            minimizedStack.splice(i, 1);
        if (w.minimized)
            minimizedStack.push(w);
    });
}
workspace.windowList().forEach(trackMinimize);
workspace.windowAdded.connect(trackMinimize);
workspace.windowRemoved.connect(function (w) {
    var i = minimizedStack.indexOf(w);
    if (i >= 0)
        minimizedStack.splice(i, 1);
});
registerShortcut("AwesomeRestoreMinimized", "Awesome: Restore last minimized window", "Meta+Ctrl+N", function () {
    while (minimizedStack.length) {
        var w = minimizedStack.pop();
        if (w.minimized) {
            w.minimized = false;
            workspace.activeWindow = w;
            return;
        }
    }
});

function forbidMinimize(w) {
    if (w.minimized && w.resourceClass != SCRATCH_CLASS && (w.normalWindow || w.dialog))
        w.minimized = false;
}
workspace.windowList().forEach(function (w) {
    forbidMinimize(w);
    w.minimizedChanged.connect(function () { forbidMinimize(w); });
});
workspace.windowAdded.connect(function (w) {
    w.minimizedChanged.connect(function () { forbidMinimize(w); });
});

function findScratchpad() {
    var list = workspace.windowList();
    for (var i = 0; i < list.length; i++)
        if (list[i].resourceClass == SCRATCH_CLASS)
            return list[i];
    return null;
}
function placeScratchpad(w) {
    var area = workspace.clientArea(KWin.MaximizeArea, workspace.activeScreen, workspace.currentDesktop);
    var width = Math.round(area.width * 0.9), height = Math.round(area.height * 0.4);
    w.onAllDesktops = true;
    w.keepAbove = true;
    w.skipTaskbar = true;
    w.skipSwitcher = true;
    w.frameGeometry = { x: area.x + Math.round((area.width - width) / 2), y: area.y, width: width, height: height };
}
function showScratchpad(w) {
    placeScratchpad(w);
    w.minimized = false;
    workspace.activeWindow = w;
}
workspace.windowAdded.connect(function (w) {
    if (w.resourceClass == SCRATCH_CLASS)
        showScratchpad(w);
});
registerShortcut("AwesomeScratchpad", "Awesome: Toggle scratchpad terminal", "Meta+A", function () {
    var w = findScratchpad();
    if (!w) {
        callDBus("org.kde.kglobalaccel", "/component/kitty_scratchpad_desktop",
                 "org.kde.kglobalaccel.Component", "invokeShortcut", "_launch");
        return;
    }
    if (w.minimized || workspace.activeWindow !== w)
        showScratchpad(w);
    else
        w.minimized = true;
});
