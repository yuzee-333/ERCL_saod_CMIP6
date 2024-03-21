#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Aug 24 18:43:18 2023

@author: yuzee

This script generates a scatterplot of regression (ie b values) against rainfall
standard deviations for the historical (blue) and projected (red) scenarios in all four regions.
The obs counterparts are delineated using vertical and horizontal lines.
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
from scipy.stats import pearsonr


ave_REG_df = pd.DataFrame(columns=['region', 'b', 'b_proj']) #dataframe for 'b' and 'b_proj' average values
regions = ["Northern_Amazon", "Central_Africa", "Guinea_Coast", "SE_Brazil"]  #loop over regions

for region in regions:                  #[:1]


    data = pd.read_csv('Model_names_by_Cat.csv')
    df_a = pd.read_csv('iAll2_reg_'+region+'_manuscript.csv')
    df_b = pd.read_csv('iAllproj_reg_'+region+'_manuscript.csv')

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

    plt.figure(figsize=(12, 6), frameon=True, dpi=400)

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

                          #the following are required to specify the Obs values
    obs_bcoef = alldata.iloc[row_ind - 1, 1]
    obs_stde = alldata.iloc[row_ind - 1, 8]
    obs_pri_stdev = alldata.iloc[row_ind - 1, 5]
    obs_saod_stdev = alldata.iloc[row_ind - 1, 6]


    #to Draw the SAODI and rainfall stddev scatterplot
    DRAW_SCATTERPLOT = True
    if DRAW_SCATTERPLOT:
        # Read the data from CSV file

        plt.figure(figsize=(25, 20), dpi=400)

        # Plot historical data
        for i, row in enumerate(df_combined.iterrows()):
            plt.scatter(row[1]['b'], row[1]['pri_std'], c='blue', alpha=0.7)
            plt.text(row[1]['b'], row[1]['pri_std']+0.02, str(i + 1),
                     color='blue', fontsize=15, ha='center', va='center')

        # Plot projected data
        for i, row in enumerate(df_combined.iterrows()):
            plt.scatter(row[1]['b_proj'], row[1]['pri_std_proj'], c='red', alpha=0.7)
            plt.text(row[1]['b_proj'], row[1]['pri_std_proj']+0.01, str(i + 1),
                     color='red', fontsize=15, ha='center', va='center')

        font1 = {'family':'serif','color':'black','size':24}                    #font for x and y-labels
        font2 = {'family':'serif','color':'black','size':24}
        plt.axvline(0, color='black')

        #for Obs
        plt.axvline(obs_bcoef, color="skyblue", ls="dashed")
        plt.axhline(obs_pri_stdev, color="skyblue", ls="dashed")
        plt.plot(obs_bcoef,obs_pri_stdev, marker='o',mfc ='black',color='black', ms=15) #obs marker

        # Add legend outside the plot
        legend_labels = [f"{i+1}: {name}" for i, name in enumerate(data[region])]
        plt.legend(legend_labels,loc=8, bbox_to_anchor=(1.0, -0.4, -1, 5),
                   ncol=5, fontsize=20)

        # Set labels and title
        plt.xlabel('Regression \u03b2 (mm/day)', fontdict=font2)
        plt.ylabel('Rainfall standard deviation (mm/day)', fontdict=font2)
        plt.title('Model \u03B2 values against rainfall anomaly standard deviations in '+region,
                  fontdict=font1)
        plt.xticks(fontsize=20)
        plt.yticks(fontsize=20)

        ycor_pos   = 1.25
        xcor_pos   = -0.35

        # Adding text with the beta symbol using LaTeX notation
        if region == "Northern_Amazon":
            y_position = obs_pri_stdev-0.3
            x_position = obs_bcoef-0.01
            yr_position = obs_pri_stdev+0.02
            xr_position = obs_bcoef+0.24
            ycor_position = ycor_pos
            xcor_position = xcor_pos
        elif region == "Guinea_Coast":
            y_position = obs_pri_stdev-0.28
            x_position = obs_bcoef-0.01
            yr_position = obs_pri_stdev+0.02
            xr_position = obs_bcoef+0.2
            ycor_position = ycor_pos
            xcor_position = xcor_pos
        elif region == "Central_Africa":
            y_position = obs_pri_stdev+0.8
            x_position = obs_bcoef-0.01
            yr_position = obs_pri_stdev+0.02
            xr_position = obs_bcoef+0.38
            ycor_position = ycor_pos
            xcor_position = xcor_pos
        else:
            y_position = obs_pri_stdev-0.2
            x_position = obs_bcoef-0.01
            yr_position = obs_pri_stdev+0.02
            xr_position = obs_bcoef+0.35
            ycor_position = 0.1
            xcor_position = 0.21


