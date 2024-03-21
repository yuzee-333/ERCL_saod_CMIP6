;
begin
wcStrt     = systemfunc("date")		;To check the time taken for the code
;======================================
yrStrt = 1950
yrLast = 2014
latS   = -90.
latN   =  90.
lonL   = -180.
lonR   =  180.
p95    = 0.05

season = (/"JJA"/) ;,"DJF", "MAM", "SON"/)    ; choose Dec-Jan-Feb seasonal mean

do sq=0,dimsizes(season)-1,1

 ZOOM    = (/0,1/)                          ;loop through zoom off '0' and on '1'
 do zz=0,dimsizes(ZOOM)-1,1

 pltType = (/"eps", "png"/)
 pltDir = "/home/yuzee/nclfolder/RESULTS/02global_correlation/"
if (ZOOM(zz).eq.1) then
 pltName = "obs_zoom_"+season(sq)+"_"+"mean_corrplots"
else
 pltName = "obs_"+season(sq)+"_"+"mean_corrplots"
end if
            ; to zoom in on the region for the plot
 latSp = -35
 latNp =  18
 lonLp = -75
 lonRp =  25

WRITE_RESULTS =  True
PLOT_MAP      =  True

day_factor = 86400.			; # seconds in in a day
;
;==============================================================================================================================
diriT = "/home/yuzee/nclfolder/DATA/obs/"
hdataT = (/"HadISST_sst.nc"/)
print(hdataT)
printVarSummary(hdataT)



diri = "/home/yuzee/nclfolder/DATA/obs/"
hdata = (/"precip_monthly_gpcc_v2022_1941_2020_10.nc"/)
print(hdata)
printVarSummary(hdata)

;
rDATA = new((/dimsizes(hdata),180,360/),float,1e+20)                ;array to hold the data
printVarSummary(rDATA)
;

var = "precip"
varT = "sst"

do nn=0,dimsizes(hdataT)-1,1
print("=================================================")
print(nn)
print("=================================================")
title  = "correlation_obs" ;str_upper(var)+": "+hdata_names(nn)
print(title)
;===============================================================
; Open the file: Read only the user specified period
;===============================================================
f    = addfiles(diri+hdata,"r")
  TIME   = f[nn]->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  GPCC   = f[nn]->$var$(iYYYY,:,:)
  printVarSummary(GPCC)       ; variable overview
  delete(f)
  delete(TIME)
  delete(YYYY)
  delete(iYYYY)
  GPCC = GPCC*day_factor		;	converts to mm/day

  GPCC = lonFlip(GPCC)
;=============================================================
;==============================================================
; Mask out ocean grid-points for precipitation
;=============================================================
   a    = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
   lsdata = a->LSMASK
   lsm  = landsea_mask(lsdata,GPCC&lat,GPCC&lon)
;;  GPCC = mask(GPCC,conform(GPCC,lsm,(/1,2/)).eq.0,False)
  GPCC = mask(GPCC,lsm.eq.0,False)
  delete(a)
  delete(lsdata)
  delete(lsm)
;==============================================================
;==============================================================
;==============================================================
;==============================================================
GPCCClm      = clmMonTLL(GPCC)
printVarSummary(GPCCClm)                   ; (12,nlat,nlon)
GPCC         = calcMonAnomTLL(GPCC, GPCCClm)    ; replace with anonamlies
GPCC@long_name = "ANOMALIES: "+GPCC@long_name
;==============================================================
gpcc = month_to_season(GPCC,season(sq))
printVarSummary(gpcc)
printMinMax(gpcc,True)
gpcc = dtrend_msg_n(gpcc&time,gpcc,True,False,0)

gpcc_std = gpcc/stddev(gpcc)
printVarSummary(gpcc_std)
;==============================================================
;==============================================================
delete(GPCC)
delete(GPCCClm)
;
;
;==============================================================
; Open the file: Read only the user specified period - SST DATA
;===============================================================


  f    = addfiles(diriT+hdataT,"r")
  TIME   = f[nn]->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  HADI   = f[nn]->$varT$(iYYYY,:,:)
  printVarSummary(HADI)       ; variable overview
  delete(f)
  delete(TIME)
  delete(YYYY)
  delete(iYYYY)
  printMinMax(HADI,True)
