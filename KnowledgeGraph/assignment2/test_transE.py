import numpy as np
import codecs
import operator
import json
from transE import traindata_loader,entity2id,relation2id
import random
import time

def dataloader(entity_file,relation_file,test_file):
    entity_dict = {}
    relation_dict = {}
    test_triple = []

    with codecs.open(entity_file) as e_f:
        lines = e_f.readlines()
        for line in lines:
            entity,embedding = line.strip().split('\t')
            embedding = np.array(json.loads(embedding))
            entity_dict[int(entity)] = embedding

    with codecs.open(relation_file) as r_f:
        lines = r_f.readlines()
        for line in lines:
            relation,embedding = line.strip().split('\t')
            embedding = np.array(json.loads(embedding))
            relation_dict[int(relation)] = embedding

    with codecs.open(test_file) as t_f:
        lines = t_f.readlines()
        for line in lines:
            triple = line.strip().split('\t')
            if len(triple) != 3:
                continue

            # 没有的就随机 // KeyError: '00770151'
            if entity2id.get(triple[0]) == None:
                h_ = random.choice(list(entity2id.values()))
            else:
                h_ = entity2id[triple[0]]

            if entity2id.get(triple[2]) == None:
                t_ = random.choice(list(entity2id.values()))
            else:
                t_ = entity2id[triple[2]]
            r_ = relation2id[triple[1]]

            test_triple.append(tuple((h_,t_,r_)))

    return entity_dict,relation_dict,test_triple

def distance(h,r,t):
    return np.linalg.norm(h+r-t)

class Test:
    def __init__(self,entity_dict,relation_dict,test_triple,train_triple,isFit = True):
        self.entity_dict = entity_dict
        self.relation_dict = relation_dict
        self.test_triple = test_triple
        self.train_triple = train_triple
        print(len(self.entity_dict), len(self.relation_dict), len(self.test_triple), len(self.train_triple))
        self.isFit = isFit

        self.hits1 = 0
        self.hits3 = 0
        self.hits10 = 0
        self.mean_rank = 0

        self.relation_hits1 = 0
        self.relation_hits3 = 0
        self.relation_hits10 = 0
        self.relation_mean_rank = 0

    def rank(self):
        hits_1 = 0
        hits_3 = 0
        hits_10 = 0
        rank_sum = 0
        step = 1
        start = time.time()
        for triple in self.test_triple:
            rank_head_dict = {}
            rank_tail_dict = {}

            for entity in self.entity_dict.keys():
                if self.isFit:
                    if [entity,triple[1],triple[2]] not in self.train_triple:
                        h_emb = self.entity_dict[entity]
                        r_emb = self.relation_dict[triple[2]]
                        t_emb = self.entity_dict[triple[1]]
                        rank_head_dict[entity]=distance(h_emb,r_emb,t_emb)
                else:
                    h_emb = self.entity_dict[entity]
                    r_emb = self.relation_dict[triple[2]]
                    t_emb = self.entity_dict[triple[1]]
                    rank_head_dict[entity] = distance(h_emb, r_emb, t_emb)

                if self.isFit:
                    if [triple[0],entity,triple[2]] not in self.train_triple:
                        h_emb = self.entity_dict[triple[0]]
                        r_emb = self.relation_dict[triple[2]]
                        t_emb = self.entity_dict[entity]
                        rank_tail_dict[entity] = distance(h_emb, r_emb, t_emb)
                else:
                    h_emb = self.entity_dict[triple[0]]
                    r_emb = self.relation_dict[triple[2]]
                    t_emb = self.entity_dict[entity]
                    rank_tail_dict[entity] = distance(h_emb, r_emb, t_emb)

            rank_head_sorted = sorted(rank_head_dict.items(),key = operator.itemgetter(1))
            rank_tail_sorted = sorted(rank_tail_dict.items(),key = operator.itemgetter(1))

            #rank_sum and hits_10
            for i in range(len(rank_head_sorted)):
                if triple[0] == rank_head_sorted[i][0]:
                    if i < 1:
                        hits_1 += 1
                    if i < 3:
                        hits_3 += 1
                    if i < 10:
                        hits_10 += 1
                    rank_sum = rank_sum + i + 1
                    break

            for i in range(len(rank_tail_sorted)):
                if triple[1] == rank_tail_sorted[i][0]:
                    if i < 1:
                        hits_1 += 1
                    if i < 3:
                        hits_3 += 1
                    if i<10:
                        hits_10 += 1
                    rank_sum = rank_sum + i + 1
                    break

            step += 1
            if step % 200 == 0:
                end = time.time()
                # 一个triple的time
                print("step:", step, " hit@1:",format(hits_1/(2*step), '.2f'), " hit@3:",format(hits_3/(2*step), '.2f'), " hit@10:",format(hits_10/(2*step), '.2f')," mean_rank:",format(rank_sum/(2*step), '.4f'), ' time:%s'%(round((end - start),3)))
                start = end
        self.hits1 = hits_1 / (2*len(self.test_triple))
        self.hits3 = hits_3 / (2*len(self.test_triple))
        self.hits10 = hits_10 / (2*len(self.test_triple))
        self.mean_rank = rank_sum / (2*len(self.test_triple))

    def relation_rank(self):
        hits_1 = 0
        hits_3 = 0
        hits_10 = 0
        rank_sum = 0
        step = 1

        start = time.time()
        for triple in self.test_triple:
            rank_dict = {}
            for r in self.relation_dict.keys():
                if self.isFit and (triple[0],triple[1],r) in self.train_triple:
                    continue

                h_emb = self.entity_dict[triple[0]]
                r_emb = self.relation_dict[r]
                t_emb = self.entity_dict[triple[1]]
                rank_dict[r]=distance(h_emb, r_emb, t_emb)

            rank_sorted = sorted(rank_dict.items(),key = operator.itemgetter(1))

            rank = 1
            for i in rank_sorted:
                if triple[2] == i[0]:
                    break
                rank += 1
            if rank < 1:
                hits_1 += 1
            if rank < 3:
                hits_3 += 1
            if rank<10:
                hits_10 += 1
            rank_sum = rank_sum + rank + 1
        
            step += 1
            if step % 200 == 0:
                end = time.time()
                print("step:", step, " hit@1:",format(hits_1/step, '.2f'), " hit@3:",format(hits_3/step, '.2f'), " hit@10:",format(hits_10/step, '.2f')," mean_rank:",format(rank_sum/step, '.4f'), ' time:%s'%(round((end - start),3)))
                start = end
        self.relation_hits1 = hits_1 / len(self.test_triple)
        self.relation_hits3 = hits_3 / len(self.test_triple)
        self.relation_hits10 = hits_10 / len(self.test_triple)
        self.relation_mean_rank = rank_sum / len(self.test_triple)

