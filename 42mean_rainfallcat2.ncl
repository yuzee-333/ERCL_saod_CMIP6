; FOR MANUSCRIPT
; To average the Regression coefficient values...MMM
;----extract values from NC file generated above and write to csv ----

; " This script will generate nc files holding the mean rainfall and mean sst of \
;each model in category 1 per region. I will also plot the multi-model mean map for each \
;region"


scenario = (/"Hist", "Proj"/)
do sce=0, dimsizes(scenario)-1,1
;do sce=0,0,1
if (scenario(sce).eq."Proj") then

                    ;load in file containing model list in each region are arranged according to category

if(scenario(sce).eq."Hist") then
load "names_cat1hist.ncl"
else
load "names_cat1proj.ncl"
end if

TEST_OVER = True
PLOT_RESULTS = True
season = "JJA"

nplots   = 2    ; number of plots
ZOOM    = (/0,1/)                          ;loop through zoom off '0' and on '1'

pltType = (/"eps", "png"/)

region = (/"Northern_Amazon","Guinea_Coast","Central_Africa","SE_Brazil"/)
do cb=0,dimsizes(region)-1,1
;do cb=0,0,1

if(scenario(sce).eq."Hist") then
    diriT  = "/home/yuzee/nclfolder/DATA/cmip6/historical/tos/"
    diri   = "/home/yuzee/nclfolder/DATA/cmip6/historical/pr/"
    yrStrt = 1950
    yrLast = 2014
    diro   = "/home/yuzee/nclfolder/RESULTS/07manuscript/mean_maps/"
    filo   = "Cat2"+scenario(sce)+"_mean_models_"+region(cb)+"_"+season        ;+"_"+yrStrt+"_"+yrLast+".nc"
    else
    diriT  = "/home/yuzee/nclfolder/DATA/cmip6/projection/tos/"
    diri   = "/home/yuzee/nclfolder/DATA/cmip6/projection/pr/"
    yrStrt = 2015
    yrLast = 2079
    diro   = "/home/yuzee/nclfolder/RESULTS/07manuscript/mean_maps/proj/"
    filo   = "Cat2"+scenario(sce)+"_mean_models_"+region(cb)+"_"+season        ;+"_"+yrStrt+"_"+yrLast  ;+".nc"
end if

latSp = -60
latNp =  32
lonLp = -80
lonRp =  40

; ===  FOR HISTORICAL CALCULATION =============================================
;========== generate saodi index ===================



  day_factor = 86400.			; # seconds in in a day
;=====================================================================================================
 ;==========================read-in SST datafiles===============================================================================



;=========setting up the lon and lat coordinates for each box per season =======

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
end if                                                                    ;


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

 varT    = "tos"
 var     = "pr"

print("=================================================")
print("================= Start Loop "+region(cb)+" =======================")

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
 f     = addfiles(diri+hdata,"r")
 TIME   = f[nn]->time
 YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
 iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
 PRC   = f[nn]->$var$(iYYYY,:,:)
 PRC = PRC*day_factor
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
 ;printVarSummary(prc_ann)                          ; from monthly climatologies

; clat     = latRegWgt( prc_ann&lat, "float", 0)   ; lwt weights
; prcAvg   = wgt_areaave( prc_ann, clat, 1.0, 0)   ; areal average

 prDATA(nn,:,:)  =  prc_ann                            ;write to array


 ;=========================SST MEAN CALC =======================================
 title1  = str_upper(varT)+": "+hdata_names(nn)
 print(title1)
 delete(title1)
 ;==============================================================================

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



;========================

sstDATA!0 = "model"
prDATA!0  = "model"

printVarSummary(prDATA)
printMinMax(prc_ann, True)
printVarSummary(sstDATA)
printMinMax(sst_ann, True)


delete(PRC)
delete(prc_clm)
delete(prc_ann2)
delete(GSST)
delete(sst_clm)
delete(sst_ann2)

end do                                                 ;end 'nn' loop over model list
delete(nn)
print("=============== End of models' Loop =============================")


;************************************************
 ; Create plot
 ;************************************************
 ; graphics
                                                    ; arry1 = textf ->prDATA(:)
 pr_avg    = dim_avg_n(prDATA, (0))    ;average of models mean rainfall values, the MMM
 printVarSummary(pr_avg)
 printMinMax(pr_avg, True)



 arrysst    = sstDATA                                                    ;arry2 = textf ->sstDATA(:)
 sst_avg    = dim_avg_n(arrysst, (0))
 copy_VarCoords(sst_ann,sst_avg)
 arrysst2   = sst_avg
 ;copy_VarCoords(sst_avg(:,:),arrysst2)
 printVarSummary(sst_avg)
 printMinMax(sst_avg, True)

 delete(arrysst)
 ;delete(arry2)

