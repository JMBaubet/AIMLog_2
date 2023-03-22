import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Dialogs
import QtCore



Frame {
    property int materialColor: Material.Indigo
    property int windowMode: Material.Dark
    property int frameWidth: 700
    property int buttonWidth: 80

    id: choixCouleur
    width: frameWidth
    height:  50 + listRextangle.height

    Rectangle {
        id: rectanglechoixDomaine
        height: 26
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 0
        anchors.topMargin: 0
        color: Material.color(couleur, Material.Shade500)

        Label {
            id: labelchoixDomaine
            text: qsTr("Couleur du bandeau.")
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            font.pixelSize: 14
            font.bold: true
            anchors.leftMargin: 20
        }
    }

    Row {
        id: listRextangle
        anchors.top: rectanglechoixDomaine.bottom
        anchors.topMargin: 4
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 1

        Repeater {
            model: [Material.Red, Material.Pink, Material.Purple, Material.DeepPurple, Material.Indigo, Material.Blue, Material.LightBlue, Material.Cyan,
            Material.Teal, Material.Green, Material.LightGreen, Material.Lime, Material.Yellow, Material.Amber, Material.Orange, Material.DeepOrange,
            Material.Brown, Material.Grey, Material.BlueGrey]

            Rectangle {
                width: red.width - 9
                height:red.width - 8
                radius: 3
                color: Material.color(modelData, Material.Shade500)

                RadioButton{
                    id: red
                    anchors.centerIn: parent
                    checked: couleur === modelData ? true : false
                    onClicked: if (checked) backend.selectionColor(modelData)
                }

            }

        }
    }

    Connections{
        target: backend
    }


}
