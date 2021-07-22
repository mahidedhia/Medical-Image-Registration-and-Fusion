import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Styles 1.2
import QtQuick.Window 2.0
import "componentCreation.js" as MyScript

ApplicationWindow {
    id: wideviewwindow
    visible: true
    visibility: "Maximized"
    minimumHeight: 550
    minimumWidth: 800
    title: "Wide View"
    Page{
        id: root2
        anchors.fill: parent
        // property bool fusionDone: true
        property string referencepath: ""
        property string alignpath: ""
        property string registeredpath: ""
        property string fusionpath: ""

        Connections{
            target: registrationFusionPage
            function onSendPathsToNewWindow(referencepath, alignpath, registeredpath, fusionpath, fusionDone) {
                root2.referencepath = referencepath
                root2.alignpath = alignpath
                root2.registeredpath = registeredpath
                root2.fusionpath = fusionpath
                imgLeft.source = ""
                imgLeft.source = referencepath
                imgRight.source = ""
                if (fusionDone){
                    comboboxLeft.model = ["Reference Image", "Original Aligned Image", "Registered Image", "Fusion Image"]
                    comboboxRight.model = ["Reference Image", "Original Aligned Image", "Registered Image", "Fusion Image"]
                    imgRight.source = fusionpath
                    comboboxRight.currentIndex = 3

                }
                else{
                    comboboxLeft.model = ["Reference Image", "Original Aligned Image", "Registered Image"]
                    comboboxRight.model = ["Reference Image", "Original Aligned Image", "Registered Image"]
                    imgRight.source = registeredpath
                    comboboxRight.currentIndex = 2
                }
            }
        }

        Rectangle {
            id: sectionLeft
            width: 0.5 * parent.width
            color: "#232323"
            anchors{
                top: parent.top
                bottom: parent.bottom
                left: parent.left
            }

            ComboBox{
                id: comboboxLeft
                model: ["Reference Image", "Original Aligned Image", "Registered Image", 'Fusion Image']
                anchors{
                    top: parent.top
                    topMargin: 0.03 * parent.height
                    bottom: imgLeft.top
                    bottomMargin: 0.025 * parent.height
                }
                anchors.horizontalCenter: parent.horizontalCenter
                width: 0.4 * parent.width
                background: Rectangle {
                    color: parent.hovered ? "#deeeea" : "white"
                }
                onActivated: {
                    imgLeft.source = ""
                    if (comboboxLeft.currentText == 'Reference Image'){
                        imgLeft.source = root2.referencepath
                    }
                    else if (comboboxLeft.currentText == 'Original Aligned Image'){
                        imgLeft.source = root2.alignpath
                    }
                    else if (comboboxLeft.currentText == 'Registered Image'){
                        imgLeft.source = root2.registeredpath
                    }
                    else if (comboboxLeft.currentText == 'Fusion Image'){
                        imgLeft.source = root2.fusionpath
                    }
                }
            }      

            Image{
                id: imgLeft
                cache: false
                source: "./images/gallery-icon.svg"
                anchors{
                    top: parent.top
                    topMargin: 0.10 * parent.height
                    left: parent.left
                    leftMargin: 0.03 * parent.width
                    right: parent.right
                    rightMargin: 0.03 * parent.width
                    bottom: parent.bottom
                    bottomMargin: 0.06 * parent.height
                }
            }
        }

        Rectangle {
            id: sectionRight
            width: 0.5 * parent.width
            color: "#232323"
            anchors{
                top: parent.top
                bottom: parent.bottom
                right: parent.right
            }
            
            ComboBox{
                id: comboboxRight
                model: ["Reference Image", "Original Aligned Image", "Registered Image", 'Fusion Image']
                anchors{
                    top: parent.top
                    topMargin: 0.03 * parent.height
                    bottom: imgRight.top
                    bottomMargin: 0.025 * parent.height
                }
                anchors.horizontalCenter: parent.horizontalCenter
                width: 0.4 * parent.width
                background: Rectangle {
                    color: parent.hovered ? "#deeeea" : "white"
                }
                onActivated: {
                    imgRight.source = ""
                    if (comboboxRight.currentText == 'Reference Image'){
                        imgRight.source = root2.referencepath
                    }
                    else if (comboboxRight.currentText == 'Original Aligned Image'){
                        imgRight.source = root2.alignpath
                    }
                    else if (comboboxRight.currentText == 'Registered Image'){
                        imgRight.source = root2.registeredpath
                    }
                    else if (comboboxRight.currentText == 'Fusion Image'){
                        imgRight.source = root2.fusionpath
                    }
                }
            }     

            Image{
                id: imgRight
                cache: false
                source: "./images/gallery-icon.svg"
                anchors{
                    top: parent.top
                    topMargin: 0.1 * parent.height
                    left: parent.left
                    leftMargin: 0.03 * parent.width
                    right: parent.right
                    rightMargin: 0.03 * parent.width
                    bottom: parent.bottom
                    bottomMargin: 0.06 * parent.height
                }
            }
        }
    }
}