import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
Item {


    Label {
        text: qsTr("Page Information")
        color: Material.foreground
    }

    Component.onCompleted: backend.checkInfo()


    Connections{
        target: backend
    }

}
