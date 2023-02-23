import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Dialogs

Row {

    property int duree: 30
    property string unite: "jours"

    SpinBox {
        id: dureeSpinBox
        width: 120
        anchors.verticalCenter: parent.verticalCenter
        from:  unite === "jours" ? 30 : 1
        to: unite === "jours" ? 61 : unite === "mois" ? 25 : 10
        value: duree
        onValueModified: {
            duree = dureeSpinBox.value
            if (unitLabel.text === "jours") {
                if (dureeSpinBox.value === 61) {
                    unitLabel.text = "mois"
                    unite = unitLabel.text
                    dureeSpinBox.from = 1
                    dureeSpinBox.to = 25
                    dureeSpinBox.value = 2
                }
            }
            else if (unitLabel.text === "mois") {
                if (dureeSpinBox.value === 1) {
                    unitLabel.text = "jours"
                    unite = unitLabel.text
                    dureeSpinBox.from = 30
                    dureeSpinBox.to = 61
                    dureeSpinBox.value = 60
                }
                else if (dureeSpinBox.value === 25) {
                    unitLabel.text = "ans"
                    unite = unitLabel.text
                    dureeSpinBox.from = 1
                    dureeSpinBox.to = 10
                    dureeSpinBox.value = 2
                }
            }
            else if (unitLabel.text === "ans") {
                if (dureeSpinBox.value === 1) {
                    unitLabel.text = "mois"
                    unite = unitLabel.text
                    dureeSpinBox.from = 1
                    dureeSpinBox.to = 25
                    dureeSpinBox.value = 24
                }
            }
            duree = dureeSpinBox.value
        }
    }

    Label {
        id: unitLabel
        anchors.verticalCenter: parent.verticalCenter
        text: qsTr(unite)

    }
}
