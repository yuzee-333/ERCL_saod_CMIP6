#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Aug 29 02:03:42 2023

@author: yuzee
"""

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Jul  1 01:36:17 2023

@author: yuzee

This script generates a bar plot showing the historical and projected regression values
of each model in all four regions. The obs counterparts are also displayed with
horizontal lines. This uses the 'i-variants of the csv files generated for the manuscript
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

for region in regions[:4]:                            #[:1]
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
        # Create the bar plot
        
        # Create the first 3 pairs of bars with no fill and blue edge color
        for i in range(3):
            plt.bar(bar_positions_hist[i], hist_values[i], yerr=hist_stde[i], capsize=1, 
                    width=bar_width, label='historical', color='royalblue', edgecolor='blue')
            plt.bar(bar_positions_proj[i], proj_values[i], yerr=proj_stde[i], capsize=1, width=bar_width,
                    label='ssp585 projections', color='red', edgecolor='red')
        
        # Create the rest of the bars with 'royalblue'& 'red' fill color
        for i in range(3, len(x_values)):
            plt.bar(bar_positions_hist[i], hist_values[i], 
                    width=bar_width, label='historical', yerr=hist_stde[i], capsize=1, color='royalblue')
            plt.bar(bar_positions_proj[i], proj_values[i], yerr=proj_stde[i], capsize=1, width=bar_width,
                    label='ssp585 projections', color='red')
        plt.axhline(0, color='black')
        
#               

        # Plot the horizontal line to show the threshold (i.e., Obs coefficient)
        plt.axhline(obs_bcoef, color="darkred", ls="dotted")
        plt.axvline(cat1, color = 'blue', ls='solid')
        plt.axvline(2.7, color = 'green', ls='solid')

        # Plot the band (for obs standard error) using fill_between
        plt.fill_between([0, len(x_values)], obs_bcoef - obs_stde, obs_bcoef + obs_stde,
                        color='darkred', alpha=0.15)

        font1 = {'family': 'serif', 'color': 'black', 'size': 13}
        font2 = {'family': 'serif', 'color': 'black', 'size': 12}

        # Set the x-axis labels
        plt.xticks(bar_positions_hist, x_values, rotation=90, fontsize=12)

        # Set the y-axis label
        plt.ylabel('rainfall anomaly (mm/day)')
        # plt.ylabel('\u0394 precipitation (mm/day)')    #to add the delta sign
        plt.xlabel('Model names', fontdict=font2)

        # Set the y-axis limits
        plt.ylim(y_min, y_max)

        # Set the title of the plot
        plt.title('CMIP6 historical and projected simulations of rainfall anomaly response to SAOD in ' + region,
                  fontdict=font1)

        # Create a custom legend handler
        obs_line = lines.Line2D([], [], color='darkred', ls='dotted',
                                label='Obs \u03b2 = ' + str(obs_bcoef))
    
        stde_line = lines.Line2D([], [], color='black', ls='solid',
                                label='standard error')
        band_patch = mpatches.Patch(color='darkred', alpha=0.15, label='Obs stde')
        
        legend_patches = [mpatches.Patch(color='royalblue', label='Historical \u03b2'),
                          mpatches.Patch(color='red', label='SSP585 \u03b2'),
                          #mpatches.Patch(fill=False, edgecolor='royalblue', label='Model Historical \u03b2'),
                          #mpatches.Patch(fill=False, edgecolor='red', label='Model SSP585 \u03b2'),
                          obs_line, band_patch, stde_line]

        # Add the custom legend
#        plt.legend(handles=legend_patches)
        plt.legend(handles=legend_patches, loc ='upper right',
                       bbox_to_anchor=(1.22, 1))

        # Display the plot
        plt.show()
        plt.close()


"""
Horizontal line to show threshold (i.e., Obs coefficient) plus annotation
"""
#   anTitle = 'Obs = ' + str(obs_bcoef)
#   xlist = x_values.tolist()
#   x_coordinate = xlist.index('NorESM2-MM')
#   plt.axhline(obs_bcoef, color="darkred", ls="dotted")


#   # Annotation on plot

# #  plt.text(x_coordinate, y_min - 0.05, anTitle, ha="center", va="center",
# #           color="darkred", fontdict=font2)
