import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

Button {
    id: btnLeftMenu

    //mes properties
    property int windowMode: Material.Light
    property int materialColor: Material.Indigo

    property string btnText: qsTr("A compléter")
    property url btnIconSource:  "menu.svg"
    property bool isActive: false


    implicitWidth: 240
    implicitHeight: 60
    topInset: 0 //Permet d'avoir le bouton calé en haut
    bottomInset: 0//Permet d'avoir le bouton calé en bas
    enabled: ! isActive

    background: Rectangle {
        id: bgBtn
        color: if(isActive) {
                   Material.background
               } else if (btnLeftMenu.down) {
                   Material.color(materialColor, Material.Shade900)
                } else if (btnLeftMenu.hovered) {
                   Material.color(materialColor, Material.Shade700)
                } else {
                   Material.color(materialColor, Material.Shade500)
               }

        Rectangle {
            id: bandeBtn
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
            }
            width: 10
            color : Material.color(materialColor, Material.Shade500)
            visible: true
        }

        Image {
            id: iconBtn
            height:44
            width: 44
            anchors.leftMargin: 18
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            source: if (mode == Material.Light) {
                        "qrc:/icons/light/" + btnIconSource
                    } else {
                        "qrc:/icons/dark/" + btnIconSource
                    }
            fillMode: Image.PreserveAspectFit
        }

        Text {
            id: libelleBtn
            text: btnText
            color: Material.foreground
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 75
            width: 160
            clip: true
        }

    }
}


