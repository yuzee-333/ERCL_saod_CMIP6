begin

diriT  = "/home/yuzee/nclfolder/DATA/cmip6/historical/tos/"    ;for sst
diri   = "/home/yuzee/nclfolder/DATA/cmip6/historical/pr/"     ; for pr
yrStrt = 1950
yrLast = 2014
season = "JJA"
day_factor = 86400

varT    = "tos"
var     = "pr"

 ;"RE_tos_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc"
;----------------Access Pr ---------------------------------------------------------
;----------------RAINFALL -----------------------------------------------------
 Ac     = addfile(diri+"RE_pr_Amon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc", "r")
 TIME   = Ac->time
 YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
 iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
 PRAc   = Ac->$var$(iYYYY,:,:)
 PRAc   = PRAc*day_factor
 ;printVarSummary(PRAc)       ; variable overview
 ;printMinMax(PRAc,True)

 delete(TIME)
 delete(YYYY)
 delete(iYYYY)
 delete(Ac)

 PRAc = lonFlip(PRAc)

 ;------------ RAINFALL annual mean ----------------------------------
 prc_clmm = clmMonTLL(PRAc)                         ; compute monthly climatology
 ;printVarSummary(prc_clmm)                         ; (12,lat,lon)

 prc_clmm  = where(prc_clmm.lt.0.10, 0.0, prc_clmm)  ; set small values to 0.0
 ;printMinMax(prc_clmm,True)
 prAc_ann  = month_to_season(prc_clmm,season)
                            ;prc_ann2 = prc_ann2/jja_day_factor
 ;printVarSummary(prAc_ann)
 print("------------rainfall for Access JJA season---------------")
 ;printMinMax(prAc_ann, True)

 prAc_avg  = dim_avg_n_Wrap(prAc_ann, 0)            ; compute annual rainfall mean ;(arithmetic);
 printVarSummary(prAc_avg)                          ; from monthly climatologies
 printMinMax(prAc_avg, True)

 delete(PRAc)
 delete(prc_clmm)
 delete(prAc_ann)

 ;----------------Obs SST ------------------------------------------------------
 ;----------------Sea Surface Temperature --------------------------------------
 Ac       = addfile(diriT+"RE_tos_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc", "r")
 TIME     = Ac->time
 YYYY     = cd_calendar(TIME,-1)/100                 ; entire file
 iYYYY    = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
 ACC_SST  = Ac->$varT$(iYYYY,:,:)
 ;printVarSummary(ACC_SST)       ; variable overview
 ;printMinMax(ACC_SST,True)

 delete(TIME)
 delete(YYYY)
 delete(iYYYY)
 delete(Ac)

 ACC_SST = lonFlip(ACC_SST)

 sst_clmm = clmMonTLL(ACC_SST)                            ; compute monthly climatology
 ;printVarSummary(sst_clmm)                             ; (12,lat,lon)
 ;printMinMax(sst_clm, True)
 sst_clmm  = where(sst_clmm.lt.0.10, 0.0, sst_clmm)      ; set small values to 0.0
 sstAc_ann  = month_to_season(sst_clmm,season)
 ;sst_cord  = sstAc_ann
 print("------------obs SST for JJA season---------------------")
 ;printVarSummary(sstAc_ann)                             ; (12,lat,lon)
 ;printMinMax(sstAc_ann, True)

 sstAc_avg  = dim_avg_n_Wrap(sstAc_ann, 0)               ; compute annual mean ;(arithmetic);
 printVarSummary(sstAc_avg)                             ; from monthly climatologies
 printMinMax(sstAc_avg, True)

 delete(ACC_SST)
 delete(sst_clmm)
 delete(sstAc_ann)


 end
