load "modelnames_proj.ncl"      ;model list in each region are arranged according to category

; for MANUSCRIPT
;========== generate saodi index ===================

;======================================
;  latS  = -50
;  latN  =  5.0
;  lonL  = -60
;  lonR  =  20    ;(coordinates for the SAODI area)

  yrStrt = 2015
  yrLast = 2079

  clStrt = 2015          ; climatology start
  clLast = 2079          ;             last

  RUNSCRIPT     = True
  WRITE_RESULTS = True
  day_factor    = 86400.			; # seconds in in a day


  season     = "JJA"
;=====================================================================================================
  region = (/"Northern_Amazon","Guinea_Coast","Central_Africa","SE_Brazil"/)
 do cb=0,dimsizes(region)-1,1
 ; # do cb=0,dimsizes(region)-4,1 ~ to loop over only the first iteration in the region array

 diriT = "/home/yuzee/nclfolder/DATA/cmip6/projection/tos/"

;=========setting up the lon and lat coordinates for each box per season ===================

if (region(cb).eq."Northern_Amazon") then
  hdataT = N_A
  modnames_short = N_A_shorts                                          ;called from file loaded in line 1
  latS =  -5.
  latN =   7.
  lonL = -70.
  lonR = -50.
 else if (region(cb).eq."Central_Africa") then
  hdataT = C_A
  modnames_short = C_A_shorts
  latS =  -5.
  latN =   5.
  lonL =  10.
  lonR =  16.
 else if (region(cb).eq."Guinea_Coast") then
  hdataT = G_C
  modnames_short = G_C_shorts
  latS =   5.
  latN =  13.
  lonL = -10.
  lonR =  10.
 else
  hdataT = S_B
  modnames_short = S_B_shorts
  latS = -27.
  latN = -12.
  lonL = -56.
  lonR = -40.

  end if
  end if

end if


;
;==============================================================================================================================


printVarSummary(hdataT)
hdata_names = modnames_short           ;also called from file loaded in line 1

                          ;hdata_names = new((/dimsizes(hdataT)/),string,1e+20)

  ;do i=0,dimsizes(hdataT)-1,1
  ;modname = getSubString(hdataT(i),12,30)
  ;print(modname)
  ;hdata_names(i) = modname
  ;end do
  ;print(hdata_names)


;=========^^^^^^^%%%%%%%%%%%%%%%%%%%%%%^^^^&&&&&&&**********==========
;
;======================== read-in Pr Data  ==================================================================================

diri = "/home/yuzee/nclfolder/DATA/cmip6/projection/pr/"
hdata = new((/dimsizes(hdataT)/),string,1e+20)

  do q=0,dimsizes(hdataT)-1,1
  prname = getSubString(hdataT(q),0,2)+"pr_Amon_"+getSubString(hdataT(q),12,-1)
  print(prname)
  hdata(q) = prname
  end do
  print(hdata)

;===================-----------=====================-----------------------=====================

rgDATA = new((/dimsizes(hdata)/),float,1e+20)  ;array to hold the rc values
 rgvalsi = new((/dimsizes(hdata)/),float, 1e+20)
 siglev = new((/dimsizes(hdata)/),float, 1e+20)
 siglevi = new((/dimsizes(hdata)/),float, 1e+20)
 rgyave  = new((/dimsizes(hdata)/),float, 1e+20)
 rgxave  = new((/dimsizes(hdata)/),float, 1e+20)
 rgnptx  = new((/dimsizes(hdata)/),float, 1e+20)
 rgsde   = new((/dimsizes(hdata)/),float, 1e+20)
 rgtstat = new((/dimsizes(hdata)/),float, 1e+20)
 rgexvar = new((/dimsizes(hdata)/), float, 1e+20)
 rgcorr  = new((/dimsizes(hdata)/), float, 1e+20)
 rstatp  = new((/dimsizes(hdata)/), float, 1e+20)


varT = "tos"
var = "pr"

if (RUNSCRIPT)
print("=================================================")
print("================= Start Loop =======================")

do nn=0,dimsizes(hdataT)-1,1         ;loop over list of models
print("=================================================")
print(nn)
print("=================================================")
title  = str_upper(varT)+": "+hdata_names(nn)
print(title)

;==============================================================
; Open the SST file and read
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
  HADI = lonFlip(HADI)
;==============================================================
;==============================================================
HADIClm      = clmMonTLL(HADI)
printVarSummary(HADIClm)                   ; (12,nlat,nlon)
HADI         = calcMonAnomTLL(HADI, HADIClm)    ; replace with anonamlies
HADI@long_name = "ANOMALIES: "+HADI@long_name
;==============================================================
;==============================================================
;==============================================================
hadi = month_to_season(HADI,season)
hadi = dtrend_msg_n(hadi&time,hadi,True,False,0)
printMinMax(hadi,True)
printVarSummary(hadi)
;==============================================================
saodi =  wgt_areaave_Wrap(hadi(time|:, {lon|-20:10}, {lat|-15:0}),1.0, 1.0, 0) -\
       	wgt_areaave_Wrap(hadi(time|:,{lon|-40:-10}, {lat|-40:-25}),1.0, 1.0, 0)
