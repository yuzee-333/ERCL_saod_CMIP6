begin

;this script is for calculating and generating 2 ncl files (for Cat 1 and Cat 2)
;used to calculate the MMM of ssp585 Cat 1 models as well as the ensemble of all
;the other models. Will be attached to regression bar plot (@ script 31...);

modelNames = (/"RE_tos_Omon_ACCESS-ESM1-5_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_ACCESS-CM2_ssp585_r1i1p1f1_gn_201501-210012.nc",\
;"RE_tos_Omon_AWI-CM-1-1-MR_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_BCC-CSM2-MR_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_CAMS-CSM1-0_ssp585_r1i1p1f1_gn_201501-209912.nc",\
"RE_tos_Omon_CanESM5_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_CAS-ESM2-0_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_CESM2_ssp585_r11i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_CESM2-WACCM_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_CMCC-CM2-SR5_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_CMCC-ESM2_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_E3SM-1-0_ssp585_r1i1p1f1_gr_201501-209912.nc",\
"RE_tos_Omon_E3SM-1-1-ECA_ssp585_r1i1p1f1_gr_201501-210012.nc",\
"RE_tos_Omon_E3SM-1-1_ssp585_r1i1p1f1_gr_201501-210012.nc",\
"RE_tos_Omon_EC-Earth3-CC_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_EC-Earth3_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_FGOALS-f3-L_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_FGOALS-g3_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_FIO-ESM-2-0_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_GFDL-ESM4_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_GISS-E2-1-G_ssp585_r1i1p1f2_gn_201501-210012.nc",\
"RE_tos_Omon_GISS-E2-1-H_ssp585_r1i1p1f2_gn_201501-210012.nc",\
"RE_tos_Omon_IITM-ESM_ssp585_r1i1p1f1_gn_201501-209912.nc",\
"RE_tos_Omon_INM-CM4-8_ssp585_r1i1p1f1_gr1_201501-210012.nc",\
"RE_tos_Omon_INM-CM5-0_ssp585_r1i1p1f1_gr1_201501-210012.nc",\
"RE_tos_Omon_IPSL-CM6A-LR_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_KACE-1-0-G_ssp585_r1i1p1f1_gr_201501-210012.nc",\
"RE_tos_Omon_MIROC6_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_MPI-ESM1-2-HR_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_MPI-ESM1-2-LR_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_MRI-ESM2-0_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_NESM3_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_NorESM2-LM_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_NorESM2-MM_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_TaiESM1_ssp585_r1i1p1f1_gn_201501-210012.nc"/)
;==============================================================================

N_A_Cat1 = (/"RE_tos_Omon_MRI-ESM2-0_ssp585_r1i1p1f1_gn_201501-210012.nc",\  ;cat1
"RE_tos_Omon_CMCC-CM2-SR5_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_IPSL-CM6A-LR_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_CanESM5_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_CMCC-ESM2_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_MPI-ESM1-2-HR_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_NorESM2-MM_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_INM-CM5-0_ssp585_r1i1p1f1_gr1_201501-210012.nc",\
"RE_tos_Omon_FIO-ESM-2-0_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_EC-Earth3-CC_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_ACCESS-ESM1-5_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_EC-Earth3_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_MIROC6_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_GISS-E2-1-H_ssp585_r1i1p1f2_gn_201501-210012.nc"/)

N_A_Cat2 = (/"RE_tos_Omon_FGOALS-g3_ssp585_r1i1p1f1_gn_201501-210012.nc",\             ;cat2
"RE_tos_Omon_CESM2-WACCM_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_KACE-1-0-G_ssp585_r1i1p1f1_gr_201501-210012.nc",\
"RE_tos_Omon_TaiESM1_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_CESM2_ssp585_r11i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_GFDL-ESM4_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_BCC-CSM2-MR_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_CAMS-CSM1-0_ssp585_r1i1p1f1_gn_201501-209912.nc",\
"RE_tos_Omon_INM-CM4-8_ssp585_r1i1p1f1_gr1_201501-210012.nc",\
"RE_tos_Omon_NESM3_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_ACCESS-CM2_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_GISS-E2-1-G_ssp585_r1i1p1f2_gn_201501-210012.nc",\          ;cat3
"RE_tos_Omon_E3SM-1-1_ssp585_r1i1p1f1_gr_201501-210012.nc",\
"RE_tos_Omon_E3SM-1-0_ssp585_r1i1p1f1_gr_201501-209912.nc",\
"RE_tos_Omon_IITM-ESM_ssp585_r1i1p1f1_gn_201501-209912.nc",\
"RE_tos_Omon_E3SM-1-1-ECA_ssp585_r1i1p1f1_gr_201501-210012.nc",\
;"RE_tos_Omon_AWI-CM-1-1-MR_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_FGOALS-f3-L_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_MPI-ESM1-2-LR_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_NorESM2-LM_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_CAS-ESM2-0_ssp585_r1i1p1f1_gn_201501-210012.nc"/)
;+++++++++++++++++++++++========================================================


