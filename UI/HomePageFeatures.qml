import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Styles 1.2

//ICONS CREATED IN - iconsdb
Rectangle {
        property string features_text: ""
        color: "#232323"
        Row{
            anchors.fill: parent
            spacing: 15
            Image {
                // sourceSize.width: 0.1*parent.width
                // sourceSize.height: 0.5*parent.height
                source: "./images/arrow-27-128.ico"
                width: 0.07*parent.width
                height: width
            }

            Text{
                text: features_text
                color: "#aad8d3"
                font.pointSize: 13
                wrapMode: Text.WordWrap
                width: 0.9375 * parent.width
                // horizontalAlignment: Text.AlignHCenter
                // verticalAlignment: Text.AlignVCenter
            }
        }
        // onClicked: MyScript.createFileDialog(1)
        // background: Rectangle {
        //     color: parent.down ? "#bbbbbb" : (parent.hovered ? "#deeeea" : "white")
        // }   
    }