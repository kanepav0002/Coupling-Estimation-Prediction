#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Feb 19 10:51:20 2025

@author: kanep
"""

import os
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

# load necessary files
os.chdir("/home/kanep/kg98_scratch/Kane/FC_estimations/data/ABCD_results")
QC_corrs= pd.read_csv("Quality_metrics/QC_FC_corrs_stringent_inclusions_with_sparsity.csv",header=None)
dist_dep=pd.read_csv("Quality_metrics/distance_dependence.csv",header=None)
#modularity=pd.read_csv('Quality_metrics/stringent_fmri_inclusions_modularity_tmp.csv', delimiter=' ', header=None)
krr_res=pd.read_csv("KRR/all_mean_across_reps_UTLT_stringent.csv",header=None)
preprocs=pd.read_csv('Quality_metrics/preproc_names_with_sparsity.csv', header=None)
preproc_values = preprocs.iloc[:, 0].tolist() 

colors = list(plt.cm.tab20.colors[:16])
colors.insert(17,(255/255, 84/255, 128/255))
colors.insert(18,(255/255, 105/255, 180/255))
colors.insert(19,(255/255, 182/255, 193/255))
palette=sns.color_palette(colors)
#######################################################################################
# QC - FC
##########################################################################################
# Prepare the data
QC_corrs=np.array(QC_corrs)
n_edges = QC_corrs.shape[1]
mean_qc = pd.DataFrame(QC_corrs, index=preproc_values).stack().reset_index()
mean_qc.columns = ['preprocs', 'edge', 'mean']

# Plot setup
sns.set_theme(style="white", rc={"axes.facecolor": (0, 0, 0, 0), 'axes.linewidth':2})
g = sns.FacetGrid(mean_qc, palette=palette, row='preprocs', hue='preprocs', aspect=6, height=2.2)
g.map_dataframe(sns.kdeplot, x='mean', fill=True, alpha=1)
g.map_dataframe(sns.kdeplot, x='mean', color='black')
plt.tight_layout()

def label(x, color, label):
    ax = plt.gca()
    ax.text(0, .2, label, color='black', fontsize=13,
            ha="left", va="center", transform=ax.transAxes)
    ax.axvline(x=0, color='black', linestyle='--')
g.map(label, "preprocs")
g.set_titles("")
g.set(yticks=[])
g.set(ylabel="")
g.set(xlabel="QC-FC (r)")
g.set(xlim=[-0.8, 0.8])
g.despine(left=True)
g.fig.subplots_adjust(hspace=-.5)
plt.suptitle("", fontsize=20, x=0.2, y=0.95)
plt.subplots_adjust(bottom=0.15)

#######################################################################################
# Distance Dependence
##########################################################################################
plt.figure(figsize=(10, 6))
ax = sns.barplot(
    x=dist_dep.iloc[0,:],  # Use preproc_values as x-axis labels
    y=preproc_values,  # Use the values from the DataFrame
    palette=palette,  # Use the custom palette
)
# Remove the top and right spines
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
# Add labels and title
plt.xlabel('Spearmans rho (r)')
plt.ylabel('')
plt.xlim(-0.7,0.3)
plt.axvline(x=0, color='grey', linestyle='-')

plt.tight_layout()
plt.show()

#######################################################################################
# Modularity
##########################################################################################
# modularity = modularity.drop(modularity.columns[12], axis=1)
# modularity.columns=["Mutual information (frequency)", "Mutual information (time)", "Glasso partial corr",
#                     "Partial corr","Pearsons corr", "Redundancy", "Regression DCM (incoming)", 
#                     "Regression DCM (outgoing)", "Spearmans corr", "Spectral Coherence", "Synergy", 
#                     "Wavelet Coherence"]

# preproc_values_modularity=[item for item in preproc_values if item != "Regression DCM (all)"]
# modularity=modularity[preproc_values_modularity]

# modularity_melted = modularity.melt(var_name='Category', value_name='Value')
# mean_modularity = modularity_melted.groupby('Category')['Value'].mean().reset_index()

# # Generate the strip plot
# plt.figure(figsize=(12, 6))
# ax = sns.stripplot(
#     x='Value',  
#     y='Category',    
#     data=modularity_melted,  
#     palette=palette,  
#     jitter=True,  
#     size=4        
# )
# sns.scatterplot(
#     x=mean_modularity['Value'], 
#     y=mean_modularity['Category'], 
#     color='grey', 
#     marker='D',  # Diamond shape for visibility
#     s=50,  # Size of the marker
#     edgecolor='black',
#     zorder=3  # Ensure it's on top
# )

# # Adjust graph labels
# ax.set_yticks(range(len(preproc_values_modularity)))
# ax.set_yticklabels(preproc_values_modularity, rotation=0)
# ax.spines['top'].set_visible(False)
# ax.spines['right'].set_visible(False)
# plt.xlabel('Modularity Value')
# plt.ylabel('')


# plt.tight_layout()
# plt.show()

#######################################################################################
# Kernel Ridge Regression
##########################################################################################
krr_res=pd.read_csv("KRR/mean_across_reps_UTLT_stringent.csv",header=None)

krr_res.columns = preprocs.iloc[:,0]

krr_res_melted = krr_res.melt(var_name='Preprocessing', value_name='Value')
means = krr_res_melted.groupby('Preprocessing')['Value'].mean().reset_index()

# Create the boxplot
plt.figure(figsize=(12, 8))
ax = sns.boxplot(x='Value', y='Preprocessing', data=krr_res_melted, palette=palette)
boxplot_order = ax.get_yticks()  # Get the y-tick positions
boxplot_labels = [ax.get_yticklabels()[i].get_text() for i in boxplot_order]  # Get the labels in the correct order
means = means.set_index('Preprocessing').loc[boxplot_labels].reset_index()

ax.scatter(x=means['Value'], y=means['Preprocessing'], color='white', marker='^', s=30, label='Mean')
plt.xlabel('mean accuracy (r)')
plt.ylabel("")
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

# Show the plot
plt.tight_layout()
plt.show()