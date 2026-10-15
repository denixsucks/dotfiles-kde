import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import org.kde.kwin

Item {
    id: root

    readonly property string fontFamily: "Terminess Nerd Font Propo"
    readonly property color bg: "#141416"
    readonly property color fg: "#dfdfdf"
    readonly property color dim: "#8b8b8b"
    readonly property color accent: "#e93a9a"

    readonly property var groups: [
        { title: "client", keys: [
            ["Meta+←↓↑→", "focus by direction"],
            ["Meta+H / L", "focus previous / next"],
            ["Meta+Shift+←↓↑→", "move window"],
            ["Meta+Ctrl+←→", "narrower / wider"],
            ["Meta+Ctrl+↑↓", "taller / shorter"],
            ["Meta+Ctrl+Return", "make master"],
            ["Meta+Ctrl+Space", "float / unfloat"],
            ["Meta+F", "fullscreen"],
            ["Meta+M", "maximize"],
            ["Meta+Shift+T", "keep on top"],
            ["Meta+O", "send to other screen"],
            ["Meta+Shift+O", "swap screens"],
            ["Meta+C", "center window"],
            ["Meta+Shift+P", "pin to all workspaces"],
            ["Meta+U", "jump to urgent"],
            ["Meta+Q", "close"],
            ["Meta+Ctrl+N", "restore minimized"],
            ["Meta+LMB / RMB", "drag move / resize"]
        ] },
        { title: "layout", keys: [
            ["Meta+Space", "next layout"],
            ["Meta+Shift+Space", "previous layout"],
            ["Meta+G", "group with previous window"],
            ["Meta+Ctrl+Tab", "next window in group"],
            ["Meta+Shift+G", "ungroup"],
            ["Meta+Ctrl+T", "tile"],
            ["Meta+Shift+F", "monocle"],
            ["Meta+Shift+H / L", "master narrower / wider"],
            ["Meta+Shift+J / K", "window shorter / taller"],
            ["Meta+Ctrl+J / K", "fewer / more masters"]
        ] },
        { title: "tag", keys: [
            ["Meta+1…0", "view (again = back)"],
            ["Meta+Shift+1…0", "move window to workspace"],
            ["Meta+J / K", "previous / next workspace"],
            ["Meta+Tab", "last workspace"]
        ] },
        { title: "apps", keys: [
            ["Meta+T / Return", "kitty"],
            ["Meta+A", "dropdown terminal"],
            ["Meta+S", "dropdown music"],
            ["Meta+R / Alt+Space", "vicinae"],
            ["Meta+W", "firefox"],
            ["Meta+Shift+W", "chromium"],
            ["Meta+D", "dolphin"],
            ["Meta+N", "rmpc"],
            ["Print", "screenshot"]
        ] },
        { title: "session", keys: [
            ["Meta+F1", "this help"],
            ["dot-reload", "reload config.conf"],
            ["Meta+X", "lock"],
            ["Meta+Shift+Q", "log out"],
            ["Meta+Shift+X", "shut down"],
            ["Meta+Shift+BkSp", "reboot"]
        ] }
    ]

    function toggle() {
        if (popup.visible) {
            popup.hide();
            return;
        }
        const g = Workspace.activeScreen.geometry;
        popup.x = g.x + Math.round((g.width - popup.width) / 2);
        popup.y = g.y + Math.round((g.height - popup.height) / 2);
        popup.show();
        popup.requestActivate();
        keys.forceActiveFocus();
    }

    ShortcutHandler {
        name: "KeyHelpToggle"
        text: "Show keybinding help"
        sequence: "Meta+F1"
        onActivated: root.toggle()
    }

    Window {
        id: popup
        flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool
        color: "transparent"
        width: frame.implicitWidth
        height: frame.implicitHeight
        visible: false
        onActiveChanged: if (!active) hide()

        Rectangle {
            id: frame
            anchors.fill: parent
            implicitWidth: content.implicitWidth + 48
            implicitHeight: content.implicitHeight + 40
            color: root.bg
            border.color: root.accent
            border.width: 2
            radius: 8

            Item {
                id: keys
                anchors.fill: parent
                focus: true
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape || event.key === Qt.Key_Q || event.key === Qt.Key_F1)
                        popup.hide();
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: popup.hide()
            }

            ColumnLayout {
                id: content
                anchors.centerIn: parent
                spacing: 14

                Text {
                    text: "keybindings"
                    color: root.accent
                    font.family: root.fontFamily
                    font.pixelSize: 20
                    font.bold: true
                }

                RowLayout {
                    spacing: 36
                    Layout.alignment: Qt.AlignTop

                    Repeater {
                        model: root.groups
                        ColumnLayout {
                            required property var modelData
                            Layout.alignment: Qt.AlignTop
                            spacing: 4

                            Text {
                                text: modelData.title
                                color: root.accent
                                font.family: root.fontFamily
                                font.pixelSize: 16
                                font.bold: true
                                bottomPadding: 4
                            }

                            Repeater {
                                model: modelData.keys
                                RowLayout {
                                    required property var modelData
                                    spacing: 12
                                    Text {
                                        text: modelData[0]
                                        color: root.fg
                                        font.family: root.fontFamily
                                        font.pixelSize: 15
                                        Layout.preferredWidth: 160
                                    }
                                    Text {
                                        text: modelData[1]
                                        color: root.dim
                                        font.family: root.fontFamily
                                        font.pixelSize: 15
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
