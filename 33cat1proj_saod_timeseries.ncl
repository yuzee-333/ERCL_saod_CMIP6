load "names_cat1proj.ncl"        ;load in file containing model names

begin
;
wcStrt     = systemfunc("date")		;To check the time taken for the code
;======================================
  latS  = -50
  latN  =  5.0
  lonL  = -60
  lonR  =  20

  nrun  = 5             ; length of running average
  season = (/"JJA"/)
region = (/"Northern_Amazon", "Central_Africa", "Guinea_Coast", "SE_Brazil"/)
do cb=0,dimsizes(region)-1,1


  yrStrt= 2015
  yrLast= 2079

  clStrt= 2015          ; climatology start
  clLast= 2079         ;             last

  txtName = "Cat1proj_SAODI_tms_"+region(cb)+"_"
  pltType = "png"       ; send graphics to eps file
  pltDir  = "/home/yuzee/nclfolder/RESULTS/05correlation_regional/"   ; dir to which plots are sent
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
diriT = "/home/yuzee/nclfolder/DATA/cmip6/projection/tos/"

if (region(cb).eq."Northern_Amazon") then
  hdataT = N_A                                                          ;called from file loaded in line 1
 else if (region(cb).eq."Central_Africa") then
  hdataT = C_A
 else if (region(cb).eq."Guinea_Coast") then
  hdataT = G_C
 else
  hdataT = S_B

  end if
  end if

end if



;print(hdataT)
printVarSummary(hdataT)


hdata_names = new((/dimsizes(hdataT)/),string,1e+20)

 do i=0,dimsizes(hdataT)-1,1
 modname = getSubString(hdataT(i),12,30)
 ;print(modname)
 hdata_names(i) = modname
 end do
 print(hdata_names)

rDATA = new((/dimsizes(hdataT),65/),float,1e+20)                ;array to hold the data
printVarSummary(rDATA)
rSTD  = new((/dimsizes(hdataT),1/), float, 1e+20)

varT = "tos"

if (RUN)

do nn=0,dimsizes(hdataT)-1,1
print("=================================================")
print(nn)
print("=================================================")
title  = str_upper(varT)+": "+hdata_names(nn)
print(title)

;==============================================================
; Open the file: Read only the user specified period
;===============================================================
;title  = str_upper(varT)+": "+hdata_names(nn)
;print(title)

  f      = addfiles(diriT+hdataT,"r")
  TIME   = f[nn]->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  HADI   = f[nn]->$varT$(iYYYY,:,:)
  ;printVarSummary(HADI)       ; variable overview

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
;printVarSummary(HADIClm)                   ; (12,nlat,nlon)
HADI         = calcMonAnomTLL(HADI, HADIClm)    ; replace with anonamlies
HADI@long_name = "ANOMALIES: "+HADI@long_name
;==============================================================
;==============================================================
;==============================================================
hadi = month_to_season(HADI,season)
;printVarSummary(hadi)
;printMinMax(hadi,True)
hadi = dtrend_msg_n(hadi&time,hadi,True,False,0)
;printMinMax(hadi,True)
;==============================================================
saodi =  wgt_areaave_Wrap(hadi(time|:, {lon|-20:10}, {lat|-15:0}),1.0, 1.0, 0) -\
       	wgt_areaave_Wrap(hadi(time|:,{lon|-40:-10}, {lat|-40:-25}),1.0, 1.0, 0)
printVarSummary(saodi)

                ;saodi is normalised
 saodi_std = saodi/stddev(saodi)
;printVarSummary(saodi_std)
saodi_std2 = stddev(saodi)

saodi_std!0 = "time"
saodi_std&time = hadi&time
printVarSummary(saodi_std)

printVarSummary(saodi_std2)
printMinMax(saodi_std2, True)

;============================================================
delete(HADIClm)
delete(HADI)
delete(hadi)


rDATA(nn,:) =  saodi_std  ; will be used again
rSTD(nn,:)  = saodi_std2
rDATA!0 = "model"
rSTD!0  = "model"
;========================
printMinMax(rDATA,True)
;
end do



;***********************************************
;---Save to a netcdf file, in the current directory
;***********************************************

  if (WRITE_RESULTS)
      diro = "/home/yuzee/nclfolder/RESULTS/results_for_doc/"
      filo = "Cat1proj_saodi_timeseries_"+region(cb)+"_"+yrStrt+"_"+yrLast+".nc"
      ptho = diro+filo
      system("/bin/rm -f "+ptho)
      ncdf = addfile(ptho,"c")

      fAtt = True
      fAtt@title         = "SAODI timeseries for CMIP6 Model ensemble"
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

saodi_avg_std = dim_avg_n_Wrap(slp,(0))
saodi_istd    = ndtooned(slp)

;saodi_avg_std = stddev(saodi_avg)
print(saodi_avg_std)


csvname = pltDir+"Cat1proj_SAODI_stdev_"+region(cb)+".csv"
col1 = "regions"
col2 = "proj_stdev"
col3 = "proj_avg_stdev"

header = [/col1, col2, col3/]
formatt = "%s,%s,%s"

write_table(csvname, "w", header, formatt)

csvlist = [/region(cb), saodi_istd, saodi_avg_std/]
format = "%s,%g,%g"

write_table(csvname, "a", csvlist, format)






;===============================================================================
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if (PLOT_TM)

;yyyymm = cd_calendar(slp&time, -1)
; ==============================================================
   printVarSummary(slp)

;============================================================
; PLOTS
;============================================================
  yrfrac = yyyymm_to_yyyyfrac(yyyymm, 0.0)
  neof = dimsizes(hdataT)

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
 delete(hdataT)
 delete(hdata_names)
 delete(slp)
 delete(saodi_istd)
 delete(saodi_avg_std)

end if                                 ;end RUN

end do                                 ;end region loop

;printVarSummary(hdataT)
end
