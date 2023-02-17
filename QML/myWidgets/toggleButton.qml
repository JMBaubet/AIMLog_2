import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

Button {

    id: btnToggle

    // CUSTOM PROPERTIES
    property int windowMode: Material.light
    property int materialColor: Material.Indigo
    property string btnIconSource: if(windowMode === Material.Light ){
                                       "qrc:/icons/light/menu.svg"}
                                   else {
                                       "qrc:/icons/dark/menu.svg"
                                   }


    implicitHeight: 60
    implicitWidth: 70
    topInset: 0
    bottomInset: 0

    background: Rectangle {
        id: bgBtn

        color: if(btnToggle.down) {
                    Material.color(materialColor, Material.Shade900)
               } else if (btnToggle.hovered) {
                    Material.color(materialColor, Material.Shade700)
               } else {
                   Material.color(materialColor, Material.Shade500)
               }
    }

        Image {
            id: iconBtn
            source: Qt.resolvedUrl(btnToggle.btnIconSource)
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            height:48
            width: 48
            fillMode: Image.PreserveAspectFit
        }
}
