#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Dec 10 10:09:21 2024

@author: kanep
"""



import os
import pandas as pd

os.chdir('/home/kanep/kg98_scratch/Kane/FC_estimations/data/')

sub_list=pd.DataFrame()
sub_list['subject_ID']=pd.read_csv('ABCD/fmri_sub_list.txt', header=None)


mri_make_list=pd.read_csv('ABCD_tabulated_data/core/imaging/mri_y_adm_info.csv')
mri_make_list=mri_make_list.loc[mri_make_list['eventname']=='baseline_year_1_arm_1']
mri_make_list['src_subject_id'] = mri_make_list['src_subject_id'].str.replace('_', '')

current_mri = pd.merge(sub_list, mri_make_list[['src_subject_id', 'mri_info_manufacturer', 'mri_info_deviceserialnumber']], 
                       left_on='subject_ID', right_on='src_subject_id', how='inner')
# Check subjects are the same
equality = current_mri['src_subject_id']==current_mri['subject_ID']
any_false = not equality.all()
current_mri=current_mri.drop(columns='src_subject_id')

demo = pd.read_csv('ABCD_tabulated_data/core/abcd-general/abcd_p_demo.csv')
demo=demo.loc[demo['eventname']=='baseline_year_1_arm_1']
demo['src_subject_id'] = demo['src_subject_id'].str.replace('_', '')

current_mri_gend = pd.merge(current_mri, demo[['src_subject_id', 'demo_gender_id_v2']], 
                       left_on='subject_ID', right_on='src_subject_id', how='inner')
# Check subjects are the same
equality = current_mri_gend['src_subject_id']==current_mri_gend['subject_ID']
any_false = not equality.all()
current_mri_gend=current_mri_gend.drop(columns='src_subject_id')

# scanner counts
scanner_counts=current_mri_gend['mri_info_deviceserialnumber'].value_counts()

#create train list
filtered_df = current_mri_gend[(current_mri_gend['mri_info_deviceserialnumber'] == 'HASHb640a1b8') & 
                              (current_mri_gend['demo_gender_id_v2'] == 2)]
list_1 = filtered_df.sample(n=7)
filtered_df = current_mri_gend[(current_mri_gend['mri_info_deviceserialnumber'] == 'HASHb640a1b8') & 
                              (current_mri_gend['demo_gender_id_v2'] == 1)]
list_2 = filtered_df.sample(n=7)
filtered_df = current_mri_gend[(current_mri_gend['mri_info_deviceserialnumber'] == 'HASH96a0c182') & 
                              (current_mri_gend['demo_gender_id_v2'] == 2)]
list_3 = filtered_df.sample(n=7)
filtered_df = current_mri_gend[(current_mri_gend['mri_info_deviceserialnumber'] == 'HASH96a0c182') & 
                              (current_mri_gend['demo_gender_id_v2'] == 1)]
list_4 = filtered_df.sample(n=7)

FIX_train_list=pd.concat([list_1, list_2, list_3, list_4], ignore_index=True)
reduced_scanner_subs=current_mri_gend[(current_mri_gend['mri_info_deviceserialnumber'] == 'HASHb640a1b8') | 
                                      (current_mri_gend['mri_info_deviceserialnumber'] == 'HASH96a0c182')]
# Save lists
reduced_scanner_subs['subject_ID'].to_csv('ABCD/reduced_2scanner_subs.csv', index=False, header=None)
FIX_train_list['subject_ID'].to_csv('ABCD_FIX_TRAINING/training_subs.csv', index=False, header=None)


value_to_search = "NDARINVKK5BJGB6"
if value_to_search in filtered_df['subject_ID'].values:
    print(f"{value_to_search} is present in the subject_ID column.")
else:
    print(f"{value_to_search} is NOT present in the subject_ID column.")

# Pick 7 males and 7 females from top 2 scanner sites

# Pick 7 males and 7 females from each scanner manafacturer
# Filter the DataFrame based on the conditions
#filtered_df = current_mri_gend[(current_mri_gend['mri_info_manufacturer'] == 'SIEMENS') & 
#                               (current_mri_gend['demo_gender_id_v2'] == 2)]
#list_1 = filtered_df.sample(n=7)
#filtered_df = current_mri_gend[(current_mri_gend['mri_info_manufacturer'] == 'SIEMENS') & 
#                               (current_mri_gend['demo_gender_id_v2'] == 1)]
#list_2 = filtered_df.sample(n=7)

#filtered_df = current_mri_gend[(current_mri_gend['mri_info_manufacturer'] == 'Philips Medical Systems') & 
#                               (current_mri_gend['demo_gender_id_v2'] == 2)]
#list_3 = filtered_df.sample(n=7)
#filtered_df = current_mri_gend[(current_mri_gend['mri_info_manufacturer'] == 'Philips Medical Systems') & 
#                                (current_mri_gend['demo_gender_id_v2'] == 1)]
# list_4 = filtered_df.sample(n=7)

# filtered_df = current_mri_gend[(current_mri_gend['mri_info_manufacturer'] == 'GE MEDICAL SYSTEMS') & 
#                                (current_mri_gend['demo_gender_id_v2'] == 2)]
# list_5 = filtered_df.sample(n=7)
# filtered_df = current_mri_gend[(current_mri_gend['mri_info_manufacturer'] == 'GE MEDICAL SYSTEMS') & 
#                                (current_mri_gend['demo_gender_id_v2'] == 1)]
# list_6 = filtered_df.sample(n=7)

# FIX_train_list=pd.concat([list_1, list_2, list_3, list_4, list_5, list_6], ignore_index=True)

# FIX_train_list.to_csv('ABCD_FIX_TRAINING/training_subs_info.csv', index=False)
# FIX_train_list['subject_ID'].to_csv('ABCD_FIX_TRAINING/training_subs.txt', index=False, header=None)

