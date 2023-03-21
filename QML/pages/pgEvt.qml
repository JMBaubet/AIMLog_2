import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Dialogs
import QtCore


import "../myWidgets"


Rectangle {

    property int materialColor: Material.Indigo
    property int windowMode: Material.Dark
    property var myListeFile: []
    property string myDomaine: ""
    property int myNbFile: 0


    id: importEvt
    width: 1370
    height: 942
    implicitWidth: 1370
    implicitHeight: 942
    anchors.fill: parent
    color: Material.backgroundColor

    Label {
        id: titre
        text: qsTr("Suppression et importation des fichiers event.")
        anchors.top: parent.top
        anchors.horizontalCenterOffset: 0
        anchors.topMargin: 10
        font.bold: true
        font.pointSize: 20
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Frame {
        id: frame
        anchors.top: titre.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 10
        width: 700
        anchors.bottom: selection.top
        bottomPadding: 3
        anchors.bottomMargin: 10

        Rectangle {
            id: rectangle
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 26
            color: Material.color(couleur, Material.ShadeA500)

            Label {
                id: label1
                text: myListeFile.length > 0 ?  qsTr("Sélectionnez les fichiers à suppimer ou importer.")  : qsTr("Le répertoire d'importation est vide !")
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                font.pixelSize: 14
                font.bold: true
                anchors.leftMargin: 20
            }
        }

        ImportFiles {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: rectangle.bottom
            anchors.bottom: parent.bottom
            anchors.topMargin: rectangle.height + 3
            myType: 1
            visible: myListeFile.length > 0 ? true : false

        }

        Label {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.top: rectangle.bottom
            anchors.topMargin: rectangle.height + 3

            visible: myListeFile.length > 0 ? false : true
            wrapMode: TextEdit.WordWrap
            textFormat: TextEdit.RichText
            text:  qsTr("Il n'y-a aucun fichier de log dans le dossier d'importation !<br><br>\
Si vous voulez importer des nouvelles données dans la base, vous devez télécharger au péalable vos fichiers dans le répertoire : <br><br>    - <b>" +
                        StandardPaths.writableLocation(StandardPaths.AppLocalDataLocation).toString().replace(StandardPaths.writableLocation(StandardPaths.HomeLocation), "~") +
                        "/" + myDomaine + "/importEvt")
            font.pixelSize: 14

        }


    }



    Item {
        id: selection
        width: 700
        height: buttonImport.height + 10
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        visible: myListeFile.length > 0 ? true : false

        Label {
            id: label
            text: qsTr("Aucun fichier de sélectionné !")
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 20
        }

        Button {
            id: buttonDel
            text: qsTr("Supprimer")
            enabled: false
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: buttonImport.left
            anchors.rightMargin: 20
            highlighted: false
            Material.accent: Material.Red
            onClicked: messageDialog.open()
        }
         Button {
             id: buttonImport
             text: qsTr("Importer")
             enabled: false
             anchors.verticalCenter: parent.verticalCenter
             anchors.right: parent.right
             anchors.rightMargin: 20
             highlighted: false
             Material.accent: Material.Green
             onClicked: backend.importEvtFile(myNbFile, myDomaine)
         }
    }

    Dialog {
        id: messageDialog
        anchors.centerIn: parent
        modal: true
        title: myNbFile === 1 ? "Suppression du fichier event*.zip sélectionné ?" : "Suppression des "+ myNbFile + " fichiers connexion*.zip sélectionnés ?"
        standardButtons: MessageDialog.No | MessageDialog.Yes
        visible: false
        onAccepted: backend.delEvtFile(myNbFile)
        onRejected: messageDialog.close()
    }



    Connections{
        target: backend

        function onSetFile(listeFile, domaine) {
            myListeFile = listeFile
            myDomaine = domaine
            //console.log("Longueur ListeFile : " + myListeFile.length)

        }

        function onSetNbFileEvt(nbFile) {
            myNbFile = nbFile
            if (nbFile === 0) {
                label.text = qsTr("Il y-a actuellement aucun fichier sélectionné !")
                buttonDel.enabled = false
                buttonDel.highlighted = false
                buttonImport.enabled = false
                buttonImport.highlighted = false
            }
            else if (nbFile === 1 ){
                label.text = qsTr("Il y-a actuellement 1 fichier sélectionné.")
                buttonDel.enabled = true
                buttonDel.highlighted = true
                buttonImport.enabled = true
                buttonImport.highlighted = true
            }
            else {
                label.text = qsTr("Il y-a actuellement " + nbFile + qsTr(" fichiers sélectionnés."))
                buttonDel.enabled = true
                buttonDel.highlighted = true
                buttonImport.enabled = true
                buttonImport.highlighted = true
            }
        }


    }


}
