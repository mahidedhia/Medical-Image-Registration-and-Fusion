import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Styles 1.2
import QtGraphicalEffects 1.0
import QtQuick.Shapes 1.0
import "componentCreation.js" as MyScript

ApplicationWindow {
    visible: true
    // width: 1600
    // height: 970
    visibility: "Maximized"
    minimumHeight: 750
    minimumWidth: 1300
    title: "Medical Image Registration and Fusion"

    property QtObject qtObj
    QtObject {
        id: mainqmldata
        //PATHS TO IMAGES CONTAINING LANDMARK POINTS
        property string landmarks_pathalign: ""
        property string landmarks_pathref: ""
        //PATH TO OUTPUT IMAGE
        property string pathoutput: ""
        property string pathfusionoutput: ""
    }
    signal sendMainQmlData(QtObject mainqmldata) 
    signal sendObjects(QtObject qtObj)
    
    Page{
        anchors.fill: parent
        Connections {
            target: qtObj
            function onUpdateAlignPath(path_align){
                // mainqmldata.landmarks_pathalign = path_align
                root.sendAlignPath(path_align)
                // signal sendFilepath1(string path_ref, string path_align)
                // main_rectangle.sendFilepath(string path_ref, string path_align)
            }
            function onUpdateRefPath(path_ref){
                root.sendRefPath(path_ref)
            }
            function onUpdateLandmarkImagesPath(ref, align){
                mainqmldata.landmarks_pathalign = align
                mainqmldata.landmarks_pathref = ref
            }
            function onUpdateOutputPath(path_output, success){
                mainqmldata.pathoutput = path_output
                root.regDone(success)
            }
            function onUpdateOutputFusionPath(path_fusionoutput, success){
                mainqmldata.pathfusionoutput = path_fusionoutput
                root.fusionDone(success)
            }
            function onUpdateFilesSaved(success){
                root.filesSaved(success)
            }
        }

        Rectangle {
            id: root
            anchors.fill: parent
            property var regfusion_page_obj: {}
            signal sendAlignPath(string alignpath)
            signal sendRefPath(string refpath)
            signal regDone(int success)
            signal fusionDone(int success)
            signal filesSaved(int success)
    
            //MENUBAR
            Rectangle{
                id: menuBar
                color: "#171717"
                width: parent.width
                height: 0.05 * parent.height
                anchors{
                    left: parent.left
                    top: parent.top
                }

                Row{
                    anchors.fill: parent
                    Button{
                        id: homeButton
                        text: "Home"
                        palette.buttonText: "white"
                        font.pixelSize: 20
                        height: menuBar.height
                        spacing: 30
                        anchors{
                            top: parent.top
                        }
                        background: Rectangle {
                            color: parent.down? "#364547" : (parent.hovered ? "#232323" : "#171717")
                            // opacity: parent.down? 1 : (parent.hovered ? 0.4 : 1)
                        }
                        onClicked: {
                            if (root.regfusion_page_obj!=null){
                                root.regfusion_page_obj.destroy()
                            }
                        }
                    }
                    Button{
                        id: menuRegFusionButton
                        text: "Image Registration and Fusion"
                        palette.buttonText: "white"
                        font.pixelSize: 20
                        height: menuBar.height
                        spacing: 30
                        anchors{
                            top: parent.top
                        }
                        background: Rectangle {
                            color: parent.down? "#364547" : (parent.hovered ? "#232323" : "#171717")
                        }
                        onClicked: {
                            if (root.regfusion_page_obj!=null){
                                root.regfusion_page_obj.destroy()
                            }
                            root.regfusion_page_obj = MyScript.createRegFusionPage()
                        }
                    }
                }
            }

            //HOMEPAGE
            Rectangle{
                id: homePage
                anchors{
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    topMargin: 0.05 * parent.height
                    bottom: parent.bottom
                }
                color: "#232323"

                Text {
                    id: titletext
                    text: "MEDICAL IMAGE \nREGISTRATION \nAND \nFUSION"
                    y: 0.02 * parent.height
                    anchors {
                        left: parent.left
                        leftMargin: 0.12 * parent.width
                        top: parent.top
                        topMargin: 0.12 * parent.height
                    }
                    color: "#aad8d3"
                    font.pointSize: 22
                }

                Text {
                    text: "A Desktop Tool to perform Image Registration and Fusion on Medical Images"
                    width: 0.25 * parent.width
                    wrapMode: Text.WordWrap
                    anchors {
                        left: parent.left
                        leftMargin: 0.12 * parent.width
                        top: parent.top
                        topMargin: 0.48 * parent.height
                    }
                    color: "#aad8d3"
                    font.pointSize: 16
                }

                HomePageFeatures{
                    id: feature1
                    width: 0.4 * parent.width
                    height: 0.06 * parent.height
                    features_text: "Perform Registration on monomodal medical images"
                    anchors {
                        left: parent.left
                        leftMargin: 0.5 * parent.width
                        top: parent.top
                        topMargin: 0.12 * parent.height
                    }
                }

                HomePageFeatures{
                    id: feature2
                    width: 0.4 * parent.width
                    height: 0.1 * parent.height
                    features_text: "Perform Landmark-based Registration on Multimodal medical images by selecting 4-10 control points"
                    anchors {
                        left: parent.left
                        leftMargin: 0.5 * parent.width
                        top: feature1.bottom
                        topMargin: 0.07 * parent.height
                    }
                }

                HomePageFeatures{
                    id: feature3
                    width: 0.4 * parent.width
                    height: 0.06 * parent.height
                    features_text: "Perform Image Fusion on the registered image"
                    anchors {
                        left: parent.left
                        leftMargin: 0.5 * parent.width
                        top: feature2.bottom
                        topMargin: 0.07 * parent.height
                    }
                }

                HomePageFeatures{
                    id: feature4
                    width: 0.4 * parent.width
                    height: 0.06 * parent.height
                    features_text: "Download all the input and result images"
                    anchors {
                        left: parent.left
                        leftMargin: 0.5 * parent.width
                        top: feature3.bottom
                        topMargin: 0.07 * parent.height
                    }
                }

                HomePageFeatures{
                    id: feature5
                    width: 0.4 * parent.width
                    height: 0.06 * parent.height
                    features_text: "View the input and result images in a new window"
                    anchors {
                        left: parent.left
                        leftMargin: 0.5 * parent.width
                        top: feature4.bottom
                        topMargin: 0.07 * parent.height
                    }
                }
                
            }  
        }
    }
}