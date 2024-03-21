; FOR MANUSCRIPT
; To average the Regression coefficient values...MMM
;----extract values from NC file generated above and write to csv ----

; " This script will generate nc files holding the mean rainfall and mean sst of \
;all the models, and also plot them."

begin

load "names_cat1hist_rev.ncl"

hdata_names = new((/dimsizes(modelNames)/),string,1e+20)                      ;
  do i=0,dimsizes(modelNames)-1,1
    modname = getSubString(modelNames(i),12,30)
    ;print(modname)
    hdata_names(i) = modname
  end do
  delete(i)
print(hdata_names)

TEST_OVER        = False
if (TEST_OVER) then
scenario = (/"Hist", "Proj"/)
;do sce=0, dimsizes(scenario)-1,1
do sce=0,0,1


if (scenario(sce).eq."Hist") then
 load "names_cat1hist_rev.ncl"
 diriT  = "/home/yuzee/DATA/cmip6/historical/tos/"    ;for sst
 diri   = "/home/yuzee/DATA/cmip6/historical/pr/"    ; for pr
 yrStrt = 1950
 yrLast = 2014

else
 ;load "names_cat1proj.ncl"
 diriT  = "/home/yuzee/nclfolder/DATA/cmip6/projection/tos/"    ;for sst
 diri   = "/home/yuzee/nclfolder/DATA/cmip6/projection/pr/"     ; for pr
 yrStrt = 2015
 yrLast = 2079
end if


;############################################################################################################

GENERATE_NCFILES = False
WRITE_RESULTS    = True
season  = "JJA"
varT    = "tos"
var     = "pr"
diro   = "/home/yuzee/RESULTS/mean_maps/"
filo   = scenario(sce)+"_All"+var+"_mean_"+season+".nc"
filos  = scenario(sce)+"_All"+varT+"_mean_"+season+".nc"

;###############################################################################################################



; ===  FOR HISTORICAL CALCULATION =============================================
;========== generate saodi index ===================

 day_factor = 86400.			; # seconds in in a day
;=====================================================================================================
 ;==========================read-in PR and SST datafiles===============================================================================

;=========setting up the lon and lat coordinates for each box per season =======

  hdataT = modelNames
  printVarSummary(hdataT)                                                   ;
;===============================================================================
;---------------Generate List of model names based on contents of hdataT------------------------------------

hdata_names = new((/dimsizes(hdataT)/),string,1e+20)                      ;
  do i=0,dimsizes(hdataT)-1,1
  modname = getSubString(hdataT(i),12,30)
  ;print(modname)
  hdata_names(i) = modname
  end do
print(hdata_names)

;=========^^^^^^^%%%%%%%%%%%%%%%%%%%%%%^^^^&&&&&&&**********==========
;
;======================== generate list of Pr Datafiles  ===============================================================


hdata = new((/dimsizes(hdataT)/),string,1e+20)

  do q=0,dimsizes(hdataT)-1,1
  prname = getSubString(hdataT(q),0,2)+"pr_Amon_"+getSubString(hdataT(q),12,-1)
  ;print(prname)
  hdata(q) = prname
  end do
print(hdata)              ;generate Pr datafile names from hdataT
print(hdataT)

;===================-----------=====================-----------------------=====================

 prDATA  = new((/dimsizes(hdataT),72,144/),float,1e+20)    ;array to hold mean rainfall
 sstDATA = new((/dimsizes(hdataT),180,360/),float, 1e+20)   ;array to hold mean sst's
; siglev  = new((/dimsizes(hdataT)/),float, 1e+20)   ;extraf

if (GENERATE_NCFILES) then

print("=================================================")
print("================= Start Pr Loop "+scenario(sce)+" =======================")

do nn=0,dimsizes(hdataT)-1,1
;do nn=0,1,1
print("=================================================")
;print(nn)
print("=================================================")
title  = str_upper(var)+": "+hdata_names(nn)
print(title)
delete(title)

