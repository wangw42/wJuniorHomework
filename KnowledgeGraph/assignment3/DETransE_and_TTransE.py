from numpy.core.numeric import argwhere
import argparse
import torch
import torch.autograd as autograd
import torch.nn as nn
import math
import torch.nn.functional as F
import random
from copy import deepcopy
import torch.optim as optim
from sklearn.metrics.pairwise import pairwise_distances
import numpy as np
from matplotlib.pyplot import hlines
from numpy.core.numeric import argwhere
import numpy as np
import os

Entity2id = {}
Relation2id = {}
Entity_set = []
Relation_set = []
Triple_set = []
Triple_set_map = {}
Test_triple_set = []
Test_triple_set_map = {}
Valid_triple_set = []

Learning_rate = 1
Batch_size = 1024
Epochs = 500
Embedding_dimension = 64
Margin = 1
Temporal_rate = 0.3

L1_loss = True 

dataset_path = 'icews14/icews_2014_'

class DETransE(nn.Module):
    def __init__(self):
        super(DETransE, self).__init__()
        self.batch_size = Batch_size
        self.entity_num = len(Entity_set)
        self.relation_num = len(Relation_set)
        self.learning_rate = Learning_rate
        self.embedding_dimension = Embedding_dimension

        # a
        self.a_embedding = nn.Parameter(torch.FloatTensor(self.entity_num, self.embedding_dimension))
        nn.init.uniform_(self.a_embedding, -6/math.sqrt(self.embedding_dimension), 6/math.sqrt(self.embedding_dimension))
        self.a_embedding.data = F.normalize(self.a_embedding, p=2, dim=1)

        # w
        self.w_embedding = nn.Parameter(torch.FloatTensor(self.entity_num, int(self.embedding_dimension * Temporal_rate)))
        nn.init.uniform_(self.w_embedding, -6/math.sqrt(self.embedding_dimension * Temporal_rate), 6/math.sqrt(self.embedding_dimension * Temporal_rate))
        self.w_embedding.data = F.normalize(self.w_embedding, p=2, dim=1)

        # b
        self.b_embedding = nn.Parameter(torch.FloatTensor(self.entity_num, int(self.embedding_dimension * Temporal_rate)))
        nn.init.uniform_(self.b_embedding, -6/math.sqrt(self.embedding_dimension * Temporal_rate), 6/math.sqrt(self.embedding_dimension * Temporal_rate))
        self.b_embedding.data = F.normalize(self.b_embedding, p=2, dim=1)
        
        self.relation_embedding = nn.Parameter(torch.FloatTensor(self.relation_num, self.embedding_dimension))
        nn.init.uniform_(self.relation_embedding, -6/math.sqrt(self.embedding_dimension), 6/math.sqrt(self.embedding_dimension))
        self.relation_embedding.data = F.normalize(self.relation_embedding, p=2, dim=1)
        
    def forward(self, batch, corrupt_batch):
        h = [triple[0] for triple in batch]
        r = [triple[1] for triple in batch]
        t = [triple[2] for triple in batch]
        tt = [triple[3] for triple in batch]
        c_h = [triple[0] for triple in corrupt_batch]
        c_r = [triple[1] for triple in corrupt_batch]
        c_t = [triple[2] for triple in corrupt_batch]
        c_tt = [triple[3] for triple in corrupt_batch]

        correct = []
        corrupt = []
        correct = torch.sum((de_embedding(h, tt) + self.relation_embedding[r] - de_embedding(t, tt)) ** 2, 1)
        corrupt = torch.sum((de_embedding(c_h, c_tt) + self.relation_embedding[c_r] - de_embedding(c_t, c_tt)) ** 2, 1)
        return correct, corrupt

    def train(self):
        for epoch in range(Epochs):
            loss_set = torch.tensor(0.0)
            random.shuffle(Triple_set)
            batch_num = len(Triple_set) // Batch_size + 1
            batch_list =  [0] * batch_num
            for i in range(batch_num - 1):
                batch_list[i] = Triple_set[i*Batch_size:(i+1)*Batch_size]
            batch_list[batch_num-1] = Triple_set[(batch_num-1)*Batch_size:]

            for batch in batch_list:
                corrupt_batch = Corrupt(batch)
                optimizer.zero_grad()
                correct, corrupt = model(batch, corrupt_batch) 
                loss = computeLoss(correct, corrupt, Margin) 
                loss_set += loss
                loss.backward()
                optimizer.step()
            
                model.a_embedding.data = F.normalize(model.a_embedding, p=2, dim=1)
                model.w_embedding.data = F.normalize(model.w_embedding, p=2, dim=1)
                model.b_embedding.data = F.normalize(model.b_embedding, p=2, dim=1)
            
            print('epoch', epoch+1, 'loss:', loss_set.data / batch_num)


    def evaluate(self, test_triple_set):
        h_list = [triple[0] for triple in test_triple_set]
        r_list = [triple[1] for triple in test_triple_set]
        t_list = [triple[2] for triple in test_triple_set]
        tt_list = [triple[3] for triple in test_triple_set]
    
        h_list_embedding = de_embedding(h_list, tt_list)
        r_list_embedding = model.relation_embedding[r_list]
        t_list_embedding =  de_embedding(t_list, tt_list)

        to_compare = t_list_embedding - r_list_embedding
        temp_h_list = [j for j in range(model.entity_num)]
        dist = np.empty((len(h_list), model.entity_num))
    
        for i in range(len(h_list)):
            temp_tt_list = [tt_list[i]] * model.entity_num
            dist[i] = pairwise_distances(to_compare[i].detach().reshape(1,-1), de_embedding(temp_h_list, temp_tt_list).detach(), metric='euclidean')
        sorted_head = np.argsort(dist, axis=1)
        rank_of_correct_triple = np.array([int(find_index_head(elem[0], elem[1], elem[2], elem[3], elem[4])) + 1 for elem in zip(h_list, r_list, t_list, tt_list, sorted_head)])
        print(rank_of_correct_triple[:10])

        hit10 = np.sum(rank_of_correct_triple <= 10)
        hit3 = np.sum(rank_of_correct_triple <= 3)
        hit1 = np.sum(rank_of_correct_triple <= 1)
        mrr = np.sum(1.0/rank_of_correct_triple)

        entity_hit10_rate = hit10 / (len(test_triple_set))
        entity_hit3_rate = hit3 / (len(test_triple_set))
        entity_hit1_rate = hit1 / (len(test_triple_set))
        entity_mrr = mrr / (len(test_triple_set))

        to_compare = h_list_embedding + r_list_embedding
        dist = np.empty((len(h_list), model.entity_num))
        for i in range(len(h_list)):
            temp_tt_list = [tt_list[i]] * model.entity_num
            dist[i] = pairwise_distances(to_compare[i].detach().reshape(1,-1), de_embedding(temp_h_list, temp_tt_list).detach(), metric='euclidean')
        sorted_tail = np.argsort(dist, axis=1)
        rank_of_correct_triple = np.array([find_index_tail(elem[0], elem[1], elem[2], elem[3], elem[4]) + 1 for elem in zip(h_list, r_list, t_list, tt_list, sorted_tail)])
    
        print(rank_of_correct_triple[:10])
        hit10 = np.sum(rank_of_correct_triple <= 10)
        hit3 = np.sum(rank_of_correct_triple <= 3)
        hit1 = np.sum(rank_of_correct_triple <= 1)
        mrr = np.sum(1.0/rank_of_correct_triple)

        entity_hit10_rate_1 = hit10 / (len(test_triple_set))
        entity_hit3_rate_1 = hit3 / (len(test_triple_set))
        entity_hit1_rate_1 = hit1 / (len(test_triple_set))
        entity_mrr_1 = mrr / (len(test_triple_set))


        return entity_hit10_rate, entity_hit3_rate, entity_hit1_rate, entity_mrr, entity_hit10_rate_1, entity_hit3_rate_1, entity_hit1_rate_1, entity_mrr_1


