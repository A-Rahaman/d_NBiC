import os, sys
import torch
from torch import autograd, nn, optim
import torch.nn.functional as F
import numpy as np
import random
import scipy.io
from sklearn.model_selection import StratifiedKFold
from scipy.io import savemat
import pickle
import torch.nn.functional as F
from statistics import mean

''''
# For computing and saving the saliency map 
# Captum is installed in the myenv
from captum.attr import (
    Saliency,
    #GradientShap,
    #DeepLift,
    #DeepLiftShap,
    #IntegratedGradients,
    #LayerConductance,
    #NeuronConductance,
    #NoiseTunnel,
)
'''

# device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
# print(torch.seed())
class SpaDE(torch.nn.Module):
    def __init__(self, feature_size,num_clusters):
        super().__init__()
        self.param = nn.Parameter(torch.randn(num_clusters, feature_size))

        self.encoder = torch.nn.Sequential(
            torch.nn.Linear(feature_size, num_clusters),
            torch.nn.ReLU()
        )

        # DECODER for Decompression 
        self.decoder = torch.nn.Sequential(
            torch.nn.Linear(num_clusters, feature_size)
        )
        # We tie the weights between encoder and decoder in the forward
        
     
    def forward(self, x):
        encoded = self.encoder(x,self.param)
        decoded = self.decoder(encoded,self.param.t())
        return encoded,decoded
####################################### Early stopping #####################################
class EarlyStopping(object):
    def __init__(self, mode='min', min_delta=0, patience=10, percentage=False):
        self.mode = mode
        self.min_delta = min_delta
        self.patience = patience
        self.best = None
        self.num_bad_epochs = 0
        self.is_better = None
        self._init_is_better(mode, min_delta, percentage)

        if patience == 0:
            self.is_better = lambda a, b: True
            self.step = lambda a: False

    def step(self, metrics):
        if self.best is None:
            self.best = metrics
            return False

        if torch.isnan(metrics):
            return True

        if self.is_better(metrics, self.best):
            self.num_bad_epochs = 0
            self.best = metrics
        else:
            self.num_bad_epochs += 1

        if self.num_bad_epochs >= self.patience:
            return True

        return False

    def _init_is_better(self, mode, min_delta, percentage):
        if mode not in {'min', 'max'}:
            raise ValueError('mode ' + mode + ' is unknown!')
        if not percentage:
            if mode == 'min':
                self.is_better = lambda a, best: a < best - min_delta
            if mode == 'max':
                self.is_better = lambda a, best: a > best + min_delta
        else:
            if mode == 'min':
                self.is_better = lambda a, best: a < best - (
                            best * min_delta / 100)
            if mode == 'max':
                self.is_better = lambda a, best: a > best + (
                            best * min_delta / 100)
class Semantic_loss(nn.Module):
    def __init__(self, dist_mat, feature_size, num_clusters):
        super(Semantic_loss, self).__init__()
        self.distance = dist_mat
        self.feature_size = feature_size
        self.num_clusters = num_clusters
         
    
    def forward(self,w):
        #abs_dist = np.zeros((self.feature_size, self.feature_size))
        enumerate_i = np.arange(self.feature_size)
        sem=[]
        for k in np.arrange(self.num_clusters):
            for i in enumerate_i:
                enumerate_j = [enumerate_i!=i]
                for j in enumerate_j:
                    sem.append = self.distance[i][j]* (abs(w[k],[i])-abs(w[k][j])**2)
        return torch.mean(sem)
    
class Sparsity_loss(nn.Module):
    def __init__(self):
        super(Semantic_loss, self).__init__()
    
    def forward(self,w):
        return torch.sqrt(torch.abs(w).sum())



'''
# A general usage In the training loop
#...
        es = EarlyStopping(patience=5)

        num_epochs = 450
        for epoch in range(num_epochs):
            train_one_epoch(model, data_loader)  # train the model for one epoch, on training set
            metric = eval(model, data_loader_dev)  # evalution on dev set (i.e., holdout from training)
            if es.step(metric):
                break  # early stop criterion is met, we can stop now
'''
# Resetting the weights 
def weight_reset(m):
        if isinstance(m, nn.Conv2d) or isinstance(m, nn.Linear):
            m.reset_parameters()

################################ End of all the models declaration SpaDE ############################