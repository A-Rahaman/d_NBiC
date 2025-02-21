import os, sys
import torch
from torch import autograd, nn, optim
import torch.nn.functional as F
import numpy as np
import scipy.io
from scipy.io import savemat
from statistics import mean
from sklearn import preprocessing
import math

def emd(a, b):
    # Earth mover distance for one dimensional vectors 
    assert len(a) == len(b), "Sequences should be same length!"
    a = preprocessing.normalize(a)
    b = preprocessing.normalize(b)
    return np.sum(np.abs(np.cumsum(a - b)))


def heat_kernel(a,b):
    return math.exp(-((emd(a,b)**2)/0.086)) # From rules of thumb of bandwidth selection

def get_the_biclusters(a,w,alpha,beta):
    # A prototype for selecting subjects and features from weight and activation matrix 
    # based on emphirical thresholds 
    for i in arrange(length(w[:,1])):
        w_i = np.array(w[i,:])
        a_i = np.array(a[:,i])
        feat = np.argwhere(w_i>beta)
        subs = np.argwhere(a_i>alpha)
        bics[i] = {'Subjects': subs,'Features':feat}
        return bics