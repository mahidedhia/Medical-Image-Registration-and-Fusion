function createRegFusionPage() {
    var page = Qt.createComponent("regFusionPage.qml");
    var rfpobj = page.createObject(root);
    if (rfpobj == null) {
        // Error Handling
        console.log("Error creating object");
    }
    return rfpobj
}

function createWideViewWindow() {
    var wideview_window = Qt.createComponent("WideViewWindow.qml");
    var wvobj = wideview_window.createObject(root);
    if (wvobj == null) {
        console.log("Error creating object");
    }
}