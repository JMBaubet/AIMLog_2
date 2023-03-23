import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Dialogs
import QtCore



Flickable {

    property int myType: 0 // O ConnexionLog, 1: EventLog
    property var listeFile: []

    id:contenant
    anchors.fill: parent

    ListView {
    id: frame
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 10
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        //anchors.bottomMargin: 5
        clip: true


            Column {
                id: listColumn
                y: -vbar.position * height
                spacing: 0


                Repeater {
                    id: repeater
                    //model: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "...", "91", "92", "93", "94", "95", "96", "97", "98", "99"]
                    //Text { text: "Data: " + modelData }
                    model: listeFile

                    CheckBox {

                        anchors.left: parent.left
                        verticalPadding: 10
                        anchors.leftMargin: 5
                        checked: false
                        text: modelData
                        onClicked: { if (myType == 0) {
                                       backend.changeSelectFileCnx(text, checked)
                                   } else {
                                       backend.changeSelectFileEvt(text, checked)
                                   }
                        }
                    }
                }
            }

        ScrollBar {
            id: vbar
            hoverEnabled: true
            active: hovered || pressed || true
            orientation: Qt.Vertical
            visible: true
            policy: ScrollBar.AlwaysOn
            //size: contenant.height / listColumn.height
            size: listColumn.height === 0 ? frame.height : frame.height / listColumn.height
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5

        }

    }



    Connections{
        target: backend

        function onSetFile(listeFile, domaine) {
            repeater.model = listeFile
        }

        function onResetSelection() {
            //console.log("On déselectionne les checkBoxes")
            repeater.model = [] // Ca marche mais je n'explique pas comment
        }

    }

}
