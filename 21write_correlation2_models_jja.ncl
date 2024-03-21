load "hist_modelnames.ncl"        ;load in file containing model names

;========== generate saodi index ===================

;======================================
;  latS  = -50
;  latN  =  5.0
;  lonL  = -60
;  lonR  =  20    ;(coordinates for the SAODI area)

  yrStrt= 1950
  yrLast= 2014

  clStrt= 1950          ; climatology start
  clLast= 2014          ;             last

  WRITE_RESULTS = True
  day_factor = 86400.			; # seconds in in a day

  season     = "JJA"
;=====================================================================================================
region = (/"Northern_Amazon","Guinea_Coast","Central_Africa","SE_Brazil"/)
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



;==============================================================================================================================
diriT = "/home/yuzee/nclfolder/DATA/cmip6/historical/tos/"

hdataT = modelNames         ;called from file loaded in line 1
;
;print(hdataT)
printVarSummary(hdataT)


hdata_names = new((/dimsizes(hdataT)/),string,1e+20)

  do i=0,dimsizes(hdataT)-1,1
  modname = getSubString(hdataT(i),12,30)
  ;print(modname)
  hdata_names(i) = modname
  end do
  print(hdata_names)


;=========^^^^^^^%%%%%%%%%%%%%%%%%%%%%%^^^^&&&&&&&**********==========
;
;======================== read-in Pr Data  ==================================================================================

 diri = "/home/yuzee/nclfolder/DATA/cmip6/historical/pr/"

 hdata = new((/dimsizes(hdataT)/),string,1e+20)

  do q=0,dimsizes(hdataT)-1,1
  prname = getSubString(hdataT(q),0,2)+"pr_Amon_"+getSubString(hdataT(q),12,-1)
  print(prname)
  hdata(q) = prname
  end do
  print(hdata)

;===================-----------=====================-----------------------=====================

rrDATA = new((/dimsizes(hdata)/),float,1e+20)      ;array to hold the corr values
rstatvar = new((/dimsizes(hdata)/),float,1e+20)    ;array to hold values of explained variance (here called evar)
rstatt = new((/dimsizes(hdata)/),float,1e+20)      ;array to hold values of t
rstatp = new((/dimsizes(hdata)/),float,1e+20)      ;array to hold values of p
rstatlo = new((/dimsizes(hdata)/),float,1e+20)     ;array to hold values of rlow
rstathi = new((/dimsizes(hdata)/),float,1e+20)     ;array to hold values of rhi
rgDATA = new((/dimsizes(hdata)/),float,1e+20)      ;array to hold the reg values



varT = "tos"
var = "pr"

print("=================================================")
print("================= Start Loop =======================")

do nn=0,dimsizes(hdataT)-1,1
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

; saodi_std = saodi
 saodi_std = saodi/stddev(saodi)
;printVarSummary(saodi_std)

saodi_std!0 = "time"
saodi_std&time = hadi&time
printVarSummary(saodi_std)
;============================================================
delete(HADIClm)
delete(HADI)
delete(hadi)




;===============================================================
; Open Pr file and read specified time period
;==============================================================

   f     = addfiles(diri+hdata,"r")
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
; printVarSummary(GPCCClm)                   ; (12,nlat,nlon)
  GPCC         = calcMonAnomTLL(GPCC, GPCCClm)    ; replace with anonamlies
  GPCC@long_name = "ANOMALIES: "+GPCC@long_name
;==============================================================
  gpcc = month_to_season(GPCC,season)
; printMinMax(gpcc,True)
  gpcc = dtrend_msg_n(gpcc&time,gpcc,True,False,0)
; printVarSummary(gpcc)
  printMinMax(gpcc,True)
;==============================================================
;==============================================================
delete(GPCC)
delete(GPCCClm)

;==============================================================
pri =  wgt_areaave_Wrap(gpcc(time|:, {lon|lonL:lonR}, {lat|latS:latN}),1.0, 1.0, 0)


pri_std = pri/stddev(pri)
printMinMax(pri,True)

pri_std!0 = "time"
pri_std&time = gpcc&time
printVarSummary(pri_std)


;========================================================================================
;========================================================================================
;========================================================================================
;************************************************
; Perform statistical operations
;************************************************
;----------------
  r = escorc_n(saodi_std, pri_std, 0, 0)              ; degC/year
  evar = r^2*100                                      ;the explained variance

;-----------------do regression -----------------------------------
  rc = regline(saodi_std, pri)                        ; degC/year
  rc@long_name = "trend"
  rc@units     = "mm/day"

  print(r)
  printVarSummary(r)
  print(evar)

;----========= compute correlation confidence interval ---------------
        nr    = dimsizes(saodi_std)
        df   = nr-2
