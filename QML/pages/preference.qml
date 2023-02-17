import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

Rectangle {
    property real alertDossierConnexions: 1 // 0 à 1 % of opacity : 0 n s'affiche pas; 1 affiché
    property real alertDossierEvenements: 1
    property real alertDossierDatabase: 1
    property string nameDossierConnexions: "Sélèctionnez un dossier"
    property string nameDossierEvenements: "Sélèctionnez un dossier"
    property string nameDossierDatabase: "Sélèctionnez un dossier"

    id: parametres
    width: 1370
    height: 942
    implicitWidth: 1370
    implicitHeight: 942
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
            id: titreParametres
            text: qsTr("Paramètres de l'application")
            font.bold: true
            font.pointSize: 20
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Dossier de log des connexions
        Row {
            id: dossierConnexion
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 20
            anchors.rightMargin: 0
            anchors.leftMargin: 0

            Label {
                id: labelConnexion
                text: qsTr("Fichiers de log des connexions, dossier de stockage :")
                anchors.verticalCenter: parent.verticalCenter
                width: labelEvenement.width
                horizontalAlignment: "AlignRight"
            }

            TextField {
                id: textFieldConnexion
                width: 160
                anchors.verticalCenter: parent.verticalCenter
                placeholderText: qsTr(nameDossierConnexions)
                enabled: false
            }

            Image {
                id: alaertConnexion
                height:32
                width: 32
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/icons/alert-triangle.svg/"
                fillMode: Image.PreserveAspectFit
                opacity: alertDossierConnexions
            }

            Button {
                id: buttonChoixConnexion
                text: qsTr("Sélectionner")
                anchors.verticalCenter: parent.verticalCenter
                onClicked: backend.Selection
            }

        }

        // Dossier de log des évènements
        Row {
            id: dossierEvenement
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 20
            anchors.rightMargin: 0
            anchors.leftMargin: 0

            Label {
                id: labelEvenement
                text: qsTr("Fichiers de log des évènements, dossier de stockage :")
                anchors.verticalCenter: parent.verticalCenter
            }

            TextField {
                id: textFieldEvenement
                width: 160
                anchors.verticalCenter: parent.verticalCenter
                placeholderText: qsTr(nameDossierEvenements)
                enabled: false
            }

            Image {
                id: alertEvenement
                height:32
                width: 32
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/icons/alert-triangle.svg/"
                fillMode: Image.PreserveAspectFit
                opacity: alertDossierEvenements
            }

            Button {
                id: buttonChoixEvenement
                text: qsTr("Séléctionner")
                anchors.verticalCenter: parent.verticalCenter
                onClicked: backend.Selection
            }
        }

        // Dossier des bases de données
        Row {
            id: dossierDatabase
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 20
            anchors.rightMargin: 0
            anchors.leftMargin: 0

            Label {
                id: labelDatabase
                text: qsTr("Bases de données, dossier de stockage :")
                anchors.verticalCenter: parent.verticalCenter
                width: labelEvenement.width
                horizontalAlignment: "AlignRight"
            }

            TextField {
                id: textFieldDatabase
                width: 160
                anchors.verticalCenter: parent.verticalCenter
                placeholderText: qsTr(nameDossierDatabase)
                enabled: false
            }

            Image {
                id: alertDatabase
                height:32
                width: 32
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/icons/alert-triangle.svg/"
                fillMode: Image.PreserveAspectFit
                opacity: alertDossierDatabase
            }

            Button {
                id: buttonChoixDatabase
                text: qsTr("Séléctionner")
                anchors.verticalCenter: parent.verticalCenter
                onClicked: backend.Selection
            }
        }


    } //Column


    Connections{
        target: backend


    }

}