C_A_Cat1 = (/"RE_tos_Omon_E3SM-1-1_ssp585_r1i1p1f1_gr_201501-210012.nc",\   ;cat1
"RE_tos_Omon_E3SM-1-1-ECA_ssp585_r1i1p1f1_gr_201501-210012.nc",\
"RE_tos_Omon_BCC-CSM2-MR_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_ACCESS-CM2_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_E3SM-1-0_ssp585_r1i1p1f1_gr_201501-209912.nc",\
"RE_tos_Omon_CESM2_ssp585_r11i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_INM-CM4-8_ssp585_r1i1p1f1_gr1_201501-210012.nc",\
"RE_tos_Omon_FGOALS-g3_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_MIROC6_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_IITM-ESM_ssp585_r1i1p1f1_gn_201501-209912.nc",\
"RE_tos_Omon_INM-CM5-0_ssp585_r1i1p1f1_gr1_201501-210012.nc",\
"RE_tos_Omon_MPI-ESM1-2-HR_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_KACE-1-0-G_ssp585_r1i1p1f1_gr_201501-210012.nc",\
"RE_tos_Omon_EC-Earth3_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_FIO-ESM-2-0_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_CMCC-CM2-SR5_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_EC-Earth3-CC_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_CMCC-ESM2_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_ACCESS-ESM1-5_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_NorESM2-MM_ssp585_r1i1p1f1_gn_201501-210012.nc"/)

C_A_Cat2 =(/"RE_tos_Omon_CESM2-WACCM_ssp585_r1i1p1f1_gn_201501-210012.nc",\          ;cat2
"RE_tos_Omon_CAS-ESM2-0_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_MRI-ESM2-0_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_NESM3_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_IPSL-CM6A-LR_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_FGOALS-f3-L_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_MPI-ESM1-2-LR_ssp585_r1i1p1f1_gn_201501-210012.nc",\
;"RE_tos_Omon_AWI-CM-1-1-MR_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_NorESM2-LM_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_TaiESM1_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_CAMS-CSM1-0_ssp585_r1i1p1f1_gn_201501-209912.nc",\
"RE_tos_Omon_GFDL-ESM4_ssp585_r1i1p1f1_gn_201501-210012.nc",\            ;cat3
"RE_tos_Omon_GISS-E2-1-G_ssp585_r1i1p1f2_gn_201501-210012.nc",\
"RE_tos_Omon_GISS-E2-1-H_ssp585_r1i1p1f2_gn_201501-210012.nc",\
"RE_tos_Omon_CanESM5_ssp585_r1i1p1f1_gn_201501-210012.nc"/)

;=======================-------------------------------=========================

G_C_Cat1 = (/"RE_tos_Omon_FIO-ESM-2-0_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_CMCC-ESM2_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_NorESM2-LM_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_CMCC-CM2-SR5_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_ACCESS-ESM1-5_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_NorESM2-MM_ssp585_r1i1p1f1_gn_201501-210012.nc"/)

