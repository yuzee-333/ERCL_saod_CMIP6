#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Sept  9 04:32:17 2023

@author: yuzee

This script generates a bar plot showing the historical and projected regression values
of each model in all four regions and adds all four plots to the same panel. The obs
counterparts are also displayed with horizontal lines. This uses the 'i-variants of the
csv files generated for the manuscript [Fig. 5]
"""


import os
os.chdir('C:/Users/BRIGHT/Desktop/UZ_work/') 
dir2  = 'C:/Users/BRIGHT/Desktop/UZ_work/'

season = 'JJA'

import math
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import matplotlib.lines as lines
import numpy as np
from scipy.stats import ttest_rel

regions = ["Northern_Amazon", "Central_Africa", "Guinea_Coast", "SE_Brazil"]  # loop over regions


for i, region in enumerate(regions[:4]):


    df_a = pd.read_csv('REG_'+region+'_man.csv')
    
    df_a.loc[0, 'Model_name'] = 'All_Models'
    df_a.loc[1, 'Model_name'] = 'Good_Models'
    df_a.loc[2, 'Model_name'] = 'Bad_Models'

    if region == 'Northern_Amazon':
       # df_combined_sub = df_a.iloc[3:38, :]      #AMMME
       # df_combined_sub = df_a.iloc[3:15, :]      #BMMME
        df_combined_sub = df_a.iloc[15:38, :]      #WMMME
    elif region == "Guinea_Coast":
       # df_combined_sub = df_a.iloc[3:38, :]      #AMME
       # df_combined_sub = df_a.iloc[3:5, :]      #BMME
        df_combined_sub = df_a.iloc[5:38, :]      #WMME
    elif region == "Central_Africa":
       # df_combined_sub = df_a.iloc[3:38, :]
       # df_combined_sub = df_a.iloc[3:20, :]
        df_combined_sub = df_a.iloc[20:38, :]
    else:
       #df_combined_sub = df_a.iloc[3:38, :]       #AMME
       #df_combined_sub = df_a.iloc[3:6, :]        #BMME
        df_combined_sub = df_a.iloc[6:38, :]        #WMMME
        
    df_combined_sub
    
    # Assuming df_combined_sub is your DataFrame
    # Extract relevant columns for 'b' and 'b_proj'
    b_values = df_combined_sub['b']
    b_proj_values = df_combined_sub['b_proj']
    r_values = df_combined_sub[' r']
    r_proj_values = df_combined_sub[' r_proj']
    
    # Perform a paired t-test
    t_stat, p_value = ttest_rel(b_values, b_proj_values)
    rt_stat, rp_value = ttest_rel(r_values, r_proj_values)
    # Print the results
    print(f"b T-statistic: {t_stat}")
    print(f"b P-value: {p_value}")
    print(f"r T-statistic: {rt_stat}")
    print(f"r P-value: {rp_value}")
    
    # Check if the result is statistically significant (common threshold is 0.05)
    print('for '+region+' >>>>>>>>>>>>>>>>>')
    if p_value < 0.05:
        print("There is a statistically significant difference between 'b' and 'b_proj'.")
    else:
        print("There is no statistically significant difference between 'b' and 'b_proj'.")
        
    if rp_value < 0.05:
        print("There is a statistically significant difference between 'r' and 'r_proj'.")
    else:
        print("There is no statistically significant difference between 'r' and 'r_proj'.")
    
    
    
    