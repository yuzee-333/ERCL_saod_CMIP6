;---------------------------------------------------------------------------
; There are four regions for which Precipitation indices are generated
;
;---------------------------------------------------------------------------
;                         User input
;---------------------------------------------------------------------------

 region = (/"Northern_Amazon","Guinea_Coast","Central_Africa","SE_Brazil"/)
;--------------------------------------------------------------------------------------------------
                   ;arrays to hold regression values for each region
 rgvals = new((/dimsizes(region)/),float, 1e+20)
 rgvalsi = new((/dimsizes(region)/),float, 1e+20)
 siglev = new((/dimsizes(region)/),float, 1e+20)
 siglevi = new((/dimsizes(region)/),float, 1e+20)
 rgyave  = new((/dimsizes(region)/),float, 1e+20)
 rgxave  = new((/dimsizes(region)/),float, 1e+20)
 rgnptx  = new((/dimsizes(region)/),float, 1e+20)
 rgsde   = new((/dimsizes(region)/),float, 1e+20)
 rgtstat = new((/dimsizes(region)/),float, 1e+20)
 rmse    = new((/dimsizes(region)/),float, 1e+20)
 rgexvar = new((/dimsizes(region)/), float, 1e+20)
 rgcorr  = new((/dimsizes(region)/), float, 1e+20)
 rstatp  = new((/dimsizes(region)/), float, 1e+20)

 prarray = new((/dimsizes(region), 65/),float, 1e+20)
 sdarray = new((/dimsizes(region), 65/),float, 1e+20)
 ypdarray = new((/dimsizes(region), 65/),float, 1e+20)

;------------------------------------------------------------------------------------------------------
  RUNSCRIPT = True

  yrStrt= 1950
  yrLast= 2014

  clStrt= 1950          ; climatology start
  clLast= 2014          ;             last

  dpmm  = (/30,31,31/)
  jja_day_factor  = avg(dpmm)
  printMinMax(jja_day_factor, True)

  WRITE_RESULTS = True
  day_factor = 86400.			; # seconds in in a day


  season     = "JJA"
;=====================================================================================================

do cb=0,dimsizes(region)-1,1

;=========setting up the lon and lat coordinates for each box per season ===================

if (region(cb).eq."Northern_Amazon") then
   latS =  -5.
   latN =   7.
   lonL = -70.
   lonR = -50.
  else if (region(cb).eq."Guinea_Coast") then
   latS =   5.
   latN =  13.
   lonL = -10.
   lonR =  10.
  else if (region(cb).eq."Central_Africa") then
   latS =  -5.
   latN =   5.
   lonL =  10.
   lonR =  16.
  else                     ;if (region(cb).eq."SE_Brazil") then
   latS = -27.
   latN = -12.
   lonL = -56.
   lonR = -40.

  end if
  end if

end if


if (RUNSCRIPT)
;==============================================================================================================================
  diri   = "/home/yuzee/nclfolder/DATA/obs/sst/"
  fili   = "KAPLAN_sst.mon.anom.nc"
  varT   = "sst"

  sstname= getSubString(fili,0,3)


;==============================================================
; Open the file: Read only the user specified period
;===============================================================

  f    = addfile(diri+fili,"r")
  TIME   = f->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  HADI   = f->$varT$(iYYYY,:,:)
  printVarSummary(HADI)       ; variable overview
  delete(f)
  delete(TIME)
  delete(YYYY)
  delete(iYYYY)
  printMinMax(HADI,True)
;
  HADI = lonFlip(HADI)
;==============================================================
;==============================================================
;HADIClm      = clmMonTLL(HADI)
;printVarSummary(HADIClm)                   ; (12,nlat,nlon)
;HADI         = calcMonAnomTLL(HADI, HADIClm)    ; replace with anonamlies
;HADI@long_name = "ANOMALIES: "+HADI@long_name
;==============================================================
;==============================================================
;==============================================================
hadi = month_to_season(HADI,season)
printVarSummary(hadi)
printMinMax(hadi,True)
hadi = dtrend_msg_n(hadi&time,hadi,True,False,0)
printMinMax(hadi,True)
;==============================================================
saodi =  wgt_areaave_Wrap(hadi(time|:, {lon|-20:10}, {lat|-15:0}),1.0, 1.0, 0) -\
       	wgt_areaave_Wrap(hadi(time|:,{lon|-40:-10}, {lat|-40:-25}),1.0, 1.0, 0)
printVarSummary(saodi)
saodi_std2 = stddev(saodi)

; saodi_std = saodi
 saodi_std = saodi/stddev(saodi)
printVarSummary(saodi_std)


