var SCRATCHPADS = [
    { name: "Scratchpad", cls: "scratchpad", key: "Meta+A", launcher: "/component/kitty_scratchpad_desktop", w: 0.9, h: 0.4 },
    { name: "MusicScratchpad", cls: "scratchpad-music", key: "Meta+S", launcher: "/component/kitty_scratchpad_rmpc_desktop", w: 0.6, h: 0.5 }
];
var TERMINALS = ["kitty"];

function enabled(key) {
    return readConfig(key, true) !== false && String(readConfig(key, true)) !== "false";
}
function isScratchClass(cls) {
    return SCRATCHPADS.some(function (s) { return s.cls == cls; });
}
function onCurrentDesktop(w) {
    return w.onAllDesktops || w.desktops.some(function (d) { return d.id == workspace.currentDesktop.id; });
}

var previousDesktop = null;
workspace.currentDesktopChanged.connect(function (prev) {
    previousDesktop = prev;
});
registerShortcut("AwesomePreviousDesktop", "Awesome: Go back to previous desktop", "Meta+Tab", function () {
    if (previousDesktop)
        workspace.currentDesktop = previousDesktop;
});
for (var n = 1; n <= 10; n++) {
    (function (n) {
        registerShortcut("AwesomeViewTag" + n, "Awesome: View workspace " + n, "Meta+" + (n % 10), function () {
            var d = workspace.desktops[n - 1];
            if (!d)
                return;
            if (enabled("backAndForth") && workspace.currentDesktop.id == d.id && previousDesktop)
                workspace.currentDesktop = previousDesktop;
            else
                workspace.currentDesktop = d;
        });
    })(n);
}

var minimizedStack = [];
var swallowedTerminals = {};
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

var groups = [];
var groupHidden = {};
var lastActive = null;
var currentActive = workspace.activeWindow;
workspace.windowActivated.connect(function (w) {
    if (w && w !== currentActive) {
        lastActive = currentActive;
        currentActive = w;
    }
});
function groupOf(w) {
    for (var i = 0; i < groups.length; i++)
        if (groups[i].indexOf(w) >= 0)
            return groups[i];
    return null;
}
function showMember(g, w) {
    g.forEach(function (m) {
        if (m !== w) {
            groupHidden[m.internalId] = true;
            m.minimized = true;
        }
    });
    delete groupHidden[w.internalId];
    w.minimized = false;
    workspace.activeWindow = w;
}
function dissolve(g) {
    g.forEach(function (m) {
        delete groupHidden[m.internalId];
        m.minimized = false;
    });
    groups.splice(groups.indexOf(g), 1);
}
registerShortcut("AwesomeGroupJoin", "Awesome: Group focused window with the previous one", "Meta+G", function () {
    var w = workspace.activeWindow, t = lastActive;
    if (!w || !t || w === t || t.deleted || !w.normalWindow || !t.normalWindow)
        return;
    var old = groupOf(w);
    if (old) {
        old.splice(old.indexOf(w), 1);
        if (old.length < 2)
            dissolve(old);
    }
    var g = groupOf(t);
    if (!g) {
        g = [t];
        groups.push(g);
    }
    g.push(w);
    showMember(g, t);
});
registerShortcut("AwesomeGroupNext", "Awesome: Show next window in group", "Meta+T", function () {
    var w = workspace.activeWindow, g = w && groupOf(w);
    if (g)
        showMember(g, g[(g.indexOf(w) + 1) % g.length]);
});
registerShortcut("AwesomeGroupBreak", "Awesome: Ungroup", "Meta+Shift+G", function () {
    var w = workspace.activeWindow, g = w && groupOf(w);
    if (g) {
        dissolve(g);
        workspace.activeWindow = w;
    }
});
workspace.windowRemoved.connect(function (w) {
    var g = groupOf(w);
    if (!g)
        return;
    var wasVisible = !groupHidden[w.internalId];
    delete groupHidden[w.internalId];
    g.splice(g.indexOf(w), 1);
    if (g.length < 2)
        dissolve(g);
    else if (wasVisible)
        showMember(g, g[0]);
});

function forbidMinimize(w) {
    if (!enabled("noMinimize"))
        return;
    if (w.minimized && !isScratchClass(w.resourceClass) && !swallowedTerminals[w.internalId] && !groupHidden[w.internalId]
        && (w.normalWindow || w.dialog))
        w.minimized = false;
}
workspace.windowList().forEach(function (w) {
    forbidMinimize(w);
    w.minimizedChanged.connect(function () { forbidMinimize(w); });
});
workspace.windowAdded.connect(function (w) {
    w.minimizedChanged.connect(function () { forbidMinimize(w); });
});

function findByClass(cls) {
    var list = workspace.windowList();
    for (var i = 0; i < list.length; i++)
        if (list[i].resourceClass == cls)
            return list[i];
    return null;
}
function placeScratchpad(w, s) {
    var area = workspace.clientArea(KWin.MaximizeArea, workspace.activeScreen, workspace.currentDesktop);
    var width = Math.round(area.width * s.w), height = Math.round(area.height * s.h);
    w.onAllDesktops = true;
    w.keepAbove = true;
    w.skipTaskbar = true;
    w.skipSwitcher = true;
    w.frameGeometry = { x: area.x + Math.round((area.width - width) / 2), y: area.y, width: width, height: height };
}
function showScratchpad(w, s) {
    placeScratchpad(w, s);
    w.minimized = false;
    workspace.activeWindow = w;
}
SCRATCHPADS.forEach(function (s) {
    registerShortcut("Awesome" + s.name, "Awesome: Toggle " + s.name, s.key, function () {
        var w = findByClass(s.cls);
        if (!w) {
            callDBus("org.kde.kglobalaccel", s.launcher, "org.kde.kglobalaccel.Component", "invokeShortcut", "_launch");
            return;
        }
        if (w.minimized || workspace.activeWindow !== w)
            showScratchpad(w, s);
        else
            w.minimized = true;
    });
});
workspace.windowAdded.connect(function (w) {
    SCRATCHPADS.forEach(function (s) {
        if (w.resourceClass == s.cls)
            showScratchpad(w, s);
    });
});

registerShortcut("AwesomeSwapScreens", "Awesome: Swap windows between screens", "Meta+Shift+O", function () {
    var screens = workspace.screens;
    if (screens.length < 2)
        return;
    var a = workspace.activeScreen;
    var b = screens[0].name == a.name ? screens[1] : screens[0];
    var toB = [], toA = [];
    workspace.windowList().forEach(function (w) {
        if (!w.normalWindow || w.minimized || isScratchClass(w.resourceClass) || !onCurrentDesktop(w))
            return;
        if (w.output.name == a.name)
            toB.push(w);
        else if (w.output.name == b.name)
            toA.push(w);
    });
    toB.forEach(function (w) { workspace.sendClientToScreen(w, b); });
    toA.forEach(function (w) { workspace.sendClientToScreen(w, a); });
});

var swallowedBy = {};
function terminalFor(chain) {
    var list = workspace.windowList();
    for (var i = 0; i < list.length; i++) {
        var t = list[i];
        if (TERMINALS.indexOf(t.resourceClass) >= 0 && !t.minimized && chain.indexOf(t.pid) >= 0)
            return t;
    }
    return null;
}
workspace.windowAdded.connect(function (w) {
    if (!enabled("swallow") || !w.normalWindow || w.pid <= 0)
        return;
    if (TERMINALS.indexOf(w.resourceClass) >= 0 || isScratchClass(w.resourceClass))
        return;
    callDBus("org.denix.PidHelper", "/", "org.denix.PidHelper", "Ancestors", w.pid, function (chain) {
        if (!chain || w.deleted)
            return;
        var t = terminalFor(Array.prototype.slice.call(chain));
        if (!t)
            return;
        swallowedBy[w.internalId] = t;
        swallowedTerminals[t.internalId] = true;
        t.minimized = true;
        workspace.activeWindow = w;
    });
});
workspace.windowRemoved.connect(function (w) {
    var t = swallowedBy[w.internalId];
    if (!t)
        return;
    delete swallowedBy[w.internalId];
    delete swallowedTerminals[t.internalId];
    if (!t.deleted) {
        t.minimized = false;
        workspace.activeWindow = t;
    }
});
