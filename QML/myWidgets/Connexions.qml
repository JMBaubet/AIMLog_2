import QtQuick

import QtQuick.Window
import QtQuick.Controls
import QtQuick.Controls.Material


import "../mywidgets"



Rectangle {

    id: itemCnx
    property int couleur: Material.Indigo
    property int mode: Material.Dark

    property date dateEvent: "2022-10-19 09:25:00"
    property var cnxModel: []

    property string position: ""

    property date dateCurseur: new Date()
    property int curseur: 900

    Material.theme: mode
    Material.accent: couleur

    width: 1370
    height: listUser.height + afficheHeure.height + 10
    visible: false
    color: Material.backgroundColor

//    title: qsTr("Test connexions")
//    color: Material.background


    function splitUser(cnxModel, position) {
        if (cnxModel.length > 0 ) {
    //        console.log("main.qml : function splitUser appelée.")
            console.log("Connexions.qml : longueur du model : ", cnxModel.length)
    //        console.log("main.qml : model traite ", cnxModel[0])
            var listUser = []
            var cnx
            var i = 0
            for (i=0; i< cnxModel.length; i++) {
                cnx = cnxModel[i]
                listUser.push(cnx[3][1])
            }
            let unique = [...new Set(listUser)]


            var modelUser = []
            for (i=0; i < unique.length; i++) {
                //modelUser.push({user:  listUser[i]})
                var myModel = '['
                //console.log(modelUser[0].user)
                for (var j=0; j < cnxModel.length; j++) {

                    if (cnxModel[j][3][1] === listUser[i]) {
                        console.log("Connexions.qml Model : User trouvé")
                        console.log("strat_time : ", cnxModel[j][0][1])
                        //myModel = myModel + "{start_time: '" + cnxModel[j].start_time + "', end_time: '" + cnxModel[j].end_time + "', channel: '" + cnxModel[j].channel + "'},"
                        myModel = myModel + '{"start_time": "' + cnxModel[j][0][1] + '", "end_time": "' + cnxModel[j][1][1] + '", "channel": "' + cnxModel[j][2][1] + '"},'
                        console.log("Connexions.qml Model extrait : ",myModel)
                    //console.log("")
                    }
                }
                modelUser.push({user:  listUser[i], model: myModel.substring(0, myModel.length-1) + ']', position: position})

            }
            console.log("main.qml : model[0] en sortie ", modelUser[0].user, modelUser[0].model)
            //console.log("main.qml : model[1] en sortie ", modelUser[1].user, modelUser[1].model)
            return modelUser
        }
    }


    // Ici il faut mettre un repeater en fonction du nbr de User

    Column {
        id: listUser
        spacing: 2

        Repeater {
            id: userRepeater
            model: splitUser(cnxModel)


            User {
                id: user
                anchors.left: parent.left
                anchors.leftMargin: 40
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

        onPaint: {
            var ctx = getContext("2d")

            ctx.reset()
            ctx.strokeStyle = Material.color(couleur, Material.ShadeA500)

            ctx.beginPath()
            ctx.lineWidth= 2
            ctx.setLineDash([4,2])
            ctx.moveTo(itemCnx.curseur, 0)
            ctx.lineTo(itemCnx.curseur, width)

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
        anchors.left: parent.left
        anchors.leftMargin: 900
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
        anchors.left: parent.left
        anchors.leftMargin: 40
        anchors.rightMargin: 1370 - 1200 - 40 -1
        hoverEnabled: true

        onPositionChanged: (mouse)=> {
                               var xCurseur  = mouse.x + 40
//                               if (xCurseur < 40) {xCurseur = 40}
//                               if (xCurseur >= 1240) {xCurseur = 1240}
                               backend.moveCurseur(xCurseur, dateEvent)
            //console.log("X : " + mouse.x)
            //splitUser(cnxModel)
            itemCnx.curseur = xCurseur
            canvasCurseur.requestPaint()
            afficheHeure.anchors.leftMargin  = (xCurseur - 5 - zoneHeure.width /2) <= 0 ? 0  : (xCurseur + 5 + zoneHeure.width / 2) > itemCnx.width ? itemCnx.width  - 10 - zoneHeure.width  :  xCurseur - 5 - zoneHeure.width /2
        }

        onDoubleClicked: itemCnx.visible = false
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
        }

        function onSetData(listCnx, position) {
            for (var i=0; i< listCnx.length; i++) {
//                console.log(dico[i].length)
                for (var j=0; j<listCnx[i].length; j++) {
//                    console.log("boucle finale...")
                    console.log(listCnx[i][j][0], listCnx[i][j][1])
                }
            }
            console.log("Connexions.qml : position", position)
            userRepeater.model = splitUser(listCnx, position)
            itemCnx.visible = true
        }

    }

}
