import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors

PlasmoidItem {
    id: root

    readonly property string fontFamily: "Terminess Nerd Font Propo"
    readonly property color accent: Kirigami.Theme.highlightColor
    readonly property color dim: Qt.alpha(Kirigami.Theme.textColor, 0.45)

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: "NoBackground"

    Sensors.Sensor { id: cpu;     sensorId: "cpu/all/usage";               updateRateLimit: 2000 }
    Sensors.Sensor { id: cpuTemp; sensorId: "cpu/all/averageTemperature";  updateRateLimit: 2000 }
    Sensors.Sensor { id: gpu;     sensorId: "gpu/gpu0/usage";              updateRateLimit: 2000 }
    Sensors.Sensor { id: gpuTemp; sensorId: "gpu/gpu0/temperature";        updateRateLimit: 2000 }
    Sensors.Sensor { id: ram;     sensorId: "memory/physical/usedPercent"; updateRateLimit: 2000 }
    Sensors.Sensor { id: down;    sensorId: "network/all/download";        updateRateLimit: 2000 }
    Sensors.Sensor { id: up;      sensorId: "network/all/upload";          updateRateLimit: 2000 }

    function pct(s) { return Math.round(s.value || 0) + "%"; }
    function deg(s) { return Math.round(s.value || 0) + "°"; }
    function rate(s) {
        let b = s.value || 0;
        const units = ["B", "K", "M", "G"];
        let i = 0;
        while (b >= 1000 && i < units.length - 1) { b /= 1024; i++; }
        return (b < 10 && i > 0 ? b.toFixed(1) : Math.round(b)) + units[i];
    }
    function label(t) { return "<font color='" + accent + "'>" + t + "</font> "; }
    readonly property string sep: "  <font color='" + dim + "'>│</font>  "

    fullRepresentation: Text {
        Layout.minimumWidth: implicitWidth
        Layout.preferredWidth: implicitWidth
        Layout.fillHeight: true
        verticalAlignment: Text.AlignVCenter
        textFormat: Text.StyledText
        color: Kirigami.Theme.textColor
        font.family: root.fontFamily
        font.pixelSize: 14
        text: root.label("cpu") + root.pct(cpu) + " " + root.deg(cpuTemp)
            + root.sep + root.label("gpu") + root.pct(gpu) + " " + root.deg(gpuTemp)
            + root.sep + root.label("ram") + root.pct(ram)
            + root.sep + "↓" + root.rate(down) + " ↑" + root.rate(up) + "  "
    }
}
