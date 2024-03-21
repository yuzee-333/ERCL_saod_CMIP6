#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jul 31 18:55:52 2023

@author: yuzee
"""

# Goal here is to create a single csv file containing all the MMM regression values
#for each region, for bothe the historical and projected scenario.
# the csv file will be used to generate a bar plot.
#the initial files are generated with ncl script '18mmm...' in historical folder

#==============================================================================
#-------------========================================-------------------------
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
 
wd = "./mmm2/"
season = "JJA"


# Sample data to create the DataFrame
column_names = ['Region', 'b', 'a-intercept', 'prob', 'alpha', 'yave', 'xave', 
                'npxy','std_error', 't', 'r_squared', ' r', ' p'] 
# Creating the DataFrame
dff = pd.DataFrame(columns=column_names)
# Display the DataFrame (optional)
print(dff)
# Save the DataFrame as a CSV file
dff.to_csv('AllMMM_reg.csv', index=False)  # Set index=False if you don't want to save the row numbers as well

regions = ["Northern_Amazon","Central_Africa", "Guinea_Coast", "SE_Brazil"]  #loop over regions

for region in regions:
    

    
    with open('mmm2_regV2hist_JJA_'+region+'.csv', 'r') as mmm_regval:
        reader_c = csv.reader(mmm_regval)        #read in mm file and extract row

        for _ in range(1):
          next(reader_c)
        m2source_row  = next(reader_c)         #extract 1st row after header from mmm_file
        dff = dff.append(m2source_row, ignore_index=True)
    

# Print the final DataFrame
print(dff)
    
    # Read the existing data from model csv file
    existing_data = []
    with open('AllMMM_reg.csv', 'r') as file_b:
        reader_b = csv.reader(file_b)
        existing_data = [row for row in reader_b]

    # Create a new list of rows with two(2) empty rows at the top
    new_data = [existing_data[0], []]    #put 2 empty rows under header row
    new_data.extend(existing_data[1:])      #Append the remaining existing data

    new_data[1] = m2source_row

    # Write the modified data to a new CSV file
    new_file_name = 'AllMMM_regV2Hist.csv'  # Specify the new file name
    with open(new_file_name, 'w', newline='') as new_file:
        writer = csv.writer(new_file)
        writer.writerows(new_data)

    print("============= file generated for "+region+" ====================================")