class TTransE(nn.Module):
    def __init__(self):
        super(TTransE, self).__init__()

        self.learning_rate = Learning_rate
        self.embedding_dimension = Embedding_dimension
        self.batch_size = Batch_size
        self.entity_num = len(Entity_set)
        self.relation_num = len(Relation_set)

        self.entity_embedding = nn.Parameter(torch.FloatTensor(self.entity_num, self.embedding_dimension))
        nn.init.uniform_(self.entity_embedding, -6/math.sqrt(self.embedding_dimension), 6/math.sqrt(self.embedding_dimension))
        self.entity_embedding.data = F.normalize(self.entity_embedding, p=2, dim=1)
        
        self.relation_embedding = nn.Parameter(torch.FloatTensor(self.relation_num, self.embedding_dimension))
        nn.init.uniform_(self.relation_embedding, -6/math.sqrt(self.embedding_dimension), 6/math.sqrt(self.embedding_dimension))
        self.relation_embedding.data = F.normalize(self.relation_embedding, p=2, dim=1)
        
    def forward(self, batch, corrupt_batch):
        h = [triple[0] for triple in batch]
        r = [triple[1] for triple in batch]
        t = [triple[2] for triple in batch]
        tt = [triple[3] for triple in batch]
        c_h = [triple[0] for triple in corrupt_batch]
        c_r = [triple[1] for triple in corrupt_batch]
        c_t = [triple[2] for triple in corrupt_batch]
        c_tt = [triple[3] for triple in corrupt_batch]

        correct = []
        corrupt = []
        correct = torch.sum((self.entity_embedding[h] + self.relation_embedding[r] + self.relation_embedding[tt] - self.entity_embedding[t]) ** 2, 1)
        corrupt = torch.sum((self.entity_embedding[c_h] + self.relation_embedding[c_r] + self.relation_embedding[c_tt] - self.entity_embedding[c_t]) ** 2, 1)
        return correct, corrupt

    def train(self):
        for epoch in range(Epochs):
            loss_set = torch.tensor(0.0)
            random.shuffle(Triple_set)
            batch_num = len(Triple_set) // Batch_size + 1
            batch_list =  [0] * batch_num
            for i in range(batch_num - 1):
                batch_list[i] = Triple_set[i*Batch_size:(i+1)*Batch_size]
            batch_list[batch_num-1] = Triple_set[(batch_num-1)*Batch_size:]

            for batch in batch_list:
                corrupt_batch = Corrupt(batch)

                optimizer.zero_grad()
                correct, corrupt = model(batch, corrupt_batch) # forward

                loss = computeLoss(correct, corrupt, Margin) 
                loss_set += loss

                loss.backward()
                optimizer.step()
            
                model.entity_embedding.data = F.normalize(model.entity_embedding, p=2, dim=1)
            
            print('epoch', epoch+1, 'loss:', loss_set.data / batch_num)
        

    def evaluate(self, test_triple_set):
        h_list = [triple[0] for triple in test_triple_set]
        r_list = [triple[1] for triple in test_triple_set]
        t_list = [triple[2] for triple in test_triple_set]
        tt_list = [triple[3] for triple in test_triple_set]

        h_list_embedding = model.entity_embedding[h_list]
        r_list_embedding = model.relation_embedding[r_list]
        t_list_embedding =  model.entity_embedding[t_list]
        tt_list_embedding = model.relation_embedding[tt_list]

        to_compare = t_list_embedding - r_list_embedding - tt_list_embedding

        dist = []
        dist = pairwise_distances(to_compare.detach(), model.entity_embedding.detach(), metric='euclidean')
        sorted_head = np.argsort(dist, axis=1)
        rank_of_correct_triple = np.array([int(find_index_head(elem[0], elem[1], elem[2], elem[3], elem[4])) + 1 for elem in zip(h_list, r_list, t_list, tt_list, sorted_head)])
    
        print(rank_of_correct_triple[:10])

        hit10 = np.sum(rank_of_correct_triple <= 10)
        hit3 = np.sum(rank_of_correct_triple <= 3)
        hit1 = np.sum(rank_of_correct_triple <= 1)
        mrr = np.sum(1.0/rank_of_correct_triple)

        entity_hit10_rate = hit10 / (len(test_triple_set))
        entity_hit3_rate = hit3 / (len(test_triple_set))
        entity_hit1_rate = hit1 / (len(test_triple_set))
        entity_mrr = mrr / (len(test_triple_set))

        to_compare = h_list_embedding + r_list_embedding + tt_list_embedding
        dist = []
        dist = pairwise_distances(to_compare.detach(), model.entity_embedding.detach(), metric='euclidean')
        sorted_tail = np.argsort(dist, axis=1)
        rank_of_correct_triple = np.array([find_index_tail(elem[0], elem[1], elem[2], elem[3], elem[4]) + 1 for elem in zip(h_list, r_list, t_list, tt_list, sorted_tail)])
    
        print(rank_of_correct_triple[:10])
        hit10 = np.sum(rank_of_correct_triple <= 10)
        hit3 = np.sum(rank_of_correct_triple <= 3)
        hit1 = np.sum(rank_of_correct_triple <= 1)
        mrr = np.sum(1.0/rank_of_correct_triple)

        entity_hit10_rate_1 = hit10 / (len(test_triple_set))
        entity_hit3_rate_1 = hit3 / (len(test_triple_set))
        entity_hit1_rate_1 = hit1 / (len(test_triple_set))
        entity_mrr_1 = mrr / (len(test_triple_set))

        return entity_hit10_rate, entity_hit3_rate, entity_hit1_rate, entity_mrr, entity_hit10_rate_1, entity_hit3_rate_1, entity_hit1_rate_1, entity_mrr_1



