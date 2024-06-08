begin

; Organizes the historical model names in each region per category. Models are also arranged according to their
; deviation from observations in ascending order. For the manuscript considering Hist and SSP585

modelNames = (/"RE_tos_Omon_ACCESS-CM2_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_AWI-CM-1-1-MR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_BCC-CSM2-MR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CAMS-CSM1-0_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CanESM5_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CAS-ESM2-0_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CESM2_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CESM2-WACCM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CMCC-CM2-SR5_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CMCC-ESM2_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_E3SM-1-0_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_E3SM-1-1-ECA_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_E3SM-1-1_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_EC-Earth3-CC_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_EC-Earth3_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_FGOALS-f3-L_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_FGOALS-g3_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_FIO-ESM-2-0_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_GFDL-ESM4_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_GISS-E2-1-G_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_GISS-E2-1-H_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_IITM-ESM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_INM-CM4-8_historical_r1i1p1f1_gr1_185001-201412.nc",\
"RE_tos_Omon_INM-CM5-0_historical_r1i1p1f1_gr1_185001-201412.nc",\
"RE_tos_Omon_IPSL-CM6A-LR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_KACE-1-0-G_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_MIROC6_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_MPI-ESM1-2-LR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_MRI-ESM2-0_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_NESM3_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_NorESM2-LM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_NorESM2-MM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_TaiESM1_historical_r1i1p1f1_gn_185001-201412.nc"/)

modnames_shorts = (/"ACCESS-CM2","ACCESS-ESM1-5","AWI-CM-1-1-MR","BCC-CSM2-MR",\
"CAMS-CSM1-0","CanESM5","CAS-ESM2-0","CESM2","CESM2-WACCM","CMCC-CM2-SR5",\
"CMCC-ESM2", "E3SM-1-0", "E3SM-1-1-ECA", "E3SM-1-1", "EC-Earth3-CC", "EC-Earth3",\
"FGOALS-f3-L","FGOALS-g3","FIO-ESM-2-0","GFDL-ESM4","GISS-E2-1-G","GISS-E2-1-H",\
"IITM-ESM","INM-CM4-8","INM-CM5-0","IPSL-CM6A-LR","KACE-1-0-G","MIROC6","MPI-ESM1-2-HR",\
"MPI-ESM1-2-LR","MRI-ESM2-0","NESM3","NorESM2-LM","NorESM2-MM","TaiESM1"/)

;===============================================================================
;===============================================================================

N_A = (/"RE_tos_Omon_MRI-ESM2-0_historical_r1i1p1f1_gn_185001-201412.nc",\  ;cat1
"RE_tos_Omon_CMCC-CM2-SR5_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_IPSL-CM6A-LR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CanESM5_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CMCC-ESM2_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_NorESM2-MM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_INM-CM5-0_historical_r1i1p1f1_gr1_185001-201412.nc",\
"RE_tos_Omon_FIO-ESM-2-0_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_EC-Earth3-CC_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_EC-Earth3_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_MIROC6_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_GISS-E2-1-H_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_FGOALS-g3_historical_r1i1p1f1_gn_185001-201412.nc",\             ;cat2
"RE_tos_Omon_CESM2-WACCM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_KACE-1-0-G_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_TaiESM1_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CESM2_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_GFDL-ESM4_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_BCC-CSM2-MR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CAMS-CSM1-0_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_INM-CM4-8_historical_r1i1p1f1_gr1_185001-201412.nc",\
"RE_tos_Omon_NESM3_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_ACCESS-CM2_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_GISS-E2-1-G_historical_r1i1p1f1_gn_185001-201412.nc",\          ;cat3
"RE_tos_Omon_E3SM-1-1_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_E3SM-1-0_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_IITM-ESM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_E3SM-1-1-ECA_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_AWI-CM-1-1-MR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_FGOALS-f3-L_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_MPI-ESM1-2-LR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_NorESM2-LM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CAS-ESM2-0_historical_r1i1p1f1_gn_185001-201412.nc"/)

