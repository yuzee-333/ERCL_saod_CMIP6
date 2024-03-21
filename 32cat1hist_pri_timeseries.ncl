load "names_cat1hist.ncl"        ;load in file containing model names

begin
;
wcStrt     = systemfunc("date")		;To check the time taken for the code
;======================================


  nrun  = 5             ; length of running average
  season = (/"JJA"/)
region = (/"Northern_Amazon", "Central_Africa", "Guinea_Coast", "SE_Brazil"/)
do cb=0,dimsizes(region)-1,1


  yrStrt= 1950
  yrLast= 2014

  clStrt= 1950          ; climatology start
  clLast= 2014          ;             last

  txtName = "Cat1_pri_tms_"+region(cb)+"_"
  pltType = "png"       ; send graphics to eps file
  pltDir  = "/home/yuzee/nclfolder/RESULTS/05correlation_regional/"        ; dir to which plots are sent
  pltName = txtName
  pltName = txtName+"_"+yrStrt+"-"+yrLast
  pltTitle= txtName+": "+yrStrt+"-"+yrLast+"("+season+")"
  ensemble = "CMIP6_historical"

  RUN            = True   ;bottleneck to turn loop on/off
  PLOT_TM        = False
  WRITE_RESULTS  = True

  day_factor = 86400.			; # seconds in in a day
;
;==============================================================================================================================
diri = "/home/yuzee/nclfolder/DATA/cmip6/historical/pr/"

if (region(cb).eq."Northern_Amazon") then
  hdataT = N_A                                                          ;called from file loaded in line 1
  latS =  -5.
  latN =   7.
  lonL = -70.
  lonR = -50.
 else if (region(cb).eq."Central_Africa") then
  hdataT = C_A
  latS =  -5.
  latN =   5.
  lonL =  10.
  lonR =  16.
 else if (region(cb).eq."Guinea_Coast") then
  hdataT = G_C
  latS =   5.
  latN =  13.
  lonL = -10.
  lonR =  10.
 else
  hdataT = S_B
  latS = -27.
  latN = -12.
  lonL = -56.
  lonR = -40.

  end if
  end if

end if

hdata = new((/dimsizes(hdataT)/),string,1e+20)

  do q=0,dimsizes(hdataT)-1,1
  prname = getSubString(hdataT(q),0,2)+"pr_Amon_"+getSubString(hdataT(q),12,-1)
  ;print(prname)
  hdata(q) = prname
  end do

printVarSummary(hdata)
print(hdata)


hdata_names = new((/dimsizes(hdata)/),string,1e+20)

 do i=0,dimsizes(hdata)-1,1
 modname = getSubString(hdata(i),12,30)
 ;print(modname)
 hdata_names(i) = modname
 end do
 print(hdata_names)

rDATA = new((/dimsizes(hdata),65/),float,1e+20)                ;array to hold the data
printVarSummary(rDATA)
rSTD  = new((/dimsizes(hdata),1/), float, 1e+20)

var = "pr"

if (RUN)

do nn=0,dimsizes(hdata)-1,1
print("=================================================")
print(nn)
print("=================================================")
title  = str_upper(var)+": "+hdata_names(nn)
print(title)

;==============================================================
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
;printVarSummary(gpcc)
;printMinMax(gpcc,True)
gpcc = dtrend_msg_n(gpcc&time,gpcc,True,False,0)
;printMinMax(gpcc,True)
;==============================================================
;==============================================================
delete(GPCC)
delete(GPCCClm)
;
;

;==============================================================
pri =  wgt_areaave_Wrap(gpcc(time|:, {lon|lonL:lonR}, {lat|latS:latN}),1.0, 1.0, 0)    ;

pri_stdev = stddev(pri)
pri = pri/stddev(pri)

printVarSummary(pri)
pri!0 = "time"
pri&time = gpcc&time
printVarSummary(pri_stdev)
;============================================================

;============================================================
;============================================================

;==============================================================
rDATA(nn,:) =  pri
rSTD(nn,:)  = pri_stdev
;========================
printMinMax(rDATA,True)
;
end do
delete(nn)
;
copy_VarCoords(gpcc(0:dimsizes(hdata_names)-1,:,:),rDATA)
rDATA!0 = "model"
printVarSummary(rDATA)
printMinMax(rDATA, True)



