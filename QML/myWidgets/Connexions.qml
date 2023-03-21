import QtQuick

import QtQuick.Window
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Dialogs


import "../mywidgets"


Rectangle {

    id: itemCnx
    property int couleur: Material.Indigo
    property int mode: Material.Dark

    property date dateEvent: "2022-10-19 09:25:00"
    property var cnxModel: []

    property string position: ""
    property int curseur: 900
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

    /*
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.top: listUser.bottom
        anchors.right : parent.right
        anchors.left: parent.left

        color:"transparent"
        Canvas {
            id: canvastimeLine
            anchors.fill: parent
            anchors.leftMargin: 130
            anchors.topMargin: 2

            onPaint: {
                var ctx = getContext("2d")

                ctx.reset()
                ctx.strokeStyle = Material.color(Material.Grey, Material.ShadeA500)

                ctx.beginPath()
                ctx.lineWidth= 2
                ctx.moveTo(0, 4)
                ctx.lineTo(0, 1)
                ctx.lineTo(1200, 1)
                ctx.lineTo(1200, 4)
                ctx.moveTo(300, 4)
                ctx.lineTo(300, 1)
                ctx.moveTo(600, 4)
                ctx.lineTo(600, 1)
                ctx.moveTo(900, 4)
                ctx.lineTo(900, 1)

                ctx.stroke()

            }

        }

    }
    */


    Canvas {
        id: canvasCurseur
        anchors.fill: parent
        anchors.leftMargin: 130
        anchors.topMargin: titreMextrics.height + listUser.anchors.topMargin

        onPaint: {
            var ctx = getContext("2d")

            ctx.reset()
            ctx.strokeStyle = Material.color(couleur, Material.ShadeA500)

            ctx.beginPath()
            ctx.lineWidth= 2
            ctx.setLineDash([4,2])
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
        color: Material.color(couleur, Material.ShadeA500)
        width: zoneHeure.width  + 10
        height: zoneHeure.height + 8
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

        onDoubleClicked: itemCnx.visible = false
        onPressed: (mouse)=> {
                            moveDate = Math.round(mouse.x)
                            console.log(moveDate)
                        }
        onReleased: (mouse)=> {
                    var delta =  Math.round(mouse.x) - moveDate
                    console.log(delta)

                    backend.changeDateRef(Math.round(mouse.x) - moveDate, dateEvent, position)

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
//            dateCurseur = date
            zoneHeure.text = heure
        }

        function onSetData(listCnx, position, dateDebut, dateFin) {
 /*           for (var i=0; i< listCnx.length; i++) {
                console.log(dico[i].length)
                for (var j=0; j<listCnx[i].length; j++) {
                    console.log("boucle finale...")
                    console.log(listCnx[i][j][0], listCnx[i][j][1])
                }
            }
            console.log("Connexions.qml : position", position)
            */
            userRepeater.model = splitUser(listCnx, position)
            itemCnx.visible = true

            if (typeof userRepeater.model !== "undefined") {
                afficheHeure.visible = true
                if ((dateDebut.toLocaleString(Qt.locale("fr_FR"), "dd")) === (dateFin.toLocaleString(Qt.locale("fr_FR"), "dd")) ) {
                    titreMextrics.text = "Chronogramme des connexions de " +
                            position + ", du " +
                            dateDebut.toLocaleString(Qt.locale("fr_FR"), "ddd dd MMM yyyy ") + "de " +
                            dateDebut.toLocaleString(Qt.locale("fr_FR"), " hh:mm:ss") + " à " +
                            dateFin.toLocaleTimeString(Qt.locale("fr_FR"), "hh:mm:ss.")
                }
                else {
                    titreMextrics.text = "Chronogramme des connexions de " +
                            position + ", du " +
                            dateDebut.toLocaleString(Qt.locale("fr_FR"), "ddd dd MMM yyyy ") +
                            dateDebut.toLocaleString(Qt.locale("fr_FR"), " hh:mm:ss") + " au " +
                            dateFin.toLocaleString(Qt.locale("fr_FR"), "ddd dd MMM yyyy ") +
                            dateFin.toLocaleTimeString(Qt.locale("fr_FR"), "hh:mm:ss.")
                }
            }
            else {
                afficheHeure.visible = false
                if ((dateDebut.toLocaleString(Qt.locale("fr_FR"), "dd")) === (dateFin.toLocaleString(Qt.locale("fr_FR"), "dd")) ) {
                    titreMextrics.text =  "Il n'y a pas  de connexion pour le receiver " +
                            position + ", sur la période du  " +
                            dateDebut.toLocaleString(Qt.locale("fr_FR"), "ddd dd MMM yyyy ") + "de " +
                            dateDebut.toLocaleString(Qt.locale("fr_FR"), " hh:mm:ss") + " à " +
                            dateFin.toLocaleTimeString(Qt.locale("fr_FR"), "hh:mm:ss.")
                }
                else {
                    titreMextrics.text =  "Il n'y a pas  de connexion pour le receiver " +
                            position + ", du " +
                            dateDebut.toLocaleString(Qt.locale("fr_FR"), "ddd dd MMM yyyy ") +
                            dateDebut.toLocaleString(Qt.locale("fr_FR"), " hh:mm:ss") + " au " +
                            dateFin.toLocaleString(Qt.locale("fr_FR"), "ddd dd MMM yyyy ") +
                            dateFin.toLocaleTimeString(Qt.locale("fr_FR"), "hh:mm:ss.")

                }
            }
        }

    }

}
