; ===================================================================================================
; ================ PLOTTING MEAN CORRELATION MAPS FOR MODEL AND OBS =================================
; -------------------------using file generated from 'write_correlation_maps' script
; -------"this version of the corr & reg combination plot also overlays mean rainfall as contour on the \
; correlation plots. Rainfall data for ensemble of all models is generated in script 43".

begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
  latS   =  -90      ;-50.
  latN   =   90.      ; 5
  lonL   =  -180    ;-60.
  lonR   =  180         ;20.

  yrStrt = 1950
  yrLast = 2014

  season = (/"JJA","DJF"/)      ; can switch between the seasons (JJA,DJF)
  ;do sq=0,dimsizes(season)-1,1                  ;do for all seasons
   do sq=0,0,1                                   ;do for just the first season


  nplots   = 4    ; number of plots

ZOOM    = (/0,1/)                          ;loop through zoom off '0' and on '1'
do zz=0,dimsizes(ZOOM)-1,1
;do zz=0,0,1

pltType = (/"eps", "png"/)
;pltDir = "/home/yuzee/my_research/my.work/manuscript/01_figures/"
pltDir = "/home/yuzee/nclfolder/RESULTS/07imanuscript/"

if (ZOOM(zz).eq.1) then
 pltName = "combined_contour_zoom_"+season(sq)+"_corrandreg"
else
 pltName = "combined_contour_global_"+season(sq)+"_corrandreg"
end if

 ; to zoom in on the region for the plot
 latSp =  -45
 latNp =   18
 lonLp =  -75
 lonRp =   25

;===============================================================================
;===============================================================================
diriT = "/home/yuzee/nclfolder/DATA/obs/"
hdataT = (/"HadISST_sst.nc"/)
qq    = addfile(diriT+hdataT,"r")
TIME   = qq->time
YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
HADI   = qq->sst(iYYYY,:,:)
printVarSummary(HADI)       ; variable overview
delete(qq)
delete(TIME)
delete(YYYY)
delete(iYYYY)
printMinMax(HADI,True)
HADIClm      = clmMonTLL(HADI)
printVarSummary(HADIClm)                   ; (12,nlat,nlon)
HADI         = calcMonAnomTLL(HADI, HADIClm)    ; replace with anonamlies
HADI@long_name = "ANOMALIES: "+HADI@long_name
hadi = month_to_season(HADI,season(sq))
printVarSummary(hadi)
printMinMax(hadi,True)
hadi = dtrend_msg_n(hadi&time,hadi,True,False,0)
printMinMax(hadi,True)
saodi =  wgt_areaave_Wrap(hadi(time|:, {longitude|-20:10}, {latitude|-15:0}),1.0, 1.0, 0) -\
       	wgt_areaave_Wrap(hadi(time|:,{longitude|-40:-10}, {latitude|-40:-25}),1.0, 1.0, 0)
printVarSummary(saodi)
saodi_std = saodi/stddev(saodi)
saodi_std!0 = "time"
saodi_std&time = hadi&time
printVarSummary(saodi_std)
delete(HADIClm)
delete(HADI)
delete(hadi)
;===============================================================================
;===============================================================================

;===============  CORRELATION ===================================================
;=============Read in the MODEL correlation data ==================================

  dirp    = "/home/yuzee/nclfolder/RESULTS/02global_correlation/"
  filp   =  "saodi_precipitation_correlations_"+season(sq)+"_1950_2014.nc"

  f      = addfile (dirp+filp, "r")
;
  slp    = f->rDATA(:,:,:)                        ; plotting the correlation file
  delete(f)
  printVarSummary(slp)                              ; variable overview
  slp_avg = dim_avg_n_Wrap(slp,(0))                  ;finding the average of all the models
  printVarSummary(slp_avg)
  printMinMax(slp_avg, True)
  p95 = 0.2
  rm = slp_avg
  rm = where(abs(rm).gt.p95,rm,rm@_FillValue)


;============================================================
;==================== Read in OBSERVATIONS correlation data ===========================================
; ==============================================================
  dir     = "/home/yuzee/nclfolder/RESULTS/02global_correlation/"
  ff      = addfile (dir+"obs_saodi_precipitation_correlations_"+season(sq)+"_1950_2014.nc", "r")
