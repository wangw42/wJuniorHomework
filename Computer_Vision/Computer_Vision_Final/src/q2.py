# -*- coding: utf-8 -*-

import cv2
import sys
import numpy as np
from PIL import Image
from sklearn.decomposition import PCA
from sklearn.tree import DecisionTreeRegressor  
from sklearn.ensemble import RandomForestRegressor  

rf = RandomForestRegressor()

def diff(img, x1, y1, x2, y2):
    r = np.square(img[0][y1, x1] - img[0][y2, x2])
    g = np.square(img[1][y1, x1] - img[1][y2, x2])
    b = np.square(img[2][y1, x1] - img[2][y2, x2])
    return np.sqrt(r + b + g)


class universe():
    def __init__(self, elements):
        self.num = elements;
        self.elts = []
        for i in range(elements):
            rank = 0;
            size = 1;
            p = i;
            self.elts.append((rank, size, p))


    # a newer func use recursion
    def find(self, u):
        if self.elts[u][2] == u:
            return u

        self.elts[u] = (self.elts[u][0], self.elts[u][1], self.find(self.elts[u][2]))
        return self.elts[u][2]

    def join(self, x, y):
        if self.elts[x][0] > self.elts[y][0]:
            self.elts[y] = (self.elts[y][0], self.elts[y][1], self.elts[x][2]);
            self.elts[x] = (self.elts[x][0], self.elts[x][1] + self.elts[y][1], self.elts[x][2])
        else:
            self.elts[x] = (self.elts[x][0], self.elts[x][1], self.elts[y][2])
            self.elts[y] = (self.elts[y][0], self.elts[y][1] + self.elts[x][1], self.elts[y][2])
            if self.elts[x][0] == self.elts[y][0]:
                self.elts[y] = (self.elts[y][0] + 1, self.elts[y][1], self.elts[y][2])
        self.num -= 1

    def size(self, x):
        return self.elts[x][1]

    def num_sets(self):
        return self.num


def THRESHOLD(size, c):
    return c / size

# Segment a graph
#
# Returns a disjoint-set forest representing the segmentation.
#
# num_vertices: number of vertices in graph.
# num_edges: number of edges in graph
# edges: array of edges.
# c: constant for treshold function.
def segment_graph(num_vertices, num_edges, graph, c):
    # make a disjoint-set forest
    u = universe(num_vertices)

    # init thresholds
    threshold = np.zeros(num_vertices, dtype=float)
    for i in range(num_vertices):
        threshold[i] = THRESHOLD(1, c)

    # for each edge, in non-decreasing weight order...
    for i in range(num_edges):
        a = u.find(graph[i][0])
        b = u.find(graph[i][1])
        if a != b:
            if ((graph[i][2] <= threshold[a]) and
                    graph[i][2] <= threshold[b]):
                u.join(a, b)
                a = u.find(a)
                threshold[a] = graph[i][2] + THRESHOLD(u.size(a), c)
    return u



def random_rgb():
    r = np.random.rand() * 255
    g = np.random.rand() * 255
    b = np.random.rand() * 255
    return (r, g, b)

# Segment an image
#
# Returns a color image representing the segmentation.
#
# im: image to segment.
# sigma: to smooth the image.
# c: constant for treshold function.
# min_size: minimum component size (enforced by post-processing stage).
# num_ccs: number of connected components in the segmentation.