if(PLOT_RESULTS)

do zz=0,dimsizes(ZOOM)-1,1                           ;start zoom loop
 do pc=0,dimsizes(pltType)-1,1

  pltDir  = diro                                     ;dir to which plots are sent
  if (ZOOM(zz).eq.1) then
    pltName = scenario(sce)+"_Cat2_mean_maps_zoom_"+season+"_"+region(cb)
 else
    pltName = scenario(sce)+"_Cat2_mean_maps_global_"+season+"_"+region(cb)
  end if

  pltPath= pltDir+pltName+"."+pltType
  wks    = gsn_open_wks(pltType(pc), pltDir+pltName)
  plot = new(nplots,graphic)

           ; manually specify colors
   colors = (/"Snow","PaleTurquoise" \
               ,"PaleGreen","SeaGreen3" ,"Yellow"       \
               ,"Orange","HotPink","Red","Violet"       \
               ,"Purple", "Brown", "Blue"/)

  res                      = True     ; plot mods desired
  res@gsnMaximize          = True     ; make ps/eps/pdf large

  res@cnFillOn             = True     ; turn on color fill
; res@cnFillPalette        = colors   ; set color map
  res@cnLinesOn            = False    ; turn of contour lines
; res@cnFillMode           = "RasterFill" ; Raster Mode
  res@cnLineLabelsOn       = False       ; Turn off contour lines
  res@cnFillPatterns       = True
  res@cnFillPalette        = "CBR_wet" ;"MPL_Reds"  ;"cmocean_matter" ;"BlWhRe"
  res@gsnPaperOrientation  = "portrait"

  res@cnLevelSelectionMode    =  "AutomaticLevels"

  res@lbOrientation             = "vertical"   ; vertical label barb's
  res@lbLabelFontHeightF        = 0.012        ; change font size
  res@pmLabelBarWidthF          =  0.1
  res@pmLabelBarOrthogonalPosF  = -0.01    ; move a bit to left

  res@mpFillOn                  = False

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
; res@mpCenterLonF               = 220.         ; don't split Africa
; res@tiMainString              = "Mean JJA maps : "+yrStrt+"-"+yrLast
; res@gsnCenterString           = "Areal Mean="+sprintf("%4.2f",  prcAvg)+" mm/mon"

         ;Panel plot resources

   resP                      = True         ; modify the panel plot
   resP@gsnMaximize          = True         ; large format
   resP@gsnPanelLabelBar     = False         ; add common colorbar
   resP@gsnPaperOrientation  = "portrait"
;  resP@gsnPanelMainString   = "Best models mean map "+season+"rainfall & SST"
   resP@tiMainFontHeightF    =  0.01


;*******************************************************************************
; combined plot
;*******************************************************************************
 do n=0,nplots-2
    res@gsnLeftString  = "Worst models in "+region(cb)+" mean rainfall"
    res@gsnRightString = season
     plot(0)=gsn_csm_contour_map(wks,pr_avg,res)  ;mean correlation plot for models
     res@gsnLeftString  = "Worst models in "+region(cb)+" mean SST"
     res@gsnRightString = season
     res@cnFillPalette  = "MPL_coolwarm"       ;"CBR_coldhot"
     plot(1)=gsn_csm_contour_map(wks,arrysst2,res)   ;mean correlation plot for observations
end do

                                        ; now draw all as one plot
;  gsn_panel(wks,plot,(/1,2/),resP)     ;draw horizontal - 1 row, 2 columns
gsn_panel(wks,plot,(/2,1/),resP)     ;draw vertical    - 2 rows, 1 column

    end do                                           ;end plot type loop
  end do                                             ;end zoom loop
end if                                               ;PLOT_RESULTS if
;===============================================================================

delete(hdata)
delete(hdataT)
delete(hdata_names)
delete(prDATA)
delete(sstDATA)
delete(sst_avg)
delete(pr_avg)
    print("------------------"+region(cb)+" done----------------------------------")
 end do                                      ;end region loop



    delete(diro)
    delete(filo)
    print("--------------"+scenario(sce)+" done-------------------------------------")


end if


delete(modelNames)
delete(N_A_Cat1)
delete(N_A_Cat2)
delete(C_A_Cat1)
delete(C_A_Cat2)
delete(G_C_Cat1)
delete(G_C_Cat2)
delete(S_B_Cat1)
delete(S_B_Cat2)
       end do                                          ;end scenario loop
