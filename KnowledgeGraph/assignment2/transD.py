import torch
import torch.nn as nn
import math
import random
import os
import codecs
import torch.autograd as autograd
import torch.nn.functional as F
from copy import deepcopy
import torch.optim as optim
from sklearn.metrics.pairwise import pairwise_distances
import numpy as np


Data_path = './WN18RR/'
Save_transD_file_path = './train_res/TransD_result'

Entity2id = {}
Relation2id = {}
Entity_set = []
Relation_set = []
Triple_set = []
Triple_set_map = {}
Test_triple_set = []
Valid_triple_set = []

Learning_rate = 0.01
Batch_size = 1024
Epochs = 500 
Embedding_dim  = 100
Margin = 1

L1 = True 

class TransD(nn.Module):
    def __init__(self):
        super(TransD, self).__init__()
        self.learning_rate = Learning_rate
        self.embedding_dim = Embedding_dim 
        self.batch_size = Batch_size
        self.entity_num = len(Entity_set)
        self.relation_num = len(Relation_set)

        self.entity_emb = nn.Parameter(torch.FloatTensor(self.entity_num, self.embedding_dim))
        nn.init.uniform_(self.entity_emb, -6/math.sqrt(self.embedding_dim), 6/math.sqrt(self.embedding_dim))
        self.entity_emb.data = F.normalize(self.entity_emb, p=2, dim=1)
        
        self.relation_emb = nn.Parameter(torch.FloatTensor(self.relation_num, self.embedding_dim))
        nn.init.uniform_(self.relation_emb, -6/math.sqrt(self.embedding_dim), 6/math.sqrt(self.embedding_dim))
        self.relation_emb.data = F.normalize(self.relation_emb, p=2, dim=1)

        self.entity_proj_emb = nn.Parameter(torch.FloatTensor(self.entity_num, self.embedding_dim))
        nn.init.uniform_(self.entity_proj_emb, -6/math.sqrt(self.embedding_dim), 6/math.sqrt(self.embedding_dim))
        self.entity_proj_emb.data = F.normalize(self.entity_proj_emb, p=2, dim=1)

        self.relation_proj_emb = nn.Parameter(torch.FloatTensor(self.relation_num, self.embedding_dim))
        nn.init.uniform_(self.relation_proj_emb, -6/math.sqrt(self.embedding_dim), 6/math.sqrt(self.embedding_dim))
        self.relation_proj_emb.data = F.normalize(self.relation_proj_emb, p=2, dim=1)


    def forward(self, batch, corrupt_batch):
        batch_h = [triple[0] for triple in batch]
        batch_r = [triple[1] for triple in batch]
        batch_t = [triple[2] for triple in batch]
        c_batch_h = [triple[0] for triple in corrupt_batch]
        c_batch_r = [triple[1] for triple in corrupt_batch]
        c_batch_t = [triple[2] for triple in corrupt_batch]

        batch_entity_set = list(set(batch_h + batch_t + c_batch_h + c_batch_t))
        batch_relation_set = list(set(batch_r + c_batch_r))

        batch_h_emb = self.entity_emb[batch_h]
        batch_r_emb = self.relation_emb[batch_r]
        batch_t_emb = self.entity_emb[batch_t]
        c_batch_h_emb = self.entity_emb[c_batch_h]
        c_batch_r_emb = self.relation_emb[c_batch_r]
        c_batch_t_emb = self.entity_emb[c_batch_t]

        batch_h_proj_emb = self.entity_proj_emb[batch_h]
        batch_r_proj_emb = self.relation_proj_emb[batch_r]
        batch_t_proj_emb = self.entity_proj_emb[batch_t]
        c_batch_h_proj_emb = self.entity_proj_emb[c_batch_h]
        c_batch_r_proj_emb = self.relation_proj_emb[c_batch_r]
        c_batch_t_proj_emb = self.entity_proj_emb[c_batch_t]
        
        batch_h_emb = batch_h_emb + torch.sum(batch_h_emb * batch_h_proj_emb, dim=1, keepdim=True) * batch_r_proj_emb
        batch_t_emb = batch_t_emb + torch.sum(batch_t_emb * batch_t_proj_emb, dim=1, keepdim=True) * batch_r_proj_emb
        c_batch_h_emb = c_batch_h_emb + torch.sum(c_batch_h_emb * c_batch_h_proj_emb, dim=1, keepdim=True) * c_batch_r_proj_emb
        c_batch_t_emb = c_batch_t_emb + torch.sum(c_batch_t_emb * c_batch_t_proj_emb, dim=1, keepdim=True) * c_batch_r_proj_emb
        
        correct = torch.sum((batch_h_emb + batch_r_emb - batch_t_emb) ** 2, 1)
        corrupt = torch.sum((c_batch_h_emb + c_batch_r_emb - c_batch_t_emb) ** 2, 1)

        return correct, corrupt, batch_entity_set, batch_relation_set

