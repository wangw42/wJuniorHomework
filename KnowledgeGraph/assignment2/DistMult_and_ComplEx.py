import argparse
import logging
import time
import torch
import os
import json
import numpy as np
import scipy.misc
import torch.optim as optim
import torch.nn as nn
import pickle as pkl
import random
import pdb
from scipy.sparse import csc_matrix
from sklearn import metrics
import torch.nn.functional as F
import codecs
from io import BytesIO
from sklearn.metrics.pairwise import pairwise_distances

MAIN_DIR = os.path.relpath(os.path.dirname(os.path.abspath(__file__)))
DATA_PATH = os.path.join(MAIN_DIR, 'WN18RR')


def get_all_adj(adj_list):
    rows = []
    cols = []
    dats = []
    dim = adj_list[0].shape
    for adj in adj_list:
        rows += adj.tocoo().row.tolist()
        cols += adj.tocoo().col.tolist()
        dats += adj.tocoo().data.tolist()
    row = np.array(rows)
    col = np.array(cols)
    data = np.array(dats)
    return csc_matrix((data, (row, col)), shape=dim)


def sample_neg(adj_list, train_triplets, valid_triplets, test_triplets, max_train_num=None):
    train_pos = (train_triplets[:, 0], train_triplets[:, 1], train_triplets[:, 2])
    valid_pos = (valid_triplets[:, 0], valid_triplets[:, 1], valid_triplets[:, 2])
    test_pos = (test_triplets[:, 0], test_triplets[:, 1], test_triplets[:, 2])

    if max_train_num is not None:
        perm = np.random.permutation(len(train_pos[0]))[:max_train_num]
        train_pos = (train_pos[0][perm], train_pos[1][perm], train_pos[2][perm])
    

    train_num, valid_num, test_num = len(train_pos[0]), len(valid_pos[0]), len(test_pos[0])
    neg = ([], [], [])
    adj_acc = get_all_adj(adj_list)  
    n = adj_acc.shape[0]
    r = len(adj_list)
    while len(neg[0]) < train_num + valid_num + test_num:
        i, j, k = random.randint(0, n - 1), random.randint(0, n - 1), random.randint(0, r - 1)
        if i != j and adj_list[k][i, j] == 0:
            neg[0].append(i)
            neg[1].append(j)
            neg[2].append(k)
        else:
            continue
    train_neg = (np.array(neg[0][:train_num]), np.array(neg[1][:train_num]), np.array(neg[2][:train_num]))
    valid_neg = (np.array(neg[0][train_num:train_num + valid_num]), np.array(neg[1][train_num:train_num + valid_num]), np.array(neg[2][train_num:train_num + valid_num]))
    test_neg = (np.array(neg[0][train_num + valid_num:]), np.array(neg[1][train_num + valid_num:]), np.array(neg[2][train_num + valid_num:]))
    return train_pos, train_neg, valid_pos, valid_neg, test_pos, test_neg


class DataSampler():
    def __init__(self ,params):

        data_path = os.path.join(params.main_dir, '{}/{}.pickle'.format(params.dataset, params.dataset))

        with open(data_path, 'rb') as f:
            data = pkl.load(f)
        adj_list = data['adj_list']
        train_triplets = data['train_triplets']
        valid_triplets = data['valid_triplets']
        test_triplets = data['test_triplets']

        params.total_ent = adj_list[0].shape[0]
        params.total_rel = len(adj_list)

        self.train_pos, self.train_neg, self.valid_pos, self.valid_neg, self.test_pos, self.test_neg = sample_neg(adj_list, train_triplets, valid_triplets, test_triplets)

        self.train_idx = np.arange(len(self.train_pos[0]))
        self.batch_size = len(self.train_pos[0]) // params.nBatches

    def get_batch(self, n_batch):

        if n_batch == 0:
            np.random.shuffle(self.train_idx)

        ids = self.train_idx[n_batch * self.batch_size: (n_batch + 1) * self.batch_size]

        batch_h = np.concatenate((self.train_pos[0][ids], self.train_neg[0][ids]))
        batch_t = np.concatenate((self.train_pos[1][ids], self.train_neg[1][ids]))
        batch_r = np.concatenate((self.train_pos[2][ids], self.train_neg[2][ids]))
        batch_y = np.concatenate((np.ones(self.batch_size), -1 * np.ones(self.batch_size)))

        return batch_h, batch_t, batch_r, batch_y

    def get_valid_data(self):

        batch_h = np.concatenate((self.valid_pos[0], self.valid_neg[0]))
        batch_t = np.concatenate((self.valid_pos[1], self.valid_neg[1]))
        batch_r = np.concatenate((self.valid_pos[2], self.valid_neg[2]))
        batch_y = np.concatenate((np.ones(len(self.valid_pos[0])), -1 * np.ones(len(self.valid_neg[0]))))

        return batch_h, batch_t, batch_r, batch_y

    def get_test_data(self):

        batch_h = np.concatenate((self.test_pos[0], self.test_neg[0]))
        batch_t = np.concatenate((self.test_pos[1], self.test_neg[1]))
        batch_r = np.concatenate((self.test_pos[2], self.test_neg[2]))
        batch_y = np.concatenate((np.ones(len(self.test_pos[0])), -1 * np.ones(len(self.test_neg[0]))))

        return batch_h, batch_t, batch_r, batch_y