;
;  HADI = lonFlip(HADI)        ;not needed using haddist data
;==============================================================
;==============================================================
HADIClm      = clmMonTLL(HADI)
printVarSummary(HADIClm)                   ; (12,nlat,nlon)
HADI         = calcMonAnomTLL(HADI, HADIClm)    ; replace with anonamlies
HADI@long_name = "ANOMALIES: "+HADI@long_name
;==============================================================
;==============================================================
;==============================================================
hadi = month_to_season(HADI,season(sq))
printVarSummary(hadi)
printMinMax(hadi,True)
hadi = dtrend_msg_n(hadi&time,hadi,True,False,0)
printMinMax(hadi,True)
;==============================================================
saodi =  wgt_areaave_Wrap(hadi(time|:, {longitude|-20:10}, {latitude|-15:0}),1.0, 1.0, 0) -\
       	wgt_areaave_Wrap(hadi(time|:,{longitude|-40:-10}, {latitude|-40:-25}),1.0, 1.0, 0)
printVarSummary(saodi)
saodi_std = saodi/stddev(saodi)
saodi_std!0 = "time"
saodi_std&time = hadi&time
printVarSummary(saodi_std)
;============================================================
delete(HADIClm)
delete(HADI)
delete(hadi)
;============================================================
;===================== CORRELATION  =======================================

rGPCC = escorc_n(saodi_std,gpcc_std,0,0)      ; ccr(nlat,mlon)
printVarSummary(rGPCC)
printMinMax(rGPCC,True)

;==============================================================
 rDATA(nn,:,:) =  rGPCC
 delete(rGPCC)  		; will be used again
;========================
printMinMax(rDATA,True)

;
end do
delete(nn)
;
;
;
copy_VarCoords(gpcc(0:dimsizes(hdata)-1,:,:),rDATA)
rDATA!0 = "model"
printVarSummary(rDATA)
;

;"ensemble_rain = dim_avg_n_Wrap(rDATA,0)
;"printVarSummary(ensemble_rain)
;"printMinMax(ensemble_rain,True)
;
;===============================================================
;===============================================================
;***********************************************
;---Save to a netcdf file, in the current directory
;***********************************************

  if (WRITE_RESULTS)
      diro = "/home/yuzee/nclfolder/RESULTS/02global_correlation/"
      filo = "obs_saodi_precipitation_correlations_"+season(sq)+"_"+yrStrt+"_"+yrLast+".nc"
      ptho = diro+filo
      system("/bin/rm -f "+ptho)
      ncdf = addfile(ptho,"c")

      fAtt = True
      fAtt@title         = "Correlations between SAODI and global precipitation"
      fAtt@source_name   = "CMIP6 historical runs"
      fAtt@source_URL    = "https://esgf-node.llnl.gov/projects/cmip6/"
      fAtt@source        = "Accessed from Levante Supercomputer, Hamburg, Germany"
      fAtt@Conventions   = "None"
      fAtt@creation_date = systemfunc("date")
      fileattdef(ncdf,fAtt)            ; copy file attributes

;     filedimdef(ncdf,"time",-1,True) ; make time an UNLIMITED dimension
      ncdf->rDATA = rDATA


;***********************************************
;===================================================================================
;===============PLOT the corr map ====================================================

 ff = addfile (diro+filo, "r")

  st    = ff->rDATA(:,:,:)                        ; plotting the correlation file
  printVarSummary(st)                              ; variable overview
  st_avg = dim_avg_n_Wrap(st,(0))
  printVarSummary(st_avg)
  printMinMax(st_avg, True)                             ; variable overview

end if