;
  st    = ff->rDATA(:,:,:)                        ; plotting the correlation file
  printVarSummary(st)                              ; variable overview
   st_avg = dim_avg_n_Wrap(st,(0))
  printVarSummary(st_avg)
  printMinMax(st_avg, True)
  rr = st_avg
  siglvl = 0.05              ;p95
 rr = st_avg                 ; rr is the correlation value
 Nr = dimsizes(saodi_std)
 pr = rtest(rr, Nr, 0)       ;rtest on the correlation values (rr)
 printVarSummary(pr)
 printMinMax(pr, True)
 rr = where(pr.lt.siglvl,rr, rr@_FillValue)
  ;rr = where(abs(rr).gt.p95,rr,rr@_FillValue)

;================= REGRESSION ==================================================
  ;=============Read in the MODEL regression data ==================================

    dirp1    = "/home/yuzee/nclfolder/RESULTS/02global_regression/"
    filp1   =  "saodi_precipitation_regression_"+season(sq)+"_1950_2014.nc"

    f1      = addfile (dirp1+filp1, "r")
  ;
    slp1    = f1->rDATA(:,:,:)                        ; plotting the regression file
    delete(f1)
    printVarSummary(slp1)                              ; variable overview
    slp_avg1 = dim_avg_n_Wrap(slp1,(2))                  ;finding the average of all the models
    printVarSummary(slp_avg1)
    printMinMax(slp_avg1, True)
    p95 = 0.2
    rm1 = slp_avg1
    rm1 = where(abs(rm1).gt.p95,rm1,rm1@_FillValue)


  ;============================================================
  ;==================== Read in OBSERVATIONS regression data ===========================================
  ; ==============================================================

    ff1      = addfile (dirp1+"obs_saodi_precipitation_regression_"+season(sq)+"_1950_2014.nc", "r")
  ;
    st1    = ff1->rDATA(:,:,:)                        ; plotting the regression file
    printVarSummary(st)                              ; variable overview
     st_avg1 = dim_avg_n_Wrap(st1,(2))
    printVarSummary(st_avg1)
    printMinMax(st_avg1, True)
    rr1 = st_avg1
    siglvl = 0.05              ;p95
   rr1 = st_avg1                 ; rr is the regression value
   Nr1 = dimsizes(saodi_std)
   pr1 = rtest(rr1, Nr1, 0)       ;rtest on the regression values (rr)
   printVarSummary(pr1)
   printMinMax(pr1, True)
   rr1 = where(pr1.lt.siglvl,rr1, rr1@_FillValue)
    ;rr1 = where(abs(rr1).gt.p95,rr1,rr1@_FillValue)

;---------DATA FOR MEAN RAINFALL CONTOUR PLOTS ----------------------------------
;============== read in MEAN RAINFALL models ====================================

diro    = "/home/yuzee/nclfolder/RESULTS/07manuscript/mean_maps/allmodels_nc/"
filo    = "Hist_Allpr_mean_JJA.nc"
P       = addfile(diro+filo, "r")

pr_nc   = P  ->allmean_rain(:,:,:)
pr_avg    = dim_avg_n(pr_nc, (0))    ;average of models mean rainfall values, the MMM
copy_VarCoords(slp_avg,pr_avg)
printVarSummary(pr_avg)
printMinMax(pr_avg, True)

obsdiro = "/home/yuzee/nclfolder/DATA/obs/"

;----------------Obs RAINFALL ---------------------------------------------------------
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
 prc_ann2  = month_to_season(prc_clm,season(sq))
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

 ;=========--------------------====================================-------------

;================================================================================

; PLOTS
;============================================================
  do pc=0,dimsizes(pltType)-1,1
  wks = gsn_open_wks(pltType(pc), pltDir+pltName)         ; send graphics to PNG/eps/jpg file
  plot = new(nplots,graphic)                ; create graphic array
                                          ; only needed if paneling
