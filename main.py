# GUI
from PyQt5.QtGui import QGuiApplication
from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtCore import QObject, pyqtSignal, pyqtProperty, pyqtSlot
import PyQt5

import sys
import threading
import numpy as np
import os
import shutil

import IPAlgorithms as algo

import cv2
from PIL import Image
import pydicom
import imageio

class RegistrationFusion(QObject):
    refimg_orig = ""
    refimg_conv = ""
    refimg_copy = ""
    refimg_landmarks = ""

    alignimg_orig = ""
    alignimg_conv = ""
    alignimg_copy = ""
    alignimg_landmarks = ""

    outputdir = ""
    outputimg_path = ""
    outputimg_fusion_path = ""

    landmarkslist_refimg = []
    landmarkslist_alignimg = []

    bool_registered_monomodal = False
    bool_registered_multimodal = False
    bool_refimg_conv = False
    bool_alignimg_conv = False
    bool_contrastref = False
    bool_contrastalign = False

    updateRefPath = pyqtSignal(str)
    updateAlignPath = pyqtSignal(str)
    updateLandmarkImagesPath = pyqtSignal(str, str)
    updateOutputPath = pyqtSignal(str, int)
    updateOutputFusionPath = pyqtSignal(str, int)
    updateFilesSaved = pyqtSignal(int)

    def __init__(self):
        QObject.__init__(self)

    #OBTAINING REFERENCE IMAGE FROM USER
    @pyqtSlot(str)
    def getRefImg(self,filepath):
        # DELETING EARLIER CONVERTED JPEG FILE IN CASE USER CHANGES THE SELECTED IMAGE
        if self.bool_refimg_conv:
            if os.path.exists(self.refimg_conv):
                os.remove(self.refimg_conv)

        # RESETTING/INITIALIZING FOR NEW IMAGE SELECTED
        self.landmarkslist_refimg = []
        self.landmarkslist_alignimg = []
        self.bool_registered_monomodal = False
        self.bool_registered_multimodal = False

        # UPDATING REFERENCE IMAGE PATH
        self.refimg_orig = filepath[8:]
        self.refimg_conv, self.bool_refimg_conv = checkForConversion(self.refimg_orig, 'ref')
        if self.bool_refimg_conv:
            self.updateRefPath.emit("file:///" + self.refimg_conv)
        else:
            self.updateRefPath.emit("file:///" + self.refimg_orig)

        # DELETE THE OUTPUT DIRECTORY OF EARLIER REGISTERED IMAGES IF USER CHANGES SELECTED IMAGES
        if os.path.exists(self.outputdir):
            shutil.rmtree(self.outputdir)

        # CREATE OUTPUT FOLDER ONLY IF BOTH IMAGES ARE SELECTED
        if self.alignimg_orig != "":
            self.bothImagesSelected()

    @pyqtSlot(str)
    def getAlignImg(self,filepath):
        if self.bool_alignimg_conv:
            if os.path.exists(self.alignimg_conv):
                os.remove(self.alignimg_conv)

        self.landmarkslist_refimg = []
        self.landmarkslist_alignimg = []
        self.bool_registered_monomodal = False
        self.bool_registered_multimodal = False

        self.alignimg_orig = filepath[8:]
        self.alignimg_conv, self.bool_alignimg_conv = checkForConversion(self.alignimg_orig, 'align')
        if self.bool_alignimg_conv:
            self.updateAlignPath.emit("file:///" + self.alignimg_conv)
        else:
            self.updateAlignPath.emit("file:///" + self.alignimg_orig)

        if os.path.exists(self.outputdir):
            shutil.rmtree(self.outputdir)
        
        if self.refimg_orig != "":
            self.bothImagesSelected()

    def bothImagesSelected(self):
        file_ref = os.path.basename(self.refimg_orig)
        filename_ref = os.path.splitext(file_ref)[0]
        file_align = os.path.basename(self.alignimg_orig)
        filename_align = os.path.splitext(file_align)[0]

        # CREATE OUTPUT DIRECTORY
        self.outputdir = "./output_"+ filename_ref + "_" + filename_align
        if os.path.exists(self.outputdir):
            shutil.rmtree(self.outputdir)
        os.makedirs(self.outputdir)

        # COPY BOTH IMAGES INSIDE THE CREATED DIRECTORY 
        self.refimg_copy = self.outputdir + "/refimg_" + file_ref
        shutil.copy(self.refimg_orig,self.refimg_copy)
        self.alignimg_copy = self.outputdir + "/alignimg_" + file_align
        shutil.copy(self.alignimg_orig,self.alignimg_copy)

        # IF ORIGINAL IMAGE TYPE IS NOT JPEG, COPY THE CONVERTED JPEG FORMAT TO OUTPUT DIRECTORY
        if self.bool_refimg_conv:
            self.refimg_copy = self.outputdir + "/refimg_conv.jpeg"
            shutil.copy(self.refimg_conv, self.refimg_copy)
        if self.bool_alignimg_conv:
            self.alignimg_copy = self.outputdir + "/alignimg_conv.jpeg"
            shutil.copy(self.alignimg_conv, self.alignimg_copy)

        # CREATE A COPY OF BOTH IMAGES FOR DISPLAYING LANDMARK POINTS
        self.refimg_landmarks = self.outputdir + "/refimg_with_landmarks.jpeg"
        shutil.copy(self.refimg_copy, self.refimg_landmarks)
        self.alignimg_landmarks = self.outputdir + "/alignimg_with_landmarks.jpeg"
        shutil.copy(self.alignimg_copy, self.alignimg_landmarks)

        # UPDATE THE FILEPATHS OF IMAGES DISPLAYED ON GUI (SHOULD HAVE THE IMAGES WITH LANDMARK POINTS IF ANY)
        refimgpath_qml = os.path.abspath(self.refimg_landmarks)
        refimgpath_qml = "file:///" + refimgpath_qml
        alignimgpath_qml = os.path.abspath(self.alignimg_landmarks)
        alignimgpath_qml = "file:///" + alignimgpath_qml
        self.updateLandmarkImagesPath.emit(refimgpath_qml,alignimgpath_qml)

    @pyqtSlot(float, float, float, float)
    def getLandmarkLocations(self, rx, ry, ax, ay):
        self.landmarkslist_refimg.append([rx, ry])
        self.landmarkslist_alignimg.append([ax, ay])

        # MARK CIRCLES AT THE LANDMARK POINTS OBTAINED FROM USER
        color = (0, 0, 255)
        thickness = -1

        image = cv2.imread(self.refimg_landmarks)
        radius = int(max(image.shape[0],image.shape[1]) * 0.006)
        center_coordinates = (int(rx), int(ry))
        image = cv2.circle(image, center_coordinates, radius, color, thickness)
        cv2.imwrite(self.refimg_landmarks, image)
        
        image = cv2.imread(self.alignimg_landmarks)
        radius = int(max(image.shape[0],image.shape[1]) * 0.006)
        center_coordinates = (int(ax), int(ay))
        image = cv2.circle(image, center_coordinates, radius, color, thickness)
        cv2.imwrite(self.alignimg_landmarks, image)

    @pyqtSlot(str, bool, bool)
    def registerThread(self, modality, contrastref, contrastalign):
        self.bool_contrastref = contrastref
        self.bool_contrastalign = contrastalign
        # THREAD REQUIRED TO KEEP THE QML GUI RUNNING WHILE PYTHON PROCESSES REGISTERED IMAGE
        if modality == 'Monomodal':
            t_thread = threading.Thread(target=self.registerMonomodal, kwargs = {'contrast_enhancement_ref' : contrastref, 'contrast_enhancement_align' : contrastalign } )
            t_thread.daemon = True
            t_thread.start()
        elif modality == 'Multimodal':
            t_thread = threading.Thread(target=self.registerMultimodal, kwargs = {'contrast_enhancement_ref' : contrastref, 'contrast_enhancement_align' : contrastalign } )
            t_thread.daemon = True
            t_thread.start()
    
    def registerMonomodal(self, contrast_enhancement_ref, contrast_enhancement_align):
        outputname = self.outputdir + "/registered_monomodal_without_contrast_enhancement.jpeg"

        # SAVE IMAGES AFTER CONTRAST ENHANCEMENT
        if contrast_enhancement_ref:
            img = cv2.imread(self.refimg_copy,0)
            equ = cv2.equalizeHist(img)
            fname = self.outputdir + "/refimg_after_contrast_enhancement.jpeg"
            cv2.imwrite(fname,equ)
            refpath = os.path.abspath(fname)
            outputname = self.outputdir + "/registered_monomodal_contrast_enhancement_on_refimg.jpeg"
        else:
            refpath = self.refimg_copy

        if contrast_enhancement_align:
            img = cv2.imread(self.alignimg_copy,0)
            equ = cv2.equalizeHist(img)
            fname = self.outputdir + "/alignimg_after_contrast_enhancement.jpeg"
            cv2.imwrite(fname,equ)
            alignpath = os.path.abspath(fname)
            outputname = self.outputdir + "/registered_monomodal_contrast_enhancement_on_alignimg.jpeg"
        else:
            alignpath = self.alignimg_copy

        if contrast_enhancement_ref and contrast_enhancement_align:
            outputname = self.outputdir + "/registered_monomodal_contrast_enhancement_on_both.jpeg"

        # CALL THE REGISTRATION FUNCTION
        success = algo.monomodalRegistrationITK(refpath, alignpath, outputname)
        if success:
            self.bool_registered_monomodal = True
            # SEND OUTPUT PATH TO QML
            self.outputimg_path = os.path.abspath(outputname)
            outputimgpath_qml = 'file:///' + self.outputimg_path
            self.updateOutputPath.emit(outputimgpath_qml,1)
        return

    def registerMultimodal(self, contrast_enhancement_ref, contrast_enhancement_align):
        # #GENERATE THE TXT FILES WITH LANDMARKS
        # with open('landmarks_refimg.txt', 'w') as file:
        #     file.write('index\n')
        #     file.write(str(len(self.landmarkslist_refimg))+'\n')
        #     for coordinate in self.landmarkslist_refimg:
        #         file.write(str(coordinate[0])+' '+str(coordinate[1])+'\n')
        # with open('landmarks_alignimg.txt', 'w') as file:
        #     file.write('index\n')
        #     file.write(str(len(self.landmarkslist_alignimg))+'\n')
        #     for coordinate in self.landmarkslist_alignimg:
        #         file.write(str(coordinate[0])+' '+str(coordinate[1])+'\n')

        outputname = self.outputdir + "/registered_multimodal_without_contrast_enhancement.jpeg"

        if contrast_enhancement_ref:
            img = cv2.imread(self.refimg_copy,0)
            equ = cv2.equalizeHist(img)
            fname = self.outputdir + "/refimg_after_contrast_enhancement.jpeg"
            cv2.imwrite(fname,equ)
            refpath = os.path.abspath(fname)
            outputname = self.outputdir + "/registered_multimodal_contrast_enhancement_on_refimg.jpeg"
        else:
            refpath = self.refimg_copy

        if contrast_enhancement_align:
            img = cv2.imread(self.alignimg_copy,0)
            equ = cv2.equalizeHist(img)
            fname = self.outputdir + "/alignimg_after_contrast_enhancement.jpeg"
            cv2.imwrite(fname,equ)
            alignpath = os.path.abspath(fname)
            outputname = self.outputdir + "/registered_multimodal_contrast_enhancement_on_alignimg.jpeg"
        else:
            alignpath = self.alignimg_copy

        if contrast_enhancement_ref and contrast_enhancement_align:
            outputname = self.outputdir + "/registered_monomodal_contrast_enhancement_on_both.jpeg"

        # CALL THE REGISTRATION FUNCTION
        # output_img = algo.multimodalRegistrationITK(refpath, alignpath, './landmarks_refimg.txt','./landmarks_alignimg.txt')
        success = algo.multimodalRegistrationNumpyOpencv(refpath, alignpath, self.landmarkslist_refimg, self.landmarkslist_alignimg, outputname)
        if success:
            self.bool_registered_multimodal = True
            # SEND OUTPUT PATH TO QML
            self.outputimg_path = os.path.abspath(outputname)
            outputimgpath_qml = 'file:///' + self.outputimg_path
            self.updateOutputPath.emit(outputimgpath_qml,1)
        return

    @pyqtSlot()
    def fusionThread(self):
        # THREAD REQUIRED TO KEEP THE QML GUI RUNNING WHILE PYTHON PERFORMS FUSION ON IMAGES
        t_thread = threading.Thread(target=self.fusion)
        t_thread.daemon = True
        t_thread.start()
        
    def fusion(self):
        refpath = ""
        if self.bool_refimg_conv:
            refpath = self.refimg_conv
        else:
            refpath = self.refimg_orig
        regpath = self.outputimg_path

        outputname = ""
        if self.bool_registered_monomodal:
            outputname = self.outputdir + "/fusion_monomodalreg_"
        else:
            outputname = self.outputdir + "/fusion_multimodalreg_"

        if self.bool_contrastref and self.bool_contrastalign:
            outputname += 'contrast_enhancement_on_both.png'
        elif self.bool_contrastref:
            outputname += 'contrast_enhancement_on_refimg.png'
        elif self.bool_contrastalign:
            outputname += 'contrast_enhancement_on_alignimg.png'
        else:
            outputname += 'without_contrast_enhancement.png'
        
        # CALL THE FUSION FUNCTION
        success = algo.fusionIFCNN(refpath, regpath, outputname)
        if success:
            # SEND OUTPUT PATH TO QML
            self.outputimg_fusion_path = os.path.abspath(outputname)
            outputimgpath_qml = 'file:///' + self.outputimg_fusion_path
            self.updateOutputFusionPath.emit(outputimgpath_qml,1)
        return

    @pyqtSlot(str)
    def saveOutputThread(self, destination):
        t_thread = threading.Thread(target=self.saveOutput, kwargs = {'destination' : destination} )
        t_thread.daemon = True
        t_thread.start()

    def saveOutput(self, destination):
        # SAVE THE OUTPUT IN THE DESTINATION DIRECTORY SELECTED BY USER
        destination = destination[8:]
        if os.path.exists(self.outputdir):
            destination += self.outputdir[1:]
            if os.path.exists(destination):
                # IF FOLDER ALREADY EXISTS, DONT SAVE
                self.updateFilesSaved.emit(0)
            else:
                shutil.copytree(self.outputdir, destination)
                if not self.bool_registered_multimodal:
                    # IF USER DIDN'T PERFORM MULTIMODAL REGISTRATION, DELETE THE IMAGES COPIED FOR DISPLAYING LANDMARKS
                    savedlandmarks = destination + '/refimg_with_landmarks.jpeg'
                    if os.path.exists(savedlandmarks):
                        os.remove(savedlandmarks)
                    savedlandmarks = destination + '/alignimg_with_landmarks.jpeg'
                    if os.path.exists(savedlandmarks):
                        os.remove(savedlandmarks)
                self.updateFilesSaved.emit(1)
    

