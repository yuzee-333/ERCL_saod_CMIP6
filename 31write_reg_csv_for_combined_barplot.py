#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Jul  1 01:36:17 2023

@author: yuzee
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

for region in regions:
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
    df_combined.to_csv('REG_'+region+'_manuscript.csv', index=False)
 #   df_REG = df_combined.drop(['a-intercept', 'yave', 'xave', 'npxy'], axis=1)
 #   df_REG.to_csv('manuscript_REG_'+region+'.csv', index=False)

    corrDir       = '/home/yuzee/nclfolder/RESULTS/05correlation_regional/'
    obs_corr_data = pd.read_csv(corrDir+'obs_Arry_correlation_JJA.csv')
    if region     == "Northern_Amazon":
        row_ind   = 1
    elif region   == "Guinea_Coast":
        row_ind   = 2
    elif region   == "Central_Africa":
        row_ind   = 3
    else:
        row_ind   = 4
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
    elif region == "Guinea_Coast":
        row_ind = 2
    elif region == "Central_Africa":
        row_ind = 3
    else:
        row_ind = 4
    obs_bcoef = alldata.iloc[row_ind - 1, 1]
    obs_stde = alldata.iloc[row_ind - 1, 8]

    # Sorted data frames for rank plots
                                #attach new columns defined as the difference
                                #between the obs and the absolute values of the
                                #individual models(ie sqrt(model value)^2)
    df_combined['corr_dev_hist'] = df_combined[' r'].apply(lambda x:math.sqrt((obs_r - x) **2))
    df_combined['obs_dev_hist']  = df_combined['b'].apply(lambda x: math.sqrt((obs_bcoef - x) ** 2))
    df_combined['obs_dev_proj']  = df_combined['b_proj'].apply(lambda x: math.sqrt((obs_bcoef - x) ** 2))
                               #sort along the newly created columns in order of
                               #increasing difference from obs
    sorted_via_corrHist = df_combined.sort_values(by='corr_dev_hist')  #to sort the reg data according to the rankings in the correlations
#    sorted_via_corrHist = sorted_via_corrHist.drop(['a-intercept', 'prob', 'alpha',
#                                                    'yave', 'xave', 'npxy'], axis = 1)

    sorted_histdata = df_combined.sort_values(by='obs_dev_hist', ascending=False)
    sorted_projdata = df_combined.sort_values(by='obs_dev_proj', ascending=False)

    print("sorted data files created")


    sorted_via_corrHist.to_csv('REG_sorted4Cat_'+region+'.csv', index = False)


    RUNALL = True
    if(RUNALL):
        # Define the y-axis values for columns 'z' and 'e'
        hist_values = df_combined['b']
        hist_stde   = df_combined['stddev_mm']
        hist_pristdev = df_combined['pri_std']
        hist_saodstdev = df_combined['saod_std']
        proj_values = df_combined['b_proj']
        proj_stde   = df_combined['stdev_mmproj']
        proj_pristdev = df_combined['pri_std_proj']
        proj_saodstdev = df_combined['saodi_std_proj']

        # Set the width of the bars
        bar_width = 0.2

        # Set the positions of the bars on the x-axis
        bar_positions =      np.arange(len(x_values))
#       bar_positions_hist = [x - 1.5 * bar_width for x in x_values]
#       bar_positions_proj = [x - 0.5 * bar_width for x in x_values]
#       bar_pos1 = [x + 0.5 * bar_width for x in x_values]
#       bar_pos2 = [x + 1.5 * bar_width for x in x_values]
        
        bar_positions_hist = bar_positions - 2.0 * bar_width
        bar_positions_proj = bar_positions - 0.7 * bar_width
        bar_pos1 = bar_positions + 0.7 * bar_width
        bar_pos2 = bar_positions + 2.0 * bar_width

        # Create the bar plot
                # plt.bar(bar_positions_hist, hist_values, yerr=hist_stde, capsize=1, width=bar_width,
                #         label='historical', color='royalblue')
                # plt.bar(bar_positions_proj, proj_values, capsize=1,
                #         width=bar_width, label='ssp585 projections', color='red')
                # plt.bar(bar_pos2,proj_pristdev, capsize=1, width=bar_width,label='rainfall variability',
                #        color='none',edgecolor = 'red')
                # plt.bar(bar_pos1, hist_pristdev, capsize=1,width=bar_width,label='rainfall variability',
                #         color='none',edgecolor = 'royalblue')
                # plt.axhline(0, color='black')
        
        # Create the bar plot
        plt.bar(bar_positions_hist, hist_values, yerr=hist_stde, capsize=1, width=bar_width,
                label='historical', color='royalblue')
        plt.bar(bar_positions_proj, proj_values, capsize=1,
                width=bar_width, label='ssp585 projections', color='red')
        plt.axhline(0, color='black')

        # Plot the horizontal line to show the threshold (i.e., Obs coefficient)
        plt.axhline(obs_bcoef, color="darkred", ls="dotted")

        # Plot the band (for obs standard error) using fill_between
   #     plt.fill_between([0, len(x_values)], obs_bcoef - obs_stde, obs_bcoef + obs_stde,
   #                     color='darkred', alpha=0.15)

        font1 = {'family': 'serif', 'color': 'black', 'size': 12}
        font2 = {'family': 'serif', 'color': 'black', 'size': 10}

        # Set the x-axis labels
        plt.xticks(bar_positions_hist, x_values, rotation=90, fontsize=10)

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
                                label='Obs coef = ' + str(obs_bcoef))
