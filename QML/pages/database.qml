import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

Rectangle {
    id: dataBase
    anchors.fill: parent
    color: Material.backgroundColor

    Column {
        id: column
        anchors.fill: parent
        anchors.rightMargin: 20
        anchors.topMargin: 20
        anchors.leftMargin: 20
        spacing: 20

        Label {
            id: titreDatabase
            text: qsTr("Gestion des bases de données")
            font.bold: true
            font.pointSize: 20
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Frame {
            id: selectionDatabase
            width: 280
            height: 100
            anchors.horizontalCenter: parent.horizontalCenter
            bottomPadding: 10
            topPadding: 0
            horizontalPadding: 0

            Rectangle {
                id: rectangleSelectionDatabase
                height: 28
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: 0
                anchors.topMargin: 0
                color: Material.color(couleur, Material.ShadeA500)

                Label {
                    id: labelCreateDatabase
                    text: qsTr("Sélection de la base travail.")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    font.pixelSize: 12
                    font.bold: true
                    anchors.leftMargin: 20
                }

            }

            ComboBox {
                id: selectionComboBox
                width: 150
                anchors.left: parent.left
                anchors.top: rectangleSelectionDatabase.bottom
                anchors.leftMargin: 10
                anchors.topMargin: 10
                               model: ListModel {
                       id: model
                       ListElement { text: "Bac à sable" }
                       ListElement { text: "ATM" }
                       ListElement { text: "Test" }
                   }
            }


            Button {
                id: buttonSelection
                text: qsTr("OK")
                width: 48
                anchors.right: parent.right
                anchors.top: rectangleSelectionDatabase.bottom
                anchors.rightMargin: 10
                anchors.topMargin: 10
                highlighted: true
                Material.accent: Material.LightGreen
                onClicked: backend.selectDatabase(selectionComboBox.currentText) //on envoie le nom de la BDD sélectionnée.
            }
        }

        Frame {
            id: suppressionDatabase
            width: 280
            height: 100
            anchors.horizontalCenter: parent.horizontalCenter
            bottomPadding: 10
            topPadding: 0
            horizontalPadding: 0

            Rectangle {
                id: rectangleSuppressionDatabase
                height: 28
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: 0
                anchors.topMargin: 0
                color: Material.color(couleur, Material.ShadeA500)

                Label {
                    id: text1
                    text: qsTr("Suppression d'une base de données.")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    font.pixelSize: 12
                    font.bold: true
                    anchors.leftMargin: 20
                }

            }

            ComboBox {
                id: suppressionComboBox
                width: 150
                anchors.left: parent.left
                anchors.top: rectangleSuppressionDatabase.bottom
                anchors.leftMargin: 10
                anchors.topMargin: 10
 /*               model: ListModel {
                       id: model
                       ListElement { text: "Bas à sable" }
                       ListElement { text: "ATM" }
                       ListElement { text: "Test" }
                   } */
            }

            Button {
                id: buttonSuppression
                text: qsTr("OK")
                width: 48
                anchors.right: parent.right
                anchors.top: rectangleSuppressionDatabase.bottom
                anchors.rightMargin: 10
                anchors.topMargin: 10
                highlighted: true
                Material.accent: Material.Orange

            }
        }

        Frame {
            id: creationDatabase
            width: 280
            height: 100
            anchors.horizontalCenter: parent.horizontalCenter
            bottomPadding: 10
            topPadding: 0
            horizontalPadding: 0

            Rectangle {
                id: rectangleCreationDatabase
                height: 28
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: 0
                anchors.topMargin: 0
                color: Material.color(couleur, Material.ShadeA500)

                Label {
                    id: textCreationDtabase
                    text: qsTr("Création d'une base de données.")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    font.pixelSize: 12
                    font.bold: true
                    anchors.leftMargin: 20
                }

            }

            TextField {
                id: textField
                width: 150
                anchors.verticalCenter: buttonCreation.verticalCenter
                anchors.left: parent.left
                anchors.top: rectangleCreationDatabase.bottom
                anchors.topMargin: 10
                anchors.leftMargin: 10
                placeholderText: qsTr("Nom de la bdd")
            }

            Button {
                id: buttonCreation
                text: qsTr("OK")
                width: 48
                anchors.right: parent.right
                anchors.top: rectangleCreationDatabase.bottom
                anchors.rightMargin: 10
                anchors.topMargin: 10
                highlighted: true
                Material.accent: Material.LightGreen
            }

        }

    } //Column

    Connections{
        target: backend

    }


}
