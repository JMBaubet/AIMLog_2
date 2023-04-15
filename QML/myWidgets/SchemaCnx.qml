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
    property var interfaceModel: [] //[{width: "1200", margin: "0", nbInterface: "3"}]


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


    function splitInterface(interfaceModel, dateDebut, start) {
        var model = []
        var debut
        var longueur
        var marge
        var heureDebut
        var heureFin
        var couleur

        if (interfaceModel.length > 0 ) {
            // console.log("SchemaCnx, splitInterface() : Nous avons au moins une interface déconnectée")
            // console.log("SchemaCnx, splitInterface() : Date de début : " + ref)
            for (var i=0; i<interfaceModel.length; i++) {
                heureDebut = new Date(interfaceModel[i][0])
                heureFin = new Date(interfaceModel[i][1])
                couleur = interfaceModel[i][2]
                start = new Date(start)
                // console.log("SchemaCnx, splitInterface() :           heure de début : " + heureDebut)
                // console.log("SchemaCnx, splitInterface() :             heure de fin : " + heureFin)
                // console.log("SchemaCnx, splitInterface() :                    start : " + start)
                // console.log("SchemaCnx, splitInterface() :                  couleur : " + couleur)

                if (heureDebut < dateDebut) {
                    heureDebut = dateDebut
                }

                if (start > dateDebut) { // Il faut initailiser en gris
                    longueur = (heureDebut - dateDebut) / 1000
                    model.push({
                               margin: 0,
                               width: longueur,
                               nbInterface: 3} )

                }

                //console.log("SchemaCnx, splitInterface() : heure de début recfitiée : " + heureDebut)
                longueur = (heureFin - heureDebut) / 1000
                marge = (heureDebut - dateDebut) / 1000
                //console.log("SchemaCnx, splitInterface() :                    marge : " + marge)
                if (longueur > 1200) longueur = 1200
                //console.log("SchemaCnx, splitInterface() :                  longueur: " + longueur)
                if (marge + longueur > 1200) longueur = 1200 - marge
                model.push({
                           margin: marge,
                           width: longueur,
                           nbInterface: couleur} )
                //debut = (heureDebut - dateDebut) / 1000
                //longueur = (heureFin - heureDebut) / 1000
                //console.log("SchemaCnx, splitInterface() : longueur : " + longueur)
            }
        }
        else if  (start > dateDebut) {

            model.push({
                           margin: 0,
                           width: 1200,
                           nbInterface: 3} )
            //console.log("SchemaCnx, splitInterface() : Toutes les interfaces sont OK")
        }
        return model
    }

    function splitUser(cnxModel, position) {
        // cnxModel : une liste qui contient les listes suivantes  [[start_time], [end-time], [channel_name], [user_name]]
        // Test : 19/10/22, 13h40 SUP_A
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

    Rectangle {
        anchors.left: parent.left
        width : 130
        anchors.top: listUser.bottom
        anchors.bottom: parent.bottom
        color: Material.color(Material.Grey, Material.Shade700)
        Text {
            text: "État des interfaces"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#ffffff"
        }


    }

    Rectangle {
        id: itemInterface
        //anchors.bottomMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 130
        anchors.right: parent.right
        anchors.top: titre.bottom
        anchors.topMargin: 10
        anchors.bottom: parent.bottom
        color: Material.color(Material.Green, Material.Shade700)

        Repeater {
            id: etatInterfaceRepeater
            model: interfaceModel

            EtatInterfaces {
                height: itemInterface.height
                longueur: modelData.width
                nombre: modelData.nbInterface
                leftMargin: modelData.margin
                anchors.left: itemInterface.left
            }
        }
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




    Item {
        id: afficheHeure
        anchors.bottom: parent.bottom // ne pas mettre fenetrePrincipale
        anchors.bottomMargin: 2
        anchors.left: parent.left
        anchors.leftMargin: 900 + 130 - 5 - zoneHeure.width / 2
        //color: Material.color(Material.BlueGrey, Material.Shade400)
        width: zoneHeure.width  + 10
        height: zoneHeure.height + 8
        visible: false
        Text {
            id: heureLabel
            text: zoneHeure.text
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
//            color: Material.foreground
            color: "#ffffff"

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
                                                    mouse.x < zoneHeure.width /2 + 5?
                                                    130 + 5 :
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
            ctx.moveTo(itemCnx.marqueur, 24)
            ctx.lineTo(itemCnx.marqueur, listUser.height)
            ctx.stroke()

            ctx.strokeStyle = "#ffffff"

            ctx.beginPath()
            ctx.moveTo(itemCnx.curseur, 24)
            ctx.lineTo(itemCnx.curseur, listUser.height + 8)
            ctx.stroke()

        }

    }

    TextMetrics {
        id: heure1
        text: ""
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

        function onSetData(listCnx, listEtatInterface, position, date, dateDebut, dateFin, debut) {
            /*for (var i=0; i< listCnx.length; i++) {
                //console.log(dico[i].length)
                for (var j=0; j<listCnx[i].length; j++) {
                    console.log("boucle finale...")
                    console.log(listCnx[i][j][0], listCnx[i][j][1])
                }
            }*/
            //console.log("Connexions.qml : position", position)


            afficheHeure.visible = false
            userRepeater.model = splitUser(listCnx, position)
            etatInterfaceRepeater.model = splitInterface(listEtatInterface, dateDebut, debut)
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
