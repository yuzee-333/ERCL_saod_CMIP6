;"this script calculates and plots the difference between the Obs and the Best and Worst\
; models respectively."
; "first the sst_ann variable is calculated for the coordinates of sst bias. then the \
; obs values for pr and sst are calculated. The model files percategory/region already created in\
; in script 44 are then read in. Following the maps (6 plots per region) are plotted "
;
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

yrStrt = 1950
yrLast = 2014
season = "JJA"
var    = "pr"
varT   = "tos"


;-------------------------------------------------------------------------------
;============ calculated to generate sst_ann for model dimension coords ========
;------------===========================================================--------

diriT   = "/home/yuzee/mywork/DATA/cmip6/historical/tos/"
f      = addfile(diriT+"RE_tos_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc","r")
TIME   = f->time
YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
GSST   = f->$varT$(iYYYY,:,:)

delete([/f,TIME,YYYY,iYYYY/])

GSST = lonFlip(GSST)

sst_clm   = clmMonTLL(GSST)                            ; compute monthly climatology
sst_clm   = where(sst_clm.lt.0.10, 0.0, sst_clm)      ; set small values to 0.0
sst_ann2  = month_to_season(sst_clm,season)
sst_ann   = dim_avg_n_Wrap(sst_ann2, 0)               ; compute annual mean ;(arithmetic);

delete([/sst_clm, sst_ann2,GSST,diriT/])

print("------------------sst_ann generated-----------==========================-")

diriT   = "/home/yuzee/mywork/DATA/cmip6/historical/pr/"
f      = addfile(diriT+"RE_pr_Amon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc","r")
TIME   = f->time
YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
PRC    = f->$var$(iYYYY,:,:)

delete([/f,TIME,YYYY,iYYYY/])

PRC = lonFlip(PRC)

prc_clm = clmMonTLL(PRC)                            ; compute monthly climatology
prc_clm  = where(prc_clm.lt.0.10, 0.0, prc_clm)      ; set small values to 0.0
prc_ann2  = month_to_season(prc_clm,season)
prc_ann  = dim_avg_n_Wrap(prc_ann2, 0)               ; compute annual mean ;(arithmetic);

delete([/prc_clm,prc_ann2,PRC,diriT/])

print("------------------prc_ann generated-----------==========================-")

;-------------------======================================-----------------
;========  OBS is calculated ==============================================
;-----------------------------============================------------------

dpmm  = (/30,31,31/)
jja_day_factor  = avg(dpmm)

ZOOM     = (/1,0/)
pltType  = (/"eps","png"/)

; ======------------ make calculations for Obs Pr and sst datafiles ------------======================;;

obsdiro = "/home/yuzee/mywork/DATA/obs/"

;----------------Obs Pr ---------------------------------------------------------
;----------------RAINFALL -----------------------------------------------------
 OBS_P   = addfile(obsdiro+"precip/Gpcp_precip.mon.mean_.nc", "r")
 TIME   = OBS_P->time
 YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
 iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
 oPRC    = OBS_P->precip(iYYYY,:,:)
 ;printVarSummary(oPRC)       ; variable overview
 ;printMinMax(oPRC,True)

 delete([/TIME,YYYY,iYYYY/])
 
 oPRC = lonFlip(oPRC)

 ;------------ RAINFALL annual mean ----------------------------------
 prc_clm = clmMonTLL(oPRC)                         ; compute monthly climatology
 ;printVarSummary(prc_clm)                         ; (12,lat,lon)

 prc_clm  = where(prc_clm.lt.0.10, 0.0, prc_clm)  ; set small values to 0.0
 ;printMinMax(prc_clm,True)
 prc_ann2  = month_to_season(prc_clm,season)
 ;prc_ann2 = prc_ann2/jja_day_factor         ;switched off cos gpcp datat is already daily
 ;printVarSummary(prc_ann2)
 print("------------rainfall for Obs JJA season---------------")
 ;printMinMax(prc_ann2, True)

 obs_prc_ann  = dim_avg_n_Wrap(prc_ann2, 0)            ; compute annual rainfall mean ;(arithmetic);
 ;printVarSummary(obs_prc_ann)                          ; from monthly climatologies
 ;printMinMax(obs_prc_ann, True)

 delete([/oPRC, prc_clm, prc_ann2/])
 

 ;----------------Obs SST ------------------------------------------------------
 ;----------------Sea Surface Temperature --------------------------------------

 OBS_SST = addfile(obsdiro+"sst/HadISST_sst.nc", "r") 
 TIME    = OBS_SST->time
 YYYY    = cd_calendar(TIME,-1)/100                 ; entire file
 iYYYY   = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
 oGSST   = OBS_SST->sst(iYYYY,:,:)
 oGSST!1 = "lat"
 oGSST!2 = "lon"
 ;printVarSummary(oGSST)       ; variable overview
 ;printMinMax(oGSST,True)

delete([/TIME,YYYY,iYYYY/])


 sst_clm = clmMonTLL(oGSST)                            ; compute monthly climatology
 ;printVarSummary(sst_clm)                             ; (12,lat,lon)
 ;printMinMax(sst_clm, True)
 sst_clm  = where(sst_clm.lt.0.10, 0.0, sst_clm)      ; set small values to 0.0

 sst_ann2  = month_to_season(sst_clm,season)
 sst_cord  = sst_ann2
 print("------------obs SST for JJA season---------------------")
 ;printVarSummary(sst_ann2)                             ; (12,lat,lon)
 printMinMax(sst_ann2, True)

 obs_sst_ann  = dim_avg_n_Wrap(sst_ann2, 0)               ; compute annual mean ;(arithmetic);
 ;copy_VarCoords(sst_ann,obs_sst_ann)
 ;printVarSummary(obs_sst_ann)                             ; from monthly climatologies
 ;printMinMax(obs_sst_ann, True)

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

print("=============== ANALYSES FOR "+region(cb)+"===========================================")
print("=============== ANALYSES FOR "+region(cb)+"===========================================")
print("=============== ANALYSES FOR "+region(cb)+"===========================================")

diro    = "/home/yuzee/mywork/ERCL_manuscript/UZ_work_latest/RESULTS/model_cat_ncfiles/"
filo    = scenario(sce)+"_"+models(cat)+var+"_mean_"+region(cb)+"_"+season+".nc"
filos   = scenario(sce)+"_"+models(cat)+varT+"_mean_"+region(cb)+"_"+season+".nc"
P       = addfile(diro+filo, "r")
SST     = addfile(diro+filos, "r")

if (models(cat).eq. "Cat1") then
  pr_nc1   = P  ->mean_rain1(:,:,:)
  sst_nc1  = SST->mean_sst1(:,:,:)
  pr_avg1    = dim_avg_n(pr_nc1, 0)    ;average of models mean rainfall values, the MMM
  copy_VarCoords(pr_nc1(0,:,:), pr_avg1)
  pr_var1    = dim_variance_n_Wrap(pr_nc1, 0)
  pr_y       = dimsizes(pr_avg1&lat)*dimsizes(pr_avg1&lon)
  ;printVarSummary(pr_avg1)
  ;printMinMax(pr_avg1, True)
  ;printVarSummary(pr_var1)
  ;printMinMax(pr_var1, True)

  arrysst1    = sst_nc1                                                ;arry2 = textf ->sstDATA(:)
  sst_avg1    = dim_avg_n(arrysst1, 0)
  copy_VarCoords(sst_nc1(0,:,:),sst_avg1)
  sst_var1    = dim_variance_n_Wrap(arrysst1, 0) 
  sst_y       = dimsizes(sst_avg1&lat)*dimsizes(sst_avg1&lon)
  arrysst   = sst_avg1
  ;printVarSummary(sst_avg1)
  ;printMinMax(sst_avg1, True)
  ;printVarSummary(sst_var1)
  ;printMinMax(sst_var1, True)


  delete(arrysst)

else
  pr_nc2      = P  ->mean_rain2(:,:,:)
  sst_nc2     = SST->mean_sst2(:,:,:)
  pr_avg2     = dim_avg_n(pr_nc2, (0))    ;average of models mean rainfall values, the MMM
  copy_VarCoords(pr_nc2(0,:,:), pr_avg2)
  pr_var2     = dim_variance_n_Wrap(pr_nc2, 0)
  pr_x        = pr_y
  ;printVarSummary(pr_nc2)
  ;printMinMax(pr_avg2, True)
  ;printVarSummary(pr_var2)
  ;printMinMax(pr_var2, True)

  arrysst2    = sst_nc2                                                ;arry2 = textf ->sstDATA(:)
  sst_avg2    = dim_avg_n(arrysst2, (0))
  copy_VarCoords(sst_nc2(0,:,:),sst_avg2)
  sst_var2    = dim_variance_n_Wrap(arrysst2, 0)
  sst_x       = sst_y
  arrysstt   = sst_avg2
  ;printVarSummary(sst_avg2)
  ;printMinMax(sst_avg2, True)
  ;printVarSummary(sst_var2)
  ;printMinMax(sst_var2, True)

  delete(arrysst2)
end if

end do                                            ;end Cat loop






















 ;------------------------------ DIFFERENCES -----------------------------------




diff_cat_pr  = pr_avg2  - pr_avg1
copy_VarCoords(prc_ann,diff_cat_pr)
;printVarSummary(diff_cat_pr)
;printMinMax(diff_cat_pr, True)


diff_cat_sst = sst_avg2  - sst_avg1
copy_VarCoords(obs_sst_ann,diff_cat_sst)
;printVarSummary(diff_cat_sst)
;printMinMax(diff_cat_sst, True)
;print(diff_cat_sst)



;-----------calculating number of observations of cat2 models relative to bias from cat1 models--------------
;============================================================================================================

PLOT_NOBS = True
if(PLOT_NOBS)

threshold_pr = round(0.95*dimsizes(pr_nc2(:,0,0)),3)

cat_bias_pr = new((/dimsizes(pr_nc2)/), float, 1e+20)
printVarSummary(cat_bias_pr)
  do im=0,dimsizes(pr_nc2(:,0,0))-1,1
    idiff_pr = pr_nc2(im,:,:) - pr_avg1
    ;printVarSummary(idiff_pr)
    cat_bias_pr(im,:,:) = idiff_pr
    delete(idiff_pr)
  end do 
  delete(im)
copy_VarCoords(pr_nc2, cat_bias_pr)
;printVarSummary(cat_bias_pr)
;printMinMax(cat_bias_pr, True)

aa_pr       = dim_num_n((where(cat_bias_pr.gt.0,cat_bias_pr,0)).ne.0, 0)
nn_pr       = dim_num_n((where(cat_bias_pr.lt.0,cat_bias_pr,0)).ne.0, 0)
aa_pr_filt  = aa_pr
aa_pr_filt  = where(aa_pr.ge.threshold_pr, aa_pr_filt, aa_pr@_FillValue)
nn_pr_filt  = nn_pr
nn_pr_filt  = where(nn_pr.ge.threshold_pr, nn_pr_filt, nn_pr@_FillValue)
pr_filt     = new((/2,dimsizes(pr_nc2&lat),dimsizes(pr_nc2&lon) /),float, 1e+20)
pr_filt(0,:,:) = aa_pr_filt
pr_filt(1,:,:) = nn_pr_filt
pr_filtt   = dim_sum_n_Wrap(pr_filt,0)

copy_VarCoords(pr_nc2(0,:,:), pr_filtt)
printVarSummary(pr_filtt)
printMinMax(pr_filtt, True)
;print(pr_filtt)


threshold_sst = round(0.95*dimsizes(pr_nc2(:,0,0)),3)

cat_bias_sst = new((/dimsizes(sst_nc2)/), float, 1e+20)
printVarSummary(cat_bias_sst)
  do im=0,dimsizes(sst_nc2(:,0,0))-1,1
    idiff_sst = sst_nc2(im,:,:) - sst_avg1
    ;printVarSummary(idiff_sst)
    cat_bias_sst(im,:,:) = idiff_sst
    delete(idiff_sst)
  end do 
  delete(im)
copy_VarCoords(sst_nc2, cat_bias_sst)
;printVarSummary(cat_bias_sst)
;printMinMax(cat_bias_sst, True)


aa_sst       = dim_num_n((where(cat_bias_sst.gt.0,cat_bias_sst,0)).ne.0, 0)
nn_sst       = dim_num_n((where(cat_bias_sst.lt.0,cat_bias_sst,0)).ne.0, 0)
aa_sst_filt  = aa_sst
aa_sst_filt  = where(aa_sst.ge.threshold_sst, aa_sst_filt, aa_sst_filt@_FillValue)
nn_sst_filt  = nn_sst
nn_sst_filt  = where(nn_sst.ge.threshold_sst, nn_sst_filt, nn_sst_filt@_FillValue)
sst_filt     = new((/2,dimsizes(sst_nc2&lat),dimsizes(sst_nc2&lon) /),float)
sst_filt(0,:,:) = aa_sst_filt
sst_filt(1,:,:) = nn_sst_filt
sst_filtt   = dim_sum_n_Wrap(sst_filt,0)

copy_VarCoords(sst_nc2(0,:,:), sst_filtt)
printVarSummary(sst_filtt)
printMinMax(sst_filtt, True)


delete([/cat_bias_pr, cat_bias_sst, aa_pr, aa_pr_filt, aa_sst, aa_sst_filt,nn_pr, nn_pr_filt, nn_sst, nn_sst_filt,sst_filt,pr_filt/])



end if                               ;end PLOTNOBS plot
;========================================================================================================


;------------------------------------- TTEST of statistical signifcance of Difference 
TTEST = False
if (TTEST)


iflag   = True                                   ; population variance similar
tval_opt= False 
p95 = 0.05

alpha_pr = 100.*(1. - ttest(pr_avg2,pr_var2,pr_x, pr_avg1,pr_var1,pr_y, iflag, False))
copy_VarCoords(diff_cat_pr, alpha_pr)
printVarSummary(alpha_pr)
printMinMax(alpha_pr, True)   
plt_alpha_pr = alpha_pr
plt_alpha_pr = where(alpha_pr.le.p95, plt_alpha_pr, plt_alpha_pr@_FillValue)      
printVarSummary(plt_alpha_pr)
printMinMax(plt_alpha_pr, True)

alpha_sst = 100.*(1. - ttest(sst_avg2,sst_var2,sst_x, sst_avg1,sst_var1,sst_y, iflag, False))
copy_VarCoords(diff_cat_sst, alpha_sst)
printVarSummary(alpha_sst)
printMinMax(alpha_sst, True)
;print(alpha_sst)
plt_alpha_sst = alpha_sst
plt_alpha_sst = where(alpha_sst.le.p95, plt_alpha_sst, plt_alpha_sst@_FillValue)      
printVarSummary(plt_alpha_sst)
printMinMax(plt_alpha_sst, True)

end if                 ;end TTEST if 
;---------------------------------------------------------------------------------------------------





















;===============================================================================
;++++++++++++++++++++++++++++++-------------------------++++++++++++++++++++++++
;---------------------------==================================------------------
;====================to plot ===================================================
PLOT_RESULTS = True

if(PLOT_RESULTS)

nplots = 2
latSp = -50
latNp =  32
lonLp = -80
lonRp =  40

                                           ;start zoom loop
do zz=0,dimsizes(ZOOM)-1,1
; do zz=0,0,1
  do pc=0,dimsizes(pltType)-1,1             ;plot type loop

  pltDir  = "/home/yuzee/mywork/ERCL_manuscript/rev_submit/Fig8/"

  if (ZOOM(zz).eq.1) then
    if (TTEST)
      pltName = "ttest_Fig8_"+region(cb)+"_Worse_vs_Best_meanmaps_zoom_"+season
    else 
      pltName = "Fig8_"+region(cb)+"_Worse_vs_Best_meanmaps_zoom_"+season
    end if 
  else
    if (TTEST)
      pltName = "ttest_Fig8_"+region(cb)+"_Worse_vs_Best_meanmaps_global_"+season
    else 
      pltName = "Fig8_"+region(cb)+"_Worse_vs_Best_meanmaps_global_"+season
    end if 
  end if

pltPath = pltDir+pltName+"."+pltType
wks     = gsn_open_wks(pltType(pc), pltDir+pltName)
plot    = new(nplots,graphic)

  res                      = True     ; plot mods desired
  res@gsnDraw              = False        ; don't draw yet
  res@gsnFrame             = False        ; don't advance frame yet
  res@gsnMaximize          = True    ; make ps/eps/pdf large

  res@cnFillOn             = True     ; turn on color fill
  res@mpProjection         = "CylindricalEquidistant" 
  
  res@cnLinesOn            = False    ; turn of contour lines
  res@cnFillMode           = "RasterFill" ; Raster Mode
  res@cnRasterSmoothingOn  = True
  res@cnLineLabelsOn       = False       ; Turn off contour lines
  res@cnFillPatterns       = True
  res@gsnPaperOrientation  = "portrait"

  ;res@cnLevelSelectionMode    =  "AutomaticLevels"

  res@lbOrientation             = "vertical"   ; vertical label barb's
  res@lbLabelFontHeightF        = 0.012        ; change font size
  res@pmLabelBarWidthF          =  0.1
  res@pmLabelBarOrthogonalPosF  = -0.01    ; move a bit to left

  res@mpFillOn                  = True

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

     res@cnLevelSpacingF         =  0.5
     res@cnMaxLevelValF          =  5
     res@cnMinLevelValF          = -5
     res@cnLevelSelectionMode    =  "ManualLevels"


     res@gsnLeftString  = "Bad - Good Models rainfall (mm/day)"
     res@gsnRightString = season   ;region(cb)+"_"+season
     res@cnFillPalette  = "BlWhRe" ;"posneg_1" ;"GMT_haxby" ;"GMT_wysiwyg" ;"MPL_gist_rainbow"  ;"temp1"
    
    if (PLOT_NOBS) then
      plot(1)=gsn_csm_contour_map_overlay(wks,diff_cat_pr,pr_filtt,res,sig_res)
      else if (TTEST) then 
        plot(1)=gsn_csm_contour_map_overlay(wks,diff_cat_pr,plt_alpha_pr,res,sig_res)
        else
          plot(1)=gsn_csm_contour_map(wks,diff_cat_pr,res)   ;
      end if 
    end if 
     
;----------------------sst plots ----------------------------------------------

     res@cnLevelSpacingF         =  0.5
     res@cnMaxLevelValF          =  5
     res@cnMinLevelValF          = -5
     res@cnLevelSelectionMode    =  "ManualLevels"


     res@gsnLeftString  = "Bad - Good models SST"+"( ~S~o~N~C )"
     res@gsnRightString = season ; region(cb)+"_"+season
     res@cnFillPalette  = "BlWhRe"; "NCV_blue_red" ;"MPL_coolwarm" ;"GMT_haxby" ;"GMT_wysiwyg" ;"MPL_gist_rainbow"  ;"temp1"
     
    if (PLOT_NOBS) then 
        plot(0)=gsn_csm_contour_map_overlay(wks,diff_cat_sst,sst_filtt,res,sig_res)
      else if (TTEST) then 
          plot(0)=gsn_csm_contour_map_overlay(wks,diff_cat_sst,plt_alpha_sst,res,sig_res)
        else 
            plot(0)=gsn_csm_contour_map(wks,diff_cat_sst,res)   ;
      end if 
    end if 
            
end do



 ;================= CREATE BOXES ==================================


;----Resources for the polyline
  pres0                    = True
  pres0@gsLineThicknessF    = 3.
  pres0@gsLineColor        = "black" ;"skyblue" "darkgreen" "green"
  pres0@gsLineDashPattern  = 0.
  pres0@tfPolyDrawOrder    = "postDraw"

  if(region(cb).eq."Northern_Amazon") then                                        ; polyline coordinates for JJA
    latEQ = (/ 7., 7., -5., -5., 7./)
    lonEQ = (/-70., -50., -50., -70., -70./)
    else if(region(cb).eq."Guinea_Coast") then                                 ;Guinea_Coast
      latEQ = (/ 13., 13., 5., 5., 13./)
      lonEQ = (/ -10., 10., 10., -10.,-10./)
      else if(region(cb).eq."Central_Africa") then                            ;Central Africa
        latEQ = (/ 5., 5., -5., -5., 5./)
        lonEQ = (/ 10., 16., 16., 10., 10./)
  else                                ;SE_Brazil
    latEQ = (/ -12., -12., -27., -27., -12./)
    lonEQ = (/ -56., -40., -40., -56., -56./)

       end if
    end if
  end if
    
  ;-------drawing the polylines -------------------------
    ;pres0@gsMarkerColor   = "green"
    ;pres0@gsLineLabelString  = "1"
    dum0 = gsn_add_polyline(wks,plot(0),lonEQ,latEQ,pres0) ; Northern Amazon
    dum1 = gsn_add_polyline(wks,plot(1),lonEQ,latEQ,pres0) ; Northern Amazon
      ;dum2 = gsn_add_polyline(wks,plot(2),lonEQ,latEQ,pres0) ; Northern Amazon
      ;dum3 = gsn_add_polyline(wks,plot(3),lonEQ,latEQ,pres0) ; Northern Amazon

      ;pres0@gsLineLabelString  = "2"
      ;dum4 = gsn_add_polyline(wks,plot(0), lon1, lat1, pres0)  ; west africa guinea coast
      ;dum5 = gsn_add_polyline(wks,plot(1), lon1, lat1,pres0) ;
      ;dum6 = gsn_add_polyline(wks,plot(2), lon1, lat1, pres0)  ; west africa guinea coast
      ;dum7 = gsn_add_polyline(wks,plot(3), lon1, lat1,pres0) ;

      ;pres0@gsLineLabelString  = "3"
      ;dum8  = gsn_add_polyline(wks,plot(0), lon2, lat2, pres0)  ; central africa
      ;dum9  = gsn_add_polyline(wks,plot(1), lon2,lat2,pres0)
      ;dum10 = gsn_add_polyline(wks,plot(2), lon2, lat2, pres0)  ; central africa
      ;dum11 = gsn_add_polyline(wks,plot(3), lon2,lat2,pres0)

      ;pres0@gsLineLabelString  = "4"
      ;dum12 = gsn_add_polyline(wks,plot(0), lon3, lat3, pres0)   ; SE Brazil
      ;dum13 = gsn_add_polyline(wks,plot(1), lon3,lat3,pres0)
      ;dum14 = gsn_add_polyline(wks,plot(2), lon3, lat3, pres0)   ; SE Brazil
      ;dum15 = gsn_add_polyline(wks,plot(3), lon3,lat3,pres0)



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
    if (ZOOM(zz).eq.1) then
      system("eog "+pltDir+pltName+".png")
    end if 

  end do                                             ;end zoom loop
end if                                               ;PLOT_RESULTS if
;===============================================================================


                   ;delete variables that will be used for another region


delete(pr_nc1)
delete(sst_nc1)
delete(pr_avg1)
delete(pr_var1)
delete(arrysst1)
delete(sst_avg1)
delete(sst_var1)
delete(diff_cat_pr)
delete(diff_cat_sst)
delete(pr_nc2)
delete(sst_nc2)
delete(pr_avg2)
delete(sst_avg2)
delete(pr_var2)
delete(sst_var2)
delete(pr_y)
delete(pr_x)
delete(sst_y)
delete(sst_x)
  if (TTEST)
    delete(alpha_pr)
    delete(alpha_sst)
  end if 
    if(PLOT_NOBS)
      print(threshold_pr)
      print(threshold_sst)
      delete(sst_filtt)
      delete(pr_filtt)
      delete(threshold_pr)
      delete(threshold_sst)
    end if 


print("--------------"+region(cb)+" DONE -------------------------------------")
print("--------------"+region(cb)+" DONE -------------------------------------")
print("--------------"+region(cb)+" DONE -------------------------------------")

  end do                                                ;end region loop

    print("--------------"+scenario(sce)+" done-------------------------------------")
end do                                          ;end scenario loop
