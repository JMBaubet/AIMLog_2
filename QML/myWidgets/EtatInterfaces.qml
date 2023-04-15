import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Dialogs

Rectangle {
    property int nombre: 0
    property int longueur: 600
    property int leftMargin: 0

    width: longueur
    anchors.leftMargin: leftMargin
    color: nombre === 2 ? Material.color(Material.Green, Material.Shade500) :
                          nombre === 1 ? Material.color(Material.Orange, Material.Shade500) :
                                         nombre === 3 ? Material.color(Material.BlueGrey, Material.Shade500) :
                                                        Material.color(Material.Red, Material.Shade500)

}