N_A_shorts = (/"MRI-ESM2-0","CMCC-CM2-SR5","IPSL-CM6A-LR","CanESM5","CMCC-ESM2",\
"MPI-ESM1-2-HR","NorESM2-MM","INM-CM5-0","FIO-ESM-2-0","EC-Earth3-CC","ACCESS-ESM1-5",\
"EC-Earth3","MIROC6","GISS-E2-1-H","FGOALS-g3","CESM2-WACCM","KACE-1-0-G","TaiESM1",\
"CESM2","GFDL-ESM4","BCC-CSM2-MR","CAMS-CSM1-0","INM-CM4-8","NESM3",\
"ACCESS-CM2","GISS-E2-1-G", "E3SM-1-1","E3SM-1-0","IITM-ESM","E3SM-1-1-ECA","AWI-CM-1-1-MR",\
"FGOALS-f3-L","MPI-ESM1-2-LR","NorESM2-LM","CAS-ESM2-0"/)

;===============================================================================

C_A = (/"RE_tos_Omon_E3SM-1-1_historical_r1i1p1f1_gr_185001-201412.nc",\   ;cat1
"RE_tos_Omon_E3SM-1-1-ECA_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_BCC-CSM2-MR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_ACCESS-CM2_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_E3SM-1-0_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_CESM2_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_INM-CM4-8_historical_r1i1p1f1_gr1_185001-201412.nc",\
"RE_tos_Omon_FGOALS-g3_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_MIROC6_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_IITM-ESM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_INM-CM5-0_historical_r1i1p1f1_gr1_185001-201412.nc",\
"RE_tos_Omon_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_KACE-1-0-G_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_EC-Earth3_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_FIO-ESM-2-0_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CMCC-CM2-SR5_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_EC-Earth3-CC_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_CMCC-ESM2_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_NorESM2-MM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CESM2-WACCM_historical_r1i1p1f1_gn_185001-201412.nc",\          ;cat2
"RE_tos_Omon_CAS-ESM2-0_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_MRI-ESM2-0_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_NESM3_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_IPSL-CM6A-LR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_FGOALS-f3-L_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_MPI-ESM1-2-LR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_AWI-CM-1-1-MR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_NorESM2-LM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_TaiESM1_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CAMS-CSM1-0_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_GFDL-ESM4_historical_r1i1p1f1_gn_185001-201412.nc",\            ;cat3
"RE_tos_Omon_GISS-E2-1-G_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_GISS-E2-1-H_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CanESM5_historical_r1i1p1f1_gn_185001-201412.nc"/)

C_A_shorts = (/"E3SM-1-1","E3SM-1-1-ECA","BCC-CSM2-MR","ACCESS-CM2","E3SM-1-0","CESM2",\
"INM-CM4-8","FGOALS-g3","MIROC6","IITM-ESM","INM-CM5-0","MPI-ESM1-2-HR","KACE-1-0-G",\
"EC-Earth3","FIO-ESM-2-0","CMCC-CM2-SR5","EC-Earth3-CC","CMCC-ESM2","ACCESS-ESM1-5",\
"NorESM2-MM","CESM2-WACCM","CAS-ESM2-0","MRI-ESM2-0","NESM3","IPSL-CM6A-LR","FGOALS-f3-L",\
"MPI-ESM1-2-LR","AWI-CM-1-1-MR","NorESM2-LM","TaiESM1","CAMS-CSM1-0","GFDL-ESM4","GISS-E2-1-G",\
"GISS-E2-1-H","CanESM5"/)

;================================================================================

G_C = (/"RE_tos_Omon_FIO-ESM-2-0_historical_r1i1p1f1_gn_185001-201412.nc",\   ;cat1
"RE_tos_Omon_CMCC-ESM2_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_NorESM2-LM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CMCC-CM2-SR5_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_NorESM2-MM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_E3SM-1-1-ECA_historical_r1i1p1f1_gr_185001-201412.nc",\         ;cat2
"RE_tos_Omon_EC-Earth3-CC_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_BCC-CSM2-MR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_E3SM-1-1_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_CAS-ESM2-0_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_NESM3_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CESM2_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_MIROC6_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CESM2-WACCM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_MPI-ESM1-2-LR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_AWI-CM-1-1-MR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_EC-Earth3_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_KACE-1-0-G_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_E3SM-1-0_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_CAMS-CSM1-0_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_TaiESM1_historical_r1i1p1f1_gn_185001-201412.nc",\              ;cat3
"RE_tos_Omon_INM-CM4-8_historical_r1i1p1f1_gr1_185001-201412.nc",\
"RE_tos_Omon_MRI-ESM2-0_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_GFDL-ESM4_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_FGOALS-g3_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_IPSL-CM6A-LR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CanESM5_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_INM-CM5-0_historical_r1i1p1f1_gr1_185001-201412.nc",\
"RE_tos_Omon_GISS-E2-1-H_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_FGOALS-f3-L_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_ACCESS-CM2_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_IITM-ESM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_GISS-E2-1-G_historical_r1i1p1f1_gn_185001-201412.nc"/)