def loadData(file_path):
    entity_id = 0
    relation_id = 0
    with open(file_path, 'r') as f:
        for line in f:
            h_, r_, t_ = line.split()
            if h_ not in Entity2id.keys():
                Entity2id[h_] = entity_id
                entity_id += 1
            if r_ not in Relation2id.keys():
                Relation2id[r_] = relation_id
                relation_id += 1
            if t_ not in Entity2id.keys():
                Entity2id[t_] = entity_id
                entity_id += 1
            Triple_set.append([Entity2id[h_], Relation2id[r_], Entity2id[t_]])
            Triple_set_map[(Entity2id[h_], Relation2id[r_], Entity2id[t_])] = True
    global Entity_set, Relation_set
    Entity_set = [i for i in range(entity_id)]
    Relation_set = [i for i in range(relation_id)]

    return
    

def Initialize():
    loadData(Data_path + 'train.txt')
    global Valid_triple_set
    Valid_triple_set =  loadTestData(Data_path + 'valid.txt')
    global model, optimizer
    model = TransD()

    for name, parameters in model.named_parameters():
        print(name, ':', parameters.size())
    optimizer = optim.SGD(model.parameters(), lr=model.learning_rate)

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

def Loss(correct, corrupt, Margin):
    zero_tensor = torch.zeros(correct.size())
    if L1:
        loss = torch.sum(torch.log(1 + torch.exp(torch.max(correct - corrupt + Margin, zero_tensor))))
    else:
        loss = torch.sum(torch.max(correct - corrupt + Margin, zero_tensor))
    return loss

def train():
    print('start training...')
    best_entity_average_rank = len(Entity_set) + 1
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
            correct, corrupt, batch_entity_set, batch_relation_set = model(batch, corrupt_batch)

            loss = Loss(correct, corrupt, Margin)
            loss_set += loss

            loss.backward()
            optimizer.step()

            model.entity_emb[batch_entity_set].data = F.normalize(model.entity_emb[batch_entity_set], p=2, dim=1)
            model.relation_emb[batch_relation_set].data = F.normalize(model.relation_emb[batch_relation_set], p=2, dim=1)
            model.entity_proj_emb[batch_entity_set].data = F.normalize(model.entity_proj_emb[batch_entity_set], p=2, dim=1)
            model.relation_proj_emb[batch_relation_set].data = F.normalize(model.relation_proj_emb[batch_relation_set], p=2, dim=1)
        
        print('epoch: ', epoch, 'loss:', loss_set.data)

    print('writing training result to file...') 
    file_path = Save_transD_file_path + ('_logistic_loss.pkl' if L1 else '_margin_loss.pkl')
    torch.save(model, file_path)


def loadTestData(file_path):
    triple_set = []
    with open(file_path, 'r') as f:
        for line in f:
            h, r, t = line.split()
            if h not in Entity2id.keys() or r not in Relation2id.keys() or t not in Entity2id.keys():
               continue
            triple_set.append([Entity2id[h], Relation2id[r], Entity2id[t]])
    return triple_set

def find_index(h, r, t, array, param):
    index = 0
    for num in array:
        if param == num:
            return index
        elif (h,r,t) not in Triple_set_map.keys():
            index += 1
    return index