def segment_and_rftraining(im, gt, sigma, c, min_size, num_ccs , global_hist):
    height, width, channel = im.shape
    h2, w2, ch2 = gt.shape

    im = np.array(im, dtype=float)
    gt = np.array(gt, dtype=float)

    gaussian_img = cv2.GaussianBlur(im, (5, 5), sigma)
    gaussian_gt = cv2.GaussianBlur(gt,(5,5), sigma)

    b, g, r = cv2.split(gaussian_img)
    b2,g2,r2 = cv2.split(gaussian_gt)
    smooth_img = (r, g, b)
    # print(height, width, channel)

    # build graph
    graph = []
    num = 0;

    #print("staring segment image")
    for y in range(height):
        for x in range(width):
            if x < width - 1:
                a = y * width + x
                b = y * width + (x + 1)
                # w = 1
                w = diff(smooth_img, x, y, x + 1, y)
                num += 1
                graph.append((a, b, w))

            if y < height - 1:
                a = y * width + x
                b = (y + 1) * width + x
                w = diff(smooth_img, x, y, x, y + 1)
                num += 1
                graph.append((a, b, w))

            if x < width - 1 and y < height - 1:
                a = y * width + x
                b = (y + 1) * width + (x + 1)
                w = diff(smooth_img, x, y, x + 1, y + 1)
                num += 1
                graph.append((a, b, w))

            if x < width - 1 and y > 0:
                a = y * width + x
                b = (y - 1) * width + (x + 1)
                w = diff(smooth_img, x, y, x + 1, y - 1)
                num += 1
                graph.append((a, b, w))
        # print(x, y)

    # sort edges by weight
    # graph.sort(key=lambda x: (x[2]))
    graph = sorted(graph, key=lambda x: (x[2]))
    # segment

    u = segment_graph(width * height, num, graph, c)

    # post process small components
    for i in range(num):
        a = u.find(graph[i][0])
        b = u.find(graph[i][1])
        if (a != b) and ((u.size(a) < min_size) or u.size(b) < min_size):
            u.join(a, b)

    num_ccs.append(u.num_sets())

    colors = []
    for i in range(width * height):
        colors.append(random_rgb())

    #print("staring random colors")

    # print("width", width, "height", height)

    area_dict = {} # (x,y) -> comp
    for y in range(height):
        for x in range(width):
            comp = u.find(y * width + x)
            area_dict[(x,y)] = comp
            #gaussian_img[y][x] = colors[comp]

    # mark background and foreground
    bg_num = {} # comp -> bg_num
    fg_num = {} # comp -> fg_num
    for i in area_dict:
        fg_num[area_dict[i]] = 0
        bg_num[area_dict[i]] = 0

    for i in area_dict:
        if all(gaussian_gt[i[1]][i[0]]):
            fg_num[area_dict[i]] += 1
        else:
            bg_num[area_dict[i]] += 1


    color_dict = {} # comp->color
    for i, j in zip(bg_num,fg_num):
        if(bg_num[i] > fg_num[i]):
            color_dict[i] = (0,0,0)
        else:
            color_dict[i] = (255,255,255)


    for y in range(height):
        for x in range(width):
            temp_comp = u.find(y * width + x)
            gaussian_img[y][x] = color_dict[temp_comp]


    # calculate hist and feature
    seg_list = {}
    for y in range(height):
        for x in range(width):
            seg_id = u.find(y * width + x)
            if seg_id not in seg_list:
                seg_list[seg_id] = Image.new("RGB",  (height,width))

            tmp_gaussimg = gaussian_img[y][x]
            tmp_gaussimg = tmp_gaussimg.astype(np.int)
            tmp_color = tuple(tmp_gaussimg)

            seg_list[seg_id].putpixel((y,x),tmp_color)


    seg_hist = {}
    for seg_id in seg_list:
        tmp_seg = cv2.cvtColor(np.array(seg_list[seg_id]), cv2.COLOR_RGB2BGR)  # PIL转cv2
        seg_hist[seg_id] = cv2.calcHist([tmp_seg], [0, 1, 2], None, [8, 8, 8], [0, 256, 0, 256, 0, 256])
        #cv2.normalize(seg_hist[seg_id], seg_hist[seg_id], 0, 1, cv2.NORM_MINMAX)

    
    seg_feature = {}
    for seg_id in seg_hist:
        tmp_feature = np.concatenate((seg_hist[seg_id],global_hist),axis=1)
        seg_feature[seg_id] = tmp_feature
        
        #print(seg_feature[seg_id])
    
    # 1024 -> 50
    seg_pca = {}
    for seg_id in seg_feature:
        pca_sk = PCA(n_components=50)   
        feature_1d = seg_feature[seg_id].flatten()
        cv2.normalize(feature_1d, feature_1d, 0, 1, cv2.NORM_MINMAX)
        seg_pca[seg_id] = feature_1d[0:50]

        #seg_pca[seg_id] = pca_sk.fit_transform(feature_2d)
    
    # label
    seg_label = {}
    for y in range(height):
        for x in range(width):
            temp_id = u.find(y * width + x)
            if all(gaussian_img[y][x]):
                seg_label[temp_id] = np.ones(50)
            else :
                seg_label[temp_id] = np.zeros(50)

    # random forest training
    for seg_id in seg_label:
        data = seg_pca[seg_id].reshape(-1,1)
        target = seg_label[seg_id]
        rf.fit(data, target)
    
    #return gaussian_img

