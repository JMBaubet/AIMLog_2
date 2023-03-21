import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml
import QtQuick.Controls.Material


Rectangle {

    property int couleur: Material.Orange
    property int mode: Material.Light

    property alias dateTimeLLocale: month_grid.locale
    property date selectDate: new Date()
    property int heure : 6
    property int minute: 30
    property date gridDate: new Date()
    property date firstDate: new Date(2022, 11, 8) // Attention le mis vaut 0 pour janvier.. 11 pour décembre
    property date lastDate: new Date(2023, 01, 25)

/*
    function dateIsready(firstDate, lastDate, reference, jour)
    {
        var debut = 0
        var fin = 0
        var ref = 0
        debut = parseInt(firstDate.toLocaleDateString(Qt.locale(), "yyyy") * 10000) +
                parseInt(firstDate.toLocaleDateString(Qt.locale(), "MM") * 100) +
                parseInt(firstDate.toLocaleDateString(Qt.locale(), "dd"))

        fin = parseInt(lastDate.toLocaleDateString(Qt.locale(), "yyyy") * 10000) +
                parseInt(lastDate.toLocaleDateString(Qt.locale(), "MM") * 100) +
                parseInt(lastDate.toLocaleDateString(Qt.locale(), "dd"))

        ref = reference.year * 10000 +
              (reference.month + 1 )* 100 +
              jour

        return ((ref >= debut) && (ref <=fin) )
    }
*/

    id: control
    Material.theme: mode
    Material.accent: couleur
    color: Material.backgroundColor
    width: 320


    Rectangle {
        id: choixMois
        color: Material.backgroundColor
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: downYear.height + 10

        Button {
            id: downYear
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            bottomInset: 0
            topInset: 0
            anchors.leftMargin: 10
            width: 40
            height: 40
            flat: true
            Image {
                height:40
                width: 40
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.left: parent.left
                source: if (mode == Material.Light) {
                            "qrc:/icons/light/chevrons-left.svg"
                        } else {
                            "qrc:/icons/dark/chevrons-left.svg"
                        }
                fillMode: Image.PreserveAspectFit
            }

            onClicked: {
                month_grid.year-=1;
                monthYear.text = month_grid.title
            }

        }
        Button {
            id: downMonth
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: downYear.right
            anchors.leftMargin: 0
            bottomInset: 0
            topInset: 0
            width: 40
            height: 40
            flat: true
            Image {
                height:40
                width: 40
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.left: parent.left
                source: if (mode == Material.Light) {
                            "qrc:/icons/light/chevron-left.svg"
                        } else {
                            "qrc:/icons/dark/chevron-left.svg"
                        }
                fillMode: Image.PreserveAspectFit
            }
            onClicked: {
                if(month_grid.month===0){
                    month_grid.year-=1;
                    month_grid.month=11;
                }else{
                    month_grid.month-=1;
                }
                monthYear.text = month_grid.title
            }

        }
        Label {
            id: monthYear
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            //text: "??"
            //text: date.toLocaleDateString(Qt.locale("fr-FR"),"MMMM yyyy")
            //text: month_grid.year
            text: selectDate.toLocaleDateString(Qt.locale("fr-FR"),"MMMM yyyy")
            font.pointSize: 18
        }
        Button {
            id: upMonth
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: upYear.left
            anchors.rightMargin: 0
            bottomInset: 0
            topInset: 0
            width: 40
            height: 40
            flat: true
            Image {
                height:40
                width: 40
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.left: parent.left
                source: if (mode == Material.Light) {
                            "qrc:/icons/light/chevron-right.svg"
                        } else {
                            "qrc:/icons/dark/chevron-right.svg"
                        }
                fillMode: Image.PreserveAspectFit
            }
            onClicked: {
                if(month_grid.month===11){
                    month_grid.year+=1;
                    month_grid.month=0;
                }else{
                    month_grid.month+=1;
                }
                monthYear.text = month_grid.title
            }
        }
        Button {
            id: upYear
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 10
            bottomInset: 0
            topInset: 0
            width: 40
            height: 40
            flat: true
            Image {
                height:40
                width: 40
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.left: parent.left
                source: if (mode == Material.Light) {
                            "qrc:/icons/light/chevrons-right.svg"
                        } else {
                            "qrc:/icons/dark/chevrons-right.svg"
                        }
                fillMode: Image.PreserveAspectFit
            }
            onClicked: {
                month_grid.year+=1;
                monthYear.text = month_grid.title
            }

        }
    }

    Button {
        id: corner
        anchors.top: choixMois.bottom
        topInset: 0
        bottomInset: 0
        anchors.left: parent.left
        implicitHeight: 30
        implicitWidth: 30
        flat: true

        //height: 30
        //width: 30
        //color: "yellow"
         Material.background: Material.color(couleur, Material.Shade200)
         onClicked: {
            console.log("hauteur : " + week_col.height + "\nLargeur : " + month_grid.width)

            month_grid.month = gridDate.getMonth()
            month_grid.year = gridDate.getFullYear()

            //month_grid.month = selectDate.getMonth()
            //month_grid.year = selectDate.getFullYear()
            monthYear.text = month_grid.title
         }

    }



    WeekNumberColumn {
        id: week_col
        anchors.top:  corner.bottom

        anchors.left: parent.left
        implicitWidth: corner.width
        implicitHeight: 222
        //spacing: 1
        leftPadding: 0
        rightPadding: 0
        month: month_grid.month
        year: month_grid.year
        locale: dateTimeLLocale

        delegate: Text {
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: weekNumber
            font: week_col.font
            color: Material.foreground
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            required property int weekNumber
        }
        contentItem: Rectangle {
            color: Material.color(couleur, Material.Shade200)

            //border.color: "black"
            ColumnLayout {
                anchors.fill: parent
                spacing: week_col.spacing
                //anchors.topMargin: 0
                //spacing: 1
                Repeater {
                    model: week_col.source
                    delegate: week_col.delegate
                }
            }
        }
    }

    //1-7
    DayOfWeekRow {
        id: week_row
        anchors.top: choixMois.bottom
        font.family: "Verdana"
        anchors.left: corner.right
        anchors.right: parent.right
        implicitHeight: corner.height
        spacing: 0
        topPadding: 0
        bottomPadding: 0
        locale: Qt.locale("fr_FR")

        delegate: Text {
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: shortName
            font: week_row.font
            color: Material.foreground
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            required property string shortName
        }
        contentItem: Rectangle {
            //color: Material.backgroundColor
            color: Material.color(couleur, Material.Shade200)

            RowLayout {
                anchors.fill: parent
                //anchors.leftMargin: 20
                //spacing: 41.42
                spacing: week_row.spacing
                Repeater {
                    model: week_row.source
                    delegate: week_row.delegate
                }
            }
        }
    }


    MonthGrid {
        id: month_grid
        anchors.top:week_row.bottom
        anchors.left: week_col.right
        height: week_col.height
        width: week_row.width
        locale: Qt.locale("fr_FR")
        spacing: 0
        font{
            //family: "Arial"
            pixelSize: 14
        }
        delegate: Rectangle {
/*
            color: model.today
                   ? Material.color( couleur, Material.Shade300)
                   :control.selectDate.valueOf()===model.date.valueOf()
                     ? Material.color( couleur)
                     : Material.background
*/

            color: model.date.toDateString()  === firstDate.toDateString() ? Material.color(couleur, Material.Shade700)
                 : model.date.toDateString()  === lastDate.toDateString() ? Material.color(couleur, Material.Shade700)
                 : (model.date  > firstDate)  &&  (model.date  < lastDate) ? Material.color(couleur)  : Material.background

            Rectangle {
                anchors.fill: parent
                //anchors.margins: 2
                color: "transparent"
                //border.color: mode ? "white" : "black"
                border.color: "grey"
                visible: item_mouse.containsMouse
            }
            Text {
                anchors.centerIn: parent
                text: model.day
                //color:  dateIsready(firstDate, lastDate, model, model.day )  ? Material.foreground : Material.foreground
                color:  Material.foreground
                opacity: model.month===month_grid.month ? 1 : 0.2
                //font.bold: dateIsready(firstDate, lastDate, model, model.day )
                font.bold: (model.date.toDateString() === firstDate.toDateString()) || ((model.date < lastDate ) && (model.date > firstDate))
            }
            MouseArea {
                id: item_mouse
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
            }
        }
        onClicked: (date)=>  {
            //dateSelectionnee.text = date.toLocaleString(Qt.locale("fr-FR"),"ddd dd MMMM")
            //annee.text = date.toLocaleDateString(Qt.locale("fr-FR"), "yyyy")


            //monthYear.text = month_grid.month.title.toLocaleString(Qt.locale("fr-FR")) + month_grid.year
            control.selectDate=date;
                        if ((date.toDateString() !== firstDate.toDateString()) && ((date > lastDate ) || (date < firstDate))) {
                           console.log("Date invalide : " + date + firstDate)
                           backend.sendMessage("Vous devez sélectionner une date valide ! (dates colorées) ", 2)
                        }
                        else
                        backend.dateSelected(
                            date.toLocaleString(Qt.locale(),"dd"),
                            date.toLocaleString(Qt.locale(),"MM"),
                            date.toLocaleString(Qt.locale(),"yyyy"),
                            date.toLocaleString(Qt.locale("fr-FR"),"ddd dd MMM yyyy"))

       }

    }

    Connections{
        target: backend

        function onSetColor(newCouleur) {
            couleur = newCouleur
        }

        function onSetMode(newMode) {
            mode = newMode
        }

        function onSetDates(dates) {
            //console.log("first-date recoit : " + dates[0])
            //console.log("last-date recoit : " + dates[1])
            firstDate = dates[0]
            lastDate = dates[1]
        }
    }

}