#       band_patch = mpatches.Patch(color='darkred', alpha=0.15, label='Obs stde')
        pri_histpatch      = mpatches.Patch(edgecolor='royalblue', fill=False,
                                        label='stdev rainfall hist')
        pri_projpatch      = mpatches.Patch(edgecolor='red', fill=False,
                                        label='stdev rainfall SSP585')
        legend_patches = [mpatches.Patch(color='royalblue', label='historical'),
                          mpatches.Patch(color='red', label='ssp585 projections'),
                          obs_line, pri_histpatch, pri_projpatch]

        # Add the custom legend
 #       if region == 'Guinea_Coast':
        plt.legend(handles=legend_patches, loc ='upper right', 
                       bbox_to_anchor=(1.25, 1))
 #       else:
 #           plt.legend(handles=legend_patches, loc = 'best')

        # Display the plot
        plt.show()
        plt.close()


  # Horizontal line to show threshold (i.e., Obs coefficient) plus annotation
#   anTitle = 'Obs = ' + str(obs_bcoef)
#   xlist = x_values.tolist()
#   x_coordinate = xlist.index('NorESM2-MM')
#   plt.axhline(obs_bcoef, color="darkred", ls="dotted")


#   # Annotation on plot

# #  plt.text(x_coordinate, y_min - 0.05, anTitle, ha="center", va="center",
# #           color="darkred", fontdict=font2)




###############################################################################
   #Create the RANK BAR PLOTS

    #plt.figure(figsize=(6, 12), dpi=400)  # Adjust the figure size as needed

    # Set the colors based on the values of obs_dev
    obstxt = obs_bcoef
    obstxtR = math.sqrt((obstxt) ** 2)  #the absolute value of obstxt
    

    ###########################################################################
    ###########################################################################

    # Define the figure and subplots

    PLOT_SECOND = False
    if PLOT_SECOND:
        fig, axs = plt.subplots(2, 1, figsize=(6, 12), dpi=400, sharex=True)

        # Set the colors based on the values of obs_dev
        colors_hist = ['green' if val < 0.2 else 'red' if val > obstxtR else 'royalblue' for val in sorted_histdata['obs_dev_hist']]
        colors_proj = ['green' if val < 0.2 else 'red' if val > obstxtR else 'royalblue' for val in sorted_projdata['obs_dev_proj']]

        # Plot the first bar plot for historical models
        axs[0].barh(sorted_histdata['Model_name'], sorted_histdata['obs_dev_hist'], color=colors_hist)
        axs[0].set_ylabel('CMIP6 historical Models')

        # Plot the second bar plot for projection models
        axs[1].barh(sorted_projdata['Model_name'], sorted_projdata['obs_dev_proj'], color=colors_proj)
        axs[1].set_ylabel('CMIP6 ssp585 Models')

        # Set the x-axis label and title
        fig.text(0.5, 1.0, 'Model ranking for SAODI and Precip regression in ' + region, ha='center', fontdict=font1)
        plt.xlabel('Difference from Obs')

        # Customize the tick labels and limits for better visibility
        plt.xticks(rotation=90, fontsize=8)
        plt.xlim(-0.05, 1.05)

        # Add a common legend
        plt.legend()

        # Add text for the observation value
        obstxtL = 'Obs =' + str(obstxt)
        axs[0].text(0.5, plt.ylim()[1], obstxtL, color='darkred', ha='center', va='top')
        axs[1].text(0.5, plt.ylim()[1], obstxtL, color='darkred', ha='center', va='top')

        plt.tight_layout()  # Adjust the spacing between subplots

        plt.show()
        plt.close()

    ###########################################################################
    ###########################################################################

    # all as 1 bar plot

    # Set the figure size
    # plt.figure(figsize=(12, 6), dpi=400)

    # # Create the bar plot for historical models
    # hist_bars = plt.barh(sorted_histdata['Model_name'], sorted_histdata['obs_dev_hist'], color='royalblue', label='Historical')
    # plt.xlabel('Difference from Obs')
    # plt.ylabel('CMIP6 Models - Historical', color='royalblue')
    # plt.xticks(rotation=0, fontsize=8)

    # # Create a second y-axis for the projected bar plots
    # ax2 = plt.gca().twinx()
    # proj_bars = ax2.barh(sorted_projdata['Model_name'], sorted_projdata['obs_dev_proj'], color='orange', label='Projected')
    # ax2.set_ylabel('CMIP6 Models - Projected', color='orange')

    # # Combine the bar plots for the legend
    # legend_patches = [mpatches.Patch(color='royalblue', label='Historical'),
    #                   mpatches.Patch(color='orange', label='Projected')]

    # # Set the title
    # plt.title('Model ranking for SAODI and Precip regression in ' + region)

    # # Add a custom legend
    # plt.legend(handles=legend_patches)

    # # Adjust the layout and spacing
    # plt.tight_layout()

    # # Show the plot
    # plt.show()