; Read variable; compute monthly climatology; annual mean
;***************************************************************
;----------------RAINFALL -----------------------------------------------------
 f      = addfiles(diri+hdata,"r")
 TIME   = f[nn]->time
 YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
 iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
 PRC    = f[nn]->$var$(iYYYY,:,:)
 PRC    = PRC*day_factor
 ;printVarSummary(PRC)       ; variable overview
 ;printMinMax(PRC,True)

 delete(f)
 delete(TIME)
 delete(YYYY)
 delete(iYYYY)

 PRC = lonFlip(PRC)

 ;------------ RAINFALL annual mean ----------------------------------
 prc_clm = clmMonTLL(PRC)                         ; compute monthly climatology
 printVarSummary(prc_clm)                         ; (12,lat,lon)

 prc_clm  = where(prc_clm.lt.0.10, 0.0, prc_clm)  ; set small values to 0.0
 printMinMax(prc_clm,True)
 prc_ann2  = month_to_season(prc_clm,season)
 ;printVarSummary(prc_ann2)
 print("------------rainfall for "+hdata_names(nn)+" JJA season---------------")
 printMinMax(prc_ann2, True)
   ;  [[  prc_ann1  = prc_ann2/jja_day_factor  ; for Obs   ]]           ;

 prc_ann  = dim_avg_n_Wrap(prc_ann2, 0)            ; compute annual rainfall mean ;(arithmetic);
 printVarSummary(prc_ann)                          ; from monthly climatologies
 printMinMax(prc_ann, True)

; clat     = latRegWgt( prc_ann&lat, "float", 0)   ; lwt weights
; prcAvg   = wgt_areaave( prc_ann, clat, 1.0, 0)   ; areal average

 prDATA(nn,:,:)  =  prc_ann                            ;write to array
 prDATA!0  = "model"

 delete(PRC)
 delete(prc_clm)
 delete(prc_ann2)
 end do                                   ;end loop over models for pr values


 printVarSummary(prDATA)
 printMinMax(prDATA, True)


;*******************************************************************************
;---Save to a netcdf file, in the current directory
;*******************************************************************************

 if (WRITE_RESULTS)
     ;filoname = filo+"rainfall_models.nc"
     ptho = diro+filo
     system("/bin/rm -f "+ptho)
     ncdf = addfile(ptho,"c")

     fAtt = True
     fAtt@title         = "Mean rainfall from CMIP6 Models"
     fAtt@source_name   = "CMIP6 historical runs"

     fAtt@source_URL    = "https://esgf-node.llnl.gov/projects/cmip6/"
     fAtt@source        = "Accessed from Levante Supercomputer, Hamburg, Germany"
     fAtt@Conventions   = "None"
     fAtt@creation_date = systemfunc("date")
     fileattdef(ncdf,fAtt)            ; copy file attributes

;    filedimdef(ncdf,"time",-1,True) ; make time an UNLIMITED dimension


      ncdf->allmean_rain    = prDATA

     print("---------------all pr nc file for "+scenario(sce)+"_DONE----------------------")
end if




 ;******************************-----------------*******************************
 ;==============================================================================
 ;==============================================================================
 ;=========================SST MEAN CALC =======================================

 ;==============================================================================


do nn=0,dimsizes(hdataT)-1,1
 ;do nn=0,1,1

 f     = addfiles(diriT+hdataT,"r")
 TIME   = f[nn]->time
 YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
 iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
 GSST   = f[nn]->$varT$(iYYYY,:,:)
 ;printVarSummary(GSST)       ; variable overview
 ;printMinMax(GSST,True)

 delete(f)
 delete(TIME)
 delete(YYYY)
 delete(iYYYY)

 GSST = lonFlip(GSST)


 ;------------ SST annual mean ----------------------------------

 sst_clm = clmMonTLL(GSST)                            ; compute monthly climatology
 printVarSummary(sst_clm)                             ; (12,lat,lon)
 printMinMax(sst_clm, True)
 sst_clm  = where(sst_clm.lt.0.10, 0.0, sst_clm)      ; set small values to 0.0

 sst_ann2  = month_to_season(sst_clm,season)
 sst_cord  = sst_ann2
