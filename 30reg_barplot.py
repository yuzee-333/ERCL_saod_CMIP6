#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jun 27 00:22:57 2023

@author: yuzee
"""
import os
os.chdir('/home/yuzee/nclfolder/RESULTS/04regression_regional/')

import pandas as pd
import matplotlib.pyplot as plt


regions = ["Northern_Amazon", "Central_Africa", "Guinea_Coast", "SE_Brazil"]  #loop over regions

for region in regions:
    if region == "SE_Brazil":
        y_min = -0.17
        y_max =  0.17
        text_pos = y_max - 0.02      #position of text on the plot along y-axis 
    else:
        y_min =  -0.55
        y_max =   0.85
        text_pos = y_max - 0.1
        
        
    figure = plt.figure
    figure("Reg_"+region+".png", dpi = 400,frameon=True)
    regdata = pd.read_csv('All2_reg_'+region+'_modified.csv', index_col=False)
    alldata = pd.read_csv('All_reg_'+region+'_modified.csv', index_col=False)
    obs_bcoef = alldata.iloc[0,1]
    
    # Extract the required columns
    model_names = regdata['Model_name']
    b_values = regdata['b']
    std_errors = regdata['std_error']
    
    # Bar plot
    # Bar plot with color customization for first two bars
    colors = ['green', 'pink'] + ['royalblue'] * (len(model_names) - 2)  # Change color values here
    plt.bar(model_names, b_values, yerr=std_errors, capsize=1, width = 0.8,
            color = colors)
    plt.axhline(0, color = 'black', ls='solid')
    
    #Horizontal line to show threshold (ie Obs coeffiecient)
    anTitle   = 'Obs = '+str(obs_bcoef)
    plt.axhline(obs_bcoef, color="darkred", ls="dotted") 
    
    font1 = {'family':'serif','color':'blue','size':7}  
    font2 = {'family':'serif','color':'black','size':7}  
    plt.xlabel('CMIP6 Models', fontdict=font2)
    plt.ylabel('regression coefficient (b)', fontdict=font2 )
    plt.title('Bar plot of Saodi and Precip regression coefficient in '+region+' (JJA:1950-2014)',
              fontdict=font1)
    plt.text(plt.xlim()[1], text_pos, anTitle, ha="right",
             va="bottom", color="darkred", fontdict=font2)
    plt.xticks(rotation=90, fontsize=5)  # Rotate x-axis labels for better visibility
    plt.ylim(y_min, y_max)
    
    # Displaying the std_error values on each bar
    #for i, (model_name, b_value, std_error) in enumerate(zip(model_names, b_values, std_errors)):
       # plt.text(i, b_value + 0.01, f'{std_error:.3f}', ha='center', va='bottom')
    
    # Show the plot
    plt.tight_layout()
    plt.show()