def de_embedding(batch_entity, tt):
    d = int(model.embedding_dimension * Temporal_rate)
    tt = torch.tensor(tt).reshape(len(tt),1)
    batch_entity_embedding = torch.cat((model.a_embedding[batch_entity,:d] * torch.sin(model.w_embedding[batch_entity] * tt + model.b_embedding[batch_entity]), 
                                    model.a_embedding[batch_entity,d:]), dim=1)
    return batch_entity_embedding



def computeLoss(correct, corrupt, Margin):
    zero_tensor = torch.zeros(correct.size())
    loss = torch.tensor(0.0)
    if L1_loss:
        loss += torch.mean(torch.log(1 + torch.exp(correct - corrupt)))
    else:
        loss += torch.mean(torch.max(correct - corrupt + Margin, zero_tensor))
    return loss



def loadData(file_path):
    entity_id = 0
    relation_id = 0
    with open(file_path, 'r') as f:
        for line in f:
            h_, r_, t_, tt_ = line.split('\t')
            if h_ not in Entity2id.keys():
                Entity2id[h_] = entity_id
                entity_id += 1
            if r_ not in Relation2id.keys():
                Relation2id[r_] = relation_id
                relation_id += 1
            if t_ not in Entity2id.keys():
                Entity2id[t_] = entity_id
                entity_id += 1
            if tt_ not in Relation2id.keys():
                Relation2id[tt_] = relation_id
                relation_id += 1
            Triple_set.append([Entity2id[h_], Relation2id[r_], Entity2id[t_], Relation2id[tt_]])
            Triple_set_map[(Entity2id[h_], Relation2id[r_], Entity2id[t_], Relation2id[tt_])] = True
    global Entity_set, Relation_set
    Entity_set = [i for i in range(entity_id)]
    Relation_set = [i for i in range(relation_id)]

    return

