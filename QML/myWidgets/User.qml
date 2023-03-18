import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material

Rectangle {

    property string nom: ""
    property string position: ""

/*
    property date dateRef: '2022-11-21 15:00:00'
]*/
/*
    property var cnxModel: [
                    {'start_time': '2022-11-18 14:06:33', 'end_time': '2022-11-21 14:58:14', 'channel': 'AVISO_Tech', 'user': 'sup_a'},
                    {'start_time': '2022-11-21 14:58:14', 'end_time': '2022-11-21 14:58:43', 'channel': 'AVISO_Tech', 'user': 'sup_a'},
                    {'start_time': '2022-11-21 14:58:43', 'end_time': '2022-11-21 15:16:22', 'channel': 'BDS01_A_VO', 'user': 'sup_a'}
                ]
*/
    property date dateRef: '2022-10-19 09:25:00'
    property string cnxModel: '[{"start_time": "2022-10-19 09:26:02", "end_time": "2022-10-19 09:26:24", "channel": "BDS01_B_VO"}]'

    property var cnxPoint: []
    property int userColor: Material.DeepPurple


    id: userItem
    width: 1200 // Le rectangle du user doit dépendre de début et la fin de connexion...
    height: channels.height + userName.height
   // color: Material.color(userColor, Material.Shade50 )


    color: nom === "admin" ?
               Material.color(Material.DeepOrange, Material.Shade100) :
               nom.toUpperCase() === position.toUpperCase() ?
                   Material.color(Material.Green, Material.Shade100) :
                   Material.color(Material.Blue, Material.Shade100)



    function calculCnxPoint(cnxModel, dateRef) {
        console.log("User.qml : function calculCnxPoint appelée, dateRef : ", dateRef)
        //console.log("User.qml : cnxModel", cnxModel, "longueur : ", cnxModel.length)

        var dict = JSON.parse(cnxModel);

        //console.log("User.qml : dict", dict, "longueur : ", dict.length)

        var newModel = []
        const ref = new Date(dateRef)
        for (var i = 0; i <dict.length; i++)  {     // voir : https://www.youtube.com/watch?v=x2pidX7xRlw
            //console.log(dict[i].start_time)
            const dateDebut = new Date(dict[i].start_time)
            const dateFin = new Date(dict[i].end_time)
            var diffDebut = 900 - ((ref - dateDebut) / 1000)
            if (diffDebut < 0) diffDebut = 0
            var diffFin = 900 - ((ref - dateFin) / 1000)
            if (diffFin > 1200) diffFin = 1200

            console.log("dates :", diffDebut, diffFin)
            newModel.push({                             // voir : https://stackoverflow.com/questions/7196212/how-to-create-dictionary-and-add-key-value-pairs-dynamically-in-javascript
                          start_time: diffDebut,
                          end_time: diffFin,
                          channel: dict[i].channel
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
        width: userText.width + 10

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: userText.text
        }
        Component.onCompleted: console.log("User.qml : Position : ", position.toUpperCase(), " - user  : ",    nom.toUpperCase())

    }

    TextMetrics {
        id: userText
        text: "login : " + nom

    }

    Item {
        anchors.top: userName.bottom
        anchors.left:userName.left
        anchors.right: userName.right
        //Component.onCompleted: console.log("User.qml : cnxModel reçu : ", cnxModel)


        Column {
            id: channels
            spacing: 2


            Repeater {
                id: user
                model: calculCnxPoint(cnxModel, dateRef)

                Rectangle {

                    width: modelData.end_time - modelData.start_time
                    height: 20
                    //anchors.left: parent.left
                    x: modelData.start_time
                    color: libelleChannel.text.substring(0, 6) === "AVISO_" ?
                               Material.color(userColor, Material.Shade200) :
                               libelleChannel.text.substring(0, 4) === "BDS0" ?
                                   Material.color(userColor, Material.Shade400) :
                                   Material.color(Material.Red, Material.Shade400)


                    Text {
                        id: libelleChannel
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.channel
                    }

                }

            }
        }

    }
}

