#!/usr/bin/env python
# coding: utf-8

# In[ ]:

# In[15]:


import pandas as pd
import numpy as np
savedir = "/home/yuzee/nclfolder/RESULTS/07manuscript/"

# In[16]:


regions = {"Northern_Amazon": ["All_Models","Best_Models","Worst_Models","MRI-ESM2-0","CMCC-CM2-SR5",\
"IPSL-CM6A-LR","CanESM5","CMCC-ESM2","MPI-ESM1-2-HR","NorESM2-MM","INM-CM5-0",\
"FIO-ESM-2-0","EC-Earth3-CC","ACCESS-ESM1-5","EC-Earth3","MIROC6","GISS-E2-1-H",\
"FGOALS-g3","CESM2-WACCM","KACE-1-0-G","TaiESM1","CESM2","GFDL-ESM4","BCC-CSM2-MR",\
"CAMS-CSM1-0","INM-CM4-8","NESM3","ACCESS-CM2","GISS-E2-1-G", "E3SM-1-1","E3SM-1-0",\
"IITM-ESM","E3SM-1-1-ECA","AWI-CM-1-1-MR","FGOALS-f3-L","MPI-ESM1-2-LR","NorESM2-LM","CAS-ESM2-0"],
                     "Central_Africa": ["All_Models","Best_Models","Worst_Models","E3SM-1-1","E3SM-1-1-ECA",\
"BCC-CSM2-MR","ACCESS-CM2","E3SM-1-0","CESM2","INM-CM4-8","FGOALS-g3","MIROC6","IITM-ESM","INM-CM5-0",\
"MPI-ESM1-2-HR","KACE-1-0-G","EC-Earth3","FIO-ESM-2-0","CMCC-CM2-SR5","EC-Earth3-CC","CMCC-ESM2",\
"ACCESS-ESM1-5","NorESM2-MM","CESM2-WACCM","CAS-ESM2-0","MRI-ESM2-0","NESM3","IPSL-CM6A-LR","FGOALS-f3-L",\
"MPI-ESM1-2-LR","AWI-CM-1-1-MR","NorESM2-LM","TaiESM1","CAMS-CSM1-0","GFDL-ESM4","GISS-E2-1-G","GISS-E2-1-H","CanESM5"],
                     "Guinea_Coast": ["All_Models","Best_Models","Worst_Models","FIO-ESM-2-0","CMCC-ESM2","NorESM2-LM","CMCC-CM2-SR5","ACCESS-ESM1-5",\
"NorESM2-MM","E3SM-1-1-ECA","EC-Earth3-CC","BCC-CSM2-MR","E3SM-1-1","CAS-ESM2-0","MPI-ESM1-2-HR","NESM3",\
"CESM2","MIROC6","CESM2-WACCM","MPI-ESM1-2-LR","AWI-CM-1-1-MR","EC-Earth3","KACE-1-0-G","E3SM-1-0","CAMS-CSM1-0",\
"TaiESM1","INM-CM4-8","MRI-ESM2-0","GFDL-ESM4","FGOALS-g3","IPSL-CM6A-LR","CanESM5","INM-CM5-0","GISS-E2-1-H",\
"FGOALS-f3-L","ACCESS-CM2","IITM-ESM","GISS-E2-1-G"],
                     "SE_Brazil": ["All_Models","Best_Models","Worst_Models","ACCESS-CM2","GFDL-ESM4","ACCESS-ESM1-5","NESM3",\
"FIO-ESM-2-0","CMCC-ESM2","CESM2","EC-Earth3-CC","MRI-ESM2-0","CMCC-CM2-SR5","NorESM2-MM","AWI-CM-1-1-MR",\
"CAMS-CSM1-0","INM-CM5-0","BCC-CSM2-MR","FGOALS-g3","CESM2-WACCM","E3SM-1-0","MIROC6","NorESM2-LM","MPI-ESM1-2-LR",\
"CanESM5","E3SM-1-1-ECA","INM-CM4-8","MPI-ESM1-2-HR","EC-Earth3","CAS-ESM2-0","IPSL-CM6A-LR","KACE-1-0-G","E3SM-1-1",\
"FGOALS-f3-L","IITM-ESM","GISS-E2-1-H","TaiESM1","GISS-E2-1-G"]}

regions_mod_names = pd.DataFrame(regions)
regions_mod_names.to_csv(savedir+'Model_names_by_Cat.csv')
regions_mod_names


# In[ ]:





# In[ ]:





# In[ ]:
