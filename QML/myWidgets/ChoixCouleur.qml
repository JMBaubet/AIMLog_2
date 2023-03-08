import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Dialogs
import QtCore



Frame {
    property int materialColor: Material.Red
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
        color: Material.color(couleur, Material.ShadeA500)

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

    // TODO
    // remplacer l'ensemble par un Repeater
    Row {
        id: listRextangle
        anchors.top: rectanglechoixDomaine.bottom
        anchors.topMargin: 4
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 4

        Rectangle {
            width: red.width - 4
            height:red.width - 4
            radius: 12
            color: "#F44336"
        }

        Rectangle {
            width: red.width - 4
            height:red.width - 4
            radius: 12
            color: "#E91E63"
        }
        Rectangle {
            width: red.width - 4
            height:red.width - 4
            radius: 12
            color: "#9C27B0"
        }
        Rectangle {
            width: red.width - 4
            height:red.width - 4
            radius: 12
            color: "#673AB7"
        }
        Rectangle {
            width: red.width - 4
            height:red.width - 4
            radius: 12
            color: "#3F51B5"
        }
        Rectangle {
            width: red.width - 4
            height:red.width - 4
            radius: 12
            color: "#2196F3"
        }
        Rectangle {
            width: red.width - 4
            height:red.width - 4
            radius: 12
            color: "#03A9F4"
        }
        Rectangle {
            width: red.width - 4
            height:red.width - 4
            radius: 12
            color: "#00BCD4"
        }
        Rectangle {
            width: red.width - 4
            height:red.width - 4
            radius: 12
            color: "#009688"
        }
        Rectangle {
            width: red.width - 4
            height:red.width - 4
            radius: 12
            color: "#4CAF50"
        }
        Rectangle {
            width: red.width - 4
            height:red.width - 4
            radius: 12
            color: "#8BC34A"
        }
        Rectangle {
            width: red.width - 4
            height:red.width - 4
            radius: 12
            color: "#FFC107"
        }
        Rectangle {
            width: red.width - 4
            height:red.width - 4
            radius: 12
            color: "#FF9800"
        }
        Rectangle {
            width: red.width - 4
            height:red.width - 4
            radius: 12
            color: "#FF5722"
        }
    }

    Row {
        id: listRadio
        anchors.top: rectanglechoixDomaine.bottom
        spacing: 0
        anchors.horizontalCenter: parent.horizontalCenter

        RadioButton{
            id: red
            checked: couleur === Material.Red ? true : false
            onClicked: if (checked) backend.selectionColor(Material.Red)
        }
        RadioButton{
            id: pink
            checked: couleur === Material.Pink ? true : false
            onClicked: if (checked) backend.selectionColor(Material.Pink)
        }
        RadioButton{
            id: purple
            checked: couleur === Material.Purple ? true : false
            onClicked: if (checked) backend.selectionColor(Material.Purple)
        }
        RadioButton{
            id: deepPurple
            checked: couleur === Material.DeepPurple ? true : false
            onClicked: if (checked) backend.selectionColor(Material.DeepPurple)
        }
        RadioButton{
            id: indogo
            checked: couleur === Material.Indigo ? true : false
            onClicked: if (checked) backend.selectionColor(Material.Indigo)
        }
        RadioButton{
            id: blue
            checked: couleur === Material.Blue ? true : false
            onClicked: if (checked) backend.selectionColor(Material.Blue)
        }
        RadioButton{
            id: lightBlue
            checked: couleur === Material.LightBlue ? true : false
            onClicked: if (checked) backend.selectionColor(Material.LightBlue)
        }
        RadioButton{
            id: cyan
            checked: couleur === Material.Cyan ? true : false
            onClicked: if (checked) backend.selectionColor(Material.Cyan)
        }
        RadioButton{
            id: teal
            checked: couleur === Material.Teal ? true : false
            onClicked: if (checked) backend.selectionColor(Material.Teal)
        }
        RadioButton{
            id: green
            checked: couleur === Material.Green ? true : false
            onClicked: if (checked) backend.selectionColor(Material.Green)
        }
        RadioButton{
            id: lightGreen
            checked: couleur === Material.LightGreen ? true : false
            onClicked: if (checked) backend.selectionColor(Material.LightGreen)
        }
        RadioButton{
            id: amber
            checked: couleur === Material.Amber ? true : false
            onClicked: if (checked) backend.selectionColor(Material.Amber)
        }
        RadioButton{
            id: orange
            checked: couleur === Material.Orange ? true : false
            onClicked: if (checked) backend.selectionColor(Material.Orange)
        }
        RadioButton{
            id: deepOrange
            checked: couleur === Material.DeepOrange ? true : false
            onClicked: if (checked) backend.selectionColor(Material.DeepOrange)
        }
    }


    Connections{
        target: backend
    }


}
