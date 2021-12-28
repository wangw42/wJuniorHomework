# -*- coding: utf-8 -*-

import cv2
import sys
import io
import numpy as np
import pandas as pd
from PIL import Image
from sklearn.decomposition import PCA
from matplotlib import pyplot as plt
from sklearn.cluster import KMeans
import imutils

def sift_function(im, im_num):
    im1 = im.copy()
    gray = cv2.cvtColor(im, cv2.COLOR_BGR2GRAY)

    sift = cv2.xfeatures2d.SIFT_create()
    kp,des = sift.detectAndCompute(gray, None)

    
    pca_sk = PCA(n_components=10)   
    pca_sift_feature = pca_sk.fit_transform(des)
    pca_sift_feature = pca_sift_feature.flatten()

    # draw sift points
    '''
    cv2.drawKeypoints(gray, kp, im)
    cv2.drawKeypoints(gray, kp, im1, flags=cv2.DRAW_MATCHES_FLAGS_DRAW_RICH_KEYPOINTS)
    plt.subplot(121), plt.imshow(im)
    plt.subplot(122), plt.imshow(im1)
    plt.show()
    '''

    # crop image based on sift points -> 16*16
    pca_sift_points = cv2.KeyPoint_convert(kp) 
    sift_patch = {}
    points = []

    for point in pca_sift_points:
        x = point[0]
        y = point[1]
        xy = (x,y)
        points.append(xy)
        tmp_crop = im[int(y-8):int(y+8), int(x-8):int(x+8)]
        sift_patch[xy] = tmp_crop



    patch_feature = []
    for point in points:
        patch_hist = cv2.calcHist([sift_patch[point]], [0, 1, 2], None, [4, 4, 4], [0, 256, 0, 256, 0, 256])
        patch_hist = patch_hist.flatten()
        patch_feature.append(np.concatenate((patch_hist,pca_sift_feature),axis=0)) 
    


    # k-means
    kmeans = KMeans(n_clusters=3, random_state=0).fit(patch_feature)
    cluster_map = pd.DataFrame()
    cluster_map['data_index'] = points
    cluster_map['cluster'] = kmeans.labels_
    # print(cluster_map[cluster_map.cluster == 0])
    
    for i in range(0,3):

        image_file = []
        patch_index = cluster_map[cluster_map.cluster == i].data_index.values
        for index in patch_index:
            if sift_patch[index].size == 0:
                continue
            tmp_img = cv2.resize(sift_patch[index], (16, 16), interpolation=cv2.INTER_LINEAR)
            image_file.append(tmp_img)

        print( "cluster", i+1 ,", include " , len(image_file), "patches")
        save_path = "./out/q3/"+ str(im_num)+ "_" +str(i)+ ".png"
        # 拼接
        final_image = cv2.hconcat(image_file)
        cv2.imwrite(save_path, final_image)
 
        print('image cluster ' + str(i) + ' saved')
    

def main():

    test_img_num = [90, 190, 290, 390, 490, 590, 690, 790, 890, 990]
    for i in test_img_num:
        test_img_name = "./data/imgs/" + str(i) + ".png"
        test_img = cv2.imread(test_img_name)
        print("--------------Image", test_img_name , "----------------")
        sift_function(test_img, i)
       


    return 0


if __name__ == '__main__':
    main()