class DistMult(nn.Module):
    def __init__(self, params):
        super(DistMult, self).__init__()
        self.params = params
        self.entity_emb = nn.Embedding(self.params.total_ent, self.params.embedding_dim, max_norm=1)
        self.relation_emb = nn.Embedding(self.params.total_rel, self.params.embedding_dim)
        self.ent_embeddings = nn.Embedding(self.params.total_ent, self.params.embedding_dim, max_norm=1)
        self.rel_embeddings = nn.Embedding(self.params.total_rel, self.params.embedding_dim)
        self.criterion = nn.MarginRankingLoss(self.params.margin, reduction='sum')
        # self.criterion = nn.Softplus()
        self.init_weights()

        
    def init_weights(self):
        nn.init.xavier_uniform_(self.ent_embeddings.weight.data)
        nn.init.xavier_uniform_(self.rel_embeddings.weight.data)

    def get_score(self, h, t, r):
        return - torch.sum(h * t * r, -1)

    def forward(self, batch_h, batch_t, batch_r, batch_y):
        h = self.ent_embeddings(torch.from_numpy(batch_h))
        t = self.ent_embeddings(torch.from_numpy(batch_t))
        r = self.rel_embeddings(torch.from_numpy(batch_r))
        y = torch.from_numpy(batch_y).type(torch.FloatTensor)

        score = self.get_score(h, t, r)

        pos_score = score[0: int(len(score) / 2)]
        neg_score = score[int(len(score) / 2): len(score)]

        # regul = torch.mean(h ** 2) + torch.mean(t ** 2) + torch.mean(r ** 2)
        # loss = torch.mean(self.criterion(score * y)) + self.params.lmbda * regul
        loss = self.criterion(pos_score, neg_score, torch.Tensor([-1]))
        
        return loss, pos_score, neg_score



class ComplEx(nn.Module):
    def __init__(self, params):
        super(ComplEx, self).__init__()
        self.params = params

        self.ent_re_embeddings = nn.Embedding(
            self.params.total_ent, self.params.embedding_dim
        )
        self.ent_im_embeddings = nn.Embedding(
            self.params.total_ent, self.params.embedding_dim
        )
        self.rel_re_embeddings = nn.Embedding(
            self.params.total_ent, self.params.embedding_dim
        )
        self.rel_im_embeddings = nn.Embedding(
            self.params.total_ent, self.params.embedding_dim
        )
        # self.criterion = nn.Softplus()
        self.criterion = nn.MarginRankingLoss(self.params.margin, reduction='sum')
        self.init_weights()

        logging.info('Initialized the model successfully!')

    def init_weights(self):
        nn.init.xavier_uniform(self.ent_re_embeddings.weight.data)
        nn.init.xavier_uniform(self.ent_im_embeddings.weight.data)
        nn.init.xavier_uniform(self.rel_re_embeddings.weight.data)
        nn.init.xavier_uniform(self.rel_im_embeddings.weight.data)

    def get_score(self, h_re, h_im, t_re, t_im, r_re, r_im):
        return -torch.sum(
            h_re * t_re * r_re
            + h_im * t_im * r_re
            + h_re * t_im * r_im
            - h_im * t_re * r_im,
            -1,
        )

    def forward(self, batch_h, batch_t, batch_r, batch_y):
        h_re = self.ent_re_embeddings(torch.from_numpy(batch_h))
        h_im = self.ent_im_embeddings(torch.from_numpy(batch_h))
        t_re = self.ent_re_embeddings(torch.from_numpy(batch_t))
        t_im = self.ent_im_embeddings(torch.from_numpy(batch_t))
        r_re = self.rel_re_embeddings(torch.from_numpy(batch_r))
        r_im = self.rel_im_embeddings(torch.from_numpy(batch_r))

        y = torch.from_numpy(batch_y).type(torch.FloatTensor)

        score = self.get_score(h_re, h_im, t_re, t_im, r_re, r_im)

        pos_score = score[0: int(len(score) / 2)]
        neg_score = score[int(len(score) / 2): len(score)]

        regul = (
            torch.mean(h_re ** 2)
            + torch.mean(h_im ** 2)
            + torch.mean(t_re ** 2)
            + torch.mean(t_im ** 2)
            + torch.mean(r_re ** 2)
            + torch.mean(r_im ** 2)
        )
        # loss = torch.mean(self.criterion(score * y)) + self.params.lmbda * regul
        loss = self.criterion(pos_score, neg_score, torch.Tensor([-1]))
        return loss, pos_score, neg_score