;printVarSummary(saodi)

saodi_std2 = stddev(saodi)
 saodi_std = saodi/stddev(saodi)
printVarSummary(saodi_std2)

saodi_std!0 = "time"
saodi_std&time = hadi&time
printVarSummary(saodi_std)
;============================================================
delete(HADIClm)
delete(HADI)
delete(hadi)




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
;printVarSummary(GPCCClm)                   ; (12,nlat,nlon)
GPCC         = calcMonAnomTLL(GPCC, GPCCClm)    ; replace with anonamlies
GPCC@long_name = "ANOMALIES: "+GPCC@long_name
;==============================================================
gpcc = month_to_season(GPCC,season)
;printMinMax(gpcc,True)
gpcc = dtrend_msg_n(gpcc&time,gpcc,True,False,0)
printVarSummary(gpcc)
printMinMax(gpcc,True)
;==============================================================
;==============================================================
delete(GPCC)
delete(GPCCClm)

;==============================================================
pri =  wgt_areaave_Wrap(gpcc(time|:, {lon|lonL:lonR}, {lat|latS:latN}),1.0, 1.0, 0)

pri_stdev = stddev(pri)
pri_std  = pri/stddev(pri)

;printVarSummary(pri)
pri!0 = "time"
pri&time = gpcc&time
printVarSummary(pri)

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
  printVarSummary(rc)
  ;>>>>>>>>>>>>>>>>>>>>>>>>>>  calculating the significance level
  df   = rc@nptxy-2

  prob = (1 - betainc(df/(df+rc@tval^2), df/2.0, 0.5) )
  alpha = betainc(df/(df+rc@tval^2), df/2.0, 0.5)

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;-----------<<<<<<<<<<<<< setting up values for regression line
  nx           = dimsizes(pri)
  pltarry      = new ( (/2,nx/), typeof(pri))
  pltarry(0,:) = pri                              ; use markers
  pltarry(1,:) = rc*saodi_std + rc@yintercept      ; [y=bx+a] y-values as predicted by reg-line
  pri_pred     = rc*saodi_std + rc@yintercept
  av_pri_pred  = avg(pri_pred)

  SST  = sum((pri - rc@yave)^2)
  SSR  = sum((pri_pred - av_pri_pred)^2)

  r_squared  = 1.0 - (SSR/SST)

;<<<<<<<<<<<---------------------------------------------------------
;------------------------------------------------------------------------------
;----------------- calculate the Pearson correlation
  r = escorc_n(saodi_std, pri_std, 0, 0)

  ;==-----An alternative for testing significance is:

      t    = r*sqrt((df)/(1-r^2))
      p    = student_t(t, df)
      psig = 0.05                       ; test significance level
      nil = 0.



  rgDATA(nn) =  rc
  rgvalsi(nn) = rc@yintercept   ;intercept (a)
  siglev(nn)  = prob            ;significance level 1
  siglevi(nn) = alpha           ;significance level 2
  rgyave(nn)  = pri_stdev       ;stdev for precip timeseries
  rgxave(nn)  = saodi_std2      ;stdev for saodi timeseries
  rgnptx(nn)  = nil        ;number of points used
  rgsde(nn)   = rc@rstd         ;standard error of regression coefficient
  rgtstat(nn) = rc@tval         ;t-statistic(assuming null hypothesis)
  rgexvar(nn) = r_squared       ;explained variance
  rgcorr(nn)  = r               ;the correlation value
  rstatp(nn)  = p               ;significance value of correlation per model
;========================
printVarSummary(rgDATA)


;===========================================================
;  user specified for plots
;===============================================================

txtName = season+"proj_regression_"+hdata_names(nn)

  pltType = "eps"       ; send graphics to PNG file
  pltDir  = "/home/yuzee/nclfolder/RESULTS/07manuscript/regline_jpegs/"               ; dir to which plots are sent

 pltName = txtName+"_"+region(cb)+"_"+yrStrt+"-"+yrLast


;************************************************
; create plot: use overlay approach
;************************************************
    wks  = gsn_open_wks(pltType, pltDir+pltName)                         ; send graphics to PNG file
     res                     = True                   ; plot mods desired
   res@xyMarkLineModes     = (/"Markers","Lines"/)  ; choose which have markers
   res@xyMarkers           = 16                     ; choose type of marker
   res@xyMarkerColor       = "red"                  ; Marker color
   res@xyMarkerSizeF       = 0.005                  ; Marker size (default 0.01)
   res@xyDashPatterns      = 1                      ; solid line
   res@xyLineThicknesses   = (/1,2/)                ; set second line to 2
   res@tmYLFormat          = "f"                    ; not necessary but nicer labels

   res@tiMainString        = "Reg_proj_"+season+"_"+hdata_names(nn)+"_"+region(cb)\
   +"_b = "+rc           ; title
   res@tiYAxisOn           = True
   res@tiYAxisPosition     = "Center"
   res@tiYAxisString       = "Precip Anomaly (mm/month)"

   res@tiXAxisOn           = True
   res@tiXAxisPosition     = "Center"
   res@tiXAxisString       = "SAOD index(normalised)"
   res@tiXAxisFontHeightF  = 0.015
   res@tiMainFontHeightF   = 0.017
