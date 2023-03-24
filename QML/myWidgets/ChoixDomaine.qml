import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Dialogs
import QtCore

//import "../myWidgets"
import "qrc:/QML/myWidgets"

Frame {
    property int materialColor: Material.Red
    property int windowMode: Material.Dark
    property int frameWidth: 700
    property int buttonWidth: 95

    id: choixDomaine
    width: frameWidth
    height: domaine.height + bdd.height + cnx.height + evt.height + 50 + choixCouleur.height

    Rectangle {
        id: rectanglechoixDomaine
        height: 26
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 0
        anchors.topMargin: 0
        color: Material.color(couleur, Material.Shade500)

        Label {
            id: labelchoixDomaine
            text: qsTr("Sélection, suppression et paramétrage du domaine de travail")
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
            id: comboBoxDomain
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: labelDomain.right
            anchors.leftMargin: 10
            onCurrentValueChanged: backend.preselectDomaine(currentText)
        }

        Button {
            id: buttonChoixDomaine
            anchors.right: buttonDelDomaine.left
            anchors.rightMargin: 10

            text: qsTr("Sélectionner")
            anchors.verticalCenter: parent.verticalCenter
            width: buttonWidth
            highlighted: false
            enabled: false
            Material.accent: Material.LightBlue
            onClicked: backend.selectDomaine(comboBoxDomain.currentText)
        }

        Button {
            id: buttonDelDomaine
            text: qsTr("Supprimer")
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: buttonWidth
            highlighted: false
            enabled: false
            Material.accent: Material.Orange
//            onClicked: backend.delDomaine(comboBoxDomain.currentText)
            onClicked: messageDialog.open()
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
            id: retentionBdd
            unite: "mois"
            duree: 6
            //onDureeChanged: console.log("changement : " + duree + unite)
            onDureeChanged: backend.checkRetention(comboBoxDomain.currentText,
                                                    retentionBdd.duree,
                                                    retentionBdd.unite,
                                                    retentionCnx.duree,
                                                    retentionCnx.unite,
                                                    retentionEvt.duree,
                                                    retentionEvt.unite)
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
            id: retentionCnx
            //onDureeChanged: console.log("changement : " + duree + unite) // il faut enregistrer la nouvelle valeur
            onDureeChanged: backend.checkRetention(comboBoxDomain.currentText,
                                                    retentionBdd.duree,
                                                    retentionBdd.unite,
                                                    retentionCnx.duree,
                                                    retentionCnx.unite,
                                                    retentionEvt.duree,
                                                    retentionEvt.unite)
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
            id: retentionEvt
            //onDureeChanged: console.log("changement : " + duree + unite)
            onDureeChanged: backend.checkRetention(comboBoxDomain.currentText,
                                                    retentionBdd.duree,
                                                    retentionBdd.unite,
                                                    retentionCnx.duree,
                                                    retentionCnx.unite,
                                                    retentionEvt.duree,
                                                    retentionEvt.unite)
        }
    }

    Button {
        id: valider
        anchors.right: parent.right
        anchors.bottom: evt.bottom
        width: buttonWidth
        highlighted: false
        enabled: false
        Material.accent: Material.LightGreen
        text: qsTr("Valider")
        onClicked: {
            backend.saveRetention(comboBoxDomain.currentText,
            retentionBdd.duree, retentionBdd.unite,
            retentionCnx.duree, retentionCnx.unite,
            retentionEvt.duree, retentionEvt.unite);

			valider.enabled = false;
			valider.highlighted = false;
        }

    }

    ChoixCouleur {
        id: choixCouleur
        anchors.top: valider.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        windowMode: windowMode
        materialColor: materialColor
    }



    Dialog {
        id: messageDialog
        anchors.centerIn: parent
        modal: true
        title: "Suppression du domaine " + comboBoxDomain.currentText + " ?"
        standardButtons: MessageDialog.No | MessageDialog.Yes
        visible: false
        onAccepted: backend.delDomaine(comboBoxDomain.currentText)
        onRejected: messageDialog.close()
    }

    Connections{
        target: backend

        function onSetDomaines(domaines) {
            comboBoxDomain.model = domaines
        }

        function onInitDomaines(domaines, domaine) {
            comboBoxDomain.model = domaines
            while (comboBoxDomain.currentText !== domaine) {
                comboBoxDomain.incrementCurrentIndex()
            }
        }

        function onSetRetention(retention) {
            retentionBdd.unite = retention["BddUnit"]
            retentionBdd.duree = retention["BddValue"]
            retentionCnx.unite = retention["CnxUnit"]
            retentionCnx.duree = retention["CnxValue"]
            retentionEvt.unite = retention["EvtUnit"]
            retentionEvt.duree = retention["EvtValue"]
            //console.log("retentionCnx.unite : " + retentionCnx.unite)
            //console.log("retentionCnx.value : " + retentionCnx.duree)
        }

		function onChangeRetention(changed) {
			valider.enabled = changed
			valider.highlighted = changed
		}

        function onChangeDomaine(boutonValide) {
            buttonChoixDomaine.enabled = boutonValide
            buttonChoixDomaine.highlighted = boutonValide
            buttonDelDomaine.enabled = boutonValide
            buttonDelDomaine.highlighted = boutonValide
        }
    }



}