class Trainer():
    def __init__(self, model, data, params):
        self.model = model
        self.data = data
        self.optimizer = None
        self.params = params

        if params.optimizer == "SGD":
            self.optimizer = optim.SGD(self.model.parameters(), lr=params.lr, momentum=params.momentum)
        if params.optimizer == "Adam":
            self.optimizer = optim.Adam(self.model.parameters(), lr=params.lr)

        self.criterion = nn.MarginRankingLoss(self.params.margin, reduction='sum')

        self.best_metric = 1e10
        self.last_metric = 1e10
        self.bad_count = 0

        assert self.optimizer is not None

    def one_epoch(self):
        all_pos_scores = []
        all_neg_scores = []
        total_loss = 0
        for b in range(self.params.nBatches):
            batch_h, batch_t, batch_r, batch_y = self.data.get_batch(b)
            loss, pos_score, neg_score = self.model(batch_h, batch_t, batch_r, batch_y)

            all_pos_scores += pos_score.detach().cpu().tolist()
            all_neg_scores += neg_score.detach().cpu().tolist()

            total_loss += loss.detach().cpu()

            self.optimizer.zero_grad()
            loss.backward()
            self.optimizer.step()

        all_labels = [0] * len(all_pos_scores) + [1] * len(all_neg_scores)
        auc = metrics.roc_auc_score(all_labels, all_pos_scores + all_neg_scores)

        return total_loss, auc

    def select_model(self, log_data):
        if log_data['auc'] < self.best_metric:
            self.bad_count = 0
            torch.save(self.model, os.path.join(self.params.exp_dir, 'best_model.pth'))  # Does it overwrite or fuck with the existing file?
            logging.info('Better model found w.r.t MR. Saved it!')
            self.best_mr = log_data['auc']
        else:
            self.bad_count = self.bad_count + 1
            if self.bad_count > self.params.patience:
                logging.info('Out of patience. Stopping the training loop.')
                return False
        self.last_metric = log_data['auc']
        return True



def get_torch_sparse_matrix(A, dev):
    idx = torch.LongTensor([A.tocoo().row, A.tocoo().col])
    dat = torch.FloatTensor(A.tocoo().data)
    return torch.sparse.FloatTensor(idx, dat, torch.Size([A.shape[0], A.shape[1]])).to(device=dev)


class Evaluator():
    def __init__(self, model, data_sampler, params):
        self.model = model
        self.data_sampler = data_sampler
        self.params = params

    def get_log_data(self, data='valid'):
        global eval_batch_h, eval_batch_t, eval_batch_r, eval_batch_y
        if data == 'valid':
            eval_batch_h, eval_batch_t, eval_batch_r, eval_batch_y = self.data_sampler.get_valid_data()
        elif data == 'test':
            eval_batch_h, eval_batch_t, eval_batch_r, eval_batch_y = self.data_sampler.get_test_data()

        _, pos_scores, neg_scores = self.model(eval_batch_h, eval_batch_t, eval_batch_r, eval_batch_y)

        all_pos_scores = pos_scores.detach().cpu().tolist()
        all_neg_scores = neg_scores.detach().cpu().tolist()

        all_labels = [0] * len(all_pos_scores) + [1] * len(all_neg_scores)
        auc = metrics.roc_auc_score(all_labels, all_pos_scores + all_neg_scores)

        log_data = dict([
            ('auc', auc)])

        return log_data


def initialize_experiment(params):
    params.main_dir = os.path.relpath(os.path.dirname(os.path.abspath(__file__)))
    exps_dir = os.path.join(params.main_dir, 'experiments')
    if not os.path.exists(exps_dir):
        os.makedirs(exps_dir)

    params.exp_dir = os.path.join(exps_dir, params.experiment_name)

    if not os.path.exists(params.exp_dir):
        os.makedirs(params.exp_dir)

    file_handler = logging.FileHandler(os.path.join(params.exp_dir, "log.txt"))
    logger = logging.getLogger()
    logger.addHandler(file_handler)

    print('\n'.join('%s: %s' % (k, str(v)) for k, v
                          in sorted(dict(vars(params)).items())))

    with open(os.path.join(params.exp_dir, "params.json"), 'w') as fout:
        json.dump(vars(params), fout)