p95 = 0.2       ;significant correlation
siglvl = 0.05
rr = st_avg              ; rr is the correlation value
Nr = dimsizes(saodi_std)
pr = rtest(rr, Nr, 0)
printVarSummary(pr)
printMinMax(pr, True)
rr = where(pr.lt.siglvl,rr, rr@_FillValue)
print("rr min max")
printMinMax(rr, True)


 ;rr = where(abs(rr).gt.p95,rr,rr@_FillValue)
 ;printMinMax(rr,True)


  ;range_only = st_avg
  ;range_only = mask(st_avg, (st_avg.ge.abs(0.2)), True)


  ;range_only = mask(st_avg,conform(st_avg, (st_avg..mincorr .and. \
  ;st_avg.le.threshold2 .and. st_avg.ge.threshold .and. st_avg.le.maxcorr), (/1,1,1/)), True)

;============================================================
; PLOTS
;============================================================
if (PLOT_MAP)
do pc=0,dimsizes(pltType)-1,1
  wks = gsn_open_wks(pltType(pc), pltDir+pltName)         ; send graphics to PNG/eps/jpg file
  plot = new(1,graphic)                ; create graphic array
                                          ; only needed if paneling
; EOF patterns

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
  res@cnLinesOn            = False       ; True is default
  res@cnLineLabelsOn       = False       ; True is default
  res@cnFillPalette        = "BlWhRe"     ; set color map
  res@lbLabelBarOn         =  False        ; turn off individual lb's
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMonoFillColor      = False
  res@cnMinLevelValF       = -0.6
  res@cnMaxLevelValF       =  0.6
  res@cnLevelSpacingF      =  0.05
  res@cnLevels             =  0.2
                                          ; set symmetric plot min/max



; panel plot only resources
  resP                     = True         ; modify the panel plot
  resP@gsnMaximize         = True         ; large format
  resP@gsnPanelLabelBar    = True         ; add common colorbar
  resP@gsnPaperOrientation = "portrait"
  resP@gsnPanelMainString  = "Observations SAOD-rainfall Correlation "+season(sq)+" : "+yrStrt+"-"+yrLast
  resP@tiMainFontHeightF   = 0.017

; Set contour options for significance plot
  sig_res                   = True
  sig_res@cnFillOn          = False
  sig_res@cnLinesOn         = True
  sig_res@cnLineLabelsOn    = False
  sig_res@cnLineDashPattern = 4
if (ZOOM(zz).eq.1) then
  sig_res@cnLineThicknessF  = 4.0
  sig_res@cnLineColor       = "white"
else
  sig_res@cnLineThicknessF  = 2.0
  sig_res@cnLineColor       = "white"
end if

;*******************************************
; first plot
;*******************************************


    ;plot=gsn_csm_contour_map(wks, rr,res)
    plot= gsn_csm_contour_map_overlay(wks, st_avg, rr,res,sig_res)

;================= CREATE BOXES ==================================


   ;----Resources for the polyline
     pres0                    = True
     pres0@gsLineThicknessF   = 3.
     pres0@gsLineColor        = "black"
     pres0@gsLineDashPattern  = 0.
     pres0@tfPolyDrawOrder    = "postDraw"

  if (season(sq).eq."JJA") then                       ; polyline coordinates for JJA
                                        ;Amazon
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

   end if


   ;-------drawing the polylines -------------------------
     pres0@gsLineLabelString  = "1"
     dum0 = gsn_add_polyline(wks,plot(0),lonEQ,latEQ,pres0) ; Northern Amazon
     pres0@gsLineLabelString  = "2"
     dum3 = gsn_add_polyline(wks,plot(0), lon1, lat1, pres0)  ; west africa guinea coast
     pres0@gsLineLabelString  = "3"
     dum5 = gsn_add_polyline(wks,plot(0), lon2, lat2, pres0)  ; central africa
     pres0@gsLineLabelString  = "4"
     dum7 = gsn_add_polyline(wks,plot(0), lon3, lat3, pres0)   ; SE Brazil


   ;========================================================================


gsn_panel(wks,plot,(/1,1/),resP)     ; now draw as one plot



;

;gsn_panel(wks,plot,(/1,1/),resP)     ; now draw as one plot

end do                               ;end pltType loop
end if                               ;end PLOT_MAP condition

end do                               ;end ZOOM loop

end do                               ;end season loop
;===============================================================
 wallClockElapseTime(wcStrt, "Processing and Graphics", 0)
;==================================================================================
;==================================================================================
;==================================================================================
;==================================================================================


end