G_C_Cat2 = (/"RE_tos_Omon_E3SM-1-1-ECA_ssp585_r1i1p1f1_gr_201501-210012.nc",\         ;cat2
"RE_tos_Omon_EC-Earth3-CC_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_BCC-CSM2-MR_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_E3SM-1-1_ssp585_r1i1p1f1_gr_201501-210012.nc",\
"RE_tos_Omon_CAS-ESM2-0_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_MPI-ESM1-2-HR_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_NESM3_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_CESM2_ssp585_r11i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_MIROC6_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_CESM2-WACCM_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_MPI-ESM1-2-LR_ssp585_r1i1p1f1_gn_201501-210012.nc",\
;"RE_tos_Omon_AWI-CM-1-1-MR_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_EC-Earth3_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_KACE-1-0-G_ssp585_r1i1p1f1_gr_201501-210012.nc",\
"RE_tos_Omon_E3SM-1-0_ssp585_r1i1p1f1_gr_201501-209912.nc",\
"RE_tos_Omon_CAMS-CSM1-0_ssp585_r1i1p1f1_gn_201501-209912.nc",\
"RE_tos_Omon_TaiESM1_ssp585_r1i1p1f1_gn_201501-210012.nc",\              ;cat3
"RE_tos_Omon_INM-CM4-8_ssp585_r1i1p1f1_gr1_201501-210012.nc",\
"RE_tos_Omon_MRI-ESM2-0_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_GFDL-ESM4_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_FGOALS-g3_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_IPSL-CM6A-LR_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_CanESM5_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_INM-CM5-0_ssp585_r1i1p1f1_gr1_201501-210012.nc",\
"RE_tos_Omon_GISS-E2-1-H_ssp585_r1i1p1f2_gn_201501-210012.nc",\
;"RE_tos_Omon_FGOALS-f3-L_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_ACCESS-CM2_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_IITM-ESM_ssp585_r1i1p1f1_gn_201501-209912.nc",\
"RE_tos_Omon_GISS-E2-1-G_ssp585_r1i1p1f2_gn_201501-210012.nc"/)


;=================------------------------=====================-----------------

S_B_Cat1 = (/"RE_tos_Omon_ACCESS-CM2_ssp585_r1i1p1f1_gn_201501-210012.nc",\  ;cat1
"RE_tos_Omon_GFDL-ESM4_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_ACCESS-ESM1-5_ssp585_r1i1p1f1_gn_201501-210012.nc"/)

S_B_Cat2 = (/"RE_tos_Omon_NESM3_ssp585_r1i1p1f1_gn_201501-210012.nc",\               ;cat2
"RE_tos_Omon_FIO-ESM-2-0_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_CMCC-ESM2_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_CESM2_ssp585_r11i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_EC-Earth3-CC_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_MRI-ESM2-0_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_CMCC-CM2-SR5_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_NorESM2-MM_ssp585_r1i1p1f1_gn_201501-210012.nc",\
;"RE_tos_Omon_AWI-CM-1-1-MR_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_CAMS-CSM1-0_ssp585_r1i1p1f1_gn_201501-209912.nc",\
"RE_tos_Omon_INM-CM5-0_ssp585_r1i1p1f1_gr1_201501-210012.nc",\
"RE_tos_Omon_BCC-CSM2-MR_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_FGOALS-g3_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_CESM2-WACCM_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_E3SM-1-0_ssp585_r1i1p1f1_gr_201501-209912.nc",\
"RE_tos_Omon_MIROC6_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_NorESM2-LM_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_MPI-ESM1-2-LR_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_CanESM5_ssp585_r1i1p1f1_gn_201501-210012.nc",\             ;cat3
"RE_tos_Omon_E3SM-1-1-ECA_ssp585_r1i1p1f1_gr_201501-210012.nc",\
"RE_tos_Omon_INM-CM4-8_ssp585_r1i1p1f1_gr1_201501-210012.nc",\
"RE_tos_Omon_MPI-ESM1-2-HR_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_EC-Earth3_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_CAS-ESM2-0_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_IPSL-CM6A-LR_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_KACE-1-0-G_ssp585_r1i1p1f1_gr_201501-210012.nc",\
"RE_tos_Omon_E3SM-1-1_ssp585_r1i1p1f1_gr_201501-210012.nc",\
"RE_tos_Omon_FGOALS-f3-L_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_IITM-ESM_ssp585_r1i1p1f1_gn_201501-209912.nc",\
"RE_tos_Omon_GISS-E2-1-H_ssp585_r1i1p1f2_gn_201501-210012.nc",\
"RE_tos_Omon_TaiESM1_ssp585_r1i1p1f1_gn_201501-210012.nc",\
"RE_tos_Omon_GISS-E2-1-G_ssp585_r1i1p1f2_gn_201501-210012.nc"/)


end
