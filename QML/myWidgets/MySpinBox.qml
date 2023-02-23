import QtQuick
//import QtQuick.Window
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Dialogs
//import QtCore

//Window {
SpinBox {

//    visible: true

    property int materialColor: Material.Indigo
    property int windowMode: Material.Light
    property color myColor: windowMode ? "#303030" : "#FAFAFA"
    property color hoverColor: windowMode ? "#4A4A4A" : "#EAEAEA"
    property color pressColor: windowMode ? "#616161" : "#DBDBDB"

    Material.theme: windowMode
    Material.accent: materialColor

//    color: Material.backgroundColor



 //   SpinBox {
        id: mySpinBox
        width: 75
        font.pointSize: 14


        onValueModified: focusIndicator.color = windowMode ? Material. color(materialColor, Material.Shade200) : Material.color(materialColor)


        contentItem: TextInput {
            z: 5
            text: mySpinBox.textFromValue(mySpinBox.value, mySpinBox.locale)
            //font.pointSize: 14

            font: mySpinBox.font
            color: Material.primaryTextColor
            selectionColor: Material.color(materialColor)
            selectedTextColor: Material.primaryTextColor
            horizontalAlignment: Qt.AlignCenter
            verticalAlignment: Qt.AlignVCenter
            validator: mySpinBox.validator
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            //anchors.right: parent.right
            width: 75
            onFocusChanged: focus ? focusIndicator.color = Material.color(materialColor) : focusIndicator.color = Material.backgroundColor
        }


        up.indicator:
            Rectangle {
            color: mySpinBox.up.hovered ? (mySpinBox.up.pressed ? pressColor : hoverColor) : myColor
            height: parent.height / 2
            anchors.right: parent.right
            anchors.top: parent.top
            implicitWidth: 20 // Adjust width here
//            implicitHeight: {
//                console.log(mySpinBox.contentItem.height)
//                return mySpinBox.contentItem.height - 10
//            }
            Image {
                source: windowMode ? "qrc:/icons/dark/chevron-up.svg" : "qrc:/icons/light/chevron-up.svg"
                height: Math.min(20, sourceSize.height)
                width: Math.min(20, sourceSize.width)
                anchors.centerIn: parent
            }

        }


        down.indicator:
            Rectangle {
            color: mySpinBox.down.hovered ? (mySpinBox.down.pressed ? pressColor : hoverColor) : myColor
                height: parent.height / 2
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                implicitWidth: 20
//                implicitHeight: {
//                    console.log("W: ",mySpinBox.width)
//                    return  mySpinBox.contentItem.height - 10
//                }
            //color: root.down.pressed ? "red" : "pink"

            Image {
                source: windowMode ? "qrc:/icons/dark/chevron-down.svg" : "qrc:/icons/light/chevron-down.svg"
                height: Math.min(20, sourceSize.height)
                width: Math.min(20, sourceSize.width)
                anchors.centerIn: parent
            }
        }

        background: Item {
//            implicitHeight: mySpinBox.height === 0 ? Math.max(30, Math.round(mySpinBox.contentItem.height)) : mySpinBox.height
//            implicitWidth: mySpinBox.contentItem.width + leftPadding +rightPadding

//            baselineOffset: mySpinBox.anchors.baselineOffset

            Rectangle {
                id: baserect
                anchors.fill: parent
                color: Material.backgroundColor
                radius: 0
                Rectangle {
                    id: focusIndicator
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 2
                    color: Material.backgroundColor
                }
            }
        }



    }



/*
    SpinBox {
        id: root
        property color borderColor: "red"
        property string multipleValuesTooltip: ""
        property color backgroundColor: "yellow"
        property bool showTooltip: true
        font.pointSize: 14

        property int maximumValue: 50
        property int minimumValue: 0
        property string suffix: ""
        property int decimals: 0
        to: maximumValue
        from: minimumValue
        editable: true
        rightPadding:  {
            console.log(root.contentItem.height)
            return Math.max(40, Math.round(root.contentItem.height))
        }

        textFromValue: function(value, locale) {
            return qsTr("%1"+suffix).arg(value);
        }

        contentItem: TextInput {
//            z: 5
            text: root.textFromValue(root.value, root.locale)

            font: root.font
            color: "white"
            selectionColor: "#21be2b"
            selectedTextColor: "#ffffff"
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            validator: root.validator
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            width: 100
        }
        up.indicator: Rectangle {
            height: parent.height / 2
            anchors.right: parent.right
            anchors.top: parent.top
            implicitWidth: 20 // Adjust width here
            implicitHeight: {
                console.log(root.contentItem.height)
                return root.contentItem.height - 10
            }
            color: root.up.pressed ? "red" : "pink"
            Image {
                source: "qrc:/icons/light/chevron-up.svg"
                height: Math.min(20, sourceSize.height)
                width: Math.min(20, sourceSize.width)
                anchors.centerIn: parent
            }
        }
        down.indicator: Rectangle {
            height: parent.height / 2
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            implicitHeight: root.contentItem.height - 10
            implicitWidth: {
                console.log("W: ",root.width)
                return 20
            }
            color: root.down.pressed ? "red" : "pink"

            Image {
                source: "qrc:/icons/light/chevron-down.svg"
                height: Math.min(20, sourceSize.height)
                width: Math.min(20, sourceSize.width)
                anchors.centerIn: parent
            }
        }
        background: Item {
            implicitHeight: root.height === 0 ? Math.max(30, Math.round(root.contentItem.height * 1.2)) : root.height
            implicitWidth: root.contentItem.width + leftPadding +rightPadding

            baselineOffset: root.anchors.baselineOffset

            Rectangle {
                id: baserect
                anchors.fill: parent
                color: "purple"
                radius: 0
            }

            Rectangle { // Border only
                anchors.fill: parent
                border.color: "black"
                color: "transparent"
                radius: 3
            }

            Rectangle {
                anchors.right: parent.right
                anchors.rightMargin: root.rightPadding - 10
                anchors.verticalCenter: parent.verticalCenter
                color: "black"
                height: parent.height - parent.height/5
                width: 1
            }
        }
    }
    */
//}
