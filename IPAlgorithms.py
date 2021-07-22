def monomodalRegistrationITK(filepath_fixed, filepath_moving, outputname):
    # RIGID, NORMALIZED CROSS CORRELATION OPTIMIZATION, VOXEL BASED, STOCHASTIC GRADIENT DESCENT
    
    '''
    ALGORITHM REFERENCE: 
    https://github.com/InsightSoftwareConsortium/ITKElastix/tree/master/examples
    https://elastix.lumc.nl/doxygen/parameter.html
    RESEARCH PAPERS REFERRED:
    http://www.iro.umontreal.ca/~sherknie/articles/medImageRegAnOverview/brussel_bvz.pdf
    https://www.sciencedirect.com/science/article/pii/S111086651500047X
    https://www.researchgate.net/publication/302975396_Intrinsic_registration_techniques_for_medical_images_A_state-of-the-art_review
    https://www.mdpi.com/2313-433X/5/1/5/htm
    '''
    import itk
    # IMPORT IMAGES IN FLOAT TYPE
    fixed_image = itk.imread(filepath_fixed, itk.F)
    moving_image = itk.imread(filepath_moving, itk.F)

    parameter_object = itk.ParameterObject.New()
    default_parameter_map = parameter_object.GetDefaultParameterMap('rigid')
    default_parameter_map['Metric'] = ['AdvancedNormalizedCorrelation']
    # default_parameter_map['FinalBSplineInterpolationOrder'] = ['2']
    parameter_object.AddParameterMap(default_parameter_map)
    # TO OBTAIN ALL THE REGISTRATION PARAMETERS:
    # parameter_object.WriteParameterFile(default_parameter_map,'parameterslist_monomodal.txt')

    # CALL REGISTRATION FUNCTION
    result_image, result_transform_parameters = itk.elastix_registration_method(
        fixed_image, moving_image,
        parameter_object=parameter_object,
        log_to_console=False)

    # CONVERT IMAGE TYPE FOR WRITING IT
    OutputPixelType = itk.ctype("unsigned char")
    InputImageType = type(result_image)
    dimension = result_image.GetImageDimension()
    OutputImageType = itk.Image[OutputPixelType, dimension]
    result_uc = itk.CastImageFilter[InputImageType, OutputImageType].New(result_image)
    itk.imwrite(result_uc , outputname)
    return True

def multimodalRegistrationITK(filepath_fixed, filepath_moving, landmarkspath_fixed, landmarkspath_moving, outputname): 

    '''
    ALGORITHM REFERENCE: 
    https://github.com/InsightSoftwareConsortium/ITKElastix/tree/master/examples
    https://elastix.lumc.nl/doxygen/parameter.html
    REFERENCE USED TO SELECT PARAMETERS FOR REGISTRATION
    https://itk.org/ITKSoftwareGuide/html/Book2/ITKSoftwareGuide-Book2ch3.html
    '''

    import itk
    import numpy as np
    # IMPORT IMAGES IN FLOAT TYPE
    fixed_image = itk.imread(filepath_fixed, itk.F)
    print(type(fixed_image))
    moving_image = itk.imread(filepath_moving, itk.F)

    fixed_point_set = np.loadtxt(landmarkspath_fixed, skiprows=2, delimiter=' ')
    moving_point_set = np.loadtxt(landmarkspath_moving, skiprows=2, delimiter=' ')

    parameter_object = itk.ParameterObject.New()
    parameter_map = parameter_object.GetDefaultParameterMap('affine')
    parameter_map['Registration'] = ['MultiMetricMultiResolutionRegistration']
    parameter_map['Metric'] = ['CorrespondingPointsEuclideanDistanceMetric','NormalizedMutualInformation']
    parameter_map['MovingImageDerivativeScales'] = ['1 1 0']
    parameter_map['NumberOfHistogramBins'] = ['24 24 24']

    parameter_map['Optimizer'] = ['RegularStepGradientDescent']
    parameter_map['MinimumStepLength'] = ['0.001 0.001 0.001']
    parameter_map['MaximumNumberOfIterations'] = ['200 200 200']
    parameter_map['RelaxationFactor'] = ['0.8 0.8 0.8']
    
    parameter_map['Transform'] = ['AffineTransform']
    parameter_map['Interpolator'] = ['LinearInterpolator']
    parameter_map['ResampleInterpolator'] = ['FinalLinearInterpolator']
    # TO OBTAIN ALL THE REGISTRATION PARAMETERS:
    # parameter_object.WriteParameterFile(parameter_map,'parameterslistlandmarks.txt')
    parameter_object.AddParameterMap(parameter_map)

    # CALL REGISTRATION FUNCTION
    elastix_object = itk.ElastixRegistrationMethod.New(fixed_image,moving_image)
    elastix_object.SetFixedPointSetFileName(landmarkspath_fixed)
    elastix_object.SetMovingPointSetFileName(landmarkspath_moving)
    elastix_object.SetParameterObject(parameter_object)
    elastix_object.SetLogToConsole(False)
    elastix_object.UpdateLargestPossibleRegion()

    # Results of Registration
    result_image = elastix_object.GetOutput()
    result_transform_parameters = elastix_object.GetTransformParameterObject()

    # CONVERT IMAGE TYPE FOR WRITING IT
    OutputPixelType = itk.ctype("unsigned char")
    InputImageType = type(result_image)
    dimension = result_image.GetImageDimension()
    OutputImageType = itk.Image[OutputPixelType, dimension]
    result_uc = itk.CastImageFilter[InputImageType, OutputImageType].New(result_image)
    itk.imwrite(result_uc , outputname)
    return True

