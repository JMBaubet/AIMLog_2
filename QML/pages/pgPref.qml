import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Dialogs
import QtCore

//import "../myWidgets"
import "qrc:/QML/myWidgets"

// import "../scripts/script.js" as MyScript


Rectangle {

    property int materialColor: Material.Indigo
    property int windowMode: Material.Dark

    property real alertDossierTravailVide: 1 // 0 à 1 % of opacity : 0 n s'affiche pas; 1 affiché
    property real alertDossierEvenements: 1
    property real alertDossierDatabase: 1
    property string workingDirectory: "~"
//    property string nameDossierConnexions: "Sélèctionnez un dossier"
    property string nameNewDomaines: "Nom du domaine"
    property string nameDossierTravail: "Sélèctionnez un dossier"
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
        spacing: 10

        Label {
            id: titreParametres
            text: qsTr("Paramétrage de l'application")
            font.bold: true
            font.pointSize: 20
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Dossier de Travail
        Row {
            id: item1
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0

            Label {
                id: labelDossierTravail
                text: qsTr("Dossier de travail : ")
                anchors.verticalCenter: parent.verticalCenter
                width: labelNewDomaine.width
                horizontalAlignment: "AlignRight"
            }

            Label {
                id: textFieldDossierTravail
                anchors.verticalCenter: parent.verticalCenter
                text: StandardPaths.writableLocation(StandardPaths.AppLocalDataLocation).toString().replace(StandardPaths.writableLocation(StandardPaths.HomeLocation), "~")
                font.bold: true
            }
        }


        // Nouveau domaine de travail
        Row {
            id: newDomaine
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            Label {
                id: labelNewDomaine
                text: qsTr("Création d'un domaine de travail :")
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: "AlignRight"
            }

            TextField {
                id: textFieldNewDomaine
                width: 352
                anchors.verticalCenter: parent.verticalCenter
                placeholderText: qsTr(nameNewDomaines)
                onAccepted: backend.newDomaine(textFieldNewDomaine.text)
            }

            Button {
                id: buttonChoixNewDomaine
                text: qsTr("Créer")
                anchors.verticalCenter: parent.verticalCenter
                onClicked: backend.newDomaine(textFieldNewDomaine.text)
            }
        }

        // Choix du ChoixDomaine
        ChoixDomaine {
            id: choixDomaine
            anchors.horizontalCenter: parent.horizontalCenter
            windowMode: windowMode
            materialColor: materialColor
        }
/*
        ChoixCouleur {
            id: choixCouleur
            anchors.horizontalCenter: parent.horizontalCenter
            windowMode: windowMode
            materialColor: materialColor
        }
*/
    } //Column


    Connections{
        target: backend

        function onSetBddDir(nomDossier) {
            alertDossierTravailVide = 0
            nameDossierTravail = nomDossier
            textFieldDossierTravail.enabled = true
         }

        function onSetDomaines(domaine) {
            //console.log("preference.qml : On efface le text saisi")
			textFieldNewDomaine.text = ""
        }
    }



}
