#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Feb 17 11:29:04 2025

@author: kanep
"""

import numpy as np
import pandas as pd
import bct
from netneurotools import cluster
import mat73

# Define key variables
base_dir="/home/kanep/kg98_scratch/Kane/FC_estimations"
FC_file="{}/data/HCP_results/FC/All_FC.mat".format(base_dir)
parcels=300

# Define Consensus calculation
def consensus_Q(W,gamma,ci):
    W0 = W * (W > 0)
    s0 = np.sum(W0)
    B0 = W0 - gamma * np.outer(np.sum(W0, axis=1), np.sum(W0, axis=0)) / s0

    W1 = -W * (W < 0)
    s1 = np.sum(W1)
    if s1:
        B1 = W1 - gamma * np.outer(np.sum(W1, axis=1), np.sum(W1, axis=0)) / s1
    else:
        B1 = 0
    B = (B0 / s0) - (B1 / (s0 + s1))
    
    n = np.max(ci)
    b1 = np.zeros((n, n))
    for i in range(1, n + 1):
        for j in range(i, n + 1):
            # pool weights of nodes in same module
            bm = np.sum(B[np.ix_(ci == i, ci == j)])
            b1[i - 1, j - 1] = bm
            b1[j - 1, i - 1] = bm
    B = b1.copy()
    consensus_Q=np.trace(B)
    return consensus_Q

# Load FC
All_FC=mat73.loadmat(FC_file)
All_FC=All_FC['All_FC']
del All_FC['reg_DCM']
proc_list= list(All_FC.keys())
num_procs=len(proc_list)
num_subs=All_FC['pearsons'].shape[2]

gamma=1.0
louv_reps=100
con_Q=np.zeros([num_subs,num_procs])

tmp_file_out="{}/data/HCP_results/Quality_metrics/all_fmri_modularity_tmp.csv".format(base_dir)
#con_Q=np.loadtxt(tmp_file_out)

for p in range(num_procs):
    curr_FC=All_FC[proc_list[p]]
    for s in range(num_subs):
        FC_s = curr_FC[:, :, s]
        if np.any(np.isinf(np.diag(FC_s))):
            max_value = np.nanmax(FC_s[np.isfinite(FC_s)])
            np.fill_diagonal(FC_s, np.where(np.isinf(np.diag(FC_s)), max_value, np.diag(FC_s)))
            
        NGs_M=np.zeros([parcels,louv_reps])
        NGs_Q=np.zeros(louv_reps)
        for r in range(louv_reps):
                NGs_M[:, r], NGs_Q[r] = bct.algorithms.community_louvain(FC_s, gamma, B="negative_asym")
                ci = cluster.find_consensus(NGs_M)
        con_Q[s,p] = consensus_Q(FC_s, gamma, ci)
        np.savetxt(tmp_file_out, con_Q)
        print(s)
col_names=proc_list
dataframe_con_Q = pd.DataFrame(con_Q, columns=col_names)     

file_out="{}/data/HCP_results/Quality_metrics/all_modularity.csv".format(base_dir)
dataframe_con_Q.to_csv(file_out, sep=',', index=False)

    