def initialize_model(params, load_model=False):

    if load_model and os.path.exists(os.path.join(params.exp_dir, 'best_model.pth')):
        logging.info('Loading existing model from %s' % os.path.join(params.exp_dir, 'best_model.pth'))
        model = torch.load(os.path.join(params.exp_dir, 'best_model.pth'))
    else:
        logging.info('No existing model found. Initializing new model..')
        if params.model == 'DistMult':
            model = DistMult(params).to(device=params.device)
        if params.model == 'ComplEx':
            model = ComplEx(params).to(device=params.device)

    return model





logging.basicConfig(level=logging.INFO)

parser = argparse.ArgumentParser(description='DistMult and ComplEx model')

parser.add_argument("--experiment_name", type=str, default="default",
                    help="A folder with this name would be created to dump saved models and log files")
parser.add_argument("--dataset", "-d", type=str, default="train_temp",
                    help="Dataset string")
parser.add_argument("--model", "-m", type=str, default="current_model",
                    help="Model to use")

parser.add_argument("--nEpochs", type=int, default=100,
                    help="Learning rate of the optimizer")
parser.add_argument("--nBatches", type=int, default=25,
                    help="Batch size")
parser.add_argument("--eval_every", type=int, default=10,
                    help="Interval of epochs to evaluate the model?")
parser.add_argument("--save_every", type=int, default=50,
                    help="Interval of epochs to save a checkpoint of the model?")
parser.add_argument('--eval_mode', type=str, default="head",
                    help='Evaluate on head and/or tail prediction?')
parser.add_argument("--neg_sample_size", type=int, default=100,
                    help="No. of negative samples to compare to for MRR/MR/Hit@10")


parser.add_argument("--sample_size", type=int, default=0,
                    help="No. of negative samples to compare to for MRR/MR/Hit@10")
parser.add_argument("--patience", type=int, default=10,
                    help="Early stopping patience")
parser.add_argument("--margin", type=int, default=1,
                    help="The margin between positive and negative samples in the max-margin loss")
parser.add_argument("--p_norm", type=int, default=1,
                    help="The norm to use for the distance metric")
parser.add_argument("--optimizer", type=str, default="SGD",
                    help="Which optimizer to use? SGD/Adam")
parser.add_argument("--embedding_dim", type=int, default=50,
                    help="Entity and relations embedding size")
parser.add_argument("--lr", type=float, default=0.01,
                    help="Learning rate of the optimizer")
parser.add_argument("--momentum", type=float, default=0,
                    help="Momentum of the SGD optimizer")
parser.add_argument("--lmbda", type=float, default=0,
                    help="Regularization constant")


parser.add_argument('--disable-cuda', action='store_true',
                    help='Disable CUDA')
parser.add_argument('--filter', action='store_true',
                    help='Filter the samples while evaluation')



params = parser.parse_args()

initialize_experiment(params)

params.device = None
if not params.disable_cuda and torch.cuda.is_available():
    params.device = torch.device('cuda')
else:
    params.device = torch.device('cpu')

logging.info(params.device)

data_sampler = DataSampler(params)
current_model = initialize_model(params)
trainer = Trainer(current_model, data_sampler, params)
evaluator = Evaluator(current_model, data_sampler, params)

logging.info('Starting training...')

# training

for e in range(params.nEpochs):
    res = 0
    tic = time.time()
    current_model.train()
    loss, auc = trainer.one_epoch()
    toc = time.time()

    logging.info('Epoch %d with loss: %f, auc: %f in %f'
                 % (e, loss, auc, toc - tic))

    if (e + 1) % params.eval_every == 0:
        tic = time.time()
        current_model.eval()
        log_data = evaluator.get_log_data('test')
        toc = time.time()
        logging.info('Performance: %s in %f' % (str(log_data), (toc - tic)))


        to_continue = trainer.select_model(log_data)
        if not to_continue:
            break
    if (e + 1) % params.save_every == 0:
        torch.save(current_model, os.path.join(params.exp_dir, 'checkpoint.pth'))



exps_dir = os.path.join(MAIN_DIR, 'experiments')
params.exp_dir = os.path.join(exps_dir, params.experiment_name)


# test auc
test_data_sampler = DataSampler(params)
current_model = initialize_model(params)
evaluator = Evaluator(current_model, test_data_sampler, params)


logging.info('Testing model %s' % os.path.join(params.exp_dir, 'best_model.pth'))


tic = time.time()
log_data = evaluator.get_log_data(params.eval_mode)
toc = time.time()

logging.info('Test performance: %s in %f' % (str(log_data), toc - tic))