###############################################################################


    #bar plot above is converted to a line plot

    PLOT_THIRD = False
    if PLOT_THIRD:
        plt.figure(figsize=(12, 6), dpi=400, frameon=True)

        # Create the line plot for historical models
        plt.scatter(sorted_histdata['obs_dev_hist'], sorted_histdata['Model_name'],
                 color='royalblue', marker='o', label='Historical')
        plt.ylabel('Ranked CMIP6 Models - Historical', color='royalblue')
        plt.xlabel('Obs - Mod')

        # Create a second y-axis for the projected line plot
        ax2 = plt.gca().twinx()
        ax2.scatter(sorted_projdata['obs_dev_proj'], sorted_projdata['Model_name'],
                 color='red', marker='o', label='Projected')
        ax2.set_ylabel('Ranked CMIP6 Models - Projected', color='red')
        plt.axvline(obstxtR, color="darkred", ls="dotted")

        # Set the labels and tick parameters

        # Combine the line plots for the legend
        obs_line2 = lines.Line2D([], [], color='darkred', ls='dotted',
                                label='abs Obs coef')
        legend_lines = [lines.Line2D([], [], color='royalblue', marker='o', label='Historical'),
                        lines.Line2D([], [], color='red', marker='o', label='Projected'),
                        obs_line2]

        # Set the title
        plt.title('Model ranking for SAODI and Precip regression in ' + region,
                  fontdict=font1)

        # Add a custom legend
        plt.legend(handles=legend_lines)


                                      #to add annotation
        obstxtL = 'Obs =' + str(obstxt)
        ylist = sorted_projdata['Model_name'].tolist()
        y_coordinate = ylist[32]
        #plt.text(0.53, y_coordinate, obstxtL, color ='darkred', ha='center', va='top')
        plt.xlim(-0.05, 0.6)

        plt.grid(visible=False)

        # Adjust the layout and spacing
        plt.tight_layout()

        # Show the plot
        plt.show()


###############################################################################
#AVERAGING CATEGORY 1 MODELS



    # Filter the DataFrame based on conditions
    filtered_df = sorted_via_corrHist.loc[(sorted_via_corrHist[' p'] <= 0.05) &
                                          (sorted_via_corrHist['corr_dev_hist'] < obs_r_abs)]
    #filtered_df = sorted_via_corrHist.loc[(sorted_via_corrHist['corr_dev_hist'] > obs_r_abs)]

    # Calculate the average of 'b' and 'b_proj'
    avg_b = filtered_df['b'].mean()
    avg_b_proj = filtered_df['b_proj'].mean()
    stde_b  = filtered_df['std_error'].mean()
    stde_b_proj = filtered_df['std_error_proj'].mean()

    # Create a new DataFrame with the calculated averages

    # Print the averages
    print("Average of 'b':", avg_b)
    print("Average of 'b_proj':", avg_b_proj)

    # Create a new row with the calculated averages
    new_row = {'region': region, 'b': avg_b, 'b_proj': avg_b_proj,
               'mod_std_error': stde_b, 'mod_std_error_proj': stde_b_proj}

    # Append the new row to the result DataFrame
 #   ave_REG_df = ave_REG_df.append(new_row, ignore_index=True)


# Print the final DataFrame
# print(ave_REG_df)

#obs_REG = pd.read_csv('obs_REG_mod_JJA.csv')
#obs_REG1 = obs_REG[['b_obs', 'std_error']]

#ave_REG_df = pd.concat([ave_REG_df, obs_REG1], axis = 1)

#ave_REG_df.to_csv('ave_Cat1_allREG.csv', index = False)

