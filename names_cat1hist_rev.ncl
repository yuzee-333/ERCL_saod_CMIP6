begin

;this script is for calculating and generating 2 ncl files (for Cat 1 and Cat 2)
;used to calculate the MMM of historical Cat 1 models as well as the ensemble of all
;the other models. Will be attached to regression bar plot (@ script 31...);

modelNames = (/"RE_tos_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_ACCESS-CM2_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_AWI-CM-1-1-MR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_BCC-CSM2-MR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CAMS-CSM1-0_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CanESM5_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CAS-ESM2-0_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CESM2_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CESM2-WACCM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CMCC-CM2-SR5_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CMCC-ESM2_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_E3SM-1-1-ECA_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_E3SM-1-1_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_EC-Earth3-CC_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_EC-Earth3_historical_r1i1p1f1_gn_185001-201412.nc",\
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

; =================================================++++++++++++++++++++++++++++=

N_A_Cat1 = (/"RE_tos_Omon_MRI-ESM2-0_historical_r1i1p1f1_gn_185001-201412.nc",\  ;cat1
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
"RE_tos_Omon_EC-Earth3_historical_r1i1p1f1_gn_185001-201412.nc"/)

N_A_Cat2 = (/"RE_tos_Omon_FGOALS-g3_historical_r1i1p1f1_gn_185001-201412.nc",\   ;cat2
"RE_tos_Omon_MIROC6_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_GISS-E2-1-H_historical_r1i1p1f1_gn_185001-201412.nc",\
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
"RE_tos_Omon_GISS-E2-1-G_historical_r1i1p1f1_gn_185001-201412.nc",\             ;cat3
"RE_tos_Omon_E3SM-1-1_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_IITM-ESM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_E3SM-1-1-ECA_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_AWI-CM-1-1-MR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_MPI-ESM1-2-LR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_NorESM2-LM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CAS-ESM2-0_historical_r1i1p1f1_gn_185001-201412.nc"/)
;+++++++++++++++++++++++========================================================


C_A_Cat1 = (/"RE_tos_Omon_E3SM-1-1-ECA_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_E3SM-1-1_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_BCC-CSM2-MR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_ACCESS-CM2_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CESM2_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_INM-CM4-8_historical_r1i1p1f1_gr1_185001-201412.nc",\
"RE_tos_Omon_FGOALS-g3_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_MIROC6_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_IITM-ESM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_INM-CM5-0_historical_r1i1p1f1_gr1_185001-201412.nc",\
"RE_tos_Omon_KACE-1-0-G_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_EC-Earth3_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_FIO-ESM-2-0_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CMCC-CM2-SR5_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_EC-Earth3-CC_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_CESM2-WACCM_historical_r1i1p1f1_gn_185001-201412.nc"/)

C_A_Cat2 =(/"RE_tos_Omon_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CMCC-ESM2_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_NorESM2-MM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CAS-ESM2-0_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_MRI-ESM2-0_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_NESM3_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_IPSL-CM6A-LR_historical_r1i1p1f1_gn_185001-201412.nc",\          
"RE_tos_Omon_MPI-ESM1-2-LR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_AWI-CM-1-1-MR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_NorESM2-LM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_TaiESM1_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CAMS-CSM1-0_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_GFDL-ESM4_historical_r1i1p1f1_gn_185001-201412.nc",\            ;cat3
"RE_tos_Omon_GISS-E2-1-G_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_GISS-E2-1-H_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CanESM5_historical_r1i1p1f1_gn_185001-201412.nc"/)

;=======================-------------------------------=========================

G_C_Cat1 = (/"RE_tos_Omon_FIO-ESM-2-0_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CMCC-ESM2_historical_r1i1p1f1_gn_185001-201412.nc"/)

G_C_Cat2 = (/"RE_tos_Omon_E3SM-1-1-ECA_historical_r1i1p1f1_gr_185001-201412.nc",\  ;cat2
"RE_tos_Omon_NorESM2-LM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CMCC-CM2-SR5_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_NorESM2-MM_historical_r1i1p1f1_gn_185001-201412.nc",\
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
"RE_tos_Omon_CAMS-CSM1-0_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_TaiESM1_historical_r1i1p1f1_gn_185001-201412.nc",\                   ;cat3
"RE_tos_Omon_INM-CM4-8_historical_r1i1p1f1_gr1_185001-201412.nc",\
"RE_tos_Omon_MRI-ESM2-0_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_GFDL-ESM4_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_FGOALS-g3_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_IPSL-CM6A-LR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CanESM5_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_INM-CM5-0_historical_r1i1p1f1_gr1_185001-201412.nc",\
"RE_tos_Omon_GISS-E2-1-H_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_ACCESS-CM2_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_IITM-ESM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_GISS-E2-1-G_historical_r1i1p1f1_gn_185001-201412.nc"/)


;=================------------------------=====================-----------------

S_B_Cat1 = (/"RE_tos_Omon_ACCESS-CM2_historical_r1i1p1f1_gn_185001-201412.nc",\  ;cat1
"RE_tos_Omon_GFDL-ESM4_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc"/)

S_B_Cat2 = (/"RE_tos_Omon_NESM3_historical_r1i1p1f1_gn_185001-201412.nc",\       ;cat2
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
"RE_tos_Omon_MIROC6_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_NorESM2-LM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_MPI-ESM1-2-LR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CanESM5_historical_r1i1p1f1_gn_185001-201412.nc",\                  ;cat3
"RE_tos_Omon_E3SM-1-1-ECA_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_INM-CM4-8_historical_r1i1p1f1_gr1_185001-201412.nc",\
"RE_tos_Omon_MPI-ESM1-2-HR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_EC-Earth3_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_CAS-ESM2-0_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_IPSL-CM6A-LR_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_KACE-1-0-G_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_E3SM-1-1_historical_r1i1p1f1_gr_185001-201412.nc",\
"RE_tos_Omon_IITM-ESM_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_GISS-E2-1-H_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_TaiESM1_historical_r1i1p1f1_gn_185001-201412.nc",\
"RE_tos_Omon_GISS-E2-1-G_historical_r1i1p1f1_gn_185001-201412.nc"/)

end