;--------------------------------------------------------------------------------

      plot = gsn_csm_xy (wks,saodi_std,pltarry,res)                         ; create plot




end do                                  ;end loop over models
 delete(nn)

;copy_VarCoords(gpcc(0:dimsizes(hdata_names)-1,:,:),rgDATA)
rgDATA!0 = "model"
printVarSummary(rgDATA)

print("=============== End of Loop =============================")

end if

;===============================================================
;===============================================================
;***********************************************
;---Save to a netcdf file, in the current directory
;***********************************************
      diro = "/home/yuzee/nclfolder/RESULTS/07manuscript/"
      filo = "iregression_proj_mod_"+region(cb)+"_"+season+"_"+yrStrt+"_"+yrLast+".nc"


  if (WRITE_RESULTS)
      ptho = diro+filo
      system("/bin/rm -f "+ptho)
      ncdf = addfile(ptho,"c")

      fAtt = True
      fAtt@title         = "Regression of Pr Index on SAOD index from Models"
      fAtt@source_name   = "CMIP6_projection_ssp585_runs"
      fAtt@source_URL    = "https://esgf-node.llnl.gov/projects/cmip6/"
      fAtt@source        = "Accessed from Levante Supercomputer, Hamburg, Germany"
      fAtt@Conventions   = "None"
      fAtt@creation_date = systemfunc("date")
      fileattdef(ncdf,fAtt)            ; copy file attributes

;     filedimdef(ncdf,"time",-1,True) ; make time an UNLIMITED dimension
      ncdf->rgDATA       = rgDATA
      ncdf->rgiDATA      = rgvalsi
      ncdf->prob         = siglev
      ncdf->alpha        = siglevi
      ncdf->stdpri       = rgyave
      ncdf->stdsaodi     = rgxave
      ncdf->nptx         = rgnptx
      ncdf->sde          = rgsde
      ncdf->tval         = rgtstat
      ncdf->exvar        = rgexvar
      ncdf->corr         = rgcorr
      ncdf->pvalcorr     = rstatp

;      print("-----------------DONE----------------------")

   end if
;***********************************************

;===============================================================
; wallClockElapseTime(wcStrt, "Processing and Graphics", 0)
;==================================================================================
;==================================================================================
;==================================================================================
;==================================================================================

;----extract values from NC file generated above and write to csv ----

  textf = addfile(diro+filo, "r")

  arry1 = textf ->rgDATA(:)
  arry2 = textf ->rgiDATA(:)
  arry3 = textf ->prob(:)
  arry4 = textf ->alpha(:)
  arry5 = textf ->stdpri(:)
  arry6 = textf ->stdsaodi(:)
  arry7 = textf ->nptx(:)
  arry8 = textf ->sde(:)
  arry9 = textf ->tval(:)
  arry10 = textf ->exvar(:)
  arry11 = textf ->corr(:)
  arry12 = textf ->pvalcorr(:)

;  print(arry)
  print(hdata_names)
  printVarSummary(hdata_names)

;------write to table --------------

 fileName = "iArry_proj_reg_"+region(cb)+"_"+season+".csv"
 wad       = diro+fileName

 col1 = "Model_name"
 col2 = "b_proj"
 col3 = "a-intercept"
 col4 = "prob"
 col5 = "alpha"
 col6 = "pri_std_proj"
 col7 = "saodi_std_proj"
 col8 = "stdev_mmproj"
 col9 = "std_error_proj"
 col10 = "t_proj"
 col11 = "r_squared_proj"
 col12 = "r_proj"
 col13 = "p_proj"
 header = [/col1, col2, col3, col4, col5, col6, col7, col8, col9, col10, col11, col12, col13/]
 formatt = "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s, %s, %s"

 write_table(wad, "w", header, formatt)  ;create header


 vec1 = ndtooned(arry1)
 vec2 = ndtooned(arry2)
 vec3 = ndtooned(arry3)
 vec4 = ndtooned(arry4)
 vec5 = ndtooned(arry5)
 vec6 = ndtooned(arry6)
 vec7 = ndtooned(arry7)
 vec8 = ndtooned(arry8)
 vec9 = ndtooned(arry9)
 vec10 = ndtooned(arry10)
 vec11 = ndtooned(arry11)
 vec12 = ndtooned(arry12)


 print(vec6)
 alist = [/hdata_names,vec1, vec2, vec3, vec4, vec5, vec6, vec7, vec8, vec9, vec10, vec11, vec12/]
 format = "%s,%g,%g,%g,%g,%g,%g,%g,%g,%g, %g, %g, %g"


 write_table(wad, "a", alist, format)  ;"a"ppend values to table





 end do                                   ;end loop over regions






;  test = addfile(diro+filo, "r")
;  testtt = test ->rgDATA(:)
;  print(testtt)
