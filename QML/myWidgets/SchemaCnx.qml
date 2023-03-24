import QtQuick

import QtQuick.Window
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Dialogs

//import "../mywidgets"
import "qrc:/QML/myWidgets"



Rectangle {

    id: itemCnx
    property int couleur: Material.Indigo
    property int mode: Material.Dark

    property date dateEvent: "2022-10-19 09:25:00"
    property date dateCurseur: new Date()
    property var cnxModel: []

    property string position: ""
    property int curseur: 900
    property int marqueur: 900
    property int moveDate: 0

    Material.theme: mode
    Material.accent: couleur

    width: 1330
    height: listUser.height + afficheHeure.height + titre.height + listUser.anchors.topMargin + 5
    anchors.left: parent.left
    visible: false
    color: Material.backgroundColor
//    color: "red"


    function splitUser(cnxModel, position) {
        if (cnxModel.length > 0 ) {
    //        console.log("main.qml : function splitUser appelée.")
    //        console.log("Connexions.qml : longueur du model : ", cnxModel.length)
    //        console.log("main.qml : model traite ", cnxModel[0])
            var listUser = []
            var cnx
            var i = 0
            for (i=0; i< cnxModel.length; i++) {
                cnx = cnxModel[i]
                //  listUser.push(cnx[3][1])
                listUser.push(cnx[3])
            }
            let unique = [...new Set(listUser)]

            var modelUser = []
            for (i=0; i < unique.length; i++) {
                var myModel = '['
                //console.log(modelUser[0].user)
                for (var j=0; j < cnxModel.length; j++) {

                    if (cnxModel[j][3] === listUser[i]) { // on ne traite que le user courant
                        //console.log("Connexions.qml Model : User trouvé")
                        //console.log("strat_time : ", cnxModel[j][0][1])
                        myModel = myModel + '{"start_time": "' + cnxModel[j][0] + '", "end_time": "' + cnxModel[j][1] + '", "channel": "' + cnxModel[j][2] + '"},'
                        //console.log("Connexions.qml Model extrait : ",myModel)
                    }
                }
                modelUser.push({user:  listUser[i], model: myModel.substring(0, myModel.length-1) + ']', position: position})

            }
            //console.log("main.qml : model[0] en sortie ", modelUser[0].user, modelUser[0].model)
            //console.log("main.qml : model[1] en sortie ", modelUser[1].user, modelUser[1].model)
            return modelUser
        }
    }


    Label {
        id: titre
        anchors.top: parent.top
        anchors.right:parent.right
        anchors.left: parent.left

        text: titreMextrics.text
        font.bold: true
        font.pointSize: 16
        horizontalAlignment: Text.AlignHCenter
    }

    TextMetrics {
        id: titreMextrics
        text: "titre"
        font.bold: true
        font.pointSize: 16
    }


    Column {
        id: listUser
        anchors.top: titre.bottom
        anchors.topMargin: 10
        spacing: 2

        Repeater {
            id: userRepeater
            model: splitUser(cnxModel)


            User {
                id: user
                anchors.left: parent.left
                nom: modelData.user
                cnxModel: modelData.model
                position: modelData.position
                dateRef: dateEvent
            }
        }
    }



    Canvas {
        id: canvasCurseur
        anchors.fill: parent
        anchors.leftMargin: 130
        anchors.topMargin: titreMextrics.height + listUser.anchors.topMargin

        onPaint: {
            var ctx = getContext("2d")

            ctx.reset()
            ctx.strokeStyle = Material.color(couleur, Material.Shade500)
            ctx.beginPath()
            ctx.lineWidth= 1
            ctx.moveTo(itemCnx.marqueur, 0)
            ctx.lineTo(itemCnx.marqueur, listUser.height)
            ctx.stroke()

            ctx.strokeStyle = Material.color(Material.BlueGrey, Material.Shade400)

            ctx.beginPath()
            ctx.moveTo(itemCnx.curseur, 0)
            ctx.lineTo(itemCnx.curseur, listUser.height)
            ctx.stroke()

        }

    }

    TextMetrics {
        id: heure1
        text: ""
    }

    Rectangle {
        id: afficheHeure
        anchors.bottom: parent.bottom // ne pas mettre fenetrePrincipale
        anchors.bottomMargin: 2
        anchors.left: parent.left
        anchors.leftMargin: 900 + 130 - 5 - zoneHeure.width / 2
        color: Material.color(Material.BlueGrey, Material.Shade400)
        width: zoneHeure.width  + 10
        height: zoneHeure.height + 8
        visible: false
        Text {
            id: heureLabel
            text: zoneHeure.text
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: Material.foreground
        }
    }


    TextMetrics {
        id: zoneHeure
        text: dateEvent.toLocaleTimeString(Qt.locale("fr_FR"), "hh:mm:ss")
    }


    Rectangle {
        id: afficheMarqueur
        anchors.top: titre.bottom // ne pas mettre fenetrePrincipale
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 900 + 130 - 5 - zoneMarqueur.width / 2
        color: Material.color(couleur, Material.Shade500)
        width: zoneMarqueur.width  + 10
        height: zoneMarqueur.height + 8
        Text {
            id: heureMarqueur
            text: zoneMarqueur.text
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: Material.foreground
        }
    }
    TextMetrics {
        id: zoneMarqueur
        text: dateEvent.toLocaleTimeString(Qt.locale("fr_FR"), "hh:mm:ss")
    }

    MouseArea {
        id: mouse
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
//        anchors.left: parent.left
//        anchors.leftMargin: 130
        width: 1200
        hoverEnabled: true

        onPositionChanged: (mouse)=> {
                               backend.moveCurseur(mouse.x, dateEvent)
            itemCnx.curseur = mouse.x
            canvasCurseur.requestPaint()
            afficheHeure.anchors.leftMargin  =      mouse.x > 1170 ?
                                                    1170  - 5 - zoneHeure.width/2 + 130  :
                                                    mouse.x - 5 - zoneHeure.width /2 + 130
        }

        onClicked: (mouse) =>{
                             //console.log("set marqueur")
                             backend.analyse(dateCurseur, comboBoxPosition.currentText)
                             dateEvent = dateCurseur
                             dateCurseur = new Date(dateCurseur.getTime() + (mouse.x -900) * 1000);
                             backend.moveCurseur(mouse.x, dateEvent)
        }
    }



    Connections{
        target: backend

        function onSetColor(newCouleur) {
            couleur = newCouleur
            canvasCurseur.requestPaint()
        }

        function onSetMode(newMode) {
            mode = newMode
        }


        function onSetHeureSelect(date, heure) {
            dateCurseur = date
            zoneHeure.text = heure
            afficheHeure.visible = true
        }

        function onSetData(listCnx, position, date, dateDebut, dateFin) {
 /*           for (var i=0; i< listCnx.length; i++) {
                console.log(dico[i].length)
                for (var j=0; j<listCnx[i].length; j++) {
                    console.log("boucle finale...")
                    console.log(listCnx[i][j][0], listCnx[i][j][1])
                }
            }
            console.log("Connexions.qml : position", position)
            */

            afficheHeure.visible = false
            userRepeater.model = splitUser(listCnx, position)
            itemCnx.visible = true
            dateEvent = date

            if (typeof userRepeater.model !== "undefined") {
                //afficheHeure.visible = true
                afficheMarqueur.visible = true
                if ((dateDebut.toLocaleString(Qt.locale("fr_FR"), "dd")) === (dateFin.toLocaleString(Qt.locale("fr_FR"), "dd")) ) {
                    titreMextrics.text = "Chronogramme des connexions de " +
                            position + ", du " +
                            dateDebut.toLocaleString(Qt.locale("fr_FR"), "ddd dd MMM yyyy ") + "de " +
                            dateDebut.toLocaleString(Qt.locale("fr_FR"), " hh:mm:ss") + " à " +
                            dateFin.toLocaleTimeString(Qt.locale("fr_FR"), "hh:mm:ss UTC.")
                }
                else {
                    titreMextrics.text = "Chronogramme des connexions de " +
                            position + ", du " +
                            dateDebut.toLocaleString(Qt.locale("fr_FR"), "ddd dd MMM yyyy ") +
                            dateDebut.toLocaleString(Qt.locale("fr_FR"), " hh:mm:ss") + " au " +
                            dateFin.toLocaleString(Qt.locale("fr_FR"), "ddd dd MMM yyyy ") +
                            dateFin.toLocaleTimeString(Qt.locale("fr_FR"), "hh:mm:ss UTC.")
                }
            }
            else {
                afficheHeure.visible = false
                afficheMarqueur.visible = false
                if ((dateDebut.toLocaleString(Qt.locale("fr_FR"), "dd")) === (dateFin.toLocaleString(Qt.locale("fr_FR"), "dd")) ) {
                    titreMextrics.text =  "Il n'y a pas  de connexion pour le receiver " +
                            position + ", sur la période du  " +
                            dateDebut.toLocaleString(Qt.locale("fr_FR"), "ddd dd MMM yyyy ") + "de " +
                            dateDebut.toLocaleString(Qt.locale("fr_FR"), " hh:mm:ss") + " à " +
                            dateFin.toLocaleTimeString(Qt.locale("fr_FR"), "hh:mm:ss UTC.")
                }
                else {
                    titreMextrics.text =  "Il n'y a pas  de connexion pour le receiver " +
                            position + ", du " +
                            dateDebut.toLocaleString(Qt.locale("fr_FR"), "ddd dd MMM yyyy ") +
                            dateDebut.toLocaleString(Qt.locale("fr_FR"), " hh:mm:ss") + " au " +
                            dateFin.toLocaleString(Qt.locale("fr_FR"), "ddd dd MMM yyyy ") +
                            dateFin.toLocaleTimeString(Qt.locale("fr_FR"), "hh:mm:ss NTC.")

                }
            }
        }

    }

}