print("------------SST "+hdata_names(nn)+" for JJA season---------------------")
 ;printVarSummary(sst_ann2)                             ; (12,lat,lon)
 printMinMax(sst_ann2, True)

 sst_ann  = dim_avg_n_Wrap(sst_ann2, 0)               ; compute annual mean ;(arithmetic);
 ;printVarSummary(sst_ann)                             ; from monthly climatologies


 ;clat1     = latRegWgt( sst_ann&lat, "float", 0)      ; lwt weights
 ;prcAvg1   = wgt_areaave( sst_ann, clat1, 1.0, 0)     ; areal average

 sstDATA(nn,:,:) =  sst_ann                                ;write to array
 sstDATA!0 = "model"

 delete(GSST)
 delete(sst_clm)
 delete(sst_ann2)
;==========================================================================
end do                                                 ;end 'nn' loop over model list
delete(nn)

printVarSummary(sstDATA)
printMinMax(sstDATA, True)

;***********************************************
;---Save to a netcdf file, in the current directory
;***********************************************

 if (WRITE_RESULTS)
     filoname = filo+"rainfall_models.nc"
     pthos = diro+filos
     system("/bin/rm -f "+pthos)
     ncdf = addfile(pthos,"c")

     fAtt = True
     fAtt@title         = "Mean SST from CMIP6 Models"
     fAtt@source_name   = "CMIP6 historical runs"

     fAtt@source_URL    = "https://esgf-node.llnl.gov/projects/cmip6/"
     fAtt@source        = "Accessed from Levante Supercomputer, Hamburg, Germany"
     fAtt@Conventions   = "None"
     fAtt@creation_date = systemfunc("date")
     fileattdef(ncdf,fAtt)            ; copy file attributes

;    filedimdef(ncdf,"time",-1,True) ; make time an UNLIMITED dimension
     ncdf->allmean_sst   = sstDATA

print("---------------all sst nc file for "+scenario(sce)+"_DONE----------------------")
end if

delete(hdataT)
delete(hdata)
delete(hdata_names)
delete(prDATA)
delete(sstDATA)
delete(modelNames)
delete(N_A_Cat1)
delete(N_A_Cat2)
delete(C_A_Cat1)
delete(C_A_Cat2)
delete(G_C_Cat1)
delete(G_C_Cat2)
delete(S_B_Cat1)
delete(S_B_Cat2)

print("=================="+scenario(sce)+" DONE=========================================")

end if                                                     ;end GENERATE_NCFILES if
end do                                                        ;end scenario loop
end if                                                           ;end TEST_OVER if 

print("==================END OF FIRST PART =========================================")
print("==================END OF FIRST PART =========================================")
print("==================END OF FIRST PART =========================================")


















































scenario = (/"Hist", "Proj"/)
;do sce=0, dimsizes(scenario)-1,1
do sce=0,0,1


yrStrt= 1950
yrLast= 2014
season = "JJA"
dpmm  = (/30,31,31/)
jja_day_factor  = avg(dpmm)

ZOOM     = (/0,1/)
pltType  = (/"eps","png"/)

var  = "pr"
varT = "tos"

; ======------------ make calculations for Obs Pr and sst datafiles ------------======================  ;;

obsdiro = "/home/yuzee/mywork/DATA/obs/"

