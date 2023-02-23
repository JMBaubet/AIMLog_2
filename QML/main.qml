import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Controls.Material
import QtCore
//import QtQuick.Layouts

import "myWidgets"


ApplicationWindow {
    id: window

    property int couleur: Material.Indigo
    property int mode: Material.Light

    Material.theme: mode
    Material.accent: couleur

    width: 1440
    height: 1050

    minimumWidth: 800
    minimumHeight: 640

    visible: true
    title: qsTr("MAKI : Analyse des connexions")

    Rectangle {
        id: topBar
        height: 60
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        color: Material.color(couleur, Material.ShadeA500)

        Row {
            id: row
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            spacing: 20

            ToggleButton {
               id: toogle
               windowMode: mode
               materialColor: couleur
               onClicked: animationMenu.running = true
            }

            Image {
                id: logoDSNA
                width: 48
                height: 48
                anchors.verticalCenter: parent.verticalCenter
                source: Qt.resolvedUrl("qrc:/icons/DGAC_DSNA.svg")
                fillMode: Image.PreserveAspectFit
            }

            Label {
                id: applicationName
                width: 470
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignLeft
                text: qsTr("Domaine de travail : <b>À configurer</b>")
                font.pointSize: 16
            }
        }

        // Switch pour le changement de mode Claire/Sombre
        Image {
            id: imageSun
            property string iconSource: if(mode === Material.Light ){
                                               "qrc:/icons/light/sun.svg"}
                                           else {
                                               "qrc:/icons/dark/sun.svg"
                                           }
            width: 32
            height: 32
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: switchMode.left
            anchors.rightMargin: 10
            fillMode: Image.PreserveAspectFit
            source: Qt.resolvedUrl(iconSource)
        }

        Switch {
            id: switchMode
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: imageMoon.left
            anchors.rightMargin: 10
            checked: mode ? true : false
//            onToggled: mode = checked // mode et checked ont les valeurs 0 ou 1
            onToggled: backend.selectionMode(checked)
        }

        Image {
            id: imageMoon
            property string iconSource: if(mode === Material.Light ){
                                               "qrc:/icons/light/moon.svg"}
                                           else {
                                               "qrc:/icons/dark/moon.svg"
                                           }
            width: 32
            height: 32
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 10
            fillMode: Image.PreserveAspectFit
            source: Qt.resolvedUrl(iconSource)
        }


    }  // fin de la topBar

    // VerticalMenu

    Rectangle {
        id: verticalMenu
        width: 70 //240
        anchors.top: topBar.bottom
        anchors.bottom: bottomBar.top
        color: Material.color(couleur, Material.ShadeA500)
        clip: true // si pas positionné la souris est active sur 240 pixels de large

        PropertyAnimation{
            id: animationMenu
            target: verticalMenu
            property: "width"
            to: if (verticalMenu.width === 70) return 240; else return 70
            duration: 700
            easing.type: Easing.OutBounce
        }



        LeftMenuButton {
            id: menuHome
            windowMode: mode
            materialColor: couleur
            anchors.left: parent.left

            anchors.top: parent.top
            btnIconSource: "home.svg"
            btnText: "Page principale"

            isActive: true
            onClicked: {
                menuHome.isActive = true
                pageHome.visible = true
                menuImportCnx.isActive = false
                pageConnexion.visible = false
                menuImportEvt.isActive = false
                pageEvenement.visible = false
                menuSettings.isActive = false
                pagePreference.visible = false
                menuInformation.isActive = false
                pageInformation.visible = false
            }
        }

        LeftMenuButton {
            id: menuImportCnx
            windowMode: mode
            materialColor: couleur
            anchors.left: parent.left

            anchors.top: menuHome.bottom
            btnIconSource: "activity.svg"
            btnText: "Importation\ndes connexions"
            onClicked: {
                menuHome.isActive = false
                pageHome.visible = false
                menuImportCnx.isActive = true
                pageConnexion.visible = true
                menuImportEvt.isActive = false
                pageEvenement.visible = false
                menuSettings.isActive = false
                pagePreference.visible = false
                menuInformation.isActive = false
                pageInformation.visible = false
            }
        }

        LeftMenuButton {
            id: menuImportEvt
            windowMode: mode
            materialColor: couleur
            anchors.left: parent.left

            anchors.top: menuImportCnx.bottom
            btnIconSource: "trending-down.svg"
            btnText: "Importation\ndes évènements"
            onClicked: {
                menuHome.isActive = false
                pageHome.visible = false
                menuImportCnx.isActive = false
                pageConnexion.visible = false
                menuImportEvt.isActive = true
                pageEvenement.visible = true
                menuSettings.isActive = false
                pagePreference.visible = false
                menuInformation.isActive = false
                pageInformation.visible = false
            }
        }


        LeftMenuButton {
            id: menuSettings
            windowMode: mode
            materialColor: couleur
            anchors.left: parent.left

            anchors.bottom: menuInformation.top
            btnIconSource: "settings.svg"
            btnText: "Paramétrage"
            onClicked: {
                menuHome.isActive = false
                pageHome.visible = false
                menuImportCnx.isActive = false
                pageConnexion.visible = false
                menuImportEvt.isActive = false
                pageEvenement.visible = false
                menuSettings.isActive = true
                pagePreference.visible = true
                menuInformation.isActive = false
                pageInformation.visible = false
            }
        }

        LeftMenuButton {
            id: menuInformation
            windowMode: mode
            materialColor: couleur
            anchors.left: parent.left

            anchors.bottom: parent.bottom
            btnIconSource: "info.svg"
            btnText: "Informations"
            onClicked: {
                menuHome.isActive = false
                pageHome.visible = false
                menuImportCnx.isActive = false
                pageConnexion.visible = false
                menuImportEvt.isActive = false
                pageEvenement.visible = false
                menuSettings.isActive = false
                pagePreference.visible = false
                menuInformation.isActive = true
                pageInformation.visible = true
            }
        }

    }

    Rectangle {
        id: centralWidget
        anchors.left: verticalMenu.right
        anchors.right: parent.right
        anchors.top: topBar.bottom
        anchors.bottom: bottomBar.top
        color: Material.background

        Loader {
            id: pageHome
            anchors.fill: parent
            source: Qt.resolvedUrl("pages/home.qml")
            visible: true
            clip: true
        }

        Loader {
            id: pageConnexion
            anchors.fill: parent
            source: Qt.resolvedUrl("pages/connexion.qml")
            visible: false
            clip: true
        }

        Loader {
            id: pageEvenement
            anchors.fill: parent
            source: Qt.resolvedUrl("pages/evenement.qml")
            visible: false
            clip: true
        }
/*
        Loader {
            id: pageDatabase
            anchors.fill: parent
            source: Qt.resolvedUrl("pages/database.qml")
            visible: false
            clip: true
        }
*/
        Loader {
            id: pagePreference
            anchors.fill: parent
            source: Qt.resolvedUrl("pages/preference.qml")
            visible: false
            clip: true
        }

        Loader {
            id: pageInformation
            anchors.fill: parent
            source: Qt.resolvedUrl("pages/information.qml")
            visible: false
            clip: true
        }

    }

    Rectangle {
        id: bottomBar
        height: 48
        color: Material.color(couleur, Material.Shade700)
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        Label {
            id: message
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            width: 300
            opacity: 1
            text: qsTr("")
            font.bold: true

            PropertyAnimation{
                id: messageAnnimation
                target: message
                property: "opacity"
                to: if (message.text !== "") return 0
                duration: 2500
                easing.type: Easing.InElastic
                easing.period: 3
            }


        }
    }


    Connections{
        target: backend

       function onSetDatabase(name) {
            applicationName.text = "Base de travail : " + name
        }


       function onAffichePreferences() {
           menuHome.isActive = false
           pageHome.visible = false
           menuImportCnx.isActive = false
           pageConnexion.visible = false
           menuImportEvt.isActive = false
           pageEvenement.visible = false
           menuSettings.isActive = true
           pagePreference.visible = true
           menuInformation.isActive = false
           pageInformation.visible = false
       }

       function onSetColor(newCouleur) {
           couleur = newCouleur
       }

       function onSetMode(newMode) {
           mode = newMode
       }

       function onSetNoWorkingDir() {
           console.log("main.qml : signal setNoWorkingDir reçu !")
           message.text = qsTr("Le dossier sélectionné n'est pas vide !")
           message.opacity = 1
           messageAnnimation.start()

       }

    }



}
