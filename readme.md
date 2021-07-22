# Desktop Application for Medical Image Registration and Fusion

Perform Image Registration and Fusion on Monomodal and Multimodal Medical images.
Voxel based algorithm has been used for monomodal registration and Manual Landmark Selection based registration for multimodal images.
IFCNN model is used for performing image fusion.

## Installation
1. Install the python package to create Virtual Environment
```
pip install virtualenv
```
2. In cmd, navigate to the directory in which you want to create the virtual environment and execute the following command to create a virtual environment
```
py -m venv virtual-env-name
```
3. Activate the Virtual environment
```
virtual-env-name\Scripts\activate.bat
```
4. Install Project Dependencies in the virtual environment
```
pip install -r requirements.txt
```
5. In cmd, navigate to the directory that contains the project files and execute the following command
```
python main.py
```

## Features of the Application

- Perform registration on monomodal images
- Perform registration on multimodal images by selecting 4-10 landmark pairs
- Apply contrast enhancement on input images if required
- Perform Fusion on registered images
- Save all the input and result images
- View the input and result images in a new window for efficient comparison and analysis

## Techstack

- Python
- QML
- JavaScript

## Registration and Fusion Algorithms References

- [Monomodal Registration](https://github.com/InsightSoftwareConsortium/ITKElastix/tree/master/examples)
- [Multimodal Registration](https://github.com/ashna111/multimodal-image-fusion-to-detect-brain-tumors)
- [Fusion](https://github.com/uzeful/IFCNN)