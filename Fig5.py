#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Sep  9 03:35:33 2023

@author: yuzee

for generating Fig.5 in ERCL Manuscript
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

# Create a 2x2 grid of subplots
#fig, axs = plt.subplots(2, 2, figsize=(56, 46), dpi=400)
#fig, axs = plt.subplots(2, 2, figsize=(46, 38), dpi=200)
fig, axs = plt.subplots(2, 2, figsize=(52, 40), dpi=100)

# Iterate over regions
for i, region in enumerate(regions):

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
    axs[i // 2, i % 2].set_title(region)

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
        # Plot historical data
        for j, row in enumerate(df_combined.iterrows()):
            axs[i // 2, i % 2].scatter(row[1]['b'], row[1]['pri_std'], c='blue', alpha=0.7)
            axs[i // 2, i % 2].text(row[1]['b'], row[1]['pri_std']+0.02, str(j + 1),
                     color='blue', fontsize=15, ha='center', va='center')

        # Plot projected data
        for j, row in enumerate(df_combined.iterrows()):
            axs[i // 2, i % 2].scatter(row[1]['b_proj'], row[1]['pri_std_proj'], c='red', alpha=0.7)
            axs[i // 2, i % 2].text(row[1]['b_proj'], row[1]['pri_std_proj']+0.01, str(j + 1),
                     color='red', fontsize=15, ha='center', va='center')

        font1 = {'family':'serif','color':'black','size':28}                    #font for x and y-labels
        font2 = {'family':'serif','color':'black','size':35}
        axs[i // 2, i % 2].axvline(0, color='black')

        #for Obs markers
        axs[i // 2, i % 2].axvline(obs_bcoef, color="skyblue", ls="dashed")
        axs[i // 2, i % 2].axhline(obs_pri_stdev, color="skyblue", ls="dashed")
        axs[i // 2, i % 2].plot(obs_bcoef,obs_pri_stdev, marker='o',mfc ='black',color='black', ms=15) #obs marker

        # Add legend outside the plot
        legend_labels = [f"{i+1}: {name}" for i, name in enumerate(data[region])]
        axs[i // 2, i % 2].legend(legend_labels,loc=8, bbox_to_anchor=(1.0, -0.4, -1, 5),
                   ncol=5, fontsize=26)

        # Set labels and title
        axs[i // 2, i % 2].set_xlabel('Regression \u03b2 (mm/day)', fontdict=font2)
        axs[i // 2, i % 2].set_ylabel('Rainfall standard deviation (mm/day)', fontdict=font2)
        axs[i // 2, i % 2].set_title('Model \u03B2 values against rainfall anomaly standard deviations in '+region,
                  fontdict=font1)
        axs[i // 2, i % 2].tick_params(axis='both', which='major', labelsize=20)

        ycor_pos   = 1.17
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
            ycor_position = 0.15
            xcor_position = 0.18

        if region == "Central_Africa":
            # Calculate the regression lines for historical and projected data
            hist_y = df_combined['pri_std']
            hist_x = df_combined['b']
            hist_slope_n, hist_intercept_n = np.polyfit(hist_x, hist_y, 1)

            proj_y = df_combined['pri_std_proj']
            proj_x = df_combined['b_proj']
            proj_slope, proj_intercept = np.polyfit(proj_x, proj_y, 1)

            # Calculate z-scores for both 'b' and 'pri_std'
            z_scores = (df_combined['pri_std'] - df_combined['pri_std'].mean()) / df_combined['pri_std'].std()

            # Identify outliers based on combined z-scores
            outliers = z_scores.nlargest(2)

            # Filter out the outliers from the historical data for regression calculation
            hist_y_filtered = df_combined.loc[~df_combined.index.isin(outliers.index), 'pri_std']
            hist_x_filtered = df_combined.loc[~df_combined.index.isin(outliers.index), 'b']

#           corr_coefficient_hist, p_value_hist = pearsonr(hist_y_filtered, hist_x_filtered)
            corr_coefficient_hist, p_value_hist = pearsonr(hist_y, hist_x)
            corr_coefficient_proj, p_value_proj = pearsonr(df_combined['pri_std_proj'], df_combined['b_proj'])

            # Calculate the regression line for the filtered historical data
#            hist_slope, hist_intercept = np.polyfit(hist_x_filtered, hist_y_filtered, 1)
            hist_slope, hist_intercept = np.polyfit(hist_x, hist_y, 1)

            # Plot the new regression line (dashed) for historical data excluding outliers
 #          axs[i // 2, i % 2].plot(hist_x_filtered, hist_slope * hist_x_filtered + hist_intercept,
 #                   color='blue', linestyle='--',
 #                   label=f'Regression Line (Hist - no outliers) y = {hist_slope:.2f}x + {hist_intercept:.2f}')
            axs[i // 2, i % 2].plot(hist_x, hist_slope_n * hist_x + hist_intercept_n, color='blue',
                     label=f'Regression Line (Hist - with outliers) y = {hist_slope_n:.2f}x + {hist_intercept_n:.2f}')
            axs[i // 2, i % 2].plot(proj_x, proj_slope * proj_x + proj_intercept, color='red',
                     label=f'Regression Line (Proj) y = {proj_slope:.2f}x + {proj_intercept:.2f}')
        else:
            # Calculate the regression lines for historical and projected data
            hist_y = df_combined['pri_std']
            hist_x = df_combined['b']
            hist_slope, hist_intercept = np.polyfit(hist_x, hist_y, 1)

            proj_y = df_combined['pri_std_proj']
            proj_x = df_combined['b_proj']
            proj_slope, proj_intercept = np.polyfit(proj_x, proj_y, 1)

            # Calculate the correlation coefficient and p-value for historical data
            corr_coefficient_hist, p_value_hist = pearsonr(df_combined['pri_std'], df_combined['b'])

            # Calculate the correlation coefficient and p-value for projected data
            corr_coefficient_proj, p_value_proj = pearsonr(df_combined['pri_std_proj'], df_combined['b_proj'])

            # Display the regression lines on the plot
            axs[i // 2, i % 2].plot(hist_x, hist_slope * hist_x + hist_intercept, color='blue',
                     label=f'Regression Line (Hist) y = {hist_slope:.2f}x + {hist_intercept:.2f}')
            axs[i // 2, i % 2].plot(proj_x, proj_slope * proj_x + proj_intercept, color='red',
                     label=f'Regression Line (Proj) y = {proj_slope:.2f}x + {proj_intercept:.2f}')

        # Display the correlation coefficient and p-value on the plot
        axs[i // 2, i % 2].text(x_position, y_position, f'\u03b2 obs = {obs_bcoef:.2f}', fontsize=20, rotation=90, va='center')
        axs[i // 2, i % 2].text(xr_position, yr_position, f'rstd = {obs_pri_stdev: .2f}', fontsize=20)
        axs[i // 2, i % 2].text(xcor_position, ycor_position, f'r (Historical) = {corr_coefficient_hist:.2f},\n p-val (Historical) = {p_value_hist:.3f},\n slope = {hist_slope:.3f} /\u03C3',
         fontsize=30, color='blue')

        if region == 'SE_Brazil':
            q_adjust = 0.07
            x_min = -0.2
            x_max =  0.3
            y_min =  0.07
            y_max =  0.7
        else:
            q_adjust = 0.15
            x_min =  -0.4
            x_max =   0.65
            y_min =  0.1
            y_max =  1.5

        axs[i // 2, i % 2].text(xcor_position, ycor_position+q_adjust, f'r (ssp585) = {corr_coefficient_proj:.2f},\n p-val (ssp585) = {p_value_proj:.3f},\n slope = {proj_slope:.3f} / \u03C3 ',
         fontsize=30, color='red')


        ymax_i = y_max - 0.05
        xmin_i = x_min + 0.05

        if region == 'Northern_Amazon':
            sub = '[a]'
        elif region == 'Central_Africa':
            sub = '[b]'
        elif region == 'Guinea_Coast':
            sub = '[c]'
        else:
            sub = '[d]'
            ymax_i = y_max - 0.05
            xmin_i = x_min + 0.02


        axs[i // 2, i % 2].text(xmin_i, ymax_i,
        sub, fontsize=20)

    # Set the x-axis limits
    axs[i // 2, i % 2].set_xlim(x_min, x_max)
    axs[i // 2, i % 2].set_ylim(y_min, y_max)

    # Show the plot
    axs[i // 2, i % 2].grid(False)

plt.tight_layout()

# Show all subplots
plt.show()
