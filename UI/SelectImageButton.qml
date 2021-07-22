import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Styles 1.2
import QtQuick.Shapes 1.0
import "componentCreation.js" as MyScript

Button {
    property string button_text: ""
    width: 0.45 * parent.width
    height: 0.05 * parent.height
    anchors{
        left: parent.left
        leftMargin: 0.05 * parent.width
        top: parent.top
        topMargin: 0.1 * parent.height
    }
    Image {
        sourceSize.width: 0.1*parent.width
        sourceSize.height: 0.5*parent.height
        source: "./images/attach-48.ico"
        width: height
        height: 0.6*parent.height
        anchors.verticalCenter: parent.verticalCenter
        anchors{
            left: parent.left
            leftMargin: 0.02*parent.width
        }
    }
    contentItem: Text{
        text: button_text
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors{
            left:parent.left
            leftMargin: 0.05 * parent.width
        }
    }
    // onClicked: MyScript.createFileDialog(1)
    background: Rectangle {
        color: parent.down ? "#bbbbbb" : (parent.hovered ? "#deeeea" : "white")
    }   
}