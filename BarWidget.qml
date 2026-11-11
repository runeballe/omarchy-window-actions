import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// A bar button for the active window.
// Left-click opens a popup with Close / Maximize / Minimize.
// The window that was active when the popup opened is remembered, so the
// action still hits it even if focus moves while the popup is open.
BarWidget {
  id: root
  moduleName: "rune.window-actions"

  readonly property string helper: Qt.resolvedUrl("window-action").toString().replace(/^file:\/\//, "")

  property bool popupOpen: false
  // Address of the window the popup acts on ("" = none).
  property string target: ""
  property string targetTitle: ""

  implicitWidth: barSize
  implicitHeight: barSize

  Commons.Translations { id: strings; directory: Qt.resolvedUrl("i18n") }

  function close() { popupOpen = false }

  // Snapshot the active window, then open the popup.
  Process {
    id: probe
    running: false
    command: ["hyprctl", "activewindow", "-j"]
    stdout: StdioCollector {
      onStreamFinished: {
        var addr = "", title = ""
        try {
          var w = JSON.parse(text)
          if (w && typeof w.address === "string" && /^0x[0-9a-f]+$/.test(w.address)) addr = w.address
          if (w && typeof w.title === "string") title = w.title.slice(0, 120)
        } catch (e) {}
        root.target = addr
        root.targetTitle = title
        root.popupOpen = true
      }
    }
  }

  Process {
    id: action
    running: false
  }

  function openPopup() {
    if (probe.running) return
    probe.running = true
  }

  function run(verb) {
    root.popupOpen = false
    if (!root.target || action.running) return
    action.command = [root.helper, verb, root.target]
    action.running = true
  }

  Text {
    anchors.centerIn: parent
    textFormat: Text.PlainText
    text: "󰖲"
    color: root.bar ? root.bar.barForeground : Color.foreground
    font.family: root.bar ? root.bar.fontFamily : Style.font.family
    font.pixelSize: Style.font.body
    opacity: mouse.containsMouse || root.popupOpen ? 1.0 : 0.75
  }

  MouseArea {
    id: mouse
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    onClicked: mouse => {
      if (root.popupOpen) { root.popupOpen = false; return }
      root.openPopup()
    }
    onEntered: if (root.bar) root.bar.showTooltip(root, strings.t("tooltip"))
    onExited: if (root.bar) root.bar.hideTooltip(root)
  }

  PopupCard {
    id: popup
    anchorItem: root
    bar: root.bar
    owner: root
    open: root.popupOpen
    onOpenChanged: if (!open) root.popupOpen = false
    contentWidth: popup.fittedContentWidth(Style.space(220))
    contentHeight: popup.fittedContentHeight(column.implicitHeight)

    Column {
      id: column
      anchors.fill: parent
      spacing: Style.space(4)

      Text {
        width: parent.width
        textFormat: Text.PlainText
        text: root.target ? root.targetTitle : strings.t("noWindow")
        color: Qt.darker(root.bar.foreground, 1.3)
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.caption
        elide: Text.ElideRight
        bottomPadding: Style.space(4)
      }

      Repeater {
        model: [
          { verb: "close",    icon: "󰅖", key: "close" },
          { verb: "maximize", icon: "󰊓", key: "maximize" },
          { verb: "minimize", icon: "󰖰", key: "minimize" }
        ]

        Button {
          required property var modelData
          width: column.width
          leftAlign: true
          iconText: modelData.icon
          text: strings.t(modelData.key)
          foreground: root.bar.foreground
          enabled: root.target !== ""
          opacity: enabled ? 1.0 : 0.4
          onClicked: root.run(modelData.verb)
        }
      }
    }
  }
}