#ave_REG_df = pd.read_csv('ave_Cat1_allREGwithMMM.csv')

               #To plot Category ensemble plots

PLOT_CAT_BAR = False
if PLOT_CAT_BAR:
    # Set the width of the bars
    plt.figure(figsize=(12, 6), frameon=True, dpi=400)
    bar_width = 0.1

    # Set the positions of the bars on the x-axis
    r1 = range(len(ave_REG_df))
    r2 = [x + bar_width for x in r1]
    r3 = [y + bar_width for y in r2]
    r4 = [z + bar_width for z in r3]
    r5 = [q + bar_width for q in r4]

    # Create the bar plot
    plt.bar(r1, ave_REG_df['b_obs'], color = 'grey', yerr=ave_REG_df['std_error'],
            capsize = 2, ecolor = 'blue', width=bar_width, label='observations')
    plt.bar(r2, ave_REG_df['b'], color='royalblue', width=bar_width, label='Cat1_historical')
    plt.bar(r3, ave_REG_df['b_proj'], color='red', width=bar_width, yerr=ave_REG_df['mod_std_error_proj'],
            capsize = 2, ecolor = 'blue', label='Cat1_SSP585')
    plt.bar(r4, ave_REG_df['MMM_hist'], color='none', edgecolor='royalblue', linewidth=2,
            width=bar_width, label='MMM_historical')
    plt.bar(r5, ave_REG_df['MMM_proj'], color='none', edgecolor='red', linewidth=2, width=bar_width, label='MMM_SSP585')

    #yerr=ave_REG_df['mod_std_error_proj'], capsize = 2, ecolor = 'blue'
    #yerr=ave_REG_df['MMM_stde'],capsize = 2, ecolor = 'blue',

    # Set the x-axis labels and ticks
    plt.xlabel('Region')
    plt.xticks([r + bar_width/2 for r in r1], ave_REG_df['region'], fontsize = 15)
    plt.axhline(0, color='black')

    # Set the y-axis label
    plt.ylabel('rainfall anomaly (mm/day)')

    # Set the plot title
    plt.title('Ensemble mean regression of rainfall anomaly on SAODI of best performing models')

    # Add a legend
    plt.legend()

    # Show the plot
    plt.show()
    plt.close()



    cat_std = pd.read_csv("ave_Cat1_allREG_stdev.csv")
    plt.figure(figsize=(12, 6), frameon=True, dpi=400)
    bar_width = 0.2

    # Set the positions of the bars on the x-axis
    st1 = range(len(cat_std))
    st2 = [x + bar_width for x in st1]
    st3 = [y + bar_width for y in st2]

    # Create the bar plot for SAODI stddev
    plt.bar(st1, cat_std['obs_saodi_stdev'], color = 'grey', width=bar_width, label='observation')
    plt.bar(st2, cat_std['hist_saodi_stdev'], color='royalblue', width=bar_width, label='historical')
    plt.bar(st3, cat_std['proj_saodi_stdev'], color='red', width=bar_width, label='SSP585 projection')


    # Set the x-axis labels and ticks
    plt.xlabel('Region')
    plt.xticks([r + bar_width/2 for r in st1], cat_std['region'], fontsize = 15)
    plt.axhline(0, color='black')

    # Set the y-axis label
    plt.ylabel('SAODI standard deviation  (\u00B0 C)')



    # Set the plot title
    plt.title('SAODI standard deviation of Category 1 models ensemble')

    # Add a legend
    plt.legend()

    # Show the plot
    plt.show()

    plt.close()




    plt.figure(figsize=(12, 6), frameon=True, dpi=400)
    bar_width = 0.2

    # Set the positions of the bars on the x-axis
    st1 = range(len(cat_std))
    st2 = [x + bar_width for x in st1]
    st3 = [y + bar_width for y in st2]

    # Create the bar plot for Precip stddev
    plt.bar(st1, cat_std['obs_pri_stdev'], color = 'grey', width=bar_width, label='observation')
    plt.bar(st2, cat_std['hist_pri_stdev'], color='royalblue', width=bar_width, label='historical')
    plt.bar(st3, cat_std['proj_pri_stdev'], color='red', width=bar_width, label='SSP585 projection')

    # Set the x-axis labels and ticks
    plt.xlabel('Region')
    plt.xticks([r + bar_width/2 for r in st1], cat_std['region'], fontsize = 15)
    plt.axhline(0, color='black')

    # Set the y-axis label
    plt.ylabel('Rainfall anomaly standard deviation (mm/day)')

    # Set the plot title
    plt.title('Rainfall anomaly standard deviation of Category 1 models ensemble')

    # Add a legend
    plt.legend()

    # Show the plot
    plt.show()
