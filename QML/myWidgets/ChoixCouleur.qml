import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Dialogs
import QtCore



Item {
    property int materialColor: Material.Indigo
    property int windowMode: Material.Dark
    property int frameWidth: 700
    property int buttonWidth: 80
    property int newColor: 0

    id: choixCouleur
    width: frameWidth
    height:  50 + listRextangle.height

    Rectangle {
        id: rectanglechoixDomaine
        height: 26
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.top: parent.top
        anchors.topMargin: 0
        color: Material.color(couleur, Material.Shade500)

        Label {
            id: labelchoixDomaine
            text: qsTr("Couleur du bandeau pour le domaine de travail en cours.")
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
            id :listColor
            model: [Material.Red, Material.Pink, Material.Purple, Material.DeepPurple, Material.Indigo, Material.Blue, Material.LightBlue, Material.Cyan,
            Material.Teal, Material.Green, Material.LightGreen, Material.Lime, Material.Yellow, Material.Amber, Material.Orange, Material.DeepOrange,
            Material.Brown, Material.Grey, Material.BlueGrey]

            Rectangle {
                width: rb.width - 9
                height:rb.width - 8
                radius: 3
                color: Material.color(modelData, Material.Shade500)

                RadioButton{
                    id: rb
                    anchors.centerIn: parent
                    checked: couleur === modelData ? true : false
                    //onClicked: if (checked) backend.selectionColor(modelData)
                    onClicked: {
                        if (checked ) {
                            newColor = modelData
                            messageDialog.open()
                            checked = false
                        }
                    }
                }

            }

        }
    }

    Dialog {
        id: messageDialog
        anchors.centerIn: parent
        modal: true
        title: "Êtes vous sûr de vouloir changer la couleur du domaine " + comboBoxDomain.currentText + " ?"
        standardButtons: MessageDialog.No | MessageDialog.Yes
        visible: false
        onAccepted: backend.selectionColor(newColor)
        onRejected: messageDialog.close()
    }


    Connections{
        target: backend
    }


}
