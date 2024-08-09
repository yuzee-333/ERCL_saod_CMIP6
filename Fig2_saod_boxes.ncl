;----------------------------------------------------------------------
; gpcp_1.ncl
;
; Concepts illustrated:
;   - Reading a GPCP Monthly netCDF file
;   - Use functions to calculate climatology and weighted area average
;   - Use explicit colors
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;**************************************************************
; User Input
;***************************************************************

latSp = -60
latNp =  32
lonLp = -80
lonRp =  40

 yrStrt= 1950
 yrLast= 2014
 season = "JJA"



 diri = "/home/yuzee/nclfolder/DATA/obs/"
 fili   = "HadISST_sst.nc"
 var =   "sst"


;***************************************************************
; End User Input
;***************************************************************
; Read variable; compute monthly climatology; annual mean
;***************************************************************
 f     = addfile(diri+fili,"r")
 ff = f->$var$
printVarSummary(ff)

 TIME   = f->time
 YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
 iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
 PRC   = f->$var$(iYYYY,:,:)
 printVarSummary(PRC)       ; variable overview

 delete(f)
 delete(TIME)
 delete(YYYY)
 delete(iYYYY)

;-----------------------------------------------------------
;-----------------------------------------------------------
;------------ annual mean ----------------------------------
prc_clm = clmMonTLL(PRC)                         ; compute monthly climatology
printVarSummary(prc_clm)                         ; (12,lat,lon)

prc_clm  = where(prc_clm.lt.0.10, 0.0, prc_clm)  ; set small values to 0.0
prc_ann  = dim_avg_n_Wrap(prc_clm, 0)            ; compute annual mean (arithmetic)
printVarSummary(prc_ann)                         ; from monthly climatologies
printMinMax(prc_ann, True)

clat     = latRegWgt( prc_ann&latitude, "float", 0)   ; lwt weights
prcAvg   = wgt_areaave( prc_ann, clat, 1.0, 0)   ; areal average

;------------------------- anomalies ---------------------
;GPCCClm      = clmMonTLL(PRC)
;printVarSummary(GPCCClm)                   ; (12,nlat,nlon)
;GPCC         = calcMonAnomTLL(PRC, GPCCClm)    ; replace with anonamlies
;GPCC@long_name = "ANOMALIES: "+PRC@long_name
;gpcc    = month_to_season(GPCC, season)
;printVarSummary(gpcc)
;gpcci  = dtrend_msg_n(gpcc&time, gpcc, False, False, 0)
;printVarSummary(gpcci)




;************************************************
; Create plot
;************************************************
; graphics
     pltType = "png"       ; send graphics to PNG file
     pltDir  = "/home/yuzee/Desktop/my_research/my.work/manuscript/01_figures/"                ; dir to which plots are sent
     pltName = "Fig_1_SAODI_boxes"
   pltPath   = pltDir+pltName+"."+pltType
   nplots    = 1

   wks    = gsn_open_wks(pltType, pltPath)
   plot = new(nplots,graphic)

          ; manually specify colors
   colors = (/"Snow","PaleTurquoise" \
             ,"PaleGreen","SeaGreen3" ,"Yellow"       \
             ,"Orange","HotPink","Red","Violet"       \
             ,"Purple", "Brown", "Blue"/)

   res                      = True     ; plot mods desired
   res@gsnMaximize          = True     ; make ps/eps/pdf large
   res@gsnDraw              = False

   res@cnFillOn             = False     ; turn on color fill
;  res@cnFillPalette        = colors   ; set color map
   res@cnLinesOn            = False    ; turn of contour lines
;  res@cnFillMode           = "RasterFill" ; Raster Mode
   res@cnLineLabelsOn       =  False       ; Turn off contour lines
   res@cnFillPatterns       =  False

   res@cnLevelSelectionMode      =  "AutomaticLevels" ;"ExplicitLevels"
   res@lbOrientation             = "vertical"   ; vertical label barb's
   res@lbLabelFontHeightF        =  0.012        ; change font size
   res@lbLabelBarOn              = False
   res@pmLabelBarWidthF          =  0.1
   res@pmLabelBarOrthogonalPosF  = -0.01    ; move a bit to left

   res@mpFillOn             = False
   res@mpMinLatF            = latSp         ; zoom in on map
   res@mpMaxLatF            = latNp
   res@mpMinLonF            = lonLp
   res@mpMaxLonF            = lonRp
   res@cnInfoLabelOn        = False
;  res@mpCenterLonF         = 220.         ; don't split Africa

   ;res@tiMainString         = "South Atlantic mean Annual SST : "+yrStrt+"-"+yrLast
;   res@tiMainString         = "SAOD Index"
;   res@tiMainFontHeightF    = 0.02

;  res@gsnCenterString       = "Areal Mean="+sprintf("%4.2f",  prcAvg)+" degC/yr"
   res@gsnPaperOrientation   = "portrait"
   res@gsnLeftString         = " "
   res@gsnRightString        = " "

   ;================= CREATE BOXES ==================================


      ;----Resources for the polyline               ;
        pres0                    = True
        pres0@gsLineThicknessF    = 3.
        pres0@gsLineColor        = "black"
        pres0@gsLineDashPattern  = 0.
        pres0@tfPolyDrawOrder    = "postDraw"
        pres0@gsLineLabelString  = "NEP"
;
        pres1                    = True
        pres1@gsLineThicknessF    = 3.
        pres1@gsLineColor        = "blue"
        pres1@gsLineDashPattern  = 1.
        pres1@tfPolyDrawOrder    = "postDraw"
        pres1@gsLineLabelString  = "SWP"

                             ; polyline coordinates for JJA
                                       ;NEP
       latEQ = (/ 0., 0., -15., -15., 0./)
       lonEQ = (/-20., 10., 10., -20., -20./)
                                       ;SWP
       lat1 = (/ -25., -25., -40., -40., -25./)
       lon1 = (/ -40., -10., -10., -40.,-40./)


       ;-------drawing the polylines -------------------------

       plot    = gsn_csm_contour_map(wks,prc_ann, res)        ;annual mean


         dum0 = gsn_add_polyline(wks,plot,lonEQ,latEQ,pres0)   ; NEP

         dum3 = gsn_add_polyline(wks,plot,lon1, lat1, pres1)   ; SWP

   ; panel plot only resources
     resP                     = True         ; modify the panel plot
     resP@gsnMaximize         = True         ; large format
     resP@gsnPanelLabelBar    = False         ; add common colorbar
     resP@gsnPaperOrientation = "portrait"
    ;resP@gsnPanelMainString  = "South Atlantic mean Annual SST : "+yrStrt+"-"+yrLast
    ;resP@tiMainFontHeightF   = 0.017



;   plot    = gsn_csm_contour_map(wks,GPCC(0,:,:), res)    ;anomalies

   delete(res@gsnCenterString)
;   plot    = gsn_csm_contour_map(wks,gpcc(0,:,:), res)    ;jja anomalies


      ;========================================================================

    gsn_panel(wks,plot,(/1,1/),resP)     ; now draw as one plot






;--------------------------------
