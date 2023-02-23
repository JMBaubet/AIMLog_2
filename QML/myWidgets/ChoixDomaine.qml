import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Dialogs
import QtCore

import "../myWidgets"

Frame {
    property int materialColor: Material.Red
    property int windowMode: Material.Dark
    property int frameWidth: 700
    property int buttonWidth: 95

    id: choixDomaine
    width: frameWidth
    height: domaine.height + bdd.height + cnx.height + evt.height + 50

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
            text: qsTr("Choix, suppression et paramétrage du domaine de travail")
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            font.pixelSize: 14
            font.bold: true
            anchors.leftMargin: 20
        }
    }

    Item {
        id: domaine
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.top: rectanglechoixDomaine.bottom
        anchors.topMargin: 10
        height: labelDomain.height + 20


        Label {
            id: labelDomain
            text: qsTr("Domaine de travail :")
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: "AlignRight"
            width: Math.max(labelBdd.width, labelEvt.width, labelCnx.width)
        }

        ComboBox {
            id: comboBox
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: labelDomain.right
            anchors.leftMargin: 10
        }

        Button {
            id: buttonChoixDomaine
            anchors.right: buttonDelDomaine.left
            anchors.rightMargin: 10

            text: qsTr("Sélectionner")
            anchors.verticalCenter: parent.verticalCenter
            width: buttonWidth
            highlighted: true
            Material.accent: Material.LightGreen
            onClicked: folderDialog.open()
        }

        Button {
            id: buttonDelDomaine
            text: qsTr("Supprimer")
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: buttonWidth
            highlighted: true
            Material.accent: Material.Orange
            onClicked: folderDialog.open()
        }

    }

    Row {
        id: bdd
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: domaine.bottom
        anchors.topMargin: 0
        anchors.leftMargin: 20
        anchors.rightMargin: 20

        Label {
            id: labelBdd
            text: qsTr("Durée de rétention dans la base de données :")
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: "AlignRight"
            width: labelCnx.width
            //width: Math.max(labelDomain.width, labelEvt.width, labelCnx.width)
        }

        RetentionCalcul {
            unite: "mois"
            duree: 12
            onDureeChanged: console.log("changement : " + duree + unite)

        }
    }

    Row {
        id: cnx
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: bdd.bottom
        anchors.leftMargin: 20
        anchors.rightMargin: 20

        Label {
            id: labelCnx
            text: qsTr("Durée de rétention des fichiers de connexions :")
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: "AlignRight"
//            width: Math.max(labelDomain.width, labelBdd.width, labelEvt.width, labelCnx.width)

        }

        RetentionCalcul {
            onDureeChanged: console.log("changement : " + duree + unite)
        }
    }

    Row {
        id: evt
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: cnx.bottom
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        Label {
            id: labelEvt
            text: qsTr("Durée de rétention des fichiers d'évnements :")
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: "AlignRight"
            width: labelCnx.width
            //width: Math.max(labelDomain.width, labelEvt.width, labelCnx.width)
        }

        RetentionCalcul {
            onDureeChanged: console.log("changement : " + duree + unite)
        }
    }

    Button {
        id: valider
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: buttonWidth
        text: qsTr("Valider")

    }

}
