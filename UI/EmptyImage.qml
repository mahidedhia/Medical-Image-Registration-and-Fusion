import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Styles 1.2
import QtQuick.Shapes 1.0
Shape {
    //DASHED BORDER
    width: 0.9 * parent.width
    anchors {
        left: parent.left
        leftMargin: 0.05 * parent.width
        top: parent.top
        topMargin: 0.32 * parent.height
        bottom: parent.bottom
        bottomMargin: 0.12 * parent.height
    }
    ShapePath {
        strokeWidth: 4
        strokeColor: "#aad8d3"
        fillColor: "transparent"
        strokeStyle: ShapePath.DashLine
        dashPattern: [ 1, 4 ]
        startX: 0; startY: 0;
        PathLine { x: width; y: 0 }
        PathLine { x: width; y: height}
        PathLine { x: 0; y: height }
        PathLine { x: 0; y: 0; }
    }
    //IMAGE ICON
    Image {
        id: imageicon
        anchors.centerIn: parent
        source : "./images/gallery-icon.svg"
        width: 0.2*parent.width
        height: width
    }
}