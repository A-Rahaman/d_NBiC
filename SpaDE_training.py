'''
This script train the SpaDE model by importing all the subnetwork's instantiation from SpaDE_models.py
After the training, we save the weight matrix W and the activation matrix
Then the posthoc analysis, use a heuristic to select the subjects and features for the biclsuetrs
'''
import os, sys
import torch
from torch import autograd, nn, optim
import torch.nn.functional as F
import numpy as np
import random
import scipy.io
from sklearn.model_selection import StratifiedKFold
from sklearn.metrics import confusion_matrix
#from sklearn.metrics import precision_score, recall_score, f1_score, accuracy_score, balanced_accuracy_score
from scipy.io import savemat
import pickle
from collections import Counter
import pandas as pd
from SpaDE_models import Semantic_loss
from SpaDE_models import Sparsity_loss
#print('Debugging')

device = torch.device("cuda:3" if torch.cuda.is_available() else "cpu")

with open(os.path.join('/data/username', 'train' + '.pickle'), 'rb') as handle:
    x_train = pickle.load(handle)

with open(os.path.join('/data/username', 'test' + '.pickle'), 'rb') as handle:
    x_test = pickle.load(handle)

with open(os.path.join('/data/username', 'validation' + '.pickle'), 'rb') as handle:
    x_valid = pickle.load(handle)

with open(os.path.join('/data/username',"emd.pickle"), "rb") as handle:
    dist = pickle.load(handle)

input1 = autograd.Variable(torch.from_numpy(x_train)).to(device)
input2 = autograd.Variable(torch.from_numpy(x_valid)).to(device)
input3 = autograd.Variable(torch.from_numpy(x_test)).to(device)
print('')
input_shape = input1.size().tolist()
# ------------------------------------------ Specifications for the models ---------------------------------------------
feature_size = input_shape(1)
num_clusters = 5
learning_rate = 0.001
epochs = 450
mu = 0.465
gamma = 0.35
delta = 0.334
# Initialize the model
from SpaDE_models import SpaDE

model = SpaDE(feature_size = feature_size,num_clusters=num_clusters)
model.to(device)
opt = optim.Adam(params=model.parameters(), lr=learning_rate)
classifier_criteria = torch.nn.MSELoss()
sem_loss = Semantic_loss(dist, feature_size=feature_size,num_clusters=num_clusters)
spa_loss = Sparsity_loss()
print('loading done')
path = '/data/username/model'
####################################### Training Loop ########################################
prev_valid_loss = max
# model.apply(weight_reset)
for epoch in range(epochs):
        
    [act_mat,dec] = model(input1)
    weight_mat = model.param.data.clone()
    rec_loss = classifier_criteria(dec, input1.to(device))
    sem_reg = sem_loss(weight_mat)
    sp_reg = spa_loss(weight_mat)
    loss = mu*rec_loss + (1-mu)*(gamma*sem_reg + delta*sp_reg) 

    opt.zero_grad()
    loss.backward()
    opt.step()
    with torch.no_grad():
        [act_mat1,out1] = model(input2)
        valid_loss = classifier_criteria(out1, input2.to(device))

        if valid_loss.cpu() < prev_valid_loss.cpu():
            prev_valid_loss = valid_loss
            m_path = os.path.join(path, 'mid_fusion_model' + '.pt')
            torch.save(model.state_dict(), m_path)
            weight_mat1 = model.param.data.clone()
            a = act_mat1
            w_path = os.path.join(path, 'Weight_matrix' + '.pt')
            torch.save(weight_mat1, w_path)
            a_path = os.path.join(path, 'activation_matrix' + '.pt')
            torch.save(a, a_path)

    # print(valid_loss)
print('Training is done, Please load the model for testing')

##################################### Load the model for Testing #######################################################
# Load the model for Testing
# Just to check its performance on test data 

model.to(device)
m_path = os.path.join(path, 'mid_fusion_model' + '.pt')
model.load_state_dict(torch.load(m_path))
model.eval()
with torch.no_grad():
    out1 = model(input3)
    metric = classifier_criteria(out1, input3.to(device))

print('saving the scores')
scores = {'test loss': metric}

with open(os.path.join(path, 'scores' + '.pickle'), 'wb') as handle:
    pickle.dump(scores, handle, pickle.HIGHEST_PROTOCOL)
print('End of Processing')