;***********************************************
;---Save to a netcdf file, in the current directory
;***********************************************

  if (WRITE_RESULTS)
      diro = "/home/yuzee/nclfolder/RESULTS/results_for_doc/"
      filo = "Cat1_pri_timeseries_"+region(cb)+"_"+yrStrt+"_"+yrLast+".nc"
      ptho = diro+filo
      system("/bin/rm -f "+ptho)
      ncdf = addfile(ptho,"c")

      fAtt = True
      fAtt@title         = "Precip timeseries for CMIP6 Model ensemble"
      fAtt@source_name   = "CMIP6 historical runs"
      fAtt@source_URL    = "https://esgf-node.llnl.gov/projects/cmip6/"
      fAtt@source        = "Accessed from Levante Supercomputer, Hamburg, Germany"
      fAtt@Conventions   = "None"
      fAtt@creation_date = systemfunc("date")
      fileattdef(ncdf,fAtt)            ; copy file attributes

;     filedimdef(ncdf,"time",-1,True) ; make time an UNLIMITED dimension
      ncdf->rDATA = rDATA
      ncdf->stdev = rSTD
  end if


;================  P L O T nc file generated  ============================
;======== Read in nc file containing Saodi timeseries ====================


  ff      = addfile (ptho, "r")

  slp    = ff->stdev(:,:)
  printVarSummary(slp)

  pri_avg_std = dim_avg_n_Wrap(slp,(0))
  pri_istd    = ndtooned(slp)


  print(pri_avg_std)


  csvname = pltDir+"Cat1_Pri_stdev_"+region(cb)+".csv"
  col1 = "regions"
  col2 = "hist_pristdev"
  col3 = "hist_avg_pristdev"

  header = [/col1, col2, col3/]
  formatt = "%s,%s,%s"

  write_table(csvname, "w", header, formatt)

  csvlist = [/region(cb), pri_istd, pri_avg_std/]
  format = "%s,%g,%g"

  write_table(csvname, "a", csvlist, format)


;===============================================================================
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if (PLOT_TM)

; ==============================================================
   printVarSummary(slp)

;yyyymm = cd_calendar(slp&time, -1)
;============================================================
; PLOTS
;============================================================
  yrfrac = yyyymm_to_yyyyfrac(yyyymm, 0.0)
  neof = dimsizes(hdata)

  wks = gsn_open_wks(pltType, pltDir+pltName)         ; send graphics to PNG/eps/jpg file
  plot = new(neof,graphic)                ; create graphic array
                                          ; only needed if paneling
; EOF patterns


  res                       = True
  res@gsnDraw               = False
  res@gsnFrame              = False
  res@vpHeightF             = 0.4            ; change aspect ratio of plot
  res@vpWidthF              = 0.8
  res@vpXF                  = 0.1            ; start plot at x ndc coord
  res@gsnYRefLine           = 0.0            ; create a reference line
  res@gsnAboveYRefLineColor = "red"              ; above ref line fill red
  res@gsnBelowYRefLineColor = "blue"             ; below ref line fill blue

  res@trYMinF               = -3.0           ; min value on y-axis
  res@trYMaxF               =  3.0           ; max value on y-axis

  resP                      = True
  resP@gsnMaximize          = True
  resP@gsnPanelMainString   = pltTitle
  resP@gsnPaperOrientation  = "portrait"
  resP@gsnPanelMainString  = "Normalized SAODI timeseries for "+ensemble+" Models: "+season+": "+yrStrt+"-"+yrLast

;*******************************************
; first plot
;*******************************************
  do n=0,neof-1
     res@gsnLeftString  = hdata_names(n)
     plot(n)= gsn_csm_xy (wks,yrfrac,slp(n,:),res)
  end do

  gsn_panel(wks,plot,(/5,5/),resP)     ; now draw as one plot

end if                                 ;end PLOT_TM


               ;these variables are deleted because they will be reused in another iteration of the region loop
delete(rDATA)
delete(rSTD)
delete(hdata)
delete(hdata_names)
delete(slp)
delete(pri_istd)
delete(pri_avg_std)
delete(hdataT)

end if                                 ;end RUN

end do                                 ;end region loop

;printVarSummary(hdata)
end
