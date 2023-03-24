import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQml


//import "../myWidgets"
import "qrc:/QML/myWidgets"


Rectangle {

    property int materialColor: Material.Indigo
    property int windowMode: Material.Light
    property bool selectDateisVisible: false
    property bool selectHeureisVisible: false
    property bool selectedDate: false
    property bool selectedHeure: false
    property bool selectedPosition: false



    id: analyse
    width: 1370
    height: 942
    implicitWidth: 1370
    implicitHeight: 942
    anchors.fill: parent
    color: Material.backgroundColor
/*
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
*/
    Frame {
        id: choix
        anchors.top: parent.top
        anchors.margins: 20
        anchors.left: parent.left
        anchors.right: parent.right

        height: 60


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
                       }
                       else if (selectDateisVisible) {
                           schemaCnx.z=0
                           selectDateisVisible = !selectDateisVisible
                       }
                       else {
                           schemaCnx.z=-1
                           selectDateisVisible = !selectDateisVisible
                       }
        }


        SelectDate {
            id: selectDate
            width: 320
            height: 48
            anchors.horizontalCenter: dateBtn.horizontalCenter
            anchors.top: parent.bottom
            anchors.topMargin: 20
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
            text: "Heure UTC :"
        }

        Label {
            id: textFieldHeure
            anchors.left: heureLabel.right
            anchors.leftMargin: 10
            //width: 50
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("--:--")
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

            onClicked: {
                if (selectDateisVisible) {
                    selectHeureisVisible = false
                    backend.sendMessage("Vous devez fermer le calendrier, pour ouvrir l'horloge !", 2)
                }
                else if (selectHeureisVisible) {
                    schemaCnx.z=0
                    selectHeureisVisible = !selectHeureisVisible
                }
                else {
                    schemaCnx.z=-1
                    selectHeureisVisible = !selectHeureisVisible
                }
            }
        }

        SelectHeure {
            id: selectHeure
            anchors.horizontalCenter: heureBtn.horizontalCenter
            anchors.top: parent.bottom
            anchors.topMargin: 20

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
            onHighlighted: {
                selectedPosition = true
                backend.selectSite()
            }
        }

        Button {
            id: analyseBtn
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            //flat: true
            anchors.rightMargin: 20
            highlighted: false
            enabled: false
            Material.accent: Material.Green
            text: "Analyse"
            onClicked: {
                //console.log("pgAnalyse : Bouton Analyse cliqué")
                schemaCnx.z = 0
                //console.log("date time" + Date.fromLocaleString(Qt.locale("fr_FR"), textFieldDate.text + " " + textFieldHeure.text, "ddd dd MMM yyyy hh:mm"))
                backend.analyse(Date.fromLocaleString(Qt.locale("fr_FR"), textFieldDate.text + " " + textFieldHeure.text, "ddd dd MMM yyyy hh:mm"), comboBoxPosition.currentText)
            }
        }


    }

    Connexions {
        id: schemaCnx
        couleur: materialColor
        mode: windowMode
        anchors.top: choix.bottom
        anchors.left: parent.left
        anchors.margins: 20
        dateEvent: Date.fromLocaleString(Qt.locale("fr_FR"), textFieldDate.text + " " + textFieldHeure.text, "ddd dd MMM yyyy hh:mm")
        position: comboBoxPosition.currentText
    }


    Connections{
        target: backend

        function onSetDate(jour, mois, annee, dateStr) {
            selectDateisVisible = !selectDateisVisible
            selectedDate = true
            textFieldDate.text = dateStr
            textFieldDate.font.bold = true
            textFieldDate.font.pointSize = 14
            if ( selectedDate && selectedHeure && selectedPosition ) {
                analyseBtn.enabled = true
                analyseBtn.highlighted = true
            }
        }

        function onSetHeure(heure, minute) {
            selectHeureisVisible = !selectHeureisVisible
            selectedHeure = true
            textFieldHeure.text = heure.toString().padStart(2, '0') + ":" + minute.toString().padStart(2, '0')
            textFieldHeure.font.bold = true
            textFieldHeure.font.pointSize = 14
            if ( selectedDate && selectedHeure && selectedPosition) {
                analyseBtn.enabled = true
                analyseBtn.highlighted = true
            }

        }

        function onSetListPositions(listPosition) {
            comboBoxPosition.model = listPosition
        }

        function onSetSelectedPosition() {
            selectedPosition = true
            if ( selectedDate && selectedHeure && selectedPosition) {
                analyseBtn.enabled = true
                analyseBtn.highlighted = true
            }

        }

        function onResetDataAnalyse(){
            textFieldDate.text = qsTr("selectionez une date")
            textFieldHeure.text = qsTr("--:--")
            selectHeure.setMidi()

            schemaCnx.visible = false
        }

    }


}