saodi_std!0 = "time"
saodi_std&time = hadi&time
printVarSummary(saodi_std)
sdarray(cb,:) = saodi_std
;============================================================
;delete(HADIClm)
delete(HADI)
delete(hadi)
delete(fili)
delete(diri)


;=========^^^^^^^%%%%%%%%%%%%%%%%%%%%%%^^^^&&&&&&&**********===========
;=======GENERATE PR INDEX =====================
;====Input coordinates of Precipitation region of Interest ======
;==============================================================================================================================

  var    = "precip"
  diri   = "/home/yuzee/nclfolder/DATA/obs/precip/"
  fili   = "Udel_precip.mon.total.v501.nc"
  in     = addfile(diri+fili,"r")
  precipname = getSubString(fili,0,3)



;===============================================================
; Open the file: Read only the user specified period
;===============================================================

  TIME   = in->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  GPCC   = in->$var$(iYYYY,:,:)
  printVarSummary(GPCC)       ; variable overview
  delete(in)
  delete(TIME)
  delete(YYYY)
  delete(iYYYY)
; GPCC = GPCC*day_factor		;no need, data is already monthly total
  GPCC = GPCC*10

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
gpcc = month_to_season(GPCC,season)
;printMinMax(gpcc,True)
gpcc = gpcc/jja_day_factor                            ;convert to mean mm/day
printMinMax(gpcc,True)
printVarSummary(gpcc)

gpcc = dtrend_msg_n(gpcc&time,gpcc,True,False,0)
printMinMax(gpcc,True)
;==============================================================
;==============================================================
delete(GPCC)
delete(GPCCClm)
;
;

;==============================================================
pri =  wgt_areaave_Wrap(gpcc(time|:, {lon|lonL:lonR}, {lat|latS:latN}),1.0, 1.0, 0)

pri_stdev = stddev(pri)
printVarSummary(pri)
pri_std = pri/stddev(pri)

pri!0 = "time"
pri&time = gpcc&time
printVarSummary(pri)
prarray(cb,:) = pri

;========================================================================================
;========================================================================================
;========================================================================================
 ;************************************************
; Perform linear regression on Saodi
;************************************************
  rc = regline(saodi_std, pri)                ; degC/year
  rc@long_name = "trend"
  rc@units     = "mm/day"

  print(rc)
  printMinMax(rc, True)

;>>>>>>>>>>>>>>>>>>>>>>>>>>  calculating the significance level
  df   = rc@nptxy-2

  prob  = (1 - betainc(df/(df+rc@tval^2), df/2.0, 0.5) )
  alpha = betainc(df/(df+rc@tval^2), df/2.0, 0.5)
  yvals = rc*saodi_std + rc@yintercept
  rmsd = dim_rmsd_n(pri, yvals,0)


  av_pri_pred  = avg(yvals)

  SST  = sum((pri - rc@yave)^2)
  SSR  = sum((yvals - av_pri_pred)^2)

  r_squared  = 1.0 - (SSR/SST)


;----------------- calculate the Pearson correlation
  r = escorc_n(saodi_std, pri_std, 0, 0)

;----========= compute correlation confidence interval ---------------
  nr    = dimsizes(saodi_std)
;==-----An alternative for testing significance is:

        t    = r*sqrt((df)/(1-r^2))
        p    = student_t(t, df)
        psig = 0.05                       ; test significance level

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;-----------<<<<<<<<<<<<< setting up values for regression line
  nx           = dimsizes(pri)
  pltarry      = new ( (/2,nx/), typeof(pri))
  pltarry(0,:) = pri                              ; use markers
  pltarry(1,:) = rc*saodi_std + rc@yintercept      ; [y=bx+a] y-values as predicted by reg-line

;<<<<<<<<<<<---------------------------------------------------------
                              ;writing the regression values to pre-generated arrays
  rgvals(cb)  = rc              ;slope (b) or regression coefficient
  rgvalsi(cb) = rc@yintercept   ;intercept (a)
  siglev(cb)  = prob            ;significance level 1
  siglevi(cb) = alpha           ;significance level 2
  rgyave(cb)  = pri_stdev       ;stdev for precip timeseries
  rgxave(cb)  = saodi_std2      ;stdev for saodi timeseries
  rgnptx(cb)  = rc@nptxy        ;number of points used
  rgsde(cb)   = rc@rstd         ;standard error of regression coefficient
  rgtstat(cb) = rc@tval         ;t-statistic(assuming null hypothesis)
  rmse(cb)    = rmsd
  ypdarray(cb, :) = yvals
  rgexvar(cb) = r_squared       ;explained variance
  rgcorr(cb)  = r               ;the correlation value
  rstatp(cb)  = p               ;significance value of correlation