def evaluate(test_triple_set):
    h_list = [triple[0] for triple in test_triple_set]
    r_list = [triple[1] for triple in test_triple_set]
    t_list = [triple[2] for triple in test_triple_set]

    h_list_emb = model.entity_emb[h_list]
    r_list_emb = model.relation_emb[r_list]
    t_list_emb =  model.entity_emb[t_list]

    h_list_proj_emb = model.entity_proj_emb[h_list]
    r_list_proj_emb = model.relation_proj_emb[r_list]
    t_list_proj_emb =  model.entity_proj_emb[t_list]

    h_list_emb = h_list_emb + torch.sum(h_list_emb * h_list_proj_emb, dim=1, keepdim=True) * r_list_proj_emb
    t_list_emb = t_list_emb + torch.sum(t_list_emb * t_list_proj_emb, dim=1, keepdim=True) * r_list_proj_emb

    to_compare = t_list_emb - r_list_emb
    dist = pairwise_distances(to_compare.detach(), model.entity_emb.detach(), metric='manhattan')
    dist = pairwise_distances(to_compare.detach(), model.entity_emb.detach(), metric='euclidean')
    sorted_head = np.argsort(dist, axis=1)
    rank_of_correct_triple = np.array([int(find_index(elem[0], elem[1], elem[2], elem[3], elem[0])) + 1 for elem in zip(h_list, r_list, t_list, sorted_head)])
    
    print(rank_of_correct_triple[:10])

    hit10 = np.sum(rank_of_correct_triple <= 10)
    hit3 = np.sum(rank_of_correct_triple <= 3)
    hit1 = np.sum(rank_of_correct_triple <= 1)
    mrr = np.sum(1.0/rank_of_correct_triple)
    

    to_compare = h_list_emb + r_list_emb
    dist = pairwise_distances(to_compare.detach(), model.entity_emb.detach(), metric='manhattan')
    dist = pairwise_distances(to_compare.detach(), model.entity_emb.detach(), metric='euclidean')
    sorted_tail = np.argsort(dist, axis=1)
    rank_of_correct_triple = np.array([int(find_index(elem[0], elem[1], elem[2], elem[3],elem[2])) + 1 for elem in zip(h_list, r_list, t_list, sorted_tail)])
    
    print(rank_of_correct_triple[:10])
    hit10 += np.sum(rank_of_correct_triple <= 10)
    hit3 += np.sum(rank_of_correct_triple <= 3)
    hit1 += np.sum(rank_of_correct_triple <= 1)
    mrr += np.sum(1.0/rank_of_correct_triple)

    entity_hit10_rate = hit10 / (len(test_triple_set) * 2)
    entity_hit3_rate = hit3 / (len(test_triple_set) * 2)
    entity_hit1_rate = hit1 / (len(test_triple_set) * 2)
    entity_mrr = mrr / (len(test_triple_set) * 2)

    to_compare = t_list_emb - h_list_emb
    dist = pairwise_distances(to_compare.detach(), model.relation_emb.detach(), metric='manhattan')
    dist = pairwise_distances(to_compare.detach(), model.relation_emb.detach(), metric='euclidean')
    sorted_relation = np.argsort(dist, axis=1)
    rank_of_correct_triple = np.array([int(np.argwhere(r1 == r2)) + 1 for r1,r2 in zip(r_list, sorted_relation)])
    

    relation_hit10_rate = np.sum(rank_of_correct_triple <= 10) / len(test_triple_set)
    relation_hit3_rate = np.sum(rank_of_correct_triple <= 3) / len(test_triple_set)
    relation_hit1_rate = np.sum(rank_of_correct_triple <= 1) / len(test_triple_set)
    relation_mrr = np.sum(1.0/rank_of_correct_triple) / len(test_triple_set)

    return entity_hit10_rate, entity_hit3_rate, entity_hit1_rate, entity_mrr, relation_hit10_rate, relation_hit3_rate, relation_hit1_rate, relation_mrr
    
def test():
    print('Testing...')
    global Test_triple_set
    Test_triple_set = loadTestData(Data_path + 'test.txt')

    e10, e3, e1, e_mrr, r10, r3, r1, r_mrr = evaluate(Test_triple_set)

    print("Relation hits@1: ", r1)
    print("Relation hits@3: ", r3)
    print("Relation hits@10: ", r10)
    print("Relation mrr: ", r_mrr)

    print("Entity hits@1: ", e1)
    print("Entity hits@3: ", e3)
    print("Entity hits@10: ", e10)
    print("Entity mrr: ", e_mrr)

    f = open("train_res/TransD_result",'w')
    f.write("Entity hits@1: "+ str(e1) + '\n')
    f.write("Entity hits@3: "+ str(e3) + '\n')
    f.write("Entity hits@10: "+ str(e10) + '\n')
    f.write("Entity mrr: " + str(e_mrr) + '\n')
    f.write("Relation hits@1: " + str(r1) + '\n')
    f.write("Relation hits@3: " + str(r3) + '\n')
    f.write("Relation hits@10: " + str(r10) + '\n')
    f.write("Relation mrr: " + str(r_mrr) + '\n')
    f.close()

if __name__ == "__main__":
    Initialize()
    train()
    test()