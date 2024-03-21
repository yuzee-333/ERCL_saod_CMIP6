; FOR MANUSCRIPT
; To average the Regression coefficient values...MMM
;----extract values from NC file generated above and write to csv ----

; " This script will generate nc files holding the mean rainfall and mean sst of \
;each model in category 1 per region. I will also plot the multi-model mean map for each \
;region"

scenario = (/"Hist", "Proj"/)
do sce=0, dimsizes(scenario)-1,1


models = (/"Cat1", "Cat2"/)
do cat=0, dimsizes(models)-1,1
;do cat=0,0,1

                    ;load in file containing model list in each region are arranged according to category
if (scenario(sce).eq."Hist") then
 load "names_cat1hist.ncl"
 diriT  = "/home/yuzee/nclfolder/DATA/cmip6/historical/tos/"    ;for sst
 diri   = "/home/yuzee/nclfolder/DATA/cmip6/historical/pr/"     ; for pr
 yrStrt = 1950
 yrLast = 2014
else
 load "names_cat1proj.ncl"
 diriT  = "/home/yuzee/nclfolder/DATA/cmip6/projection/tos/"    ;for sst
 diri   = "/home/yuzee/nclfolder/DATA/cmip6/projection/pr/"     ; for pr
 yrStrt = 2015
 yrLast = 2079
end if



TEST_OVER = True
WRITE_RESULTS = True
season  = "JJA"
varT    = "tos"
var     = "pr"

region = (/"Northern_Amazon","Guinea_Coast","Central_Africa","SE_Brazil"/)
do cb=0,dimsizes(region)-1,1
;do cb=0,0,1                                  ;test running for just 1 region

;if (region(cb).eq."Northern_Amazon") then                    ;run script for just 1 region

diro   = "/home/yuzee/nclfolder/RESULTS/07manuscript/model_cat_ncfiles/"

if(models(cat).eq."Cat1") then
  filo   = scenario(sce)+"_Cat1"+var+"_mean_"+region(cb)+"_"+season+".nc"
  filos  = scenario(sce)+"_Cat1"+varT+"_mean_"+region(cb)+"_"+season+".nc"
else
  filo   = scenario(sce)+"_Cat2"+var+"_mean_"+region(cb)+"_"+season+".nc"
  filos  = scenario(sce)+"_Cat2"+varT+"_mean_"+region(cb)+"_"+season+".nc"
end if


; ===  FOR HISTORICAL CALCULATION =============================================

  day_factor = 86400.			; # seconds in in a day
;=====================================================================================================
 ;==========================read-in PR and SST datafiles===============================================================================

;=========setting up the lon and lat coordinates for each box per season =======

if (models(cat).eq."Cat1") then
  if (region(cb).eq."Northern_Amazon") then
    hdataT = N_A_Cat1
   else if (region(cb).eq."Central_Africa") then                            ;
    hdataT = C_A_Cat1
   else if (region(cb).eq."Guinea_Coast") then                             ;
    hdataT = G_C_Cat1
   else                                                                    ;
    hdataT = S_B_Cat1

    end if
    end if
  end if
else
  if (region(cb).eq."Northern_Amazon") then
    hdataT = N_A_Cat2
   else if (region(cb).eq."Central_Africa") then                            ;
    hdataT = C_A_Cat2
   else if (region(cb).eq."Guinea_Coast") then                             ;
    hdataT = G_C_Cat2
   else                                                                    ;
    hdataT = S_B_Cat2

   end if
   end if
  end if
end if                                                                  ;

;===============================================================================

printVarSummary(hdataT)                                                   ;

hdata_names = new((/dimsizes(hdataT)/),string,1e+20)                      ;
  do i=0,dimsizes(hdataT)-1,1
  modname = getSubString(hdataT(i),12,30)
  ;print(modname)
  hdata_names(i) = modname
  end do
  print(hdata_names)

;=========^^^^^^^%%%%%%%%%%%%%%%%%%%%%%^^^^&&&&&&&**********==========
;
;======================== read-in Pr Data  ==================================================================================


