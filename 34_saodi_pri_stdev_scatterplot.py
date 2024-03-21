#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jul 26 01:25:22 2023

@author: yuzee
"""

import os
os.chdir('/home/yuzee/nclfolder/RESULTS/05correlation_regional/')

import math
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.markers import MarkerStyle
from matplotlib.lines import Line2D
import matplotlib.patches as mpatches
import seaborn as sns
sns.set_theme(style="darkgrid")


seasons = "JJA"   
regions = ["Northern_Amazon","Central_Africa", "Guinea_Coast", "SE_Brazil"]

#set x limits
x_min =  0.30
x_max =  0.70
y_min =  0.12
y_max =  1.30

cat1_names = pd.read_csv('model_names_Cat1.csv')

                            #[regions[0]]
for region in regions:
    
    Model_names = cat1_names[[region]]
    df   = pd.read_csv('Cat1_SAODI_stdev_'+region+'.csv')
    df.drop(df.columns[-1], axis=1, inplace=True)
    
    a   = pd.read_csv('Cat1_Pri_stdev_'+region+'.csv')
    a   = a[['hist_pristdev']]
    b   = pd.read_csv('Cat1proj_SAODI_stdev_'+region+'.csv')
    b   = b[['proj_stdev']]
    c   = pd.read_csv('Cat1proj_Pri_stdev_'+region+'.csv')
    c   = c[['proj_pristdev']]
    df_mix = pd.concat([df, a, b, c, Model_names], axis=1)
    
    df_mix.to_csv('Cat1_ALLstdev_'+region+'.csv', index=False)

    #to Draw the SAODI and rainfall stddev scatterplot
    DRAW_SCATTERPLOT = True
    if DRAW_SCATTERPLOT:
        # Read the data from CSV file
        data = pd.read_csv("Cat1_ALLstdev_" + region +".csv")
        plt.figure(figsize=(15, 15), dpi=400)
    
        # Plot historical data
        for i, row in enumerate(data.iterrows()):
            plt.scatter(row[1]['hist_stdev'], row[1]['hist_pristdev'], c='blue', alpha=0.7)
            plt.text(row[1]['hist_stdev'], row[1]['hist_pristdev']+0.01, str(i + 1), 
                     color='blue', fontsize=15, ha='center', va='center')
    
        # Plot projected data
        for i, row in enumerate(data.iterrows()):
            plt.scatter(row[1]['proj_stdev'], row[1]['proj_pristdev'], c='red', alpha=0.7)
            plt.text(row[1]['proj_stdev'], row[1]['proj_pristdev']+0.01, str(i + 1),
                     color='red', fontsize=15, ha='center', va='center')
    
        font1 = {'family':'serif','color':'black','size':18}                    #font for x and y-labels
        font2 = {'family':'serif','color':'black','size':18}
        # Add legend outside the plot
        legend_labels = [f"{i+1}: {name}" for i, name in enumerate(data[region])]
        plt.legend(legend_labels, loc=8, bbox_to_anchor=(1, -0.35, -1, 5), ncol=3, fontsize=17)
    
    
        # Set labels and title
        plt.ylabel('rainfall standard deviation (mm/day)', fontdict=font2)
        plt.xlabel('SAODI standard deviation (\u00B0 C)', fontdict=font2)
        plt.title('Scatter plot of SAODI and rainfall anomalies standard deviation for Category 1 models in '+region,
                  fontdict=font1)
        plt.xticks(fontsize=15)
        plt.yticks(fontsize=15)
        
        # Set the x-axis limits
        plt.xlim(x_min, x_max)
        plt.ylim(y_min, y_max)
    
        # Show the plot
        plt.grid(True)
        plt.tight_layout()  # Ensures all elements are visible
        plt.show()
    
        plt.close()