;***********************************************
;---Save to a netcdf file, in the current directory
;***********************************************

    if (WRITE_RESULTS)
        diro = "/home/yuzee/nclfolder/RESULTS/07imanuscript/"
        filo = sstname+"vs"+precipname+"_obs_reg_manuscript_"+season+"_"+region(cb)+"_"+yrStrt+"_"+yrLast+".nc"
        ptho = diro+filo
        system("/bin/rm -f "+ptho)
        ncdf = addfile(ptho,"c")

        fAtt = True
        fAtt@title         = "Regression of Pr Index on SAOD index from Models"
        fAtt@source_name   = "HadISST and GPCC monthly datasets"
        fAtt@source_URL    = "https://esgf-node.llnl.gov/projects/cmip6/"
        fAtt@source        = "Accessed from Levante Supercomputer, Hamburg, Germany"
        fAtt@Conventions   = "None"
        fAtt@creation_date = systemfunc("date")
        fileattdef(ncdf,fAtt)            ; copy file attributes

  ;     filedimdef(ncdf,"time",-1,True) ; make time an UNLIMITED dimension
        ncdf->pri = prarray(:,:)
        ncdf->saodi = sdarray(:,:)
        ncdf->yvals = ypdarray(:,:)
  ;      print("-----------------DONE----------------------")
    end if



;===========================================================
;  user specified for plots
;===============================================================

  txtName = "obs_"+season+"_regression_"+region(cb)

  pltType = "eps"       ; send graphics to PNG file
  pltDir  = "/home/yuzee/nclfolder/RESULTS/07imanuscript/"               ; dir to which plots are sent

 pltName = txtName+"_"+yrStrt+"-"+yrLast
; pltTitle= txtName+": "+yrStrt+"-"+yrLast \
;          + ": Base "+clStrt+"-"+clLast
;

;************************************************
; create plot: use overlay approach
;************************************************
    wks  = gsn_open_wks(pltType, pltDir+pltName)                         ; send graphics to PNG file

   res                     = True                     ; plot mods desired
   res@xyMarkLineModes     = (/"Markers","Lines"/)    ; choose which have markers
   res@xyMarkers           = 16                       ; choose type of marker
   res@xyMarkerColor       = "red"                    ; Marker color
   res@xyMarkerSizeF       = 0.005                    ; Marker size (default 0.01)
   res@xyDashPatterns      = 1                        ; solid line
   res@xyLineThicknesses   = (/1,2/)                  ; set second line to 2
   res@tmYLFormat          = "f"                      ; not necessary but nicer labels
   res@tiYAxisOn           = True
   res@tiYAxisPosition     = "Center"
   res@tiYAxisString       = "Precip Anomaly (mm/day)"

   res@tiXAxisOn           = True
   res@tiXAxisPosition     = "Center"
   res@tiXAxisString       = "SAOD index(normalized)"
   res@tiXAxisFontHeightF  = 0.015

   res@tiMainString        = "Regression Obs "+season+"_"+region(cb)+" b = "+rc      ;title
   res@tiMainFontHeightF   = 0.017

   plot  = gsn_csm_xy (wks,saodi_std,pltarry,res)                         ; create plot

 end if
end do                                               ;end region loop

;================================================================================================
;---- Creating csv file to hold all rc(b) and rc-intercept(a) values for all five regions -------
;------===================++++++++++++++++++-----------------==================********************

  csvname = sstname+"vs"+precipname+"_obs_Corndreg_"+season+".csv"
  wad       = pltDir+csvname

 col1 = "Region"
 col2 = "b"
 col3 = "a-intercept"
 col4 = "prob"
 col5 = "alpha"
 col6 = "pri_std"
 col7 = "saod_std"
 col8 = "npxy"
 col9 = "std_error"
 col10 = "t"
 col11 = "r_squared"
 col12  = "r"
 col13  = "p"

 regname = region+"_obs"

 header = [/col1, col2, col3, col4, col5, col6, col7, col8, col9, col10, col11, col12, col13/]
 formatt = "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s, %s, %s"

 write_table(wad, "w", header, formatt)  ;create header


 csvlist = [/regname, rgvals, rgvalsi, siglev, siglevi, rgyave, rgxave, rgnptx,\
 rgsde, rgtstat,   rgexvar, rgcorr, rstatp/]
format = "%s,%g,%g,%g,%g,%g,%g,%g,%g,%g, %g, %g, %g"

 write_table(wad, "a", csvlist, format)  ;"a"ppend values to table

 print("========== CSV file created ===============================")


 ;########################################################################