;----------------Obs Pr ---------------------------------------------------------
;----------------RAINFALL -----------------------------------------------------
 OBS_P   = addfile(obsdiro+"precip/Gpcp_precip.mon.mean_.nc", "r")
 TIME   = OBS_P->time
 YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
 iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
 oPRC    = OBS_P->precip(iYYYY,:,:)
 printVarSummary(oPRC)       ; variable overview
 printMinMax(oPRC,True)

 delete(TIME)
 delete(YYYY)
 delete(iYYYY)
 oPRC = lonFlip(oPRC)

 ;------------ RAINFALL annual mean ----------------------------------
 prc_clm = clmMonTLL(oPRC)                         ; compute monthly climatology
 printVarSummary(prc_clm)                         ; (12,lat,lon)

 prc_clm  = where(prc_clm.lt.0.10, 0.0, prc_clm)  ; set small values to 0.0
 printMinMax(prc_clm,True)
 prc_ann2  = month_to_season(prc_clm,season)
                            ;prc_ann2 = prc_ann2/jja_day_factor
 ;printVarSummary(prc_ann2)
 print("------------rainfall for Obs JJA season---------------")
 printMinMax(prc_ann2, True)

 obs_prc_ann  = dim_avg_n_Wrap(prc_ann2, 0)            ; compute annual rainfall mean ;(arithmetic);
 printVarSummary(obs_prc_ann)                          ; from monthly climatologies
 printMinMax(obs_prc_ann, True)

 delete(oPRC)
 delete(prc_clm)
 delete(prc_ann2)

 ;----------------Obs SST ------------------------------------------------------
 ;----------------Sea Surface Temperature --------------------------------------
 OBS_SST = addfile(obsdiro+"sst/HadISST_sst.nc", "r")
 TIME   = OBS_SST->time
 YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
 iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
 oGSST   = OBS_SST->sst(iYYYY,:,:)
 printVarSummary(oGSST)       ; variable overview
 ;printMinMax(oGSST,True)

 delete(TIME)
 delete(YYYY)
 delete(iYYYY)

 ;oGSST = lonFlip(oGSST)

  sst_clm = clmMonTLL(oGSST)                            ; compute monthly climatology
 printVarSummary(sst_clm)                             ; (12,lat,lon)
 printMinMax(sst_clm, True)
 sst_clm  = where(sst_clm.lt.0.10, 0.0, sst_clm)      ; set small values to 0.0
 sst_ann2  = month_to_season(sst_clm,season)
 sst_cord  = sst_ann2
 print("------------obs SST for JJA season---------------------")
 ;printVarSummary(sst_ann2)                             ; (12,lat,lon)
 printMinMax(sst_ann2, True)

 obs_sst_ann  = dim_avg_n_Wrap(sst_ann2, 0)               ; compute annual mean ;(arithmetic);
 printVarSummary(obs_sst_ann)                             ; from monthly climatologies
 printMinMax(obs_sst_ann, True)

 ;delete(oGSST)
 delete(sst_clm)
 delete(sst_ann2)

;==========================+++++++++++++++++++++++++++++++++++++========================================
;========--------read-in All models' ncfiles created in script 43-------------------------==============
;+++++++++++++++++++++++++++======================================++++++++++++++++++++++++++++++++++++++

diro    = "/home/yuzee/mywork/ERCL_manuscript/UZ_work_latest/RESULTS/mean_maps/"
filo    = scenario(sce)+"_All"+var+"_mean_"+season+".nc"
filos   = scenario(sce)+"_All"+varT+"_mean_"+season+".nc"
P       = addfile(diro+filo, "r")
SST     = addfile(diro+filos, "r")

pr_nc   = P  ->allmean_rain(:,:,:)
pr_nc&model = hdata_names
printVarSummary(pr_nc)
printMinMax(pr_nc, True)

sst_nc  = SST->allmean_sst(:,:,:)
sst_nc&model = hdata_names
printVarSummary(sst_nc)
printMinMax(sst_nc, True)



;==========---- Calculating the averages   -------------=====================================

 pr_avg    = dim_avg_n(pr_nc, (0))    ;average of models mean rainfall values, the MMM
 copy_VarCoords(obs_prc_ann, pr_avg)
 printVarSummary(pr_avg)
 printMinMax(pr_avg, True)

 arrysst    = sst_nc                                                ;arry2 = textf ->sstDATA(:)
 sst_avg    = dim_avg_n(arrysst, (0))
 copy_VarCoords(obs_sst_ann,sst_avg)
 arrysst2   = sst_avg
 ;printVarSummary(sst_avg)
 printMinMax(sst_avg, True)

 delete(arrysst)
 ;delete(arry2)
































 ;------------------------------ DIFFERENCES ----------------------------------------

