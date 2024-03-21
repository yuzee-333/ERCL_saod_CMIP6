#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jul 31 20:29:19 2023

@author: yuzee
"""

import os
os.chdir('/home/yuzee/nclfolder/RESULTS/04regression_regional/')

                #for reading the csv files
import csv      
import math
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import matplotlib.lines as lines
import numpy as np

mmm_REG_df = pd.read_csv('mmmALL_regV2Hist.csv')

#ave_REG_df.to_csv('ave_Cat1_allREG.csv', index = False)

PLOT_MMM_REG = True
if PLOT_MMM_REG:
    # Set the width of the bars
    plt.figure(figsize=(12, 6), frameon=True, dpi=400)
    bar_width = 0.2
    
    # Set the positions of the bars on the x-axis
    r1 = range(len(mmm_REG_df))
    r2 = [x + bar_width for x in r1]
    #r3 = [y + bar_width for y in r2]
    
    # Create the bar plot
    # plt.bar(r1, mmm_REG_df_REG_df['b_hist'], color = 'grey', yerr=ave_REG_df['std_error'], 
    #         capsize = 2, ecolor = 'blue', width=bar_width, label='observation')
    plt.bar(r1, mmm_REG_df['b_hist'], color='royalblue', width=bar_width, label='historical')
    plt.bar(r2, mmm_REG_df['b_proj'], color='red', width=bar_width, label='SSP585 projection')
    
    
    # Set the x-axis labels and ticks
    plt.xlabel('Region')
    plt.xticks([r + bar_width/2 for r in r1], mmm_REG_df['Model_name'], fontsize = 15)
    plt.axhline(0, color='black')
    
    # Set the y-axis label
    plt.ylabel('rainfall anomaly (mm/day)')
    
    # Set the plot title
    plt.title('Ensemble mean regression of rainfall anomaly on SAODI of all 44 models')
    
    # Add a legend
    plt.legend()
    
    # Show the plot
    plt.show()
    plt.close()