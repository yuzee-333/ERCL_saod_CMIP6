#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Aug 24 13:32:17 2023

@author: yuzee

This script generates a bar plot showing the historical and projected rainfall (barplots)
and SAOD (scatterplots) standard deviations of each model in all four regions. The obs ounterparts
are also displayed with horizontal lines.
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


ave_REG_df = pd.DataFrame(columns=['region', 'b', 'b_proj']) #dataframe for 'b' and 'b_proj' average values

regions = ["Northern_Amazon", "Central_Africa", "Guinea_Coast", "SE_Brazil"]  #loop over regions

for region in regions:                                         #[:1]:
    if region == "SE_Brazil":
        y_min = -0.25
        y_max =  0.70
        text_pos = y_min + 0.02      #position of text on the plot along y-axis
    else:
        y_min =  -0.55
        y_max =   1.5
        text_pos = y_min + 0.1


    df_a = pd.read_csv('iAll2_reg_'+region+'_manuscript.csv')
    df_b = pd.read_csv('iAllproj_reg_'+region+'_manuscript.csv')
    # df_b = df_b.rename(columns={'t' : 't_proj'})  not needed anymore

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

#    plt.figure(figsize=(12, 12), frameon=True, dpi=400)

    # Define the x-axis values
    x_values = df_combined['Model_name']

    # Extract values for Obs from Obs file
    alldata = pd.read_csv('obs_Arry_reg_JJA.csv', index_col=False)
    if region == "Northern_Amazon":
        row_ind = 1
        cat1    = 14.7
    elif region == "Guinea_Coast":
        row_ind = 2
        cat1    = 6.7
    elif region == "Central_Africa":
        row_ind = 3
        cat1    = 20.7
    else:
        row_ind = 4
        cat1    = 3.7

    obs_bcoef = alldata.iloc[row_ind - 1, 1]
    obs_stde = alldata.iloc[row_ind - 1, 8]
    obs_pri_stdev = alldata.iloc[row_ind - 1, 5]
    obs_saod_stdev = alldata.iloc[row_ind - 1, 6]

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


    sorted_via_corrHist.to_csv('iREG_sorted4Cat_'+region+'.csv', index = False)


    RUNALL = True
    if(RUNALL):
        # Define the y-axis values for columns 'z' and 'e'
        hist_values = df_combined['pri_std']
        hist_stde = df_combined['std_error']
        proj_values = df_combined['pri_std_proj']
        proj_stde = df_combined['std_error_proj']

        font1 = {'family': 'serif', 'color': 'black', 'size': 15}
        

        # Set the width of the bars
        bar_width = 0.3

        # Set the positions of the bars on the x-axis
        bar_positions_hist = range(len(x_values))
        bar_positions_proj = [x + bar_width for x in bar_positions_hist]
        
        # Scatterplot positions
        scatter_positions_hist = [x + bar_width / 2 for x in bar_positions_hist]
        scatter_positions_proj = [x + bar_width / 2 for x in bar_positions_proj]

        # Scatterplot size
        scatter_size = 20

         # Create the scatterplots for 'saod_std' and 'saod_std_proj' on the second y-axis
        fig, ax1 = plt.subplots(figsize=(12,12))

        # Create the first y-axis for rainfall
        ax1.set_xlabel('Model names', fontdict=font1)
        ax1.set_ylabel('Rainfall Standard Deviation (mm/day)', fontdict=font1)
        ax1.bar(bar_positions_hist, hist_values, width=bar_width,
                label='historical', color='none', edgecolor='royalblue')
        ax1.bar(bar_positions_proj, proj_values, width=bar_width,
                label='ssp585 projections', color='none', edgecolor='red')
        ax1.axhline(0, color='black')
        ax1.set_xticks(bar_positions_hist)
        ax1.set_xticklabels(x_values, rotation=90, fontdict=font1)
        ax1.set_ylim(y_min, y_max)

        # Create the second y-axis for SAOD
        ax2 = ax1.twinx()
        ax2.scatter(scatter_positions_hist, df_combined['saod_std'], s=scatter_size,
                    color='blue', label='SAOD Historical', marker='o')
        ax2.scatter(scatter_positions_proj, df_combined['saodi_std_proj'], s=scatter_size,
                    color='red', label='SAOD SSP585 Projections', marker='o')
        # Set the y-axis label for the second y-axis
        ax2.set_ylabel('SAOD Standard Deviation (\u00b0C)', fontdict=font1)

        # Plot the horizontal line to show the threshold (i.e., Obs coefficient)
        plt.axhline(obs_saod_stdev, color="black", ls="dotted")
        plt.axhline(obs_pri_stdev, color="blue")
 #       plt.axvline(cat1, color = 'blue', ls='dotted')

        # Set the x-axis labels
        plt.xticks(bar_positions_hist, x_values, rotation=90, fontsize=10)

        
        # Set the y-axis limits
        plt.ylim(y_min, y_max)

        # Set the title of the plot
        plt.title('CMIP6 SAOD and rainfall anomaly standard deviations in ' + region,
                  fontdict=font1)

        # Create a custom legend handler
        obs_saod_line = lines.Line2D([], [], color='black', ls='dotted',
                                label='Obs SAOD stddev')
        obs_pri_line = lines.Line2D([], [], color='blue',
                                 label='Obs rainfall stddev')
        saod_hist_marker = lines.Line2D([0], [0], marker='o', color='blue', markersize=10,
                                   label='Hist SAOD stdev')
        saod_proj_marker = lines.Line2D([0], [0], marker='o', color='red', markersize=10,
                                   label='SSP585 SAOD stdev')
#        band_patch = mpatches.Patch(color='darkred', alpha=0.15, label='Obs stde')
        legend_patches = [mpatches.Patch(edgecolor='royalblue', fill=False, label='Hist rainfall stdev'),
                          mpatches.Patch(edgecolor='red', fill=False, label='SSP585 rainfall stdev'),
                          saod_hist_marker, saod_proj_marker, obs_saod_line, obs_pri_line]

        # Add the custom legend
#        plt.legend(handles=legend_patches)
        plt.legend(handles=legend_patches, loc ='upper right',
                       bbox_to_anchor=(1.3, 1))

        # Set the DPI to 400
        plt.figure(figsize=(12, 12), dpi=400)
        # Display the plot
        plt.show()
        plt.close()

        
"""
This is to create the bar plot and scatterplot without the second y-axis. Kept here for
future reference.
"""
# Create the bar plot
#       plt.bar(bar_positions_hist, hist_values, width=bar_width,
#                label='historical', color='none', edgecolor='royalblue')
#        plt.bar(bar_positions_proj, proj_values, width=bar_width,
#                label='ssp585 projections', color='none', edgecolor='red')
#        plt.axhline(0, color='black')

        # Create the scatterplots for 'saod_std' and 'saod_std_proj'
#        plt.scatter(scatter_positions_hist, df_combined['saod_std'], s=scatter_size,
#                    color='blue', label='SAOD Historical', marker='o')
#        plt.scatter(scatter_positions_proj, df_combined['saodi_std_proj'], s=scatter_size,
#                    color='red', label='SAOD SSP585 Projections', marker='o')
"""
For reference
"""
# Plot the band (for obs standard error) using fill_between
#       plt.fill_between([0, len(x_values)], obs_bcoef - obs_stde, obs_bcoef + obs_stde,
#                        color='darkred', alpha=0.15)