def segment_and_rfpredict(im, gt, sigma, c, min_size, num_ccs , global_hist, test_img_name):
    height, width, channel = im.shape
    h2, w2, ch2 = gt.shape

    im = np.array(im, dtype=float)
    gt = np.array(gt, dtype=float)

    gaussian_img = cv2.GaussianBlur(im, (5, 5), sigma)
    gaussian_gt = cv2.GaussianBlur(gt,(5,5), sigma)

    b, g, r = cv2.split(gaussian_img)
    b2,g2,r2 = cv2.split(gaussian_gt)
    smooth_img = (r, g, b)
    # print(height, width, channel)

    # build graph
    graph = []
    num = 0;

    #print("staring segment image")
    for y in range(height):
        for x in range(width):
            if x < width - 1:
                a = y * width + x
                b = y * width + (x + 1)
                # w = 1
                w = diff(smooth_img, x, y, x + 1, y)
                num += 1
                graph.append((a, b, w))

            if y < height - 1:
                a = y * width + x
                b = (y + 1) * width + x
                w = diff(smooth_img, x, y, x, y + 1)
                num += 1
                graph.append((a, b, w))

            if x < width - 1 and y < height - 1:
                a = y * width + x
                b = (y + 1) * width + (x + 1)
                w = diff(smooth_img, x, y, x + 1, y + 1)
                num += 1
                graph.append((a, b, w))

            if x < width - 1 and y > 0:
                a = y * width + x
                b = (y - 1) * width + (x + 1)
                w = diff(smooth_img, x, y, x + 1, y - 1)
                num += 1
                graph.append((a, b, w))
        # print(x, y)

    # sort edges by weight
    # graph.sort(key=lambda x: (x[2]))
    graph = sorted(graph, key=lambda x: (x[2]))
    # segment

    u = segment_graph(width * height, num, graph, c)

    # post process small components
    for i in range(num):
        a = u.find(graph[i][0])
        b = u.find(graph[i][1])
        if (a != b) and ((u.size(a) < min_size) or u.size(b) < min_size):
            u.join(a, b)

    num_ccs.append(u.num_sets())

    colors = []
    for i in range(width * height):
        colors.append(random_rgb())

    #print("staring random colors")

    # print("width", width, "height", height)

    area_dict = {} # (x,y) -> comp
    for y in range(height):
        for x in range(width):
            comp = u.find(y * width + x)
            area_dict[(x,y)] = comp
            #gaussian_img[y][x] = colors[comp]

    # mark background and foreground
    bg_num = {} # comp -> bg_num
    fg_num = {} # comp -> fg_num
    for i in area_dict:
        fg_num[area_dict[i]] = 0
        bg_num[area_dict[i]] = 0

    for i in area_dict:
        if all(gaussian_gt[i[1]][i[0]]):
            fg_num[area_dict[i]] += 1
        else:
            bg_num[area_dict[i]] += 1


    color_dict = {} # comp->color
    for i, j in zip(bg_num,fg_num):
        if(bg_num[i] > fg_num[i]):
            color_dict[i] = (0,0,0)
        else:
            color_dict[i] = (255,255,255)


    for y in range(height):
        for x in range(width):
            temp_comp = u.find(y * width + x)
            gaussian_img[y][x] = color_dict[temp_comp]


    # calculate hist and feature
    seg_list = {}
    for y in range(height):
        for x in range(width):
            seg_id = u.find(y * width + x)
            if seg_id not in seg_list:
                seg_list[seg_id] = Image.new("RGB",  (height,width))

            tmp_gaussimg = gaussian_img[y][x]
            tmp_gaussimg = tmp_gaussimg.astype(np.int)
            tmp_color = tuple(tmp_gaussimg)

            seg_list[seg_id].putpixel((y,x),tmp_color)


    seg_hist = {}
    for seg_id in seg_list:
        tmp_seg = cv2.cvtColor(np.array(seg_list[seg_id]), cv2.COLOR_RGB2BGR)  # PIL转cv2
        seg_hist[seg_id] = cv2.calcHist([tmp_seg], [0, 1, 2], None, [8, 8, 8], [0, 256, 0, 256, 0, 256])
        #cv2.normalize(seg_hist[seg_id], seg_hist[seg_id], 0, 1, cv2.NORM_MINMAX)

    
    seg_feature = {}
    for seg_id in seg_hist:
        tmp_feature = np.concatenate((seg_hist[seg_id],global_hist),axis=1)
        seg_feature[seg_id] = tmp_feature
        
        #print(seg_feature[seg_id])
    
    # 1024 -> 50
    seg_pca = {}
    for seg_id in seg_feature:
        pca_sk = PCA(n_components=50)   
        feature_1d = seg_feature[seg_id].flatten()
        cv2.normalize(feature_1d, feature_1d, 0, 1, cv2.NORM_MINMAX)
        seg_pca[seg_id] = feature_1d[0:50]

        #seg_pca[seg_id] = pca_sk.fit_transform(feature_2d)
    
    # label 
    seg_label = {}
    for y in range(height):
        for x in range(width):
            temp_id = u.find(y * width + x)
            if all(gaussian_img[y][x]):
                seg_label[temp_id] = np.ones(50)
            else :
                seg_label[temp_id] = np.zeros(50)

    # random forest predict
    predict_label = {}
    right_predict_num = 0
    for seg_id in seg_pca:
        data = seg_pca[seg_id].reshape(-1,1)
        predict_label[seg_id] = rf.predict(data)
        if (predict_label[seg_id] == seg_label[seg_id]).all():
            right_predict_num += 1

    print("predict image" , test_img_name , "acc: ", right_predict_num*1.0/num_ccs[0])
    






