#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jun 27 01:28:27 2023

@author: yuzee
"""

# Goal here is to append the correlation values Multi-model mean(MMM) to
#the csv file containing the values for the model.
# csv files are generated from ncl scripts no 21[models], 23[obs], & 25[MMM],
# all for 'JJA' season.
#==============================================================================
#-------------========================================-------------------------
import os
os.chdir('/home/yuzee/nclfolder/RESULTS/07manuscript/')

import csv       #for reading the csv files
wd = "/home/yuzee/nclfolder/RESULTS/07manuscript/"
season = "JJA"

regions = ["Northern_Amazon","Central_Africa", "Guinea_Coast", "SE_Brazil"]  #loop over regions

for region in regions:
    if region == "Northern_Amazon":
        row_index = 2
    elif region == "Guinea_Coast":
        row_index = 3
    elif region == "Central_Africa":
        row_index = 4
    else:
        row_index = 5

    #with open('obs_Arry_reg_JJA.csv', 'r') as file_a:
        #reader_a = csv.reader(file_a)           #read-in the obs csv file

    # Skip rows until you reach the desired row
        #for _ in range(row_index - 1):
         # next(reader_a)

        #source_row = next(reader_a)  # Get the desired row from 'file_a'


    with open('immm_regV2hist_JJA_'+region+'.csv', 'r') as file_mmm:
        reader_d = csv.reader(file_mmm)        #read in mm file and extract row

        for _ in range(1):
            next(reader_d)
        msource_row  = next(reader_d)         #extract 1st row from mmm_file

    with open('immmcat1_regV2hist_'+season+'_'+region+'.csv', 'r') as file_mcat1:
        reader_cat1 = csv.reader(file_mcat1)        #read in mm file and extract row

        for _ in range(1):
             next(reader_cat1)
        mcat1source_row  = next(reader_cat1)         #extract 1st row from mmm_file

    with open('immmcat2_regV2hist_'+season+'_'+region+'.csv', 'r') as file_mcat2:
        reader_cat2 = csv.reader(file_mcat2)        #read in mm file and extract row

        for _ in range(1):
             next(reader_cat2)
        mcat2source_row  = next(reader_cat2)         #extract 1st row from mmm_file

    # Read the existing data from model csv file
    existing_data = []
    with open('iArry_reg2_'+region+'_JJA.csv', 'r') as file_b:
        reader_b = csv.reader(file_b)
        existing_data = [row for row in reader_b]

    # Create a new list of rows with two(2) empty rows at the top
    new_data = [existing_data[0], [], [],[]]    #put 3 empty rows under header row
    new_data.extend(existing_data[1:])      #Append the remaining existing data

    # Insert the extracted rows from 'reader_a' and 'reader_c' as the new empty rows

    new_data[1] = msource_row
    new_data[2] = mcat1source_row
    new_data[3] = mcat2source_row

    # Write the modified data to a new CSV file
    new_file_name = 'iAll2_reg_'+region+'_manuscript.csv'  # Specify the new file name
    with open(new_file_name, 'w', newline='') as new_file:
        writer = csv.writer(new_file)
        writer.writerows(new_data)

    print("============= file generated for "+region+" ====================================")