if __name__ == '__main__':
    _, _, train_triple = traindata_loader("WN18RR/train.txt")

    entity_dict, relation_dict, test_triple = \
        dataloader("train_temp/transE_entity","train_temp/transE_relation",
                   "WN18RR/test.txt")
    test = Test(entity_dict,relation_dict,test_triple,train_triple,isFit=False)

    test.relation_rank()
    print("Relation hits@1: ", test.relation_hits1)
    print("Relation hits@3: ", test.relation_hits3)
    print("Relation hits@10: ", test.relation_hits10)
    print("Relation mean rank: ", test.relation_mean_rank)

    print("Please wait...")
    test.rank()
    print("Entity hits@1: ", test.hits1)
    print("Entity hits@3: ", test.hits3)
    print("Entity hits@10: ", test.hits10)
    print("Entity mean rank: ", test.mean_rank)

    f = open("train_res/TransE_result",'w')
    f.write("Entity hits@1: "+ str(test.hits1) + '\n')
    f.write("Entity hits@3: "+ str(test.hits3) + '\n')
    f.write("Entity hits@10: "+ str(test.hits10) + '\n')
    f.write("Entity mean rank: " + str(test.mean_rank) + '\n')
    f.write("Relation hits@1: " + str(test.relation_hits1) + '\n')
    f.write("Relation hits@3: " + str(test.relation_hits3) + '\n')
    f.write("Relation hits@10: " + str(test.relation_hits10) + '\n')
    f.write("Relation mean rank: " + str(test.relation_mean_rank) + '\n')
    f.close()



