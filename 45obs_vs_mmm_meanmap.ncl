; generate Obs vs all model plot fpr mena rainfall and sst


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

PLOT_RESULTS = True
; ======------------ make calculations for Obs Pr and sst datafiles ------------======================

obsdiro = "/home/yuzee/nclfolder/DATA/obs/"

;----------------Obs Pr ---------------------------------------------------------
;----------------RAINFALL -----------------------------------------------------
 OBS_P   = addfile(obsdiro+"precip_monthly_gpcc_v2022_1941_2020_10.nc", "r")
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
 prc_ann2 = prc_ann2/jja_day_factor
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
 OBS_SST = addfile(obsdiro+"HadISST_sst.nc", "r")
 TIME   = OBS_SST->time
 YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
 iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
 oGSST   = OBS_SST->sst(iYYYY,:,:)
 printVarSummary(oGSST)       ; variable overview
 ;printMinMax(oGSST,True)

 delete(TIME)
 delete(YYYY)
 delete(iYYYY)

 oGSST = lonFlip(oGSST)

 ;------------ SST annual mean ----------------------------------

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

diro    = "/home/yuzee/nclfolder/RESULTS/07manuscript/mean_maps/allmodels_nc/"
filo    = scenario(sce)+"_All"+var+"_mean_"+season+".nc"
filos   = scenario(sce)+"_All"+varT+"_mean_"+season+".nc"
P       = addfile(diro+filo, "r")
SST     = addfile(diro+filos, "r")

pr_nc   = P->allmean_rain(:,:,:)
sst_nc  = SST->allmean_sst(:,:,:)

;==========---- Calculating the averages   -------------=====================================

 pr_avg    = dim_avg_n(pr_nc, (0))    ;average of models mean rainfall values, the MMM
 printVarSummary(pr_avg)
 printMinMax(pr_avg, True)

 arrysst    = sst_nc                                                ;arry2 = textf ->sstDATA(:)
 sst_avg    = dim_avg_n(arrysst, (0))
 copy_VarCoords(obs_sst_ann,sst_avg)
 arrysst2   = sst_avg
 printVarSummary(sst_avg)
 printMinMax(sst_avg, True)

 delete(arrysst)
 ;delete(arry2)

 ;------------------------------- differences ----------------------------------------
 ;diff_pr  = obs_prc_ann - pr_avg
 diff_sst = obs_sst_ann - sst_avg

;===============================================================================
;++++++++++++++++++++++++++++++-------------------------++++++++++++++++++++++++
;---------------------------==================================------------------
;====================to plot ===================================================

if(PLOT_RESULTS)

nplots = 5
latSp = -60
latNp =  32
lonLp = -80
lonRp =  40

do zz=0,dimsizes(ZOOM)-1,1                           ;start zoom loop
 do pc=0,dimsizes(pltType)-1,1

  pltDir  = diro                                     ;dir to which plots are sent
  if (ZOOM(zz).eq.1) then
    pltName = scenario(sce)+"_Obs_vs_Allmodels_meanmaps_zoom_"+season
 else
    pltName = scenario(sce)+"_Obs_vs_Allmodels_meanmaps_global_"+season
  end if

pltPath= pltDir+pltName+"."+pltType
wks    = gsn_open_wks(pltType(pc), pltDir+pltName)
plot = new(nplots,graphic)

           ; manually specify colors
   colors = (/"Snow","PaleTurquoise" \
               ,"PaleGreen","SeaGreen3" ,"Yellow"       \
               ,"Orange","HotPink","Red","Violet"       \
               ,"Purple", "Brown", "Blue"/)

  res                      = True     ; plot mods desired
  res@gsnDraw              = False        ; don't draw yet
  res@gsnFrame             = False        ; don't advance frame yet
  res@gsnMaximize          = True     ; make ps/eps/pdf large

  res@cnFillOn             = True     ; turn on color fill
; res@cnFillPalette        = colors   ; set color map
  res@cnLinesOn            = False    ; turn of contour lines
; res@cnFillMode           = "RasterFill" ; Raster Mode
  res@cnLineLabelsOn       = False       ; Turn off contour lines
  res@cnFillPatterns       = True
  res@cnFillPalette        = "GMT_drywet" ;"CBR_wet" ;"MPL_Reds"  ;"cmocean_matter" ;"BlWhRe"
  res@gsnPaperOrientation  = "portrait"

  res@cnLevelSelectionMode    =  "AutomaticLevels"

  res@lbOrientation             = "vertical"   ; vertical label barb's
  res@lbLabelFontHeightF        = 0.012        ; change font size
  res@pmLabelBarWidthF          =  0.1
  res@pmLabelBarOrthogonalPosF  = -0.01    ; move a bit to left

  res@mpFillOn                  = False

  if (ZOOM(zz).eq.1) then
    res@mpMinLatF              = latSp         ; zoom in on map
    res@mpMaxLatF              = latNp
    res@mpMinLonF              = lonLp
    res@mpMaxLonF              = lonRp
  else
    res@mpMinLatF              = -90        ; zoom in on map
    res@mpMaxLatF              =  90
    res@mpMinLonF              = -180
    res@mpMaxLonF              =  180
  end if
; res@mpCenterLonF              = 220.         ; don't split Africa
; res@tiMainString              = "Mean JJA maps : "+yrStrt+"-"+yrLast
; res@gsnCenterString           = "Areal Mean="+sprintf("%4.2f",  prcAvg)+" mm/mon"

         ;Panel plot resources

   resP                      = True         ; modify the panel plot
   resP@gsnMaximize          = True         ; large format
   resP@gsnPanelLabelBar     = False         ; add common colorbar
   resP@gsnPaperOrientation  = "portrait"
;  resP@gsnPanelMainString   = "Best models mean map "+season+"rainfall & SST"
   resP@tiMainFontHeightF    =  0.01


;*******************************************************************************
; combined plot
;*******************************************************************************
 do n=0,nplots-5
    res@gsnLeftString  = "All models mean rainfall"
    res@gsnRightString = scenario(sce)+"_"+season
     plot(0)=gsn_csm_contour_map(wks,pr_avg,res)  ;mean correlation plot for models
     res@gsnLeftString  = "All models mean SST"
     res@gsnRightString = scenario(sce)+"_"+season
     res@cnFillPalette  = "MPL_coolwarm" ;"GMT_haxby" ;"GMT_wysiwyg" ;"MPL_gist_rainbow"  ;"temp1"
     plot(2)=gsn_csm_contour_map(wks,arrysst2,res)   ;mean correlation plot for observations
     res@gsnLeftString  = "Obs mean rainfall"
     res@gsnRightString = scenario(sce)+"_"+season
     res@cnFillPalette  = "GMT_drywet" ;"GMT_haxby" ;"GMT_wysiwyg" ;"MPL_gist_rainbow"  ;"temp1"
     plot(1)=gsn_csm_contour_map(wks,obs_prc_ann,res)   ;mean correlation plot for observations
     res@gsnLeftString  = "Obs mean SST"
     res@gsnRightString = scenario(sce)+"_"+season
     res@cnFillPalette  = "MPL_coolwarm" ;"GMT_haxby" ;"GMT_wysiwyg" ;"MPL_gist_rainbow"  ;"temp1"
     plot(3)=gsn_csm_contour_map(wks,obs_sst_ann,res)   ;mean correlation plot for observations
     ;res@gsnLeftString  = "Difference rainfall"
     ;res@gsnRightString = scenario(sce)+"_"+season
     ;res@cnFillPalette  = "MPL_coolwarm" ;"GMT_haxby" ;"GMT_wysiwyg" ;"MPL_gist_rainbow"  ;"temp1"
     ;plot(4)=gsn_csm_contour_map(wks,diff_pr,res)   ;mean correlation plot for observations
     res@gsnLeftString  = "Difference SST"
     res@gsnRightString = scenario(sce)+"_"+season
     res@cnFillPalette  = "MPL_coolwarm" ;"GMT_haxby" ;"GMT_wysiwyg" ;"MPL_gist_rainbow"  ;"temp1"
     plot(4)=gsn_csm_contour_map(wks,diff_sst,res)   ;mean correlation plot for observations
end do

                                        ; now draw all as one plot
gsn_panel(wks,plot,(/2,3/),resP)     ;draw horizontal - 1 row, 2 columns
;gsn_panel(wks,plot,(/3,2/),resP)        ;draw vertical    - 2 rows, 1 column

    end do                                           ;end plot type loop
  end do                                             ;end zoom loop
end if                                               ;PLOT_RESULTS if
;===============================================================================



delete(sst_avg)
delete(pr_avg)
delete(diro)
delete(filo)


    print("--------------"+scenario(sce)+" done-------------------------------------")


end do                                          ;end scenario loop
