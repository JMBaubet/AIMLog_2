import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material

import "qrc:/QML/myWidgets"

Rectangle {

    property string nom: ""
    property string position: ""

/*
    property date dateRef: '2022-11-21 15:00:00'
*/
/*
    property var cnxModel: [
                    {'start_time': '2022-11-18 14:06:33', 'end_time': '2022-11-21 14:58:14', 'channel': 'AVISO_Tech', 'user': 'sup_a'},
                    {'start_time': '2022-11-21 14:58:14', 'end_time': '2022-11-21 14:58:43', 'channel': 'AVISO_Tech', 'user': 'sup_a'},
                    {'start_time': '2022-11-21 14:58:43', 'end_time': '2022-11-21 15:16:22', 'channel': 'BDS01_A_VO', 'user': 'sup_a'}
                ]

    property date dateRef: '2022-10-19 09:25:00'
    property string cnxModel: '[{"start_time": "2022-10-19 09:26:02", "end_time": "2022-10-19 09:26:24", "channel": "BDS01_B_VO"}]'
*/
    property date dateRef: '2000-01-01 00:00:00'
    property string cnxModel: ''



    id: userItem
    width: 1330
    height: channels.height + userName.height
    color: nom === "admin" ?
               Material.color(Material.DeepOrange, Material.Shade100) :
               nom.toUpperCase() === position.toUpperCase() ?
                   Material.color(Material.Green, Material.Shade100) :
                   Material.color(Material.Blue, Material.Shade100)


    function calculCnxPoint(cnxModel, dateRef) {
        //console.log("User.qml : function calculCnxPoint appelée, dateRef : ", dateRef)
        var dict = JSON.parse(cnxModel);
        // console.log("User.qml : cnxModel", cnxModel, "longueur : ", cnxModel.length)

        //console.log("User.qml : dict", dict, "longueur : ", dict.length)

        var newModel = []
        var warningHeureFin = false
        const ref = new Date(dateRef)
        for (var i = 0; i <dict.length; i++)  {     // voir : https://www.youtube.com/watch?v=x2pidX7xRlw
            //console.log(dict[i].start_time)
            const dateDebut = new Date(dict[i].start_time)
            const dateFin = new Date(dict[i].end_time)
            //if (dateFin >= new Date (2099, 12, 01)) {
            if (dateFin >= new Date ('2099-12-31 23:59:59')) {
                warningHeureFin = true
            }

            var diffDebut = 900 - ((ref - dateDebut) / 1000)
            if (diffDebut < 0) diffDebut = 0
            var diffFin = 900 - ((ref - dateFin) / 1000)
            if (diffFin > 1200) diffFin = 1200

            //console.log("dates :", diffDebut, diffFin)
            newModel.push({                             // voir : https://stackoverflow.com/questions/7196212/how-to-create-dictionary-and-add-key-value-pairs-dynamically-in-javascript
                          start_time: diffDebut,
                          end_time: diffFin,
                          channel: dict[i].channel,
                          warning: warningHeureFin
                          })

        }
        //console.log(newModel)
        return newModel
    }


    Rectangle {
        id: userName
        anchors.top: parent.top
        anchors.left: parent.left
        color: nom.substring(0, 5) === "admin" ?
                   Material.color(Material.DeepOrange, Material.Shade500) :
                   nom.toUpperCase() === position.toUpperCase() ?
                       Material.color(Material.Green, Material.Shade500) :
                       Material.color(Material.Blue, Material.Shade500)
        height: userText.height + 8
        width: 130

        Text {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: userText.text
        }
        //Component.onCompleted: console.log("User.qml : Debug")

    }

    TextMetrics {                   // Permet de calculer la hauteur du rectangle userName en fonction de la police de caractère
        id: userText
        text: "Login : <b>" + nom + "</b>"
    }

    Item {
        anchors.top: userName.bottom
        anchors.left:parent.left
        anchors.right: parent.right
        //Component.onCompleted: console.log("User.qml : cnxModel reçu : ", cnxModel)

        Column {
            id: channels
            spacing: 2

            Repeater {
                id: user
                model: calculCnxPoint(cnxModel, dateRef)

                Row {
                    id: rangee

                    Text {
                        text: modelData.channel
                        width: modelData.start_time + 120
                        height: 25
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        opacity: modelData.warning ? 0.2 : 1

                    }
                    Item {
                        Rectangle {
                            width: modelData.end_time - modelData.start_time
                            height: 25
                            anchors.left: parent.left
                            anchors.leftMargin: modelData.start_time + 130
                            color: modelData.channel.substring(0, 6) === "AVISO_" ?
                                       Material.color(Material.Green, Material.Shade400) :
                                       modelData.channel.substring(0, 4) === "BDS0" ?
                                           Material.color(Material.Yellow, Material.Shade400) :
                                           modelData.channel.substring(modelData.channel.length - 8) === "_sur_ODS" ?
                                               Material.color(Material.LightBlue, Material.Shade400) :
                                               Material.color(Material.Red, Material.Shade400)
                            Rectangle{
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 11
                                anchors.verticalCenter: parent.verticalCenter
                                color:  userItem.color
                                visible: modelData.warning

                            }


                        }
                    }
                }

            }
        }

    }
}