def Initialize(params):
    global Valid_triple_set
    global model, optimizer
    loadData(dataset_path + 'train.txt')
    Valid_triple_set, _ =  loadTestData(dataset_path + 'valid.txt')
    if params.model == 'TTransE':
        model = TTransE()
    if params.model == 'DETransE':
        model = DETransE()
    optimizer = optim.SGD(model.parameters(), lr=model.learning_rate)

    return model

def Corrupt_triple(triple, t_or_h):
    corrupt_triple = deepcopy(triple)
    newEntity = corrupt_triple[t_or_h]
    while newEntity == corrupt_triple[t_or_h]:
        newEntity = random.randrange(len(Entity_set))
    corrupt_triple[t_or_h] = newEntity
    return corrupt_triple

def Corrupt(batch):
    corrupt_batch = [Corrupt_triple(triple, 0) if random.random() < 0.5 else Corrupt_triple(triple, 2) for triple in batch]
    return corrupt_batch

def loadTestData(file_path):
    triple_set = []
    triple_set_map = {}
    with open(file_path, 'r') as f:
        for line in f:
            h, r, t, tt = line.split('\t')
            if h not in Entity2id.keys() or r not in Relation2id.keys() or t not in Entity2id.keys() or tt not in Relation2id.keys():
               continue
            triple_set.append([Entity2id[h], Relation2id[r], Entity2id[t], Relation2id[tt]])
            triple_set_map[(Entity2id[h], Relation2id[r], Entity2id[t], Relation2id[tt])] = True

    return triple_set, triple_set_map