def checkForConversion(filepath, img):
    file = os.path.basename(filepath)
    file = os.path.splitext(file)
    filename = file[0]
    extension = file[1]
    # IF DICOM IMAGE SELECTED, CONVERT IT TO JPEG
    if extension == ".dcm":
        dicom_file = pydicom.read_file(filepath)
        converted_img = dicom_file.pixel_array
        converted_img = np.uint8(converted_img)
        if img == 'ref':
            filejpegpath = ".//" + filename + "_convref.jpeg"
        else:
            filejpegpath = ".//" + filename + "_convalign.jpeg"
        imageio.imwrite(filejpegpath, converted_img)
        filejpegpath = os.path.abspath(filejpegpath)
        return filejpegpath, True
    # IF PNG IMAGE SELECTED, CONVERT IT TO JPEG
    elif extension == ".png":
        img_png = Image.open(filepath)
        if img == 'ref':
            filejpegpath = ".//" + filename + "_convref.jpeg"
        else:
            filejpegpath = ".//" + filename + "_convalign.jpeg"
        img_png.save(filejpegpath)
        filejpegpath = os.path.abspath(filejpegpath)
        return filejpegpath, True
    else:
        return "", False


# CONNECT AND START THE QML APPLICATION
app = QGuiApplication(sys.argv)
app.setOrganizationName("kjsce")
app.setOrganizationDomain("kjsce")
app.setWindowIcon(PyQt5.QtGui.QIcon("./UI/images/app-icon.png"))

engine = QQmlApplicationEngine()
engine.quit.connect(app.quit)
engine.load('./UI/main.qml')

QObj = RegistrationFusion()
engine.rootObjects()[0].setProperty('qtObj', QObj)
# sys.exit(app.exec())
app.exec()

# DELETE ALL EXTRA FILES CREATED DURING PROCESSING BEFORE EXITING PROGRAM
if os.path.exists(QObj.outputdir):
    shutil.rmtree(QObj.outputdir)
if QObj.bool_refimg_conv:
    if os.path.exists(QObj.refimg_conv):
        os.remove(QObj.refimg_conv)
if QObj.bool_alignimg_conv:
    if os.path.exists(QObj.alignimg_conv):
        os.remove(QObj.alignimg_conv)
if QObj.bool_registered_multimodal:
    path = './landmarks_refimg.txt'
    if os.path.exists(path):
        os.remove(path)
    path = './landmarks_alignimg.txt'
    if os.path.exists(path):
        os.remove(path)
sys.exit()