import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Controls.Material
import QtCore
//import QtQuick.Layouts

import "myWidgets"



Window {
    id: window

    property int couleur: Material.Grey
    property int mode: Material.Light

    Material.theme: mode
    Material.accent: couleur

    width: 1440
    height: 1050

    minimumWidth: 800
    minimumHeight: 640

    visible: true
    title: qsTr("MAKI : Analyse des connexions et des évènements")

    Rectangle {
        id: topBar
        height: 60
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        color: Material.color(couleur, Material.Shade500)

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
            checked: mode
            onToggled: {
//                mode = ~ mode
                backend.selectionMode(checked)
            }
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
        anchors.bottom: parent.bottom
        color: Material.color(couleur, Material.Shade500)
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
                // lecture du repertoire cnx du domaine
                backend.lireCnxFile()
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
                // lecture du repertoire evt du domaine
                backend.lireEvtFile()
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
            anchors.bottomMargin: 48
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
            source: Qt.resolvedUrl("pages/pgAnalyse.qml")
            visible: true
            clip: true
        }

        Loader {
            id: pageConnexion
            anchors.fill: parent
            source: Qt.resolvedUrl("pages/pgCnx.qml")
            visible: false
            clip: true
        }

        Loader {
            id: pageEvenement
            anchors.fill: parent
            source: Qt.resolvedUrl("pages/pgEvt.qml")
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
            source: Qt.resolvedUrl("pages/pgPref.qml")
            visible: false
            clip: true
        }

        Loader {
            id: pageInformation
            anchors.fill: parent
            source: Qt.resolvedUrl("pages/pgInfo.qml")
            visible: false
            clip: true
        }

    }

    // La basse de dessous
    Rectangle {
        id: bottomBar
        height: 48
//        color: Material.color(couleur, Material.Shade700)
        color: mode ? "#2D2D2D" : "#F6F6F6"
        anchors.left: verticalMenu.right
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 0

        Label {
            id: message
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            width: 300
            opacity: 1
            text: ""
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
    Component.onCompleted: backend.onSetMsg(qsTr("Bienvenue sur l'application."), 1)


    Connections{
        target: backend

        function onSetDomaine(domaine) {
            //console.log("domaine : " + domaine)
            applicationName.text = qsTr("Domaine de travail : <b>") + domaine + "</b>"
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

        function onSetMsg(text, level) {
            // Voir les actions en fonction du level...
            // Idées : jouer sur la durée du message, sur la couleur
            // Debug = 0
            // Info = 1
            // Warning = 2
            // Error = 3
            // Critical =4
            // console.log("onSetMsg : ", text, " ", level )
            switch (level) {
                  case 0: //Debug
                      message.color = Material.color(Material.LightGreen, Material.Shade200)
                      messageAnnimation.duration = 2500
                       break
                  case 1: // Info
                      message.color = Material.color(Material.LightGreen)
                      messageAnnimation.duration = 2500
                      break
                  case 2: // Warning
                      message.color = Material.color(Material.Orange)
                      messageAnnimation.duration = 4000
                      break
                  case 3: // Error
                      message.color = Material.color(Material.Red)
                      messageAnnimation.duration = 5000
                      break
                  case 4: // Critical
                      message.color = Material.color(Material.DeepPurple)
                      messageAnnimation.duration = 5000
                      break

                  default:
            }
            message.text = text
            message.opacity = 1
            messageAnnimation.start()

        }

       /*
       function onSetNoWorkingDir() {
           console.log("main.qml : signal setNoWorkingDir reçu !")
           message.text = qsTr("Le dossier sélectionné n'est pas vide !")
           message.opacity = 1
           messageAnnimation.start()
       }
*/
    }



}
