import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material


import "../myWidgets"

Rectangle {

    property int materialColor: Material.Indigo
    property int windowMode: Material.Light
    property bool selectDateisVisible: false
    property bool selectHeureisVisible: false



    id: analyse
    width: 1370
    height: 942
    implicitWidth: 1370
    implicitHeight: 942
    anchors.fill: parent
    color: Material.backgroundColor

    Label {
        id: titre
        text: qsTr("Analyse des connexions et des évènements.")
        anchors.top: parent.top
        anchors.horizontalCenterOffset: 0
        anchors.topMargin: 10
        font.bold: true
        font.pointSize: 20
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Rectangle {
        id: choix
        anchors.top: titre.bottom
        anchors.margins: 20
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 2 * anchors.margins
        height: 40
        color: Material.color(couleur, Material.ShadeA500)


        Label {
            id: dateLabel
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            font.pointSize: 16
            text: "Date :"
        }

        Label {
            id: textFieldDate
            anchors.left: dateLabel.right
            anchors.leftMargin: 10
            //width: 50
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("selectionez une date")
        }

        Button {
            id: dateBtn
            anchors.left: textFieldDate.right
            anchors.leftMargin: 10
            width: 40
            height: 40
            anchors.verticalCenter: parent.verticalCenter
            topInset: 0
            bottomInset: 0
            flat: true
            Image {
                height:36
                width: 36
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.left: parent.left
                source: if (mode === Material.Light) {
                            "qrc:/icons/light/calendar.svg"
                        } else {
                            "qrc:/icons/dark/calendar.svg"
                        }
                fillMode: Image.PreserveAspectFit
            }

            onClicked: if (selectHeureisVisible) {
                           selectDateisVisible = false
                           backend.sendMessage("Vous devez fermer l'horloge, pour ouvrir le calendrier !", 2)
                       } else {
                           selectDateisVisible = !selectDateisVisible
                       }
        }


        SelectDate {
            id: selectDate
            anchors.horizontalCenter: dateBtn.horizontalCenter
            anchors.top: choix.bottom
            //anchors.top: choix.bottom
            //anchors.left: textFieldDate.left
            mode: windowMode
            couleur: materialColor
            visible: selectDateisVisible
        }


        Label {
            id: heureLabel
            anchors.left: dateBtn.right
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            font.pointSize: 16
            text: "Heure :"
        }

        Label {
            id: textFieldHeure
            anchors.left: heureLabel.right
            anchors.leftMargin: 10
            //width: 50
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Heure")
        }

        Button {
            id: heureBtn
            anchors.left: textFieldHeure.right
            anchors.leftMargin: 10
            width: 40
            height: 40
            anchors.verticalCenter: parent.verticalCenter
            topInset: 0
            bottomInset: 0
            flat: true
            Image {
                height:36
                width: 36
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.left: parent.left
                source: if (mode === Material.Light) {
                            "qrc:/icons/light/clock.svg"
                        } else {
                            "qrc:/icons/dark/clock.svg"
                        }
                fillMode: Image.PreserveAspectFit
            }

            onClicked: if (selectDateisVisible) {
                           selectHeureisVisible = false
                           backend.sendMessage("Vous devez fermer le calendrier, pour ouvrir l'horloge !", 2)
                       } else {
                           selectHeureisVisible = !selectHeureisVisible
                       }
        }

        SelectHeure {
            id: selectHeure
            anchors.horizontalCenter: heureBtn.horizontalCenter
            anchors.top: choix.bottom
            //anchors.top: choix.bottom
            //anchors.left: textFieldDate.left
            mode: windowMode
            couleur: materialColor
            visible: selectHeureisVisible
        }

        Label {
            id: textSite
            anchors.left: heureBtn.right
            anchors.leftMargin: 20
            //width: 50
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Site :")
        }


        ComboBox {
            id: comboBoxSite
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: textSite.right
            anchors.leftMargin: 10
            //onCurrentValueChanged: backend.selectSite(currentText)
            model: ["Tous", "Vigie Nord", "Vigie Centrale", "Vigie Sud", "Salle IFR", "Vigies Trafic E. et S.", "Autre..."]
        }

        Label {
            id: textPosition
            anchors.left: comboBoxSite.right
            anchors.leftMargin: 20
            //width: 50
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Position :")
        }


        ComboBox {
            id: comboBoxPosition
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: textPosition.right
            anchors.leftMargin: 10
            //onCurrentValueChanged: backend.selectSite(currentText)

        }


    }


    Connections{
        target: backend

        function onSetDate(jour, mois, annee, dateStr) {
            selectDateisVisible = !selectDateisVisible
            textFieldDate.text = dateStr
            textFieldDate.font.bold = true
            textFieldDate.font.pointSize = 14
        }

        function onSetHeure(heure, minute) {
            selectHeureisVisible = !selectHeureisVisible
            textFieldHeure.text = heure.toString().padStart(2, '0') + "h" + minute.toString().padStart(2, '0')
            textFieldHeure.font.bold = true
            textFieldHeure.font.pointSize = 14

        }

        function onSetListPositions(listPosition) {
            comboBoxPosition.model = listPosition
        }

    }


}