#        plt.text(x_position, y_position,
#                 '\u03b2 obs ='+str(obs_bcoef), fontsize=16)
#        plt.text(xr_position, yr_position,' rstd ='+str(obs_pri_stdev),
#                 fontsize=16, rotation=90, va='center')

        # Calculate the correlation coefficient and p-value for historical data
        corr_coefficient_hist, p_value_hist = pearsonr(df_combined['pri_std'], df_combined['b'])

        # Calculate the correlation coefficient and p-value for projected data
        corr_coefficient_proj, p_value_proj = pearsonr(df_combined['pri_std_proj'], df_combined['b_proj'])

        # Display the correlation coefficient and p-value on the plot
        plt.text(x_position, y_position,
                 f'\u03b2 obs = {obs_bcoef:.2f}',
                 fontsize=18, rotation=90, va='center')
        plt.text(xr_position, yr_position,
                 f'rstd = {obs_pri_stdev: .2f}',
                 fontsize=18) #, rotation=90, va='center')
        plt.text(xcor_position, ycor_position,                  #plotting the hist r and p values in blue color
                 f'r (Historical) = {corr_coefficient_hist:.2f},\n'
                 f'p-val (Historical) = {p_value_hist:.3f}',
                 fontsize=18, color='blue')
        if region == 'SE_Brazil':
            q_adjust = 0.03
            x_min = -0.2
            x_max =  0.3
            y_min =  0.07
            y_max =  0.7
        else:
            q_adjust = 0.07
            x_min =  -0.4
            x_max =   0.65
            y_min =  0.1
            y_max =  1.5

        plt.text(xcor_position, ycor_position+q_adjust,          #plotting the proj r and p values in red color
                 f'r (ssp585) = {corr_coefficient_proj:.2f},\n'
                 f'p-val (ssp585) = {p_value_proj:.3f}',
                 fontsize=18, color='red')


        """
        #Calculate the regression lines for historical and projected data
       """
        # Historical (blue)
        hist_y = df_combined['pri_std']
        hist_x = df_combined['b']
        hist_slope, hist_intercept = np.polyfit(hist_x, hist_y, 1)

        # Projected (red)
        proj_y = df_combined['pri_std_proj']
        proj_x = df_combined['b_proj']
        proj_slope, proj_intercept = np.polyfit(proj_x, proj_y, 1)
        
        if region == "Central_Africa":
            # Display the regression lines on the plot
            plt.plot(hist_x, hist_slope * hist_x + hist_intercept, color='green', ls = "dashed", label=f'Regression Line (Hist) y = {hist_slope:.2f}x + {hist_intercept:.2f}')
            plt.plot(proj_x, proj_slope * proj_x + proj_intercept, color='red', label=f'Regression Line (Proj) y = {proj_slope:.2f}x + {proj_intercept:.2f}')
        
            # Calculate z-scores for both 'b' and 'pri_std'
            z_scores = (df_combined['pri_std'] - df_combined['pri_std'].mean()) / df_combined['pri_std'].std()

            
            # Identify outliers based on combined z-scores
            outliers = z_scores.nlargest(2)
            
            # Filter out the outliers from the historical data for regression calculation
            hist_y_filtered = df_combined.loc[~df_combined.index.isin(outliers.index), 'pri_std']
            hist_x_filtered = df_combined.loc[~df_combined.index.isin(outliers.index), 'b']
            
            # Calculate the regression line for the filtered historical data
            hist_slope_filtered, hist_intercept_filtered = np.polyfit(hist_x_filtered, hist_y_filtered, 1)
            
            # Plot the new regression line (dashed) for historical data excluding outliers
            plt.plot(hist_x_filtered, hist_slope_filtered * hist_x_filtered + hist_intercept_filtered, 
                     color='blue') #ls="dotted")                #linestyle='--',
                     #label=f'Regression Line (Hist - No Outliers) y = {hist_slope_filtered:.2f}x + {hist_intercept_filtered:.2f}')
        else:
            # Display the regression lines on the plot
            plt.plot(hist_x, hist_slope * hist_x + hist_intercept, color='blue', label=f'Regression Line (Hist) y = {hist_slope:.2f}x + {hist_intercept:.2f}')
            plt.plot(proj_x, proj_slope * proj_x + proj_intercept, color='red', label=f'Regression Line (Proj) y = {proj_slope:.2f}x + {proj_intercept:.2f}')

            


        # Set the x-axis limits
        plt.xlim(x_min, x_max)
        plt.ylim(y_min, y_max)

        # Show the plot
        plt.grid(False)
        plt.tight_layout()  # Ensures all elements are visible
        plt.show()

        plt.close()


"""
Tried to create a double legend here. didn't work
"""
# obs_marker = lines.Line2D([0], [0], marker='o', color='black', markersize=10, label='Observatioons')
# obs_line   = lines.Line2D([], [], color='darkred', ls='dashed',label='Obs threshold')
# legend_patches = [obs_marker, obs_line]

# # Plot something to create a base plot
# plt.plot(range(len(legend_labels)), [0] * len(legend_labels), 'w')

# legend1 = plt.legend(legend_labels,loc=8, bbox_to_anchor=(1.0, -0.25, -1, 5),
#                      ncol=5, fontsize=20)
# plt.gca().add_artist(legend1)

# legend2  = plt.legend(handles=legend_patches, loc='upper right',
#                       bbox_to_anchor=(1.25,1))
# plt.gca().add_artist(legend2)

#       bbox_to_anchor=(1, -0.35, -1, 5)
"""
Removing outliers from Central Africa plot using combined z-scores. Didn't really work
"""
#            z_scores_b = (df_combined['b'] - df_combined['b'].mean()) / df_combined['b'].std()
#           z_scores_pri_std = (df_combined['pri_std'] - df_combined['pri_std'].mean()) / df_combined['pri_std'].std()
            
            # Calculate a combined z-score (e.g., sum of z-scores)
#            combined_z_scores = z_scores_b + z_scores_pri_std
