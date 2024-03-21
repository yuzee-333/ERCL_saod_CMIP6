#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Sept  9 04:32:17 2023

@author: yuzee

This script generates a bar plot showing the historical and projected regression values
of each model in all four regions and adds all four plots to the same panel. The obs
counterparts are also displayed with horizontal lines. This uses the 'i-variants of the csv files generated for the manuscript
"""


import os
os.chdir('/home/yuzee/nclfolder/RESULTS/07manuscript/')
dir2  = '/home/yuzee/nclfolder/RESULTS/06projections/regression/'

season = 'JJA'

import math
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import matplotlib.lines as lines
import numpy as np

ave_REG_df = pd.DataFrame(columns=['region', 'b', 'b_proj'])  # dataframe for 'b' and 'b_proj' average values

regions = ["Northern_Amazon", "Central_Africa", "Guinea_Coast", "SE_Brazil"]  # loop over regions

font1 = {'family': 'serif', 'color': 'black', 'size': 22}
font2 = {'family': 'serif', 'color': 'black', 'size': 22}

# Create a subplot with 2 rows and 2 columns
fig, axs = plt.subplots(2, 2, figsize=(48, 38), frameon=True, dpi=200)

for i, region in enumerate(regions[:4]):
    if region == "SE_Brazil":
        y_min = -0.25
        y_max =  0.35
        text_pos = y_min + 0.02      #position of text on the plot along y-axis
    else:
        y_min =  -0.55
        y_max =   0.85
        text_pos = y_min + 0.1


    df_a = pd.read_csv('iAll2_reg_'+region+'_manuscript.csv')
    df_b = pd.read_csv('iAllproj_reg_'+region+'_manuscript.csv')
    # df_b = df_b.rename(columns={'t' : 't_proj'})  not needed anymore

    df_a.loc[0, 'Model_name'] = 'All_Models'
    df_a.loc[1, 'Model_name'] = 'Best_Models'
    df_a.loc[2, 'Model_name'] = 'Worst_Models'

    # Extract columns from df_b
    df_b_extracted = df_b[['b_proj', 'std_error_proj','pri_std_proj', 'saodi_std_proj',
    'r_squared_proj','t_proj',' r_proj', ' p_proj', 'stdev_mmproj']]

    # Concatenate extracted columns with df_a
    df_combined = pd.concat([df_a, df_b_extracted], axis=1)

    # Save combined dataframe to a new CSV file
    df_combined.to_csv('iREG_'+region+'_mod.csv', index=False)
#    df_REG = df_combined.drop(['a-intercept', 'yave', 'xave', 'npxy'], axis=1)
#    df_REG.to_csv('imodified_REG_'+region+'.csv', index=False)

    corrDir       = '/home/yuzee/nclfolder/RESULTS/05correlation_regional/'
    obs_corr_data = pd.read_csv(corrDir+'obs_Arry_correlation_JJA.csv')
    if region == "Northern_Amazon":
        row_ind = 1
    elif region == "Guinea_Coast":
        row_ind = 2
    elif region == "Central_Africa":
        row_ind = 3
    else:
        row_ind = 4
    obs_r = obs_corr_data.iloc[row_ind - 1, 1]  #read-in obs correlation data
    obs_r_abs = math.sqrt((obs_r)**2)
    print(obs_r_abs)
    # Set the figure size
    #plot first bar plot with historical and projections side by side per model

    plt.figure(figsize=(12, 8), frameon=True, dpi=400)

    # Define the x-axis values
    x_values = df_combined['Model_name']

    # Extract values for Obs from Obs file
    alldata = pd.read_csv('obs_Arry_reg_JJA.csv', index_col=False)
    if region == "Northern_Amazon":
        row_ind = 1
        cat1    = 16.7
    elif region == "Guinea_Coast":
        row_ind = 2
        cat1    = 8.7
    elif region == "Central_Africa":
        row_ind = 3
        cat1    = 22.7
    else:
        row_ind = 4
        cat1    = 5.7
    obs_bcoef = alldata.iloc[row_ind - 1, 1]
    obs_stde = alldata.iloc[row_ind - 1, 8]

    # Sorted data frames for rank plots
                                #attach new columns defined as the difference
                                #between the obs and the absolute values of the
                                #individual models(ie sqrt(model value)^2)
    df_combined['corr_dev_hist'] = df_combined[' r'].apply(lambda x:math.sqrt((obs_r - x) **2))
    df_combined['obs_dev_hist'] = df_combined['b'].apply(lambda x: math.sqrt((obs_bcoef - x) ** 2))
    df_combined['obs_dev_proj'] = df_combined['b_proj'].apply(lambda x: math.sqrt((obs_bcoef - x) ** 2))
                               #sort along the newly created columns in order of
                               #increasing difference from obs
    sorted_via_corrHist = df_combined.sort_values(by='corr_dev_hist')  #to sort the reg data according to the rankings in the correlations
#   sorted_via_corrHist = sorted_via_corrHist.drop(['a-intercept', 'prob', 'alpha',
#                                                   'yave', 'xave', 'npxy'], axis = 1)

#   sorted_histdata = df_combined.sort_values(by='obs_dev_hist', ascending=False)
#   sorted_projdata = df_combined.sort_values(by='obs_dev_proj', ascending=False)

    print("sorted data files created")


    sorted_via_corrHist.to_csv('iREG_sorted4Cat_'+region+'.csv', index = False)


    RUNALL = True
    if(RUNALL):
        # Define the y-axis values for columns 'z' and 'e'
        hist_values = df_combined['b']
        hist_stde = df_combined['std_error']
        proj_values = df_combined['b_proj']
        proj_stde = df_combined['std_error_proj']

        # Set the width of the bars
        bar_width = 0.45

        # Set the positions of the bars on the x-axis
        bar_positions_hist = range(len(x_values))
        bar_positions_proj = [x + bar_width for x in bar_positions_hist]

        # Inside the loop, replace plt.figure() with axs[i // 2, i % 2].bar() for creating bar plots.

        # Create the bar plot inside the subplot
        axs[i // 2, i % 2].bar(bar_positions_hist, hist_values, yerr=hist_stde, capsize=2,
                               width=bar_width, label='historical', color='royalblue', edgecolor='blue')
        axs[i // 2, i % 2].bar(bar_positions_proj, proj_values, yerr=proj_stde, capsize=2, width=bar_width,
                               label='ssp585 projections', color='red', edgecolor='red')

        # Customize the plot for each subplot
        axs[i // 2, i % 2].axhline(0, color='black')
        axs[i // 2, i % 2].axhline(obs_bcoef, color="darkred", ls="dotted", linewidth = 3.0)
        axs[i // 2, i % 2].axvline(cat1, color='blue', ls='solid', linewidth = 4.0)
        axs[i // 2, i % 2].axvline(2.7, color='green', ls='solid', linewidth = 4.0)
        axs[i // 2, i % 2].set_xticks(bar_positions_hist)
        axs[i // 2, i % 2].set_xticklabels(x_values, rotation=90, fontsize=16)
        axs[i // 2, i % 2].set_ylim(y_min, y_max)
        axs[i // 2, i % 2].set_ylabel('rainfall anomaly (mm/day)', fontdict=font2)
        axs[i // 2, i % 2].set_xlabel('Model names', fontdict=font2)
        axs[i // 2, i % 2].set_title('CMIP6 historical and projected simulations of rainfall anomaly response to SAOD in ' + region,
                                      fontdict=font1)

        ymax_i = y_max - 0.1
        ymin_i = y_min + 0.05


        if region == 'Northern_Amazon':
            sub = '[a]'
        elif region == 'Central_Africa':
            sub = '[b]'
        elif region == 'Guinea_Coast':
            sub = '[c]'
        else:
            sub = '[d]'
            ymax_i = y_max - 0.05
            ymin_i = y_min + 0.02


        axs[i // 2, i % 2].text(0, ymax_i,
        sub, fontsize=20)

        axs[i // 2, i % 2].text(30, ymin_i, region , fontsize=27)



        # Create a custom legend for each subplot
        obs_line = lines.Line2D([], [], color='darkred', ls='dotted',
                                label='Obs \u03b2 = ' + str(obs_bcoef))
        band_patch = mpatches.Patch(color='darkred', alpha=0.15, label='Obs stde')
        legend_patches = [mpatches.Patch(color='royalblue', label='Historical \u03b2'),
                          mpatches.Patch(color='red', label='SSP585 \u03b2'),
                          obs_line]

        axs[i // 2, i % 2].legend(handles=legend_patches, loc='upper right',
                                 bbox_to_anchor=(1.15, 1), fontsize=20)

# Ensure proper spacing and display the subplots
plt.tight_layout()
plt.show()