def find_index_head(h, r, t, tt, array):
    idx = 0
    for num in array:
        if h == num:
            break
        elif (num,r,t,tt) not in Triple_set_map.keys() and (num,r,t,tt) not in Test_triple_set_map.keys():
            idx += 1
    return idx

def find_index_tail(h, r, t, tt, array):
    idx = 0
    for num in array:
        if t == num:
            return idx
        elif (h,r,num,tt) not in Triple_set_map.keys() and (h,r,num,tt) not in Test_triple_set_map.keys():
            idx += 1
    return idx


def test():
    print('testing...')
    global Test_triple_set, Test_triple_set_map
    Test_triple_set, Test_triple_set_map = loadTestData(dataset_path + 'test.txt')


    hits10, hits3, hits1, mrr, hits10_t, hits3_t, hits1_t, mrr_t = current_model.evaluate(Test_triple_set)
    print("Head hits@1: ", hits1)
    print("Head hits@3: ", hits3)
    print("Head hits@10: ", hits10)
    print("Head mrr: ", mrr)

    print("Tail hits@1: ", hits1_t)
    print("Tail hits@3: ", hits3_t)
    print("Tail hits@10: ", hits10_t)
    print("Tail mrr: ", mrr_t)

    f = open("train_res/TTransE_result",'w')
    f.write("Head hits@1: "+ str(hits1) + '\n')
    f.write("Head hits@3: "+ str(hits3) + '\n')
    f.write("Head hits@10: "+ str(hits10) + '\n')
    f.write("Head mrr: " + str(mrr) + '\n')
    f.write("Tail hits@1: " + str(hits1_t) + '\n')
    f.write("Tail hits@3: " + str(hits3_t) + '\n')
    f.write("Tail hits@10: " + str(hits10_t) + '\n')
    f.write("Tail mrr: " + str(mrr_t) + '\n')
    f.close()

# ----------------

parser = argparse.ArgumentParser(description='TTransE and DETransE model')
parser.add_argument("--experiment_name", type=str, default="default",
                    help="A folder with this name would be created to dump saved models and log files")
parser.add_argument("--model", "-m", type=str, default="current_model",
                    help="Model to use")

params = parser.parse_args()

current_model = Initialize(params)


save_file_path = 'train_res/{}'.format(current_model)
    
current_model.train()
test()