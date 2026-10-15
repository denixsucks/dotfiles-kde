import QtQuick
import org.kde.kwin

Item {
    id: root

    DBusCall {
        id: warpCall
        service: "org.kde.kglobalaccel"
        path: "/component/kwin"
        dbusInterface: "org.kde.kglobalaccel.Component"
        method: "invokeShortcut"
        arguments: ["MoveMouseToFocus"]
    }

    DBusCall {
        id: centerCall
        service: "org.kde.kglobalaccel"
        path: "/component/kwin"
        dbusInterface: "org.kde.kglobalaccel.Component"
        method: "invokeShortcut"
        arguments: ["MoveMouseToCenter"]
    }

    function warp(w) {
        lastWarp = Date.now();
        if (w.desktopWindow)
            centerCall.call();
        else
            warpCall.call();
    }

    function eligible(w) {
        return w && !w.deleted && (w.normalWindow || w.dialog || w.desktopWindow)
            && !w.minimized && !w.move && !w.resize;
    }

    function pointerInside(w) {
        const p = Workspace.cursorPos;
        const g = w.frameGeometry;
        return p.x >= g.x && p.x < g.x + g.width
            && p.y >= g.y && p.y < g.y + g.height;
    }

    property real lastUserMove: 0
    property real lastWarp: 0

    function mouseActive() {
        return Date.now() - lastUserMove < 250;
    }

    property bool pending: false

    function topWindowOn(output) {
        const order = Workspace.stackingOrder;
        for (let i = order.length - 1; i >= 0; i--) {
            const c = order[i];
            if (c.output.name === output.name && c.normalWindow && !c.minimized && !c.deleted
                && (c.onAllDesktops || Array.from(c.desktops).some(d => d.id === Workspace.currentDesktop.id))
                && (c.activities.length === 0 || Array.from(c.activities).includes(Workspace.currentActivity)))
                return c;
        }
        return null;
    }

    function maybeWarp() {
        let w = Workspace.activeWindow;
        if (mouseActive())
            return;
        if (w && w.desktopWindow && !pointerInside(w)) {
            const top = topWindowOn(w.output);
            if (top) {
                Qt.callLater(() => { Workspace.activeWindow = top; });
                return;
            }
        }
        if (eligible(w) && !pointerInside(w)) {
            warp(w);
            pending = true;
            settle.restart();
        }
    }

    Timer {
        id: settle
        interval: 120
        onTriggered: {
            const w = Workspace.activeWindow;
            if (root.pending && !root.mouseActive() && root.eligible(w))
                root.warp(w);
            root.pending = false;
        }
    }

    Connections {
        target: Workspace
        function onWindowActivated(w) {
            root.maybeWarp();
        }
        function onCursorPosChanged() {
            if (Date.now() - root.lastWarp < 150)
                return;
            root.lastUserMove = Date.now();
            root.pending = false;
            settle.stop();
        }
    }

    Connections {
        target: Workspace.activeWindow
        ignoreUnknownSignals: true
        function onOutputChanged() {
            root.maybeWarp();
        }
        function onFrameGeometryChanged() {
            if (root.pending)
                settle.restart();
        }
    }
}
