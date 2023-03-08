import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml
import QtQuick.Controls.Material


Rectangle {

    property int couleur: Material.Orange
    property int mode: Material.Dark

    property int heure : 12
    property int minute: 00



    id: control
    border.color: mode ? Material.foreground : Material.backgroundColor
    Material.theme: mode
    Material.accent: couleur
    color: Material.backgroundColor
    width: 240

    // HEURE
    Rectangle {
        id: choixHheure
        anchors.top: parent.top
        width: parent.width
        height: 80
        color: Material.backgroundColor


        Button {
            id: upHours
            anchors.top: parent.top
            anchors.left: parent.left
            bottomInset: 0
            topInset: 0
            anchors.topMargin: 5
            anchors.leftMargin: 10
            width: 40
            height: 40
            flat: true

            Image {
                height:40
                width: 40
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.left: parent.left
                source: if (mode == Material.Light) {
                            "qrc:/icons/light/chevron-up.svg"
                        } else {
                            "qrc:/icons/dark/chevron-up.svg"
                        }
                fillMode: Image.PreserveAspectFit
            }
            onClicked: {
                if (heure < 23) heure +=1
                heureSelected.text = heure.toString().padStart(2, '0') + "h" + minute.toString().padStart(2, '0')
            }
        }

        Button {
            id: downHours
            anchors.top: upHours.bottom
            anchors.left: parent.left
            bottomInset: 0
            topInset: 0
            anchors.leftMargin: 10
            width: 40
            height: 40
            flat: true

            Image {
                height:40
                width: 40
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.left: parent.left
                source: if (mode == Material.Light) {
                            "qrc:/icons/light/chevron-down.svg"
                        } else {
                            "qrc:/icons/dark/chevron-down.svg"
                        }
                fillMode: Image.PreserveAspectFit
            }

            onClicked: {
                if (heure > 0) heure -=1
                heureSelected.text = heure.toString().padStart(2, '0') + "h" + minute.toString().padStart(2, '0')
            }

        }

        Button{
            id: heureSelected
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            topInset: 0
            bottomInset: 0
            flat: true
            Material.foreground: Material.accent
            height:40
            text: heure.toString().padStart(2, '0') + "h" + minute.toString().padStart(2, '0')
            font.pointSize: 28

            onClicked: {
                backend.heureSelected(heure, minute)
            }
        }
/*
        Rectangle {
            id: heureAffiche
            anchors.horizontalCenter: parent.horizontalCenter
            height: 40
            width: heureLabel.width + centerHeure.width + minuteLabel.width + 20
            color: Material.color(couleur, Material.ShadeA500)
            anchors.top: parent.top
            anchors.topMargin: 5
            border.color: Material.color(couleur, Material.ShadeA500)

            Label {
                id: heureLabel
                text : heure.toString().padStart(2, '0')
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                font.pointSize: 32
                horizontalAlignment: "AlignRight"
            }
            Label {
                id: centerHeure
                anchors.left: heureLabel.right
                anchors.verticalCenter: parent.verticalCenter
                text : "h"
                font.pointSize: 32
                horizontalAlignment: "AlignHCenter"
            }
            Label {
                id: minuteLabel
                anchors.left: centerHeure.right
                anchors.verticalCenter: parent.verticalCenter
                text : minute.toString().padStart(2, '0')
                font.pointSize: 32
                horizontalAlignment: "AlignLeft"
            }

        }
*/

        Button {
            id: upMinutes
            anchors.top: parent.top
            anchors.right: parent.right
            bottomInset: 0
            topInset: 0
            anchors.topMargin: 5
            anchors.rightMargin: 10
            width: 40
            height: 40
            flat: true
            Image {
                height:40
                width: 40
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.left: parent.left
                source: if (mode == Material.Light) {
                            "qrc:/icons/light/chevron-up.svg"
                        } else {
                            "qrc:/icons/dark/chevron-up.svg"
                        }
                fillMode: Image.PreserveAspectFit
            }

            onClicked: {
                if (heure < 23) {
                    if (minute == 55) {
                        minute = 0
                        heure +=1
                    }
                    else minute += 5
                }
                else if (minute != 55) minute += 5
                heureSelected.text = heure.toString().padStart(2, '0') + "h" + minute.toString().padStart(2, '0')
            }
        }

        Button {
            id: downMinutes
            bottomInset: 0
            topInset: 0
            width: 40
            height: 40
            flat: true
            anchors.right: parent.right
            anchors.top: upMinutes.bottom
            anchors.topMargin: 0
            anchors.rightMargin: 10
            Image {
                height:40
                width: 40
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.left: parent.left
                source: if (mode == Material.Light) {
                            "qrc:/icons/light/chevron-down.svg"
                        } else {
                            "qrc:/icons/dark/chevron-down.svg"
                        }
                fillMode: Image.PreserveAspectFit
            }

            onClicked: {
                if (heure > 0 ) {
                    if (minute == 0) {
                        minute = 55
                        heure -= 1
                    }
                    else minute -= 5
                }
                else if (minute != 0) minute -= 5
                heureSelected.text = heure.toString().padStart(2, '0') + "h" + minute.toString().padStart(2, '0')
            }
        }

    }

    Connections{
        target: backend

        function onSetColor(newCouleur) {
            couleur = newCouleur
        }

        function onSetMode(newMode) {
            mode = newMode
        }
    }




}