; plot resources

  res                      = True
  res@gsnDraw              = False        ; don't draw yet
  res@gsnFrame             = False        ; don't advance frame yet

  res@gsnAddCyclic         = True        ; plotted data are not cyclic

  res@mpFillOn             = False        ; turn off map fill
  if (ZOOM(zz).eq.1) then
    res@mpMinLatF            = latSp         ; zoom in on map
    res@mpMaxLatF            = latNp
    res@mpMinLonF            = lonLp
    res@mpMaxLonF            = lonRp
  else
    res@mpMinLatF            = latS         ; zoom in on map
    res@mpMaxLatF            = latN
    res@mpMinLonF            = lonL
    res@mpMaxLonF            = lonR
  end if

  res@cnFillOn             = True         ; turn on color fill
  res@cnLinesOn            = False        ; True is default
  res@cnLineLabelsOn       = False        ; True is default
  res@cnFillPalette        = "BlWhRe"     ; set color map
  res@lbLabelBarOn         = True        ; turn off individual lb's
  res@lbOrientation        = "vertical"   ; vertical label barb's
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMonoFillColor      = False

  res@cnMinLevelValF       = -0.6
  res@cnMaxLevelValF       =  0.6
  res@cnLevelSpacingF      =  0.05
            ; res@gsnCenterString      = "Manual"
            ;  res@tiMainString         = "SAOD index and rainfall correlation "+season(sq)+" (Obs vs Model)"
            ;  res@tiMainFontHeightF    =  0.02

  ; panel plot only resources
  resP                     = True         ; modify the panel plot
  resP@gsnMaximize         = True         ; large format
  resP@gsnPanelLabelBar    = False        ; add common colorbar
  resP@gsnPaperOrientation = "portrait"
  ;resP@gsnPanelMainString  = "SAOD-rainfall correlation "+season(sq)+" (Obs vs Model)"
  resP@tiMainFontHeightF    =  0.01
  ; Set contour options for significance plot
    sig_res                   = True
    sig_res@cnFillOn          = False
    sig_res@cnLinesOn         = True
    sig_res@cnLineLabelsOn    = False
    sig_res@cnInfoLabelOn     = False
    sig_res@cnLineDashPattern = 4
  if (ZOOM(zz).eq.1) then
    sig_res@cnLineThicknessF  = 4.0
    sig_res@cnLineColor       = "white"
  else
    sig_res@cnLineThicknessF  = 2.0
    sig_res@cnLineColor       = "white"
  end if

  tres               =  True
  tres@txFontHeightF = 0.02
  tres@txFontColor   = "black"


  res2                      = True
  res2@gsnDraw              = False             ; do not draw the plot
  res2@gsnFrame             = False
  res2@gsnMaximize          = True
  res2@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res2@cnMinLevelValF       =  0.              ; set min contour level
  res2@cnMaxLevelValF       =  15.              ; set max contour level
  res2@cnLevelSpacingF      =  3.              ; set contour spacing
  res2@cnLineLabelsOn       = True
  res2@cnInfoLabelOn        = False
  res2@gsnLeftString        = " "
  res2@gsnContourZeroLineThicknessF = 2. 	; doubles thickness of zero contour
  res2@gsnContourNegLineDashPattern = 1 	; sets negative contours to dash pattern 1
  res2@cnLineColor          = "black"


                                          ; set symmetric plot min/max
;  symMinMaxPlt(slp_avg, 0, False, res)       ; contributed.ncl
;========================================================================
;*******************************************
; combined plot
;*******************************************
  do n=0,nplots-2
     res@gsnLeftString  = "[b] CMIP6 Ensemble JJA SAOD-rainfall correlation"
     res@gsnRightString = " "

     res@lbTitleString    = "corr"                ; title string
     res@lbTitlePosition  = "Bottom"              ; title position
     res@lbTitleFontHeightF= .018                ; make title smaller
     res@lbTitleDirection = "Across"             ; title direction
     plot(1)=gsn_csm_contour_map_overlay(wks,slp_avg,rm,res, sig_res)
     plot_ov=gsn_csm_contour(wks,pr_avg,res2)                       ; create the U-wind plot
     overlay(plot(1),plot_ov)                       ; overlay the U-wind plot on the temperature plot

     res@gsnRightString = " "
     res2@gsnRightString = " "
     res@gsnLeftString  = "[a] Observations JJA SAOD-rainfall correlation"
     plot(0)=gsn_csm_contour_map_overlay(wks,st_avg,rr,res,sig_res)
     plot_ovobs=gsn_csm_contour(wks,obs_prc_ann,res2)
     overlay(plot(0),plot_ovobs)



     res@lbTitleString      = "mm/day"                ; title string
     res@lbTitlePosition    = "Bottom"              ; title position
     res@lbTitleFontHeightF = .018                ; make title smaller
     res@lbTitleDirection = "Across"             ; title direction
     res@gsnLeftString  = "[d] CMIP6 Ensemble JJA SAOD-rainfall regression"
  ;   res@gsnRightString = "mm/day"
     plot(3)=gsn_csm_contour_map_overlay(wks,slp_avg1,rm1,res, sig_res)
     res@gsnLeftString  = "[c] Observations JJA SAOD-rainfall regression"
  ;   res@gsnRightString = "mm/day"
     plot(2)=gsn_csm_contour_map_overlay(wks,st_avg1,rr,res,sig_res)

  end do

  ;================= CREATE BOXES ==================================