hdata = new((/dimsizes(hdataT)/),string,1e+20)

  do q=0,dimsizes(hdataT)-1,1
  prname = getSubString(hdataT(q),0,2)+"pr_Amon_"+getSubString(hdataT(q),12,-1)
  ;print(prname)
  hdata(q) = prname
  end do
  print(hdata)              ;generate Pr datafile names from hdataT

;===================-----------=====================-----------------------=====================

 prDATA  = new((/dimsizes(hdataT),72,144/),float,1e+20)    ;array to hold mean rainfall
 sstDATA = new((/dimsizes(hdataT),180,360/),float, 1e+20)   ;array to hold mean sst's
; siglev  = new((/dimsizes(hdataT)/),float, 1e+20)   ;extra


print("=================================================")
print("================= Start Pr Loop "+region(cb)+" =======================")

do nn=0,dimsizes(hdataT)-1,1
;do nn=0,1,1
print("=================================================")
;print(nn)
print("=================================================")
title  = str_upper(var)+": "+hdata_names(nn)
print(title)
delete(title)

; Read variable; compute monthly climatology; annual mean
;***************************************************************
;----------------RAINFALL -----------------------------------------------------
 f      = addfiles(diri+hdata,"r")
 TIME   = f[nn]->time
 YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
 iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
 PRC    = f[nn]->$var$(iYYYY,:,:)
 PRC    = PRC*day_factor
 ;printVarSummary(PRC)       ; variable overview
 ;printMinMax(PRC,True)

 delete(f)
 delete(TIME)
 delete(YYYY)
 delete(iYYYY)

 PRC = lonFlip(PRC)

 ;------------ RAINFALL annual mean ----------------------------------
 prc_clm = clmMonTLL(PRC)                         ; compute monthly climatology
 printVarSummary(prc_clm)                         ; (12,lat,lon)

 prc_clm  = where(prc_clm.lt.0.10, 0.0, prc_clm)  ; set small values to 0.0
 printMinMax(prc_clm,True)
 prc_ann2  = month_to_season(prc_clm,season)
 ;printVarSummary(prc_ann2)
 print("------------rainfall for "+hdata_names(nn)+" JJA season---------------")
 printMinMax(prc_ann2, True)
   ;  [[  prc_ann1  = prc_ann2/jja_day_factor  ; for Obs   ]]           ;

 prc_ann  = dim_avg_n_Wrap(prc_ann2, 0)            ; compute annual rainfall mean ;(arithmetic);
 printVarSummary(prc_ann)                          ; from monthly climatologies
 printMinMax(prc_ann, True)

; clat     = latRegWgt( prc_ann&lat, "float", 0)   ; lwt weights
; prcAvg   = wgt_areaave( prc_ann, clat, 1.0, 0)   ; areal average

 prDATA(nn,:,:)  =  prc_ann                            ;write to array
 prDATA!0  = "model"

 delete(PRC)
 delete(prc_clm)
 delete(prc_ann2)
 end do                                   ;end loop over models for pr values


 printVarSummary(prDATA)
 printMinMax(prDATA, True)


 ;***********************************************
;---Save to a netcdf file, in the current directory
;***********************************************

 if (WRITE_RESULTS)
     filoname = filo+"rainfall_models.nc"
     ptho = diro+filo
     system("/bin/rm -f "+ptho)
     ncdf = addfile(ptho,"c")

     fAtt = True
     fAtt@title         = "Mean rainfall from CMIP6 Models"
     fAtt@source_name   = "CMIP6 historical runs"

     fAtt@source_URL    = "https://esgf-node.llnl.gov/projects/cmip6/"
     fAtt@source        = "Accessed from Levante Supercomputer, Hamburg, Germany"
     fAtt@Conventions   = "None"
     fAtt@creation_date = systemfunc("date")
     fileattdef(ncdf,fAtt)            ; copy file attributes