def main():
    sigma = 0.8
    k = 300
    min_size = 20

    train_num = int(sys.argv[1])
    for i in range(train_num):
        if i % 90 == 0:
            continue
        i += 200
        train_img_name = "./data/imgs/" + str(i) + ".png"
        train_img = cv2.imread(train_img_name)
        train_gt_name = "./data/gt/" + str(i) + ".png"
        train_gt = cv2.imread(train_gt_name)

        global_hist = cv2.calcHist([train_img], [0, 1, 2], None, [8, 8, 8], [0, 256, 0, 256, 0, 256])
        #cv2.normalize(global_hist, global_hist, 0, 1, cv2.NORM_MINMAX)
        num_ccs = [];
        #cv2.imwrite(sys.argv[5], segment_and_rftraining(input, sigma, k, min_size, num_ccs))
        segment_and_rftraining(train_img,train_gt, sigma, k, min_size, num_ccs, global_hist)

        print("finish training image:", i, "区域数", num_ccs[0])

    test_img_num = [90, 190, 290, 390, 490, 590, 690, 790, 890, 990]
    for i in test_img_num:
        test_img_name = "./data/imgs/" + str(i) + ".png"
        test_img = cv2.imread(test_img_name)
        test_gt_name = "./data/gt/" + str(i) + ".png"
        test_gt = cv2.imread(test_gt_name)
        test_global_hist = cv2.calcHist([test_img], [0, 1, 2], None, [8, 8, 8], [0, 256, 0, 256, 0, 256])
        num_ccs = []
        segment_and_rfpredict(test_img, test_gt, sigma, k, min_size, num_ccs , test_global_hist, test_img_name)



    return 0


if __name__ == '__main__':
    main()