;----------------- PR --------------------------------------------------------------
threshold = round(0.95*dimsizes(pr_nc&model),3)    ;using 95% of the total number of models  ;;;
print(threshold)
nobs      = (/"pos","neg"/)

diff_pr      = pr_avg - obs_prc_ann
copy_VarCoords(obs_prc_ann, diff_pr)
printVarSummary(diff_pr)
printMinMax(diff_pr, True)

imodel_bias_pr = new((/dimsizes(pr_nc)/), float)
printVarSummary(imodel_bias_pr)
  do im=0,dimsizes(pr_nc&model)-1,1
    idiff_pr = pr_nc(im,:,:) - obs_prc_ann
    ;printVarSummary(idiff_pr)
    imodel_bias_pr(im,:,:) = idiff_pr
    delete(idiff_pr)
  end do 
  delete(im)
copy_VarCoords(pr_nc, imodel_bias_pr)
printVarSummary(imodel_bias_pr)
printMinMax(imodel_bias_pr, True)

printVarSummary(pr_nc)
printMinMax(pr_nc, True)

pos_mask_pr = where(imodel_bias_pr.gt.0,imodel_bias_pr,0)        ;/model x lat x lon/
neg_mask_pr = where(imodel_bias_pr.lt.0,imodel_bias_pr,0)
aa_pr       = dim_num_n(pos_mask_pr.ne.0, 0)                     ;/lat x lon/
nn_pr       = dim_num_n(neg_mask_pr.ne.0, 0)
aa_pr_filt  = aa_pr
;aa_pr_filt  = where(aa_pr.ge.threshold, aa_pr_filt, 0)
aa_pr_filt  = where(aa_pr.ge.threshold, aa_pr_filt, aa_pr_filt@_FillValue)
nn_pr_filt  = nn_pr
;nn_pr_filt  = where(nn_pr.ge.threshold, nn_pr_filt, 0)
nn_pr_filt  = where(nn_pr.ge.threshold, nn_pr_filt, nn_pr_filt@_FillValue)
;pr_filt     = aa_pr_filt + nn_pr_filt
    pr_filt     = new((/2,dimsizes(diff_pr&lat),dimsizes(diff_pr&lon) /),float)
    pr_filt(0,:,:) = aa_pr_filt
    pr_filt(1,:,:) = nn_pr_filt
    pr_filtt   = dim_sum_n_Wrap(pr_filt,0)
    ;print(pr_filt)
;print(aa_pr_filt)
printVarSummary(pr_filt)
printMinMax(pr_filt, True)

copy_VarCoords(pr_nc(0,:,:), pr_filtt)
copy_VarCoords(pr_nc(0,:,:), pr_filt(0,:,:))
;pr_filt!0 = "nobs"
;pr_filt&nobs = nobs 
printVarSummary(pr_filtt)
printMinMax(pr_filtt, True)
;print(aa_pr)


delete(pos_mask_pr)
delete(neg_mask_pr)
delete(aa_pr)
delete(nn_pr)
delete(aa_pr_filt)
delete(nn_pr_filt)

;---------------------SST ---------------------------------------------------


diff_sst      = sst_avg - obs_sst_ann
copy_VarCoords(obs_sst_ann,diff_sst)
dif_sst   = diff_sst
copy_VarCoords(obs_sst_ann,dif_sst)
printVarSummary(dif_sst)
printMinMax(dif_sst, True)

imodel_bias_sst = new((/dimsizes(sst_nc)/), float)
printVarSummary(imodel_bias_sst)
  do im=0,dimsizes(sst_nc&model)-1,1
    idiff_sst = sst_nc(im,:,:) - obs_sst_ann
    ;printVarSummary(idiff_sst)
    imodel_bias_sst(im,:,:) = idiff_sst
    delete(idiff_sst)
  end do 
  delete(im)
