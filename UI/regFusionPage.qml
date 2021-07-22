import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Styles 1.2
import QtQuick.Shapes 1.0
//FOR FILE DIALOG
import Qt.labs.platform 1.1 
import "componentCreation.js" as MyScript

Rectangle{
    id: registrationFusionPage
    visible: true
    color: "#232323"
    anchors{
        left: parent.left
        right: parent.right
        top: parent.top
        topMargin: 0.05 * parent.height
        bottom: parent.bottom
    }

    QtObject {
        id: regFusionQmlData
        property string pathref: ""
        property string pathalign: ""
        property bool fusionDone: false
        //FOR LANDMARK POINTS
        property string no_controlpoints : noOfControlPoints.currentText
        property int added_landmarks: 0
        property double axfactor: 0
        property double ayfactor: 0
        property double rxfactor: 0
        property double ryfactor: 0

        function alignImagePath(pathalign){
            // imagealign.source = pathalign
            // regFusionQmlData.pathalign = pathalign
            txtmsg.text = "Image Selected"
            imagereference.source = regFusionQmlData.pathref
            regFusionQmlData.added_landmarks = 0
            emptyimage1.visible = false
            aLandmarkCircle.visible = false
            aLandmarkDot.visible = false
            imageoutput.source = ""
            emptyimage3.visible = true
            outputError.visible = false
            outputErrorText.visible = false
            section4.visible = false
            regFusionQmlData.fusionDone = false
            btfusion.visible = false
            //FILENAME TO BE DISPLAYED
            var x = String(pathalign)
            x = x.slice(8, x.length )
            x = x.split('\\').pop().split('/').pop()
            x = ( x.length > 33 ? x.slice(0,30) + "..." :  x)
            txtalign.text = x;
        }
        function referenceImagePath(pathref){
            // imagereference.source = pathref
            // regFusionQmlData.pathref = pathref
            txtmsg.text = "Image Selected"
            imagealign.source = regFusionQmlData.pathalign
            regFusionQmlData.added_landmarks = 0
            emptyimage2.visible = false
            rLandmarkCircle.visible = false
            rLandmarkDot.visible = false
            imageoutput.source = ""
            emptyimage3.visible = true
            outputError.visible = false
            outputErrorText.visible = false
            section4.visible = false
            regFusionQmlData.fusionDone = false
            btfusion.visible = false
            //FILENAME TO BE DISPLAYED
            var x = String(pathref)
            x = x.slice(8, x.length )
            x = x.split('\\').pop().split('/').pop()
            x = ( x.length > 33 ? x.slice(0,30) + "..." :  x)
            txtref.text = x;
        }
        function ifBothImagesChosen() {
            //USER CAN SELECT LANDMARK POINTS ONLY IF BOTH IMAGES ARE SELECTED AND TYPE OF REGISTRATION IS MULTIMODAL
            if(imagealign.source != "" && imagereference.source != "" && monomulti.currentText=="Multimodal"){
                btaddpair.visible = true
                aMouseArea.cursorShape = Qt.CrossCursor
                rMouseArea.cursorShape = Qt.CrossCursor
            }
        }
    }
    signal sendregFusionQmlData( QtObject regFusionQmlData ) 
    signal sendPathsToNewWindow(string referencepath, string alignpath, string registeredpath, string fusionpath, bool fusionDone)
    // registrationFusionPage.send(regpageobj)
    
    Connections{
        target: root
        function onSendAlignPath(alignpath){
            imagealign.source = alignpath
            regFusionQmlData.pathalign = alignpath
        }
        function onSendRefPath(refpath){
            imagereference.source = refpath
            regFusionQmlData.pathref = refpath
        }
        function onRegDone(success) {
            if(success==1){
                txtmsg.text = "Registration Successful"
                imageoutput.source = ""
                imageoutput.source = mainqmldata.pathoutput
                outputError.visible = false
                displayLoading.visible = false
                section4.visible = true
                btfusion.visible = true
            }
            else{
                imageoutput.source = ""
                txtmsg.text = "Registration Failed"
                displayLoading.visible = false
                outputErrorText.text = "Can't Register the selected images! Try with other images"
                outputErrorText.visible = true
            } 
        }
        function onFusionDone(success){
            if(success==1){
                txtmsg.text = "Fusion Successful"
                imageoutput.source = ""
                imageoutput.source = mainqmldata.pathfusionoutput
                outputError.visible = false
                displayLoading.visible = false
                regFusionQmlData.fusionDone = true
            }
            else{
                imageoutput.source = ""
                txtmsg.text = "Fusion Failed"
                displayLoading.visible = false
                outputErrorText.text = "Can't perform fusion on the selected images! Try with different parameters!"
                outputErrorText.visible = true
            } 
        }
        function onFilesSaved(success){
            if(success==1){
                txtmsg.text = "The files have been saved!"
            }
            else{
                txtmsg.text = "A folder with same name already exists! Choose other destination"
            }
        }
    }

    
    //SECTION FOR IMAGE TO BE ALIGNED
    Rectangle{
        id: section1
        width: 0.32 * parent.width
        color: "#232323"
        anchors{
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        EmptyImage {
            id: emptyimage1
        }
        property double xloc : 0
        property double yloc : 0
        Image{
            id: imagealign
            cache: false
            source: ""
            width: 0.9 * parent.width
            anchors {
                left: parent.left
                leftMargin: 0.05 * parent.width
                top: parent.top
                topMargin: 0.32 * parent.height
                bottom: parent.bottom
                bottomMargin: 0.12 * parent.height
            }
            MouseArea {
                id: aMouseArea
                anchors.fill: parent
                onClicked: { 
                    if(imagealign.source != "" && imagereference.source!="" && monomulti.currentText == "Multimodal"){
                        // console.log(parent.sourceSize.height + " " + parent.sourceSize.width)
                        var xfactor = parent.sourceSize.width/parent.width
                        var yfactor = parent.sourceSize.height/parent.height
                        regFusionQmlData.axfactor = mouseX*xfactor
                        regFusionQmlData.ayfactor = mouseY*yfactor 
                        section1.xloc = mouseX / parent.width
                        section1.yloc = mouseY / parent.height
                        // aArc.centerX = mouseX
                        // aArc.centerY = mouseY
                        aLandmarkCircle.visible = true
                        aLandmarkDot.visible = true
                    }
                }
            }
            Shape {
                id: aLandmarkCircle
                visible: false
                anchors.fill: parent
                ShapePath {
                    fillColor: "transparent"
                    strokeColor: "red"
                    strokeWidth: 4
                    capStyle: ShapePath.FlatCap
                    PathAngleArc {
                        id: aArc
                        centerX: section1.xloc * imagealign.width; centerY: section1.yloc * imagealign.height
                        radiusX: 20; radiusY: 20
                        startAngle: -360
                        sweepAngle: 360
                    }
                }
            }
            Shape {
                id: aLandmarkDot
                visible: false
                anchors.fill: parent
                ShapePath {
                    fillColor: "red"
                    strokeColor: "red"
                    capStyle: ShapePath.FlatCap
                    PathAngleArc {
                        id: aDot
                        centerX: section1.xloc * imagealign.width; centerY: section1.yloc * imagealign.height
                        radiusX: 1.5; radiusY: 1.5
                        startAngle: -360
                        sweepAngle: 360
                    }
                }
            }
        }
        SelectImageButton{
            id: btalign
            button_text: "Image to be Aligned"
            onClicked: { 
                // MyScript.createFileDialog(2)
                afiledialog.open()
            }
        }

        CheckBox{
            id: contrastOptionAlign
            text: "Contrast Enhancement"
            height: btalign.height
            background: Rectangle {
                color: parent.hovered ? "#deeeea" : "white"
            }
            anchors{
                left: btalign.right
                leftMargin: 0.02 * parent.width
                top: parent.top
                topMargin: 0.1 * parent.height
                right: parent.right
                rightMargin: 0.05 * parent.width
            }
        }

        FileDialog {
            id: afiledialog
            nameFilters: ["Image files (*.jpg *.jpeg *.png *.dcm)"]
            selectedNameFilter.index: 0
            onAccepted: {
                qtObj.getAlignImg(afiledialog.file)
                regFusionQmlData.alignImagePath(afiledialog.file)
                regFusionQmlData.ifBothImagesChosen()
            }
        }

        Text {
            id: txtalign
            text: "No Image Selected"
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors{
                left: parent.left
                leftMargin: 0.15 * parent.width
                right: parent.right
                rightMargin: 0.15 * parent.width
                top: parent.top
                topMargin: 0.2 * parent.height
            }
        }
    }

    //SECTION FOR REFERENCE IMAGE
    Rectangle{
        id: section2
        width: 0.32 * parent.width
        color: "#232323"
        anchors{
            left: section1.right
            top: parent.top
            bottom: parent.bottom
        }
        EmptyImage {
            id: emptyimage2
        }
        property double xloc : 0
        property double yloc : 0
        Image{
            id: imagereference
            cache: false
            source: ""
            width: 0.9 * parent.width
            anchors {
                left: parent.left
                leftMargin: 0.05 * parent.width
                top: parent.top
                topMargin: 0.32 * parent.height
                bottom: parent.bottom
                bottomMargin: 0.12 * parent.height
            }
            MouseArea {
                id: rMouseArea
                anchors.fill: parent
                onClicked: {
                    if(imagereference.source != "" && imagealign.source != "" && monomulti.currentText == "Multimodal"){ 
                        // console.log(parent.sourceSize.height + " " + parent.sourceSize.width)
                        var xfactor = parent.sourceSize.width/parent.width
                        var yfactor = parent.sourceSize.height/parent.height
                        regFusionQmlData.rxfactor = mouseX*xfactor
                        regFusionQmlData.ryfactor = mouseY*yfactor
                        section2.xloc = mouseX / parent.width
                        section2.yloc = mouseY / parent.height
                        rLandmarkCircle.visible = true
                        rLandmarkDot.visible = true
                    }
                }
            }
            Shape {
                id: rLandmarkCircle
                visible: false
                anchors.fill: parent
                ShapePath {
                    fillColor: "transparent"
                    strokeColor: "red"
                    strokeWidth: 4
                    capStyle: ShapePath.FlatCap
                    PathAngleArc {
                        id: rArc
                        centerX: section2.xloc * imagereference.width; centerY: section2.yloc * imagereference.height
                        radiusX: 20; radiusY: 20
                        startAngle: -360
                        sweepAngle: 360
                    }
                }
            }
            Shape {
                id: rLandmarkDot
                visible: false
                anchors.fill: parent
                ShapePath {
                    fillColor: "red"
                    strokeColor: "red"
                    capStyle: ShapePath.FlatCap
                    PathAngleArc {
                        id: rDot
                        centerX: section2.xloc * imagereference.width; centerY: section2.yloc * imagereference.height
                        radiusX: 1.5; radiusY: 1.5
                        startAngle: -360
                        sweepAngle: 360
                    }
                }
            }
        }
        SelectImageButton{
            id: btreference
            button_text: "Reference Image"
            onClicked: {
                rfiledialog.open()
            }
        }

        CheckBox{
            id: contrastOptionRef
            text: "Contrast Enhancement"
            height: btreference.height
            background: Rectangle {
                color: parent.hovered ? "#deeeea" : "white"
            }
            anchors{
                left: btreference.right
                leftMargin: 0.02 * parent.width
                top: parent.top
                topMargin: 0.1 * parent.height
                right: parent.right
                rightMargin: 0.05 * parent.width
            }
        }

        FileDialog {
            id: rfiledialog
            nameFilters: ["Image files (*.jpg *.jpeg *.png *.dcm)"]
            selectedNameFilter.index: 0
            onAccepted: {
                qtObj.getRefImg(rfiledialog.file)
                regFusionQmlData.referenceImagePath(rfiledialog.file)
                regFusionQmlData.ifBothImagesChosen()
            }
        }

        Text {
            id: txtref
            text: "No Image Selected"
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors{
                left: parent.left
                leftMargin: 0.15 * parent.width
                right: parent.right
                rightMargin: 0.15 * parent.width
                top: parent.top
                topMargin: 0.2 * parent.height
            }
        }
    }

    //ADD LANDMARK PAIRS
    Rectangle{
        id: addpair
        width: 0.32 * parent.width
        color: "transparent"
        anchors{
            left: section1.right
            top: parent.top
            bottom: parent.bottom
        }
        Button{
            id: btaddpair
            visible: false
            contentItem: Text{
                text: "Add Landmark Pair"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            height: 0.05 * parent.height
            anchors{
                bottom: parent.bottom
                bottomMargin: 0.04 * parent.height
                right: parent.right
                rightMargin: 0.05 * parent.width
            }
            onClicked: {
                if(!aLandmarkCircle.visible || !rLandmarkCircle.visible){
                    txtmsg.text = "Please select both the landmarks"
                }
                else if(regFusionQmlData.added_landmarks==parseInt(regFusionQmlData.no_controlpoints)){
                    txtmsg.text = "Specified no. of landmarks have already been added"
                }
                else{
                    qtObj.getLandmarkLocations(regFusionQmlData.rxfactor, regFusionQmlData.ryfactor, regFusionQmlData.axfactor, regFusionQmlData.ayfactor)
                    regFusionQmlData.added_landmarks = regFusionQmlData.added_landmarks + 1
                    txtmsg.text = "Landmark " + regFusionQmlData.added_landmarks + " added"
                    imagealign.source = ""
                    imagealign.source = mainqmldata.landmarks_pathalign
                    imagereference.source = ""
                    imagereference.source = mainqmldata.landmarks_pathref
                }
            }
            background: Rectangle {
                color: parent.down ? "#bbbbbb" : (parent.hovered ? "#deeeea" : "white")
            }   
        }
    }

    //TEST CASE TEXTBOX FOR DISPLAYING MESSAGES
    Rectangle{
        id: testCaseMsgs
        height: parent.height
        color: "transparent"
        anchors {
            left: section1.left
            right: section2.right
        }

        Text {
            id: txtmsg
            text: ""
            color: "white"
            font.pointSize: 11
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors{
                bottom: parent.bottom
                bottomMargin: 0.05 * parent.height
            }
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    //REGISTER AND FUSION SECTION
    Rectangle{
        id: section3
        width: 0.32 * parent.width
        color: "#232323"
        anchors{
            left: section2.right
            top: parent.top
            bottom: parent.bottom
        }

        ComboBox{
            id: monomulti
            background: Rectangle {
                color: parent.hovered ? "#deeeea" : "white"
            }
            model: ["Multimodal", "Monomodal"]
            width: 0.3 * parent.width
            height: 0.05 * parent.height
            anchors{
                left: parent.left
                leftMargin: 0.05 * parent.width
                top: parent.top
                topMargin: 0.1 * parent.height
            }
            onActivated: {
                if (monomulti.currentText == "Multimodal"){
                    txtmsg.text = "Switched to Multimodal Registration"
                    txtcontrolpoints.visible = true
                    noOfControlPoints.visible = true
                    imagealign.source = mainqmldata.landmarks_pathalign
                    imagereference.source = mainqmldata.landmarks_pathref
                    if (imagealign.source != "" && imagereference.source != ""){
                        btaddpair.visible = true
                        aMouseArea.cursorShape = Qt.CrossCursor
                        rMouseArea.cursorShape = Qt.CrossCursor
                    }
                }
                if (monomulti.currentText == "Monomodal"){
                    txtmsg.text = "Switched to Monomodal Registration"
                    btaddpair.visible = false
                    txtcontrolpoints.visible = false
                    noOfControlPoints.visible = false
                    aMouseArea.cursorShape = Qt.ArrowCursor
                    rMouseArea.cursorShape = Qt.ArrowCursor
                    aLandmarkCircle.visible = false
                    aLandmarkDot.visible = false
                    rLandmarkCircle.visible = false
                    rLandmarkDot.visible = false
                    imagealign.source = regFusionQmlData.pathalign
                    imagereference.source = regFusionQmlData.pathref
                }
            }
        }

        Button{
            id: btregister
            contentItem: Text{
                text: "Register"
                clip: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            height: monomulti.height
            anchors{
                left: monomulti.right
                leftMargin: 0.02 * parent.width
                top: parent.top
                topMargin: 0.1 * parent.height
                right: parent.right
                rightMargin: 0.05 * parent.width
            }
            onClicked: {
                txtmsg.text = ""
                if(imagealign.source == ""){
                    txtmsg.text = "Cannot Register! Please select the image to be aligned"
                }
                else if(imagereference.source == ""){
                    txtmsg.text = "Cannot Register! Please select the reference image"
                }
                else{
                    if (monomulti.currentText == "Multimodal"){
                        if(regFusionQmlData.added_landmarks<parseInt(regFusionQmlData.no_controlpoints)){
                            txtmsg.text = "Cannot Register! Please add the specified no. of landmarks"
                            return
                        }
                    }
                    imageoutput.source = ""
                    emptyimage3.visible = false
                    outputErrorText.visible = false
                    section4.visible = false

                    regFusionQmlData.fusionDone = false
                    btfusion.visible = false
                    
                    outputError.visible = true
                    displayLoading.visible = true
                    txtmsg.text = "Please Wait..."

                    var contrastalign = contrastOptionAlign.checkState == Qt.Checked ? true : false
                    var contrastref = contrastOptionRef.checkState == Qt.Checked ? true : false
                    qtObj.registerThread(monomulti.currentText, contrastref, contrastalign)
                }
                // ro_obj = MyScript.createRegOutput()
                // registrationFusionPage.destroy()
                // MyScript.createRegPage()  
            }
            background: Rectangle {
                color: parent.down ? "#bbbbbb" : (parent.hovered ? "#deeeea" : "white")
            }   
        }

        Rectangle{
            id: txtcontrolpoints
            color: "white"
            width: 0.6 * parent.width
            height: 0.05 * parent.height
            anchors{
                left: parent.left
                leftMargin: 0.05 * parent.width
                top: parent.top
                topMargin: 0.2 * parent.height
            }
            Text{
                text: "Select No. of Control Points:"
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
        
        ComboBox {
            id: noOfControlPoints
            height: 0.05 * parent.height
            background: Rectangle {
                color: parent.hovered ? "#deeeea" : "white"
            }
            model: ["4", "5", "6", "7", "8", "9", "10"]
            anchors{
                left: txtcontrolpoints.right
                leftMargin: 0.02 * parent.width
                top: parent.top
                topMargin: 0.2 * parent.height
                right: parent.right
                rightMargin: 0.05 * parent.width
            }
            onActivated: {
                if (regFusionQmlData.added_landmarks>parseInt(noOfControlPoints.currentText)){
                    noOfControlPoints.currentIndex = regFusionQmlData.no_controlpoints - 4
                    txtmsg.text = "You have already added " + regFusionQmlData.added_landmarks + " landmark pairs"
                }
                else{
                    regFusionQmlData.no_controlpoints = noOfControlPoints.currentText
                }
            }
        }

        Image{
            id: imageoutput
            cache: false
            source: ""
            width: 0.9 * parent.width
            anchors {
                left: parent.left
                leftMargin: 0.05 * parent.width
                top: parent.top
                topMargin: 0.32 * parent.height
                bottom: parent.bottom
                bottomMargin: 0.12 * parent.height
            }
        }
        
        EmptyImage {
            id: emptyimage3
        }

        Shape{
            id: outputError
            visible: false
            width: emptyimage3.width
            height: emptyimage3.height
            anchors {
                left: parent.left
                leftMargin: 0.05 * parent.width
                right: parent.right
                rightMargin: 0.05 * parent.width
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
                PathLine { x: outputError.width; y: 0 }
                PathLine { x: outputError.width; y: outputError.height}
                PathLine { x: 0; y: outputError.height }
                PathLine { x: 0; y: 0; }
            }
            Text {
                id: outputErrorText
                visible: false
                text: ""
                color: "white"
                font.pointSize: 11
                wrapMode: Text.WordWrap
                // width: 0.5 * parent.width
                // anchors.horizontalCenter : parent.horizontalCenter
                anchors.verticalCenter : parent.verticalCenter
                anchors{
                    left: parent.left
                    leftMargin: 0.2 * parent.width
                    right: parent.right
                    rightMargin: 0.2 * parent.width
                }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            AnimatedImage {
                id: displayLoading
                visible: false
                source: "./images/Rolling-2.6s.gif"
                anchors.centerIn: parent
                width: 0.4*parent.width
                height: width
            }
        }
        Button{
            id: btfusion
            visible: false
            width: 0.5 * parent.width 
            anchors{
                bottom: parent.bottom
                bottomMargin: 0.04 * parent.height
                top: imageoutput.bottom
                topMargin: 0.03 * parent.height
            }
            anchors.horizontalCenter: parent.horizontalCenter
            contentItem: Text{
                text: "Perform Fusion"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                color: parent.down ? "#bbbbbb" : (parent.hovered ? "#deeeea" : "white")
            }  
            onClicked: {
                imageoutput.source = ""
                emptyimage3.visible = false
                outputErrorText.visible = false
                
                outputError.visible = true
                displayLoading.visible = true
                txtmsg.text = "Please Wait..."

                qtObj.fusionThread()
            }
        }
    }

    //SAVE OUTPUT AND WIDE VIEW BUTTON SECTION
    Rectangle{
        id: section4
        visible: false
        color: "#232323"
        anchors{
            left: section3.right
            right: parent.right
            top: parent.top
            topMargin: 0.32 * parent.height
            bottom: parent.bottom
            bottomMargin: 0.12 * parent.height
        }
        Image{
            id: btsave
            source : "./images/download-128.ico"
            property double btwidth: btsave.width
            height: btwidth
            anchors{
                left: parent.left
                leftMargin: 0.12 * parent.width
                right: parent.right
                rightMargin: 0.26 * parent.width
                bottom: parent.bottom
                bottomMargin: 0.55 * parent.height
            }
            MouseArea {
                id: btsaveMouseArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onPressed: {
                    parent.anchors.leftMargin = 1.2 * parent.anchors.leftMargin
                    parent.anchors.rightMargin = 1.2 * parent.anchors.rightMargin
                }
                onReleased: {
                    parent.anchors.leftMargin = parent.anchors.leftMargin / 1.2
                    parent.anchors.rightMargin = parent.anchors.rightMargin / 1.2
                }
                onClicked: {
                    saveDestination.open()
                }
            }
        }
        FolderDialog{
            id: saveDestination
            onAccepted: {
                txtmsg.text = 'Saving files...'
                qtObj.saveOutputThread(folder)
            }
        }
        Image{
            id: btwideview
            source : "./images/expand-128.ico"
            property double btwidth: btwideview.width
            height: btwidth
            anchors{
                left: parent.left
                leftMargin: 0.12 * parent.width
                right: parent.right
                rightMargin: 0.26 * parent.width
                top: parent.top
                topMargin: 0.55 * parent.height
            }
            MouseArea {
                id: btwideviewMouseArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onPressed: {
                    parent.anchors.leftMargin = 1.2 * parent.anchors.leftMargin
                    parent.anchors.rightMargin = 1.2 * parent.anchors.rightMargin
                }
                onReleased: {
                    parent.anchors.leftMargin = parent.anchors.leftMargin / 1.2
                    parent.anchors.rightMargin = parent.anchors.rightMargin / 1.2
                }
                onClicked: {
                    MyScript.createWideViewWindow()
                    registrationFusionPage.sendPathsToNewWindow(regFusionQmlData.pathref, regFusionQmlData.pathalign, mainqmldata.pathoutput, mainqmldata.pathfusionoutput, regFusionQmlData.fusionDone)
                }
            }
        }
    }  
}