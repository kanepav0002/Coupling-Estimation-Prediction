#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Apr 19 11:02:02 2023

@author: kanepavlovich
"""

import pandas as pd
import os
os.chdir('/home/kanep/kg98_scratch/Kane/FC_estimations')

full_58=pd.read_csv('KRR/file_list/HCP/HCP_58Behaviours.csv')
sub_list=pd.read_csv('data/HCP/stringent_sub_list_exclusions.csv', header=None)
unrestricted=pd.read_csv('KRR/file_list/HCP/HCP_unrestricted_behav.csv')
restricted=pd.read_csv('KRR/file_list/HCP/restricted_1110.csv')
FD=pd.read_csv('data/HCP_results/FC/stringent_motion_exclusions_mean_FD.csv', header=None)

# Add gender back to behaviour
full_58['Gender']=unrestricted['Gender']

# Drop Participants who didn't fill out all behaviours
nan_values=full_58.isnull().any(axis=1)
nan_values[0]=False
full_58.drop(full_58[nan_values].index, inplace=True)
# sort numerically like FC is
full_58=full_58.sort_values(by='Subject', ascending=True)
full_58=full_58.drop(0)
full_58=full_58.reset_index(drop=True)

# Put subjects with Age in restricted file into behavioural file
subs_with_age=pd.Series(list(set(full_58['Subject']).intersection(set(restricted['Subject']))))
mis_match_age=full_58[~full_58['Subject'].isin(restricted['Subject'])]
full_58 = full_58[~full_58['Subject'].isin(mis_match_age['Subject'])]
Age = restricted[['Subject', 'Age_in_Yrs']]
full_58=full_58.merge(Age, on='Subject', how='inner')


# Get list of subjects who do not have beahvioural entries but have FC
mis_match_subs=sub_list[0].isin(full_58['Subject'])
mis_match_subs=mis_match_subs
no_behav_subs=sub_list.copy()
no_behav_subs.drop(no_behav_subs[mis_match_subs].index, inplace=True)

# Create boolean of subs to include in final analysis from FC
remove_from_FC=sub_list[0].isin(no_behav_subs[0])
remove_from_FC=~remove_from_FC
remove_from_FC = remove_from_FC.astype(int)

final_sub_list=sub_list.copy()
final_sub_list.drop(final_sub_list[remove_from_FC].index, inplace=True)
final_sub_list=final_sub_list.rename(columns={0:"Subject_FCsort"})
final_sub_list=final_sub_list.reset_index(drop=True)
# Do same for behaviour
remove_from_Behav=full_58['Subject'].isin(final_sub_list["Subject_FCsort"])
full_58.drop(full_58[~remove_from_Behav].index, inplace=True)

# Recode covariates
covariates=full_58[['Gender', 'Age_in_Yrs']]
covariates['Gender'] = covariates['Gender'].str.replace('M','0')
covariates['Gender'] = covariates['Gender'].str.replace('F','1')
covariates = covariates.reset_index(drop=True)
covariates['FD'] = FD.loc[:,0]

full_58.drop(columns=['Gender', 'Age_in_Yrs'], inplace=True)

# Save everything
final_sub_list.to_csv("KRR/file_list/HCP/All_sub_list.csv", index=False, header=None)
#no_behav_subs.to_csv("KRR/file_list/HCP/subs_to_remove_from_FC.csv", index=False)
remove_from_FC.to_csv("KRR/file_list/HCP/stringent_subject_inclusions.csv", index=False, header=False)
full_58.to_csv("KRR/file_list/HCP/All_behaviours.csv", index=False)
covariates.to_csv("KRR/file_list/HCP/All_covars.csv", index=False, header=None)