;    filedimdef(ncdf,"time",-1,True) ; make time an UNLIMITED dimension

     if (models(cat).eq."Cat1") then
      ncdf->mean_rain1    = prDATA
     else
      ncdf->mean_rain2    = prDATA
     end if

     print("---------------pr nc file for "+models(cat)+"_"+region(cb)+" DONE----------------------")
end if




 ;******************************-----------------*******************************
 ;==============================================================================
 ;==============================================================================
 ;=========================SST MEAN CALC =======================================

 ;==============================================================================


do nn=0,dimsizes(hdataT)-1,1
 ;do nn=0,1,1

 f     = addfiles(diriT+hdataT,"r")
 TIME   = f[nn]->time
 YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
 iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
 GSST   = f[nn]->$varT$(iYYYY,:,:)
 ;printVarSummary(GSST)       ; variable overview
 ;printMinMax(GSST,True)

 delete(f)
 delete(TIME)
 delete(YYYY)
 delete(iYYYY)

 GSST = lonFlip(GSST)


 ;------------ SST annual mean ----------------------------------

 sst_clm = clmMonTLL(GSST)                            ; compute monthly climatology
 printVarSummary(sst_clm)                             ; (12,lat,lon)
 printMinMax(sst_clm, True)
 sst_clm  = where(sst_clm.lt.0.10, 0.0, sst_clm)      ; set small values to 0.0

 sst_ann2  = month_to_season(sst_clm,season)
 sst_cord  = sst_ann2
print("------------SST "+hdata_names(nn)+" for JJA season---------------------")
 ;printVarSummary(sst_ann2)                             ; (12,lat,lon)
 printMinMax(sst_ann2, True)

 sst_ann  = dim_avg_n_Wrap(sst_ann2, 0)               ; compute annual mean ;(arithmetic);
 ;printVarSummary(sst_ann)                             ; from monthly climatologies


 ;clat1     = latRegWgt( sst_ann&lat, "float", 0)      ; lwt weights
 ;prcAvg1   = wgt_areaave( sst_ann, clat1, 1.0, 0)     ; areal average

 sstDATA(nn,:,:) =  sst_ann                                ;write to array
 sstDATA!0 = "model"

 delete(GSST)
 delete(sst_clm)
 delete(sst_ann2)
;==========================================================================
end do                                                 ;end 'nn' loop over model list
delete(nn)

printVarSummary(sstDATA)
printMinMax(sstDATA, True)

;***********************************************
;---Save to a netcdf file, in the current directory
;***********************************************

 if (WRITE_RESULTS)
     filoname = filo+"rainfall_models.nc"
     pthos = diro+filos
     system("/bin/rm -f "+pthos)
     ncdf = addfile(pthos,"c")

     fAtt = True
     fAtt@title         = "Mean rainfall from CMIP6 Models"
     fAtt@source_name   = "CMIP6 historical runs"

     fAtt@source_URL    = "https://esgf-node.llnl.gov/projects/cmip6/"
     fAtt@source        = "Accessed from Levante Supercomputer, Hamburg, Germany"
     fAtt@Conventions   = "None"
     fAtt@creation_date = systemfunc("date")
     fileattdef(ncdf,fAtt)            ; copy file attributes

;    filedimdef(ncdf,"time",-1,True) ; make time an UNLIMITED dimension

     if (models(cat).eq."Cat1") then
      ncdf->mean_sst1    = sstDATA
     else
      ncdf->mean_sst2    = sstDATA
     end if

print("---------------sst nc file for "+models(cat)+"_"+region(cb)+" DONE------------")
end if

     delete(hdataT)
     delete(hdata)
     delete(hdata_names)
     delete(prDATA)
     delete(sstDATA)
     end do                                                      ;region loop

  end do                                                         ; models (Cat)

delete(modelNames)
delete(N_A_Cat1)
delete(N_A_Cat2)
delete(C_A_Cat1)
delete(C_A_Cat2)
delete(G_C_Cat1)
delete(G_C_Cat2)
delete(S_B_Cat1)
delete(S_B_Cat2)

print("=================="+scenario(sce)+" DONE=========================================")
end do                                                        ;end scenario loop