copy_VarCoords(sst_nc, imodel_bias_sst)
printVarSummary(imodel_bias_sst)
printMinMax(imodel_bias_sst, True)

printVarSummary(sst_nc)
printMinMax(sst_nc, True)

pos_mask_sst = where(imodel_bias_sst.gt.0,imodel_bias_sst,0)
neg_mask_sst = where(imodel_bias_sst.lt.0,imodel_bias_sst,0)
aa_sst       = dim_num_n(pos_mask_sst.ne.0, 0)
nn_sst       = dim_num_n(neg_mask_sst.ne.0, 0)
aa_sst_filt  = aa_sst
;aa_sst_filt = where(aa_sst.ge.threshold, aa_sst_filt, 0)
aa_sst_filt  = where(aa_sst.ge.threshold, aa_sst_filt, aa_sst_filt@_FillValue)
nn_sst_filt  = nn_sst
;nn_sst_filt = where(nn_sst.ge.threshold, nn_sst_filt, 0)
nn_sst_filt  = where(nn_sst.ge.threshold, nn_sst_filt, nn_sst_filt@_FillValue)
;sst_filt    = aa_sst_filt + nn_sst_filt
  sst_filt     = new((/2,dimsizes(sst_nc&lat),dimsizes(sst_nc&lon) /),float)
  sst_filt(0,:,:) = aa_sst_filt
  sst_filt(1,:,:) = nn_sst_filt
  sst_filtt   = dim_sum_n_Wrap(sst_filt,0)

;print(aa_sst_filt)
;printVarSummary(sst_filt)
;printMinMax(sst_filt, True)
;printVarSummary(aa_sst)
;printMinMax(aa_sst, True)



copy_VarCoords(sst_nc(0,:,:), sst_filtt)
copy_VarCoords(sst_nc(0,:,:), sst_filt(0,:,:))
;sst_filt!0 = "nobs"
;sst_filt&nobs = nobs 
printVarSummary(sst_filtt)
printMinMax(sst_filtt, True)
;print(sst_filt)



delete(pos_mask_sst)
delete(neg_mask_sst)
delete(aa_sst)
delete(nn_sst)
delete(aa_sst_filt)
delete(nn_sst_filt)












































;===============================================================================
;++++++++++++++++++++++++++++++-------------------------++++++++++++++++++++++++
;---------------------------==================================------------------
;====================to plot ===================================================


PLOT_RESULTS = True
if(PLOT_RESULTS)


nplots = 2
latSp = -60
latNp =  32
lonLp = -80
lonRp =  40

do zz=0,dimsizes(ZOOM)-1,1                           ;start zoom loop
 do pc=0,dimsizes(pltType)-1,1

 ; pltDir  = "/home/yuzee/RESULTS/mean_maps/"                                    ;dir to which plots are sent
  pltDir  = "/home/yuzee/mywork/ERCL_manuscript/rev2/Fig3/"

  if (ZOOM(zz).eq.1) then
    pltName = "irev2Fig_2mini_"+scenario(sce)+"_Obs_vs_Allmodels_meanmaps_zoom_"+season
 else
   pltName = "irev2Fig_2mini_"+scenario(sce)+"_Obs_vs_Allmodels_meanmaps_global_"+season
  end if

