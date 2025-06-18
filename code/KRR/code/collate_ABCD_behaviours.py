#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Feb 20 10:30:37 2025

@author: kanep
"""

import os
import pandas as pd
import numpy as np

os.chdir('/home/kanep/kg98_scratch/Kane/FC_estimations/data/ABCD_tabulated_data/core/')
# load subject list
subject_list=pd.read_csv('/home/kanep/kg98_scratch/Kane/FC_estimations/data/ABCD/recommended_subs_to_keep.csv',
                         header=None)
subject_list.columns=['Subject']

# Collect NIH Toolbox relevant variables
NIH=pd.read_csv('neurocognition/nc_y_nihtb.csv')
NIH=NIH[NIH['eventname']=='baseline_year_1_arm_1']
NIH_col_names=['src_subject_id','nihtbx_picvocab_uncorrected','nihtbx_flanker_uncorrected',
           'nihtbx_list_uncorrected', 'nihtbx_cardsort_uncorrected', 'nihtbx_pattern_uncorrected',
           'nihtbx_picture_uncorrected', 'nihtbx_reading_uncorrected', 'nihtbx_fluidcomp_uncorrected',
           'nihtbx_cryst_uncorrected', 'nihtbx_totalcomp_uncorrected']
NIH_replace_names=['Subject', 'Vocabulary', 'Attention', 'Working Memory', 'Executive Function',
                    'Processing Speed', 'Episodic Memory', 'Reading', 'Fluid Cognition',
                    'Crystalised Cognition', 'Overall Cognition']
NIH=NIH[NIH_col_names]
NIH = NIH.rename(columns=dict(zip(NIH_col_names, NIH_replace_names)))

# Rey auditory verbal learning task
REY=pd.read_csv('neurocognition/nc_y_ravlt.csv')
REY=REY[REY['eventname']=='baseline_year_1_arm_1']
REY_col_names=['src_subject_id', 'pea_ravlt_sd_trial_vi_tc', 'pea_ravlt_ld_trial_vii_tc']
REY_replace_names=['Subject','Short delay recall', 'Long delay recall']
REY=REY[REY_col_names]
REY = REY.rename(columns=dict(zip(REY_col_names, REY_replace_names)))

# Wescler intelligence scale
WESC=pd.read_csv('neurocognition/nc_y_wisc.csv')
WESC=WESC[WESC['eventname']=='baseline_year_1_arm_1']
WESC_col_names=['src_subject_id', 'pea_wiscv_trs']
WESC_replace_names=['Subject','Fluid Intelligence']
WESC=WESC[WESC_col_names]
WESC = WESC.rename(columns=dict(zip(WESC_col_names, WESC_replace_names)))

# Little man task
LMT=pd.read_csv('neurocognition/nc_y_lmt.csv')
LMT=LMT[LMT['eventname']=='baseline_year_1_arm_1']
LMT_col_names=['src_subject_id', 'lmt_scr_perc_correct', 'lmt_scr_rt_correct',
               'lmt_scr_efficiency']
LMT_replace_names=['Subject','Visuospatial Accuracy','Visuospatial reaction time',
                   'Visuospatial Efficiency']
LMT=LMT[LMT_col_names]
LMT = LMT.rename(columns=dict(zip(LMT_col_names, LMT_replace_names)))

# Urgency, Premeditation, Perseverance, Sensation Seeking, ... Behaviour scale
UPPS=pd.read_csv('mental-health/mh_y_upps.csv')
UPPS=UPPS[UPPS['eventname']=='baseline_year_1_arm_1']
UPPS_col_names=['src_subject_id', 'upps_y_ss_negative_urgency', 'upps_y_ss_lack_of_planning',
                'upps_y_ss_sensation_seeking', 'upps_y_ss_positive_urgency', 'upps_y_ss_lack_of_perseverance']
UPPS_replace_names=['Subject','Negative urgency', 'Lack of planning', 'Sensation seeking',
                    'Positive urgency', 'Lacks perserverance']
UPPS=UPPS[UPPS_col_names]
UPPS = UPPS.rename(columns=dict(zip(UPPS_col_names, UPPS_replace_names)))

# Behavioural Inhibition
BI=pd.read_csv('mental-health/mh_y_bisbas.csv')
BI=BI[BI['eventname']=='baseline_year_1_arm_1']
BI_col_names=['src_subject_id', 'bis_y_ss_bis_sum', 'bis_y_ss_bas_rr', 'bis_y_ss_bas_drive',
              'bis_y_ss_bas_fs']
BI_replace_names=['Subject', 'Behvaioural inhibition', 'Reward responsiveness', 'Drive',
                  'Fun seeking']
BI=BI[BI_col_names]
BI = BI.rename(columns=dict(zip(BI_col_names, BI_replace_names)))

# CBCL
CBCL=pd.read_csv('mental-health/mh_p_cbcl.csv')
CBCL=CBCL[CBCL['eventname']=='baseline_year_1_arm_1']
CBCL_col_names=['src_subject_id', 'cbcl_scr_syn_anxdep_r', 'cbcl_scr_syn_withdep_r',
                'cbcl_scr_syn_somatic_r', 'cbcl_scr_syn_social_r', 'cbcl_scr_syn_thought_r',
                'cbcl_scr_syn_attention_r', 'cbcl_scr_syn_rulebreak_r', 'cbcl_scr_syn_aggressive_r']
CBCL_replace_names=['Subject',  'Anxious depressed', 'Withdrawn depressed', 'Somatic compaints',
                    'Social problems', 'Thought problems', 'Attention problems', 'Rule breaking',
                    'Aggression']
CBCL=CBCL[CBCL_col_names]
CBCL = CBCL.rename(columns=dict(zip(CBCL_col_names, CBCL_replace_names)))

# Prodromal Psychosis scale
PPS=pd.read_csv('mental-health/mh_y_pps.csv')
PPS=PPS[PPS['eventname']=='baseline_year_1_arm_1']
PPS_col_names=['src_subject_id', 'pps_y_ss_number', 'pps_y_ss_severity_score']
PPS_replace_names=['Subject','Total psychosis symptoms', 'Psychosis severity']
PPS=PPS[PPS_col_names]
PPS = PPS.rename(columns=dict(zip(PPS_col_names, PPS_replace_names)))

# General Behaviour Inventory
GBI=pd.read_csv('mental-health/mh_p_gbi.csv')
GBI=GBI[GBI['eventname']=='baseline_year_1_arm_1']
GBI_col_names=['src_subject_id', 'pgbi_p_ss_score']
GBI_replace_names=['Subject','Mania']
GBI=GBI[GBI_col_names]
GBI = GBI.rename(columns=dict(zip(GBI_col_names, GBI_replace_names)))

#######################################################################################
# Merge all variables and save by FC index
########################################################################################
all_vars = NIH
dataframes = [REY, WESC, LMT, UPPS, BI, CBCL, PPS, GBI]

for df in dataframes:
    all_vars = pd.merge(all_vars, df, on='Subject', how='inner')

all_vars['Subject'] = all_vars['Subject'].str.replace('_', '')

# subset the behaviour list to match FC
filtered_all_vars = all_vars[all_vars['Subject'].isin(subject_list['Subject'])]
filtered_all_vars['Subject'] = pd.Categorical(
    filtered_all_vars['Subject'], 
    categories=subject_list['Subject'], 
    ordered=True
)
filtered_all_vars = filtered_all_vars.sort_values('Subject')

# Get a boolean to subset FC with the remaining subjects 
missing_subjects = subject_list[~subject_list['Subject'].isin(all_vars['Subject'])]
FC_boolen_inclusions = np.where(subject_list['Subject'].isin(missing_subjects['Subject']), 0, 1)

########################
# Add in Covariates
#########################
# Age and Gender
DEMO=pd.read_csv('abcd-general/abcd_p_demo.csv')
DEMO=DEMO[DEMO['eventname']=='baseline_year_1_arm_1']
DEMO_col_names=['src_subject_id', 'demo_brthdat_v2', 'demo_sex_v2']
DEMO_replace_names=['Subject','Age', 'Sex']
DEMO=DEMO[DEMO_col_names]
DEMO = DEMO.rename(columns=dict(zip(DEMO_col_names, DEMO_replace_names)))
DEMO['Subject'] = DEMO['Subject'].str.replace('_', '')


# FD
subject_list['FD']=pd.read_csv('/home/kanep/kg98_scratch/Kane/FC_estimations/data/ABCD_results/FC/recommended_fmri_inclusions_mean_FD.csv', 
               header=None)
covars= [DEMO, subject_list]
filtered_all_vars_with_covars=filtered_all_vars
for df in covars:
    filtered_all_vars_with_covars = pd.merge(filtered_all_vars_with_covars, df, on='Subject', how='inner')

#######################################################################################
# Save behaviours and covariates
########################################################################################
covars_out = filtered_all_vars_with_covars[['Age',"Sex","FD"]]
behaviours_out=filtered_all_vars.drop(columns=["Subject"])

covars_out.to_csv("/home/kanep/kg98_scratch/Kane/FC_estimations/data/KRR/file_list/ABCD/recommended_covars.csv",
                  index=False)
behaviours_out.to_csv("/home/kanep/kg98_scratch/Kane/FC_estimations/data/KRR/file_list/ABCD/recommended_behaviours.csv",
                  index=False)
np.savetxt("/home/kanep/kg98_scratch/Kane/FC_estimations/data/KRR/file_list/ABCD/recommended_FC_subject_inclusions.csv",
                  FC_boolen_inclusions, delimiter=',')
filtered_all_vars['Subject'].to_csv("/home/kanep/kg98_scratch/Kane/FC_estimations/data/KRR/file_list/ABCD/recommended_sub_list.csv",
                  index=False)



