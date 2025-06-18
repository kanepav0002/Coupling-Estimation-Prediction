#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Feb  3 07:23:42 2025

@author: kanep
"""
# Code to estimate the graphical Lasso partial correlation FC as described in 
# Peterson et al., 2023 https://doi.org/10.1101/2023.09.16.558065
import sys
import numpy as np
from argparse import ArgumentParser
parser = ArgumentParser(epilog="A function to estimate the glasso partial correlation from Peterson et al., 2023")
parser.add_argument("-s", dest="sub_name",
	help="subject ID", metavar="sub_name")
parser.add_argument("-f", dest="sub_folder",
	help="folder where subjects ts is located", metavar="sub_folder")
parser.add_argument("-ts", dest="time_series",
	help="Time series file name", metavar="time_series")
parser.add_argument("-b", dest="base_dir",
	help="base directory for downloaded repository", metavar="base_dir")

args = parser.parse_args()

# Setting the arguments
sub_name = args.sub_name
sub_folder = args.sub_folder
ts_file = args.time_series
base_dir = args.base_dir

# REMOVE LATER 
#sub_name="275645"
#sub_folder = "/home/kanep/kg98_scratch/Kane/FC_estimations/data/HCP/275645/func"
#ts_file = "fsl_parc_ts.txt"
#base_dir = "/home/kanep/kg98_scratch/Kane/FC_estimations"

# Import GGLasso function
sys.path.append(base_dir+'/utils')
from graphicalLassoCV import graphicalLassoCV

# Define list of lambda hyperparameters to run through 
# Values are defined based on a range of optimal values on 10 subjects.
#L1s = np.linspace(0.005,0.15,num=25) # for ABCD
L1s = np.linspace(0.001,0.1,num=25) # for HCP

# Run glasso
ts=np.loadtxt((sub_folder + '/' + ts_file))
ts=ts.T # Change dimensions to nNodes x nTime

glas_p_corr, cv_params = graphicalLassoCV(ts, L1s=L1s,saveFiles=0)

# Save result
file_out_name=(sub_folder + '/' + 'Schaef300_glasso_pcorr.csv')
np.savetxt(file_out_name, glas_p_corr, delimiter=',')