pltPath= pltDir+pltName+"."+pltType
wks    = gsn_open_wks(pltType(pc), pltDir+pltName)
plot = new(nplots,graphic)
plotS = new(nplots,graphic)

  

  res                      = True     ; plot mods desired
  res@gsnDraw              = False        ; don't draw yet
  res@gsnFrame             = False        ; don't advance frame yet
  res@gsnMaximize          = True     ; make ps/eps/pdf large

  res@cnFillOn             = True     ; turn on color fill
  res@cnLinesOn            = False    ; turn of contour lines
  res@cnFillMode           = "RasterFill" ; Raster Mode
  res@cnRasterSmoothingOn  = True
  res@cnLineLabelsOn       = False       ; Turn off contour lines
  res@cnFillPatterns       = True
  res@gsnPaperOrientation  = "portrait"
  ;res@cnFillDrawOrder      = "PostDraw"


  res@lbOrientation             = "vertical"   ; vertical label barb's
  res@lbLabelFontHeightF        = 0.012        ; change font size
  res@pmLabelBarWidthF          =  0.1
  res@pmLabelBarOrthogonalPosF  = -0.01    ; move a bit to left

  res@mpFillOn                  = False
  ;res@cnLevelSelectionMode    =  "AutomaticLevels"

  if (ZOOM(zz).eq.1) then
    res@mpMinLatF              = latSp         ; zoom in on map
    res@mpMaxLatF              = latNp
    res@mpMinLonF              = lonLp
    res@mpMaxLonF              = lonRp
    res@gsnLeftStringFontHeightF  = 0.03
  else
    res@mpMinLatF              = -90        ; zoom in on map
    res@mpMaxLatF              =  90
    res@mpMinLonF              = -180
    res@mpMaxLonF              =  180
    res@gsnLeftStringFontHeightF  = 0.025
  end if
; res@mpCenterLonF              = 220.         ; don't split Africa
; res@tiMainString              = "Mean JJA maps : "+yrStrt+"-"+yrLast
; res@gsnCenterString           = "Areal Mean="+sprintf("%4.2f",  prcAvg)+" mm/mon"

         ;Panel plot resources

   resP                      = True         ; modify the panel plot
   resP@gsnMaximize          = True         ; large format
   resP@gsnPanelLabelBar     = False         ; add common colorbar
   resP@gsnPaperOrientation  = "portrait"
   resP@tiMainFontHeightF    =  0.01

   ; Set contour options for significance plot    ;;;
    sig_res                   = True
    sig_res@gsnDraw           = False
    sig_res@cnFillOn          = True
    sig_res@cnFillMode        = "AreaFill"
    sig_res@cnFillPattern     = 17
    sig_res@cnMonoFillColor   = True
    sig_res@cnFillColor       = "black"
    sig_res@cnFillDotSizeF    = 0.003
    sig_res@cnLinesOn         = False
    sig_res@cnLineLabelsOn    = False
    sig_res@cnInfoLabelOn     = False
    sig_res@cnLineDashPattern = 4
    sig_res@cnFillDrawOrder   = "PostDraw"
    sig_res@lbLabelBarOn      = False 

   tres       =  True
   if(ZOOM(zz).eq.0) then
   tres@txFontHeightF = 0.02
   else
   tres@txFontHeightF = 0.03
   end if


;*******************************************************************************
; combined plot
;*******************************************************************************
 do n=0,nplots-2

 ;----------------------sst plot ----------------------------------------------


      res@cnLevelSpacingF         =  1
      res@cnMaxLevelValF          =  5
      res@cnMinLevelValF          = -5
      res@cnLevelSelectionMode    =  "ManualLevels"

      res@gsnLeftString  = "[a] Cmip6 - Obs (SST ~S~o~N~C )"
   ;   res@gsnLeftStringFontHeightF  = 0.1
      res@gsnRightString = scenario(sce)+"_"+season
      res@cnFillPalette  = "BlWhRe"; "posneg_1" ;"BlWhRe" ;"MPL_coolwarm" ;"GMT_haxby" ;"GMT_wysiwyg" ;"MPL_gist_rainbow"  ;"temp1"
      ;plot(0)=gsn_csm_contour_map(wks,dif_sst,res)   ;mean correlation plot for observations
      plot(0)=gsn_csm_contour_map_overlay(wks,dif_sst,sst_filtt,res,sig_res)
      ;plot(0)= gsn_csm_contour_map_overlay(wks,dif_sst,sst_filt(0,:,:),res,sig_res)
      ;plotq1 =  gsn_csm_contour(wks,sst_filt(1,:,:),sig_res)
      ;plotS(0) = gsn_contour_shade(plotS(0),threshold,)
      ;overlay(plot(0),plotS(0))
      ;overlay(plot(0),plotq1)
      ;plot(0) = plot(0)

      ;res@gsnLeftString  = "[c] Access_ESM - Obs (SST ~S~o~N~C )"
      ;plot(2)=gsn_csm_contour_map(wks,diff_sst_best,res)   ;mean correlation plot for observations