;----Resources for the polyline
  pres0                    = True
  pres0@gsLineThicknessF    = 3.
  pres0@gsLineColor        = "black" ;"skyblue" "darkgreen" "green"
  pres0@gsLineDashPattern  = 0.
  pres0@tfPolyDrawOrder    = "postDraw"

                                          ; polyline coordinates for JJA
                                  ; Amazon
  latEQ = (/ 7., 7., -5., -5., 7./)
  lonEQ = (/-70., -50., -50., -70., -70./)
                                  ;Guinea_Coast
  lat1 = (/ 13., 13., 5., 5., 13./)
  lon1 = (/ -10., 10., 10., -10.,-10./)
                                  ;Central Africa
  lat2 = (/ 5., 5., -5., -5., 5./)
  lon2 = (/ 10., 16., 16., 10., 10./)
                                  ;SE_Brazil
  lat3 = (/ -12., -12., -27., -27., -12./)
  lon3 = (/ -56., -40., -40., -56., -56./)



  ;-------drawing the polylines -------------------------
    ;pres0@gsMarkerColor   = "green"
    pres0@gsLineLabelString  = "1"
    dum0 = gsn_add_polyline(wks,plot(0),lonEQ,latEQ,pres0) ; Northern Amazon
    dum1 = gsn_add_polyline(wks,plot(1),lonEQ,latEQ,pres0) ; Northern Amazon
    dum2 = gsn_add_polyline(wks,plot(2),lonEQ,latEQ,pres0) ; Northern Amazon
    dum3 = gsn_add_polyline(wks,plot(3),lonEQ,latEQ,pres0) ; Northern Amazon

    pres0@gsLineLabelString  = "2"
    dum4 = gsn_add_polyline(wks,plot(0), lon1, lat1, pres0)  ; west africa guinea coast
    dum5 = gsn_add_polyline(wks,plot(1), lon1, lat1,pres0) ;
    dum6 = gsn_add_polyline(wks,plot(2), lon1, lat1, pres0)  ; west africa guinea coast
    dum7 = gsn_add_polyline(wks,plot(3), lon1, lat1,pres0) ;

    pres0@gsLineLabelString  = "3"
    dum8  = gsn_add_polyline(wks,plot(0), lon2, lat2, pres0)  ; central africa
    dum9  = gsn_add_polyline(wks,plot(1), lon2,lat2,pres0)
    dum10 = gsn_add_polyline(wks,plot(2), lon2, lat2, pres0)  ; central africa
    dum11 = gsn_add_polyline(wks,plot(3), lon2,lat2,pres0)

    pres0@gsLineLabelString  = "4"
    dum12 = gsn_add_polyline(wks,plot(0), lon3, lat3, pres0)   ; SE Brazil
    dum13 = gsn_add_polyline(wks,plot(1), lon3,lat3,pres0)
    dum14 = gsn_add_polyline(wks,plot(2), lon3, lat3, pres0)   ; SE Brazil
    dum15 = gsn_add_polyline(wks,plot(3), lon3,lat3,pres0)

    if (ZOOM(zz).eq.1) then
;      a = gsn_add_text(wks,plot(0),"[a]",-70,15,tres)
;      b = gsn_add_text(wks,plot(1),"[b]",-70,15,tres)
;      c = gsn_add_text(wks,plot(2),"[c]",-70,15,tres)
;      d = gsn_add_text(wks,plot(3),"[d]",-70,15,tres)
      e = gsn_add_text(wks,plot(0),"3",9,-4, tres)
      f = gsn_add_text(wks,plot(1),"3",9,-4, tres)
      g = gsn_add_text(wks,plot(2),"3",9,-4, tres)
      h = gsn_add_text(wks,plot(3),"3",9,-4, tres)
    end if


;========================================================================

                                      ; now draw all as one plot
  gsn_panel(wks,plot,(/2,2/),resP)     ;draw horizontal - 1 row, 2 columns
; gsn_panel(wks,plot,(/2,1/),resP)     ;draw vertical    - 2 rows, 1 column


  end do                                    ;end pltType loop
 end do                                     ;end zoom loop
end do                                      ;end season loop

end
