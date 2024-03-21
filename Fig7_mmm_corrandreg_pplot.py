# -*- coding: utf-8 -*-
"""
Created on Sat Feb 17 20:54:09 2024

@author: yuzee
"""


"""

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

regions = ["Northern_Amazon", "Central_Africa", "Guinea_Coast", "SE_Brazil"]  # loop over regions

font1 = {'family': 'serif', 'color': 'black', 'size': 30}
font2 = {'family': 'serif', 'color': 'black', 'size': 22}

# Create a subplot with 2 rows and 2 columns
fig, axs = plt.subplots(4, 2, figsize=(38, 50), frameon=True, dpi=400) #Width, height

for i, region in enumerate(regions[:4]):
    if region == "SE_Brazil":
        y_min = -0.50
        y_max =  0.70
        text_pos = y_min + 0.02      #position of text on the plot along y-axis
    else:
        y_min =  -0.50
        y_max =   0.7
        text_pos = y_min + 0.1


    df_a = pd.read_csv('REG_'+region+'_man.csv')
    
    df_a.loc[0, 'Model_name'] = 'All_Models'
    df_a.loc[1, 'Model_name'] = 'Good_Models'
    df_a.loc[2, 'Model_name'] = 'Bad_Models'

    
    df_combined_sub = df_a.iloc[:3, :]
    df_combined_sub

    # Save combined dataframe to a new CSV file
    df_combined_sub.to_csv('iREG_'+region+'_mod.csv', index=False)

   
    obs_corr_data = pd.read_csv('obs_Arry_correlation_JJA.csv')
    if region == "Northern_Amazon":
        row_ind = 2
    elif region == "Guinea_Coast":
        row_ind = 1
    elif region == "Central_Africa":
        row_ind = 3
    else:
        row_ind = 4
    obs_r = obs_corr_data.iloc[row_ind - 1, 1]  #read-in obs correlation data
    obs_r_abs = math.sqrt((obs_r)**2)
    print(obs_r_abs)
    # Set the figure size
    #plot first bar plot with historical and projections side by side per model

    plt.figure(figsize=(8, 8), frameon=True, dpi=400)

    # Define the x-axis values
    x_values = df_combined_sub['Model_name']

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


    RUNALL = True
    if(RUNALL):
        # Define the y-axis values for columns 'z' and 'e'
        hist_values = df_combined_sub['b']
        hist_stde = df_combined_sub['bstdev_mm']
        proj_values = df_combined_sub['b_proj']
        proj_stde = df_combined_sub['bproj_stdev']

        # Set the width of the bars
        bar_width = 0.3

        # Set the positions of the bars on the x-axis
        bar_positions_hist = range(len(x_values))
        bar_positions_proj = [x + bar_width for x in bar_positions_hist]

        # Inside the loop, replace plt.figure() with axs[i // 2, i % 2].bar() for creating bar plots.

        # Create the bar plot inside the subplot
        axs[i, 0].bar(bar_positions_hist, hist_values, yerr=[hist_stde[j] if j < 3 else 0 for j in range(len(hist_stde))], capsize=2,
                               width=bar_width, label='historical', color='royalblue', edgecolor='blue')
        axs[i, 0].bar(bar_positions_proj, proj_values, yerr=[proj_stde[j] if j < 3 else 0 for j in range(len(proj_stde))], capsize=2, width=bar_width,
                               label='ssp585 projections', color='red', edgecolor='red')

        # Customize the plot for each subplot
        axs[i, 0].axhline(0, color='black')
        axs[i, 0].axhline(obs_bcoef, color="darkred", ls="dotted", linewidth = 3.0)
        
        # Plot the band (for obs standard error) using fill_between
#        axs[i, 0].fill_between([0, len(x_values)], obs_bcoef - obs_stde, obs_bcoef + obs_stde,

        axs[i, 0].set_xticks(bar_positions_hist)
        axs[i, 0].set_xticklabels(x_values, rotation=0, fontsize=40)
        axs[i, 0].set_ylim(y_min, y_max)
        axs[i, 0].set_ylabel('rainfall anomaly (mm/day)', fontsize=35)
        axs[i, 0].set_xlabel('CMIP6_Ensemble_Mean ', fontdict=font2)
        axs[i, 0].tick_params(axis='y', labelsize=25)  # Adjust fontsize as needed
   

#        axs[i // 2, i % 2].set_title('CMIP6 historical and projected simulations of rainfall anomaly response to SAOD in ' + region,
#                                      fontdict=font1)

        ymax_i = 0.6
        ymin_i = -0.5


        if region == 'Northern_Amazon':
            sub = '[a]'
        elif region == 'Central_Africa':
            sub = '[b]'
        elif region == 'Guinea_Coast':
            sub = '[c]'
        else:
            sub = '[d]'
            ymax_i = 0.6
            ymin_i = -0.5 + 0.02


        axs[i, 0].text(-0.2, ymax_i, sub, fontsize=40)

        axs[i, 0].text(0, ymax_i, region , fontsize=40)



        # Create a custom legend for each subplot
        obs_line = lines.Line2D([], [], color='darkred', ls='dotted',
                                label=f'Obs \u03b2 = {obs_bcoef:.2f}') #ef:.2f)
#        band_patch = mpatches.Patch(color='darkred', alpha=0.15, label='Obs stde')
        legend_patches = [mpatches.Patch(color='royalblue', label='Historical \u03b2'),
                          mpatches.Patch(color='red', label='SSP585 \u03b2'),
                          obs_line]

        axs[i, 0].legend(handles=legend_patches, loc='upper right',
                                 bbox_to_anchor=(1.0, 1), fontsize=25)
        
        
        RUNALL2 = True
        if(RUNALL2):
            # Define the y-axis values for columns 'z' and 'e'
            hist_values = df_combined_sub[' r']
            hist_stde = df_combined_sub['rstdev_mm']
            proj_values = df_combined_sub[' r_proj']
            proj_stde = df_combined_sub['rproj_stdev']

            # Set the width of the bars
            bar_width = 0.3

            # Set the positions of the bars on the x-axis
            bar_positions_hist = range(len(x_values))
            bar_positions_proj = [x + bar_width for x in bar_positions_hist]

            # Inside the loop, replace plt.figure() with axs[i // 2, i % 2].bar() for creating bar plots.

            # Create the bar plot inside the subplot
            axs[i, 1].bar(bar_positions_hist, hist_values, yerr=[hist_stde[j] if j < 3 else 0 for j in range(len(hist_stde))], capsize=2,
                                   width=bar_width, label='historical', color='royalblue', edgecolor='blue')
            axs[i, 1].bar(bar_positions_proj, proj_values, yerr=[proj_stde[j] if j < 3 else 0 for j in range(len(proj_stde))], capsize=2, width=bar_width,
                                   label='ssp585 projections', color='red', edgecolor='red')

            # Customize the plot for each subplot
            axs[i, 1].axhline(0, color='black')
            axs[i, 1].axhline(obs_r, color="darkred", ls="dotted", linewidth = 3.0)
            
            # Plot the band (for obs standard error) using fill_between
    #        axs[i, 0].fill_between([0, len(x_values)], obs_bcoef - obs_stde, obs_bcoef + obs_stde,

            axs[i, 1].set_xticks(bar_positions_hist)
            axs[i, 1].set_xticklabels(x_values, rotation=0, fontsize=40)
            axs[i, 1].set_ylim(-0.5, 0.7)
            axs[i, 1].set_ylabel('correlation', fontsize=35)
            axs[i, 1].set_xlabel('CMIP6_Ensemble_Mean ', fontdict=font2)
            axs[i, 1].tick_params(axis='y', labelsize=25)  # Adjust fontsize as needed
    #        axs[i // 2, i % 2].set_title('CMIP6 historical and projected simulations of rainfall anomaly response to SAOD in ' + region,
    #                                      fontdict=font1)

            max_y = 0.6
            min_y =-0.5


            if region == 'Northern_Amazon':
                sub = '[e]'
            elif region == 'Central_Africa':
                sub = '[f]'
            elif region == 'Guinea_Coast':
                sub = '[g]'
            else:
                sub = '[h]'
                max_y= max_y 
                min_y= min_y + 0.02


            axs[i, 1].text(-0.2, max_y, sub, fontsize=40)

            axs[i, 1].text(0, max_y, region , fontsize=40)



            # Create a custom legend for each subplot
            obs_line = lines.Line2D([], [], color='darkred', ls='dotted',
                                    label=f'Obs r={ obs_r:.2f}')
 #           band_patch = mpatches.Patch(color='darkred', alpha=0.15, label='Obs stde')
            legend_patches = [mpatches.Patch(color='royalblue', label='Historical r'),
                              mpatches.Patch(color='red', label='SSP585 r'),
                              obs_line]

            axs[i, 1].legend(handles=legend_patches, loc='upper right',
                                     bbox_to_anchor=(1.3, 1), fontsize=25)   #Horiz, Vert

# Ensure proper spacing and display the subplots
plt.tight_layout()
plt.show()