;      res@gsnLeftString  = "[e] a - c"
;      plot(4)=gsn_csm_contour_map(wks,diff_2sst,res)   ;mean correlation plot for observations


;---------------------pr plot ------------------------------------------------

     res@cnLevelSpacingF         =  1
     res@cnMaxLevelValF          =  5
     res@cnMinLevelValF          = -5
     res@cnLevelSelectionMode    =  "ManualLevels"

     res@gsnLeftString  = "[b] Cmip6 - Obs (rainfall mm/day)"
  ;   res@gsnLeftStringFontHeightF  = 0.1
     res@gsnRightString = scenario(sce)+"_"+season
     res@cnFillPalette  = "BlWhRe" ;"posneg_1" ;"GMT_drywet" ;"GMT_haxby" ;"GMT_wysiwyg" ;"MPL_gist_rainbow"  ;"temp1"
     ;plot(1)=gsn_csm_contour_map(wks,diff_pr,res)        ;mean correlation plot for observations
     plot(1)=gsn_csm_contour_map_overlay(wks,diff_pr,pr_filtt,res,sig_res)
     ;plot(1)=gsn_csm_contour_map_overlay(wks,diff_pr,pr_filt(0,:,:),res,sig_res)
     ;plotq2 =gsn_csm_contour(wks,pr_filt(1,:,:),sig_res)
    ;overlay(plot(1),plotS(1))
     ;overlay(plot(1),plotq2)
     ;plot(1) = plot(1)

     ;res@gsnLeftString  = "[d] Access_ESM - Obs (rainfall mm/day)"
     ;plot(3)=gsn_csm_contour_map(wks,diff_pr_best,res)   ;mean correlation plot for observations

;     res@gsnLeftString  = "[f] b - d"
;     plot(5)=gsn_csm_contour_map(wks,diff_2pr,res)        ;mean correlation plot for observations


end do                ;end nplots loop 

;if(ZOOM(zz).eq.0) then
;    a = gsn_add_text(wks,plot(0),"[a]",-160,80,tres)
;    b = gsn_add_text(wks,plot(1),"[b]",-160,80,tres)
;    c = gsn_add_text(wks,plot(2),"[c]",-160,80,tres)
;    d = gsn_add_text(wks,plot(3),"[d]",-160,80,tres)
;else
;     a = gsn_add_text(wks,plot(0),"[a]",-71,27,tres)
;     b = gsn_add_text(wks,plot(1),"[b]",-71,27,tres)
;     c = gsn_add_text(wks,plot(2),"[c]",-71,27,tres)
;     d = gsn_add_text(wks,plot(3),"[d]",-71,27,tres)
; end if

                                        ; now draw all as one plot
;gsn_panel(wks,plot,(/1,2/),resP)     ;draw horizontal - 1 row, 2 columns
gsn_panel(wks,plot,(/2,1/),resP)        ;draw vertical    - 2 rows, 1 column

    end do                                           ;end plot type loop

    if (ZOOM(zz).eq.0) then
      system("eog "+pltDir+pltName+".png")
    end if 

  end do                                             ;end zoom loop
end if                                               ;PLOT_RESULTS if
;===============================================================================



delete(sst_avg)
delete(pr_avg)
delete(diro)
delete(filo)


    print("--------------"+scenario(sce)+" done-------------------------------------")


end do                                          ;end scenario loop

end   