G_C_shorts = (/"FIO-ESM-2-0","CMCC-ESM2","NorESM2-LM","CMCC-CM2-SR5","ACCESS-ESM1-5",\
"NorESM2-MM","E3SM-1-1-ECA","EC-Earth3-CC","BCC-CSM2-MR","E3SM-1-1","CAS-ESM2-0",\
"MPI-ESM1-2-HR","NESM3","CESM2","MIROC6","CESM2-WACCM","MPI-ESM1-2-LR","AWI-CM-1-1-MR",\
"EC-Earth3","KACE-1-0-G","E3SM-1-0","CAMS-CSM1-0","TaiESM1","INM-CM4-8","MRI-ESM2-0",\
"GFDL-ESM4","FGOALS-g3","IPSL-CM6A-LR","CanESM5","INM-CM5-0","GISS-E2-1-H","FGOALS-f3-L",\
"ACCESS-CM2","IITM-ESM","GISS-E2-1-G"/)

;===============================================================================

S_B = (/"RE_tos_Omon_ACCESS-CM2_historical_r1i1p1f1_gn_185001-201412.nc",\  ;cat1
"RE_tos_Omon_GFDL-ESM4_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_NESM3_historical_r1i1p1f1_gn_185001-201412.nc",\               ;cat2
"RE_tos_Omon_FIO-ESM-2-0_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CMCC-ESM2_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CESM2_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_EC-Earth3-CC_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_MRI-ESM2-0_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CMCC-CM2-SR5_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_NorESM2-MM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_AWI-CM-1-1-MR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CAMS-CSM1-0_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_INM-CM5-0_historical_r1i1p1f1_gr1_185001-201412.nc",\
"RE_tos_Omon_BCC-CSM2-MR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_FGOALS-g3_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CESM2-WACCM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_E3SM-1-0_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_MIROC6_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_NorESM2-LM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_MPI-ESM1-2-LR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CanESM5_historical_r1i1p1f1_gn_185001-201412.nc",\             ;cat3
"RE_tos_Omon_E3SM-1-1-ECA_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_INM-CM4-8_historical_r1i1p1f1_gr1_185001-201412.nc",\
"RE_tos_Omon_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_EC-Earth3_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CAS-ESM2-0_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_IPSL-CM6A-LR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_KACE-1-0-G_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_E3SM-1-1_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_FGOALS-f3-L_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_IITM-ESM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_GISS-E2-1-H_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_TaiESM1_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_GISS-E2-1-G_historical_r1i1p1f1_gn_185001-201412.nc"/)

S_B_shorts = (/"ACCESS-CM2","GFDL-ESM4","ACCESS-ESM1-5","NESM3","FIO-ESM-2-0",\
"CMCC-ESM2","CESM2","EC-Earth3-CC","MRI-ESM2-0","CMCC-CM2-SR5","NorESM2-MM",\
"AWI-CM-1-1-MR","CAMS-CSM1-0","INM-CM5-0","BCC-CSM2-MR","FGOALS-g3","CESM2-WACCM",\
"E3SM-1-0","MIROC6","NorESM2-LM","MPI-ESM1-2-LR","CanESM5","E3SM-1-1-ECA","INM-CM4-8",\
"MPI-ESM1-2-HR","EC-Earth3","CAS-ESM2-0","IPSL-CM6A-LR","KACE-1-0-G","E3SM-1-1",\
"FGOALS-f3-L","IITM-ESM","GISS-E2-1-H","TaiESM1","GISS-E2-1-G"/)

;============================================================================================
end