;------ Fischer z-transformation --------------
        z    = 0.5*log((1+r)/(1-r))                 ; z-statistic
        se   = 1.0/sqrt(nr-3)                        ; standard error of z-statistic

;------low  and hi z values
        zlow = z - 1.96*se                ; 95%  (2.58 for 99%)
        zhi  = z + 1.96*se

;--------inverse z-transform; return to r space (-1 to +1)
        rlow = (exp(2*zlow)-1)/(exp(2*zlow)+1)
        rhi  = (exp(2*zhi )-1)/(exp(2*zhi )+1)

        print("r="+r)
        print("z= "+z+"  se= "+se)
        print("zlow="+zlow+"  zhi="+zhi)
        print("rlow="+rlow+"  rhi="+rhi)

;"====---If the r confidence interval includes 0.0, the calculated r is not significant.
;==-----An alternative for testing significance is:

        t    = r*sqrt((nr-2)/(1-r^2))
        p    = student_t(t, df)
        psig = 0.05                       ; test significance level
        print("t="+t+"  p="+p)            ;
        if (p.le.psig) then
            print("r= "+r+" is significant at the 95% level")
        else
            print("r="+r+" is NOT significant at the 95% level")
        end if


  rrDATA(nn) =  r               ;for correlation (r) values
  rgDATA(nn) = rc               ;for regression values
  rstatvar(nn) = evar           ;for explained variance
  rstatt(nn) = t                ;for t-statistic
  rstatp(nn) = p                ;for p-statistic
  rstatlo(nn) = rlow            ;for r confidence interval L
  rstathi(nn) = rhi             ;for r confidence interval R
;========================
printVarSummary(rrDATA)


end do
 delete(nn)

; copy_VarCoords(gpcc(0:dimsizes(hdata_names)-1,:,:),rrDATA)
rrDATA!0 = "model"
printVarSummary(rrDATA)



print("=============== End of Loop =============================")



;===============================================================
;===============================================================
;***********************************************
;---Save to a netcdf file, in the current directory
;***********************************************

  if (WRITE_RESULTS)
      diro = "/home/yuzee/nclfolder/RESULTS/05correlation_regional/"
      filo = "correlation_models_"+season+"_"+region(cb)+"_"+yrStrt+"_"+yrLast+".nc"
      ptho = diro+filo
      system("/bin/rm -f "+ptho)
      ncdf = addfile(ptho,"c")

      fAtt = True
      fAtt@title         = "Correlation of Pr Index on SAOD index from Models"
      fAtt@source_name   = "CMIP6 historical runs"
      fAtt@source_URL    = "https://esgf-node.llnl.gov/projects/cmip6/"
      fAtt@source        = "Accessed from Levante Supercomputer, Hamburg, Germany"
      fAtt@Conventions   = "None"
      fAtt@creation_date = systemfunc("date")
      fileattdef(ncdf,fAtt)            ; copy file attributes

;     filedimdef(ncdf,"time",-1,True) ; make time an UNLIMITED dimension
      ncdf->rrDATA = rrDATA
      ncdf->exvar = rstatvar
      ncdf->tstat = rstatt
      ncdf->pval  = rstatp
      ncdf->rlow   = rstatlo
      ncdf->rhi    = rstathi
      ncdf->reg   = rgDATA
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
;"----------->>>>>>>>>>>>>>>>>>>>>>" ;extracting the values from the nc file created above

  arry1 = textf ->rrDATA(:)
  arry2 = textf ->exvar(:)
  arry3 = textf ->reg(:)
  arry4 = textf ->tstat(:)
  arry5 = textf ->pval(:)
  arry6 = textf ->rlow(:)
  arry7 = textf ->rhi(:)



;  print(arry)
  print(hdata_names)
  printVarSummary(hdata_names)

;------write to table --------------

 fileName = "Arry_corr_"+season+"_"+region(cb)+".csv"
 wad       = diro+fileName
           ;creating header names
 col1 = "Model_name"
 col2 = "r"
 col3 = "ex_var"
 col4 = "b"
 col5 = "t"
 col6 = "p"
 col7 = "rlow"
 col8 = "rhigh"

 header = [/col1, col2, col3, col4, col5, col6, col7, col8/]
 formatt = "%s,%s,%s,%s,%s,%s,%s,%s"

 write_table(wad, "w", header, formatt)  ;create table with header


 var1 = ndtooned(arry1)
 var2 = ndtooned(arry2)
 var3 = ndtooned(arry3)
 var4 = ndtooned(arry4)
 var5 = ndtooned(arry5)
 var6 = ndtooned(arry6)
 var7 = ndtooned(arry7)


; print(var1)
 alist = [/hdata_names,var1, var2, var3, var4, var5, var6,var7/]
 format = "%s,%g,%g,%g,%g,%g,%g,%g"


 write_table(wad, "a", alist, format)  ;"a"ppend values to table created in line 408



 end do
