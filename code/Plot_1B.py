#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed May 28 11:38:20 2025

@author: kanep
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.cluster.hierarchy import dendrogram, linkage, leaves_list
from scipy.spatial.distance import squareform

# Load data
vectorized = np.loadtxt('/home/kanep/kg98_scratch/Kane/FC_estimations/data/ABCD_results/FC/recommended_vectorised.csv', delimiter=',')
vectorized=vectorized[0:11:,:]
names = ['Pearsons', 'Spearmans', 'Partial correlation', 'GLASSO', 'Mutual information (time)', 
         'Mutual information (frequency)', 'Spectral Coherence', 'Wavelet Coherence', 'Synergy',
         'Redundancy', 'Regression DCM']
n_measures = len(names)

# Compute similarity matrix
similarity = np.corrcoef(vectorized)

# Convert to distance matrix
distance = 1 - similarity

# Perform hierarchical clustering
Z = linkage(squareform(distance, checks=False), method='average')
order = leaves_list(Z)
sorted_sim = similarity[order, :][:, order]

# Create figure 1: Heatmap with colorbar
plt.figure(figsize=(10, 8))
ax = plt.gca()
im = plt.imshow(sorted_sim, cmap='Blues', vmin=0, vmax=1)

# Add correlation values
for i in range(n_measures):
    for j in range(n_measures):
        color = 'black' if sorted_sim[i, j] < 0.6 else 'white'
        plt.text(j, i, f"{sorted_sim[i, j]:.2f}",
                ha="center", va="center",
                color=color, fontsize=9)

# Format heatmap
plt.xticks(np.arange(n_measures), [names[i] for i in order], rotation=45, ha='right')
plt.yticks(np.arange(n_measures), [names[i] for i in order])
plt.tick_params(axis='both', which='both', length=0)

# Add colorbar
cbar = plt.colorbar(im, fraction=0.046, pad=0.01)
cbar.set_label('Correlation', rotation=270, labelpad=15)
cbar.outline.set_visible(False)

plt.tight_layout()
plt.show()

# Create figure 2: Dendrogram
plt.figure(figsize=(6, 8))
ax = plt.gca()
dendrogram(Z, orientation='left', labels=names,
          color_threshold=0,
          above_threshold_color='#1f77b4',
          leaf_font_size=10)

# Format dendrogram
plt.setp(ax.get_ymajorticklabels(), rotation=0, ha='right')
for spine in ['top', 'right', 'bottom', 'left']:
    ax.spines[spine].set_visible(False)
ax.set_xticks([])
ax.set_yticks([])

plt.tight_layout()
plt.show()