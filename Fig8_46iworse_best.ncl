;"this script calculates and plots the difference between the Obs and the Best and Worst\
; models respectively."
; "first the sst_ann variable is calculated for the coordinates of sst bias. then the \
; obs values for pr and sst are calculated. The model files percategory/region already created in\
; in script 44 are then read in. Following the maps (6 plots per region) are plotted "
;

yrStrt = 1950
yrLast = 2014
season = "JJA"
var    = "pr"
varT   = "tos"

PLOT_RESULTS = True

;-------------------------------------------------------------------------------
;============ calculated to generate sst_ann for model dimension coords ========
;------------===========================================================--------

diriT  = "/home/yuzee/nclfolder/DATA/cmip6/historical/tos/"
f      = addfile(diriT+"RE_tos_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc","r")
TIME   = f->time
YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
GSST   = f->$varT$(iYYYY,:,:)

delete(f)
delete(TIME)
delete(YYYY)
delete(iYYYY)
GSST = lonFlip(GSST)

sst_clm   = clmMonTLL(GSST)                            ; compute monthly climatology
sst_clm   = where(sst_clm.lt.0.10, 0.0, sst_clm)      ; set small values to 0.0
sst_ann2  = month_to_season(sst_clm,season)
sst_ann   = dim_avg_n_Wrap(sst_ann2, 0)               ; compute annual mean ;(arithmetic);

delete(sst_clm)
delete(sst_ann2)
delete(GSST)
delete(diriT)
print("------------------sst_ann generated-----------==========================-")

diriT   = "/home/yuzee/nclfolder/DATA/cmip6/historical/pr/"
f      = addfile(diriT+"RE_pr_Amon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc","r")
TIME   = f->time
YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
PRC    = f->$var$(iYYYY,:,:)

delete(f)
delete(TIME)
delete(YYYY)
delete(iYYYY)
PRC = lonFlip(PRC)

prc_clm = clmMonTLL(PRC)                            ; compute monthly climatology
prc_clm  = where(prc_clm.lt.0.10, 0.0, prc_clm)      ; set small values to 0.0
prc_ann2  = month_to_season(prc_clm,season)
prc_ann  = dim_avg_n_Wrap(prc_ann2, 0)               ; compute annual mean ;(arithmetic);

delete(prc_clm)
delete(prc_ann2)
delete(PRC)
delete(diriT)
print("------------------prc_ann generated-----------==========================-")

;-------------------======================================-----------------
;========  OBS is calculated ==============================================
;-----------------------------============================------------------

dpmm  = (/30,31,31/)
jja_day_factor  = avg(dpmm)

ZOOM     = (/1,0/)
pltType  = (/"eps","png"/)

; ======------------ make calculations for Obs Pr and sst datafiles ------------======================

obsdiro = "/home/yuzee/nclfolder/DATA/obs/"

;----------------Obs Pr ---------------------------------------------------------
;----------------RAINFALL -----------------------------------------------------
 OBS_P   = addfile(obsdiro+"precip.mon.mean.nc", "r")
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
 ;prc_ann2 = prc_ann2/jja_day_factor         ;switched off cos gpcp datat is already daily
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
 TIME    = OBS_SST->time
 YYYY    = cd_calendar(TIME,-1)/100                 ; entire file
 iYYYY   = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
 oGSST   = OBS_SST->sst(iYYYY,:,:)
 oGSST!1 = "lat"
 oGSST!2 = "lon"
 printVarSummary(oGSST)       ; variable overview
 ;printMinMax(oGSST,True)

 delete(TIME)
 delete(YYYY)
 delete(iYYYY)

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
 ;copy_VarCoords(sst_ann,obs_sst_ann)
 printVarSummary(obs_sst_ann)                             ; from monthly climatologies
 printMinMax(obs_sst_ann, True)

 ;delete(oGSST)
 delete(sst_clm)
 delete(sst_ann2)

 print("---------------------==========================-------------------------")
 print("---------------------==========================-------------------------")
 print("--------------------------OBS calculated -------------------------------")
 print("--------------------now reading-in model files--------------------------")



;=======================READ IN THE MODEL CATEGORIZED NC FILES =====================
;==========================+++++++++++++++++++++++++++++++++++++========================================
;========--------read-in All models' ncfiles created in script 43-------------------------==============
;+++++++++++++++++++++++++++======================================++++++++++++++++++++++++++++++++++++++
scenario = (/"Hist", "Proj"/)
;do sce=0, dimsizes(scenario)-1,1
do sce=0,0,1

region = (/"Northern_Amazon","Central_Africa","Guinea_Coast","SE_Brazil"/)
do cb=0,dimsizes(region)-1,1
;do cb=0,0,1                                  ;test running for just 1 region


models = (/"Cat1", "Cat2"/)
do cat=0, dimsizes(models)-1,1
;do cat=0,0,1

diro   = "/home/yuzee/nclfolder/RESULTS/07manuscript/model_cat_ncfiles/"
filo    = scenario(sce)+"_"+models(cat)+var+"_mean_"+region(cb)+"_"+season+".nc"
filos   = scenario(sce)+"_"+models(cat)+varT+"_mean_"+region(cb)+"_"+season+".nc"
P       = addfile(diro+filo, "r")
SST     = addfile(diro+filos, "r")

if (models(cat).eq. "Cat1") then
  pr_nc1   = P  ->mean_rain1(:,:,:)
  sst_nc1  = SST->mean_sst1(:,:,:)
  pr_avg1    = dim_avg_n(pr_nc1, (0))    ;average of models mean rainfall values, the MMM
  printVarSummary(pr_avg1)
  printMinMax(pr_avg1, True)

  arrysst1    = sst_nc1                                                ;arry2 = textf ->sstDATA(:)
  sst_avg1    = dim_avg_n(arrysst1, (0))
  copy_VarCoords(obs_sst_ann,sst_avg1)
  arrysst   = sst_avg1
  printVarSummary(sst_avg1)
  printMinMax(sst_avg1, True)

  delete(arrysst)
else
  pr_nc2      = P  ->mean_rain2(:,:,:)
  sst_nc2     = SST->mean_sst2(:,:,:)
  pr_avg2     = dim_avg_n(pr_nc2, (0))    ;average of models mean rainfall values, the MMM
  printVarSummary(pr_avg2)
  printMinMax(pr_avg2, True)

  arrysst2    = sst_nc2                                                ;arry2 = textf ->sstDATA(:)
  sst_avg2    = dim_avg_n(arrysst2, (0))
  copy_VarCoords(obs_sst_ann,sst_avg2)
  arrysstt   = sst_avg2
  printVarSummary(sst_avg2)
  printMinMax(sst_avg2, True)

  delete(arrysst2)
end if

end do                                            ;end Cat loop

 ;------------------------------ DIFFERENCES -----------------------------------


diff_pr1     = pr_avg1 - obs_prc_ann
copy_VarCoords(prc_ann, diff_pr1)
printVarSummary(diff_pr1)
printMinMax(diff_pr1, True)
diff_pr2     = pr_avg2 - obs_prc_ann
copy_VarCoords(prc_ann,diff_pr2)
printVarSummary(diff_pr2)
printMinMax(diff_pr2, True)
diff_cat_pr  = pr_avg2  - pr_avg1
copy_VarCoords(prc_ann,diff_cat_pr)
printVarSummary(diff_cat_pr)
printMinMax(diff_cat_pr, True)


diff_sst1    =  sst_avg1 - obs_sst_ann
copy_VarCoords(obs_sst_ann,diff_sst1)
printVarSummary(diff_sst1)
printMinMax(diff_sst1, True)
diff_sst2    =  sst_avg2 - obs_sst_ann
copy_VarCoords(obs_sst_ann,diff_sst2)
printVarSummary(diff_sst2)
printMinMax(diff_sst2, True)
diff_cat_sst = sst_avg2  - sst_avg1
copy_VarCoords(obs_sst_ann,diff_cat_sst)
printVarSummary(diff_cat_sst)
printMinMax(diff_cat_sst, True)


;===============================================================================
;++++++++++++++++++++++++++++++-------------------------++++++++++++++++++++++++
;---------------------------==================================------------------
;====================to plot ===================================================

if(PLOT_RESULTS)

nplots = 2
latSp = -60
latNp =  32
lonLp = -80
lonRp =  40

                                           ;start zoom loop
;do zz=0,dimsizes(ZOOM)-1,1
 do zz=0,0,1
  do pc=0,dimsizes(pltType)-1,1             ;plot type loop

  pltDir  = "/home/yuzee/my_research/my.work/manuscript/01_figures/"
  if (ZOOM(zz).eq.1) then
    pltName = region(cb)+"_Worse_vs_Best_meanmaps_zoom_"+season
  else
    pltName = region(cb)+"_Worse_vs_Best_meanmaps_global_"+season
  end if

pltPath = pltDir+pltName+"."+pltType
wks     = gsn_open_wks(pltType(pc), pltDir+pltName)
plot    = new(nplots,graphic)

           ; manually specify colors
   colors = (/"Snow","PaleTurquoise" \
               ,"PaleGreen","SeaGreen3" ,"Yellow"       \
               ,"Orange","HotPink","Red","Violet"       \
               ,"Purple", "Brown", "Blue"/)

  res                      = True     ; plot mods desired
  res@gsnDraw              = False        ; don't draw yet
  res@gsnFrame             = False        ; don't advance frame yet
  res@gsnMaximize          = True    ; make ps/eps/pdf large

  res@cnFillOn             = True     ; turn on color fill
; res@cnFillPalette        = colors   ; set color map
  res@cnLinesOn            = False    ; turn of contour lines
; res@cnFillMode           = "RasterFill" ; Raster Mode
  res@cnLineLabelsOn       = False       ; Turn off contour lines
  res@cnFillPatterns       = True
  res@gsnPaperOrientation  = "portrait"

  ;res@cnLevelSelectionMode    =  "AutomaticLevels"

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
; res@mpCenterLonF             = 220.         ; don't split Africa
; res@gsnCenterString          = "Areal Mean="+sprintf("%4.2f",  prcAvg)+" mm/mon"

         ;Panel plot resources

   resP                      = True         ; modify the panel plot
   resP@gsnMaximize          = True         ; large format
   resP@gsnPanelLabelBar     = False         ; add common colorbar
   resP@gsnPaperOrientation  = "portrait"
;   resP@tiMainString        = region(cb)
   resP@gsnPanelMainString   = region(cb)
   resP@tiMainFontHeightF    =  0.01

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

     res@cnLevelSpacingF         =  0.5
     res@cnMaxLevelValF          =  3
     res@cnMinLevelValF          = -3
     res@cnLevelSelectionMode    =  "ManualLevels"


     res@gsnLeftString  = "Bad - Good Models rainfall (mm/day)"
     res@gsnRightString = season   ;region(cb)+"_"+season
     res@cnFillPalette  = "BlWhRe" ;"posneg_1" ;"GMT_haxby" ;"GMT_wysiwyg" ;"MPL_gist_rainbow"  ;"temp1"
     plot(1)=gsn_csm_contour_map(wks,diff_cat_pr,res)   ;mean correlation plot for observations

;----------------------sst plots ----------------------------------------------

     res@cnLevelSpacingF         =  0.5
     res@cnMaxLevelValF          =  3
     res@cnMinLevelValF          = -3
     res@cnLevelSelectionMode    =  "ManualLevels"


     res@gsnLeftString  = "Bad - Good models SST"+"( ~S~o~N~C )"
     res@gsnRightString = season ; region(cb)+"_"+season
     res@cnFillPalette  = "BlWhRe"; "NCV_blue_red" ;"MPL_coolwarm" ;"GMT_haxby" ;"GMT_wysiwyg" ;"MPL_gist_rainbow"  ;"temp1"
     plot(0)=gsn_csm_contour_map(wks,diff_cat_sst,res)   ;mean correlation plot for observations
end do


if(region(cb).eq."Northern_Amazon") then
  pic_tagtos = "[a]"
  pic_tagpr  = "[e]"
else if(region(cb).eq."Central_Africa") then
  pic_tagtos = "[b]"
  pic_tagpr  = "[f]"
else if(region(cb).eq."Guinea_Coast") then
  pic_tagtos = "[c]"
  pic_tagpr  = "[g]"
else
  pic_tagtos = "[d]"
  pic_tagpr  = "[h]"
end if
end if

end if

  if(ZOOM(zz).eq.0) then
      a = gsn_add_text(wks,plot(0),pic_tagtos,-160,80,tres)
      b = gsn_add_text(wks,plot(1),pic_tagpr,-160,80,tres)
   else
       a = gsn_add_text(wks,plot(0),pic_tagtos,-71,27,tres)
       b = gsn_add_text(wks,plot(1),pic_tagpr,-71,27,tres)
   end if


                                        ; now draw all as one plot
;gsn_panel(wks,plot,(/1,2/),resP)       ;draw horizontal   - 1 row, 2 columns
gsn_panel(wks,plot,(/2,1/),resP)        ;draw vertical     - 2 rows, 1 column




    end do                                           ;end plot type loop
  end do                                             ;end zoom loop
end if                                               ;PLOT_RESULTS if
;===============================================================================


                   ;delete variables that will be used for another region
delete(pr_nc1)
delete(sst_nc1)
delete(pr_avg1)
delete(arrysst1)
delete(sst_avg1)
delete(diff_pr1)
delete(diff_pr2)
delete(diff_cat_pr)
delete(diff_sst1)
delete(diff_sst2)
delete(diff_cat_sst)
delete(pr_nc2)
delete(sst_nc2)
delete(pr_avg2)
delete(sst_avg2)

print("--------------"+region(cb)+" done-------------------------------------")

  end do                                                ;end region loop

 typp      = "eps"
  wkss     = gsn_open_wks(typp, pltDir+"All_worseBias")
  plott    = new(4,graphic)

  resPP                      = True                      ; modify the panel plot
  resPP@gsnMaximize          = True                      ; large format
  resPP@gsnPanelLabelBar     = False                     ; add common colorbar
  resPP@gsnPaperOrientation  = "portrait"
  ;resPP@gsnPanelMainString   = region(cb)
  resPP@tiMainFontHeightF    =  0.01

  gsn_panel(wkss,plott,(/1,4/),resPP)        ;draw vertical     - 2 rows, 1 column


    print("--------------"+scenario(sce)+" done-------------------------------------")
end do                                          ;end scenario loop