# USED BY FUNCTION: multimodalRegistrationNumpyOpencv
def procrustes(X, Y, scaling=True, reflection='best'):
    import numpy as np
    n,m = X.shape
    ny,my = Y.shape

    muX = X.mean(0)
    muY = Y.mean(0)

    X0 = X - muX
    Y0 = Y - muY

    ssX = (X0**2.).sum()
    ssY = (Y0**2.).sum()

    # centred Frobenius norm
    normX = np.sqrt(ssX)
    normY = np.sqrt(ssY)

    # scale to equal (unit) norm
    X0 /= normX
    Y0 /= normY

    if my < m:
        Y0 = np.concatenate((Y0, np.zeros(n, m-my)),0)

    # optimum rotation matrix of Y
    A = np.dot(X0.T, Y0)
    U,s,Vt = np.linalg.svd(A,full_matrices=False)
    V = Vt.T
    T = np.dot(V, U.T)

    if reflection != 'best':

        # does the current solution use a reflection?
        have_reflection = np.linalg.det(T) < 0
        # if that's not what was specified, force another reflection
        if reflection != have_reflection:
            V[:,-1] *= -1
            s[-1] *= -1
            T = np.dot(V, U.T)

    traceTA = s.sum()

    if scaling:
        # optimum scaling of Y
        b = traceTA * normX / normY
        # standarised distance between X and b*Y*T + c
        d = 1 - traceTA**2
        # transformed coords
        Z = normX*traceTA*np.dot(Y0, T) + muX
    else:
        b = 1
        d = 1 + ssY/ssX - 2 * traceTA * normY / normX
        Z = normY*np.dot(Y0, T) + muX

    # transformation matrix
    if my < m:
        T = T[:my,:]
    c = muX - b*np.dot(muY, T)
    #rot =1
    #scale=2
    #translate=3
    #transformation values 
    tform = {'rotation':T, 'scale':b, 'translation':c}
    return d, Z, tform

def multimodalRegistrationNumpyOpencv(refpath, alignpath, ref_points, align_points, outputname):
    '''
    ALGORITHM USED:
    https://github.com/ashna111/multimodal-image-fusion-to-detect-brain-tumors
    '''

    import numpy as np
    import cv2
    from PIL import Image

    ref_cv = cv2.imread(refpath)
    ref_cv = cv2.cvtColor(ref_cv, cv2.COLOR_BGR2GRAY)
    align_cv = cv2.imread(alignpath)
    align_cv = cv2.cvtColor(align_cv, cv2.COLOR_BGR2GRAY)

    X_pts = np.asarray(ref_points)
    Y_pts = np.asarray(align_points)
    d,Z_pts,Tform = procrustes(X_pts,Y_pts)
    R = np.eye(3)
    R[0:2,0:2] = Tform['rotation']

    S = np.eye(3) * Tform['scale'] 
    S[2,2] = 1
    t = np.eye(3)
    t[0:2,2] = Tform['translation']
    M = np.dot(np.dot(R,S),t.T).T
    h=ref_cv.shape[0]
    w=ref_cv.shape[1]
    registered_cv = cv2.warpAffine(align_cv,M[0:2,:],(h,w))

    registered_image = Image.fromarray(registered_cv)
    registered_image.save(outputname)
    return True

# FUNCTION TO PERFORM FUSION
def fusionIFCNN(refpath, regpath, outputname):
    '''
    ALGORITHM USED:
    https://github.com/uzeful/IFCNN
    '''

    import os
    import cv2
    import numpy
    from PIL import Image
    import torch
    from model import myIFCNN

    os.environ['CUDA_DEVICE_ORDER']='PCI_BUS_ID'
    os.environ['CUDA_VISIBLE_DEVICES']='0'

    from torchvision import transforms
    from torch.autograd import Variable
    from utils.myTransforms import denorm, norms, detransformcv2

    # Load the well-trained image fusion model (IFCNN-MAX)

    # we use fuse_scheme to choose the corresponding model, 
    # choose 0 (IFCNN-MAX) for fusing multi-focus, infrare-visual and multi-modal medical images, 2 (IFCNN-MEAN) for fusing multi-exposure images
    fuse_scheme = 0
    model_name = 'IFCNN-MAX'

    device = torch.device("cpu")
    model = myIFCNN(fuse_scheme=fuse_scheme)
    model.load_state_dict(torch.load('./'+ model_name + '.pth', map_location=torch.device('cpu')))
    model.eval()
    model = model.to(device)

    # Use IFCNN to fuse
    from utils.myDatasets import ImagePair
    is_save = True
    is_gray = False
    # normalization parameters
    mean=[0, 0, 0]        
    std=[1, 1, 1]

    path1 = os.path.abspath(regpath)
    path2 = os.path.abspath(refpath)

    # load source images
    pair_loader = ImagePair(impath1=path1, impath2=path2, 
                            transform=transforms.Compose([
                            transforms.ToTensor(),
                            transforms.Normalize(mean=mean, std=std)
                            ]))
    img1, img2 = pair_loader.get_pair()
    img1.unsqueeze_(0)
    img2.unsqueeze_(0)

    # perform image fusion
    with torch.no_grad():
        res = model(Variable(img1.to(device)), Variable(img2.to(device)))
        res = denorm(mean, std, res[0]).clamp(0, 1) * 255
        res_img = res.cpu().data.numpy().astype('uint8')
        img = res_img.transpose([1,2,0])

    # save fused images
    if is_save:
        if is_gray:
            img = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)
            img = Image.fromarray(img)
            img.save(outputname, format='PNG', compress_level=0)
        else:
            img = Image.fromarray(img)
            img.save(outputname, format='PNG', compress_level=0)
    return True