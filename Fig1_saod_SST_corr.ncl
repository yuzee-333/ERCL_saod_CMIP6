begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
  latS   =  -90      ;-50.
  latN   =   90.      ; 5
  lonL   =  -180    ;-60.
  lonR   =  180         ;20.

  yrStrt = 1950
  yrLast = 2014



ZOOM    = (/0,1/)                          ;loop through zoom off '0' and on '1'
;do zz=0,dimsizes(ZOOM)-1,1
do zz=0,0,1

pltType = (/"eps", "png"/)
pltDir = "/home/yuzee/Desktop/mywork/ERCL_manuscript/UZ_work_latest/CPAM_poster/"

if (ZOOM(zz).eq.1) then
 pltName = "FIG2_zoom_corr"            ;
else
 pltName = "FIG2_global_corr"          ;
end if

 ; to zoom in on the region for the plot
 latSp =  -45
 latNp =   18
 lonLp =  -75
 lonRp =   25

;===============================================================================
;===============================================================================
diriT = "/home/yuzee/mywork/DATA/obs/sst/"
hdataT = (/"HadISST_sst.nc"/)
qq    = addfile(diriT+hdataT,"r")
TIME   = qq->time
YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
HADI   = qq->sst(iYYYY,:,:)
HADI   = where(HADI.gt.-30.,HADI,HADI@_FillValue)	;removes padded values
printVarSummary(HADI)       ; variable overview

delete([/qq, TIME, YYYY, iYYYY/])

printMinMax(HADI,True)
HADIClm      = clmMonTLL(HADI)
printVarSummary(HADIClm)                   ; (12,nlat,nlon)
HADI         = calcMonAnomTLL(HADI, HADIClm)    ; replace with anonamlies
HADI@long_name = "ANOMALIES: "+HADI@long_name



hadi = month_to_season(HADI,"JJA")
hadi = dtrend_msg_n(hadi&time,hadi,True,False,0)
printVarSummary(hadi)
printMinMax(hadi,True)



saodi =  wgt_areaave_Wrap(hadi(time|:, {longitude|-20:10}, {latitude|-15:0}),1.0, 1.0, 0) -\
       	wgt_areaave_Wrap(hadi(time|:,{longitude|-40:-10}, {latitude|-40:-25}),1.0, 1.0, 0)

saodi_std = saodi/stddev(saodi)
saodi_std!0 = "time"
saodi_std&time = hadi&time
printVarSummary(saodi_std)
delete([/HADIClm,HADI,saodi/])
;===============================================================================
;===============================================================================

;correlation 
p95  = 0.05


corr = escorc_n(saodi_std, hadi, 0, 0)
rc   = regCoef_n(saodi_std, hadi, 0, 0)
copy_VarMeta(hadi(0,:,:), corr(:,:))
printVarSummary(corr)

df1     = onedtond(rc@nptxy, dimsizes(rc)) - 2    ;degrees of freedom
cr_t    = corr*sqrt((df1)/(1-corr^2))
cr_p    = student_t(cr_t, df1)
copy_VarCoords(corr, cr_p)
sigC    = corr 
sigC    = where(abs(cr_p).lt.p95, sigC, sigC@_FillValue)
printVarSummary(sigC)
copy_VarMeta(hadi(0,:,:), sigC(:,:))

delete([/rc,df1,cr_p,cr_t,hadi/])


;===========================================================================





















;To plot 
nplots  = 1     ;

do pc=0,dimsizes(pltType)-1,1
  wks = gsn_open_wks(pltType(pc), pltDir+pltName)         ; send graphics to PNG/eps/jpg file
  plot = new(nplots,graphic)                ; create graphic array
                                          ; only needed if paneling
; plot resources

  res                      = True
  res@gsnDraw              = False        ; don't draw yet
  res@gsnFrame             = False        ; don't advance frame yet

  res@gsnAddCyclic         = True        ; plotted data are not cyclic

  res@mpFillOn             = False        ; turn off map fill
  if (ZOOM(zz).eq.1) then
    res@mpMinLatF            = latSp         ; zoom in on map
    res@mpMaxLatF            = latNp
    res@mpMinLonF            = lonLp
    res@mpMaxLonF            = lonRp   ;
  else
    res@mpMinLatF            = latS         ; zoom in on map
    res@mpMaxLatF            = latN
    res@mpMinLonF            = lonL
    res@mpMaxLonF            = lonR
  end if

  res@cnFillOn             = True         ; turn on color fill
  res@cnLinesOn            = False        ; True is default
  res@cnLineLabelsOn       = False        ; True is default
  res@cnFillPalette        = "BlWhRe"     ; set color map
  res@lbLabelBarOn         = False        ; turn off individual lb's
  res@lbOrientation        = "vertical"   ; vertical label barb's
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMonoFillColor      = False

  res@cnMinLevelValF       = -0.6
  res@cnMaxLevelValF       =  0.6
  res@cnLevelSpacingF      =  0.05
  res@gsnCenterString      = " "
  res@tiMainString         = " "
            ;  res@tiMainFontHeightF    =  0.02




  ; panel plot only resources
  resP                     = True         ; modify the panel plot
  resP@gsnMaximize         = True         ; large format
  resP@gsnPanelLabelBar    = False        ; add common colorbar
  resP@gsnPaperOrientation = "portrait"
;  resP@gsnPanelMainString  = "Correlation of SAOD and global SST anomalies (JJA)"
  resP@tiMainFontHeightF    =  0.01

  resP@lbOrientation             = "horizontal"
  resP@pmLabelBarOrthogonalPosF  = -0.05   ;;;
  resP@gsnPanelLabelBar         = True ;
  resP@pmLabelBarHeightF        = 0.05
  resP@pmLabelBarWidthF         = 0.8
  resP@lbBoxEndCapStyle     = "TriangleBothEnds"
  resP@lbTitleOn            = True 
  resP@lbTitleString        = "sst (~S~o~N~C)"
  resP@lbTitleFontHeightF   = 0.02
  resP@lbTitlePosition       = "Bottom"   ;"Right"
  resP@lbTitleDirection      = "Across"
  resP@lbTitleFont          = "helvetica-bold" ;"gothic_english" ;"triplex_italic"  ; 
  resP@lbLabelStride        =  2
  resP@cnLevelSelectionMode = "ManualLevels"
  resP@cnLevelSpacingF      =  0.1
  resP@cnMaxLevelValF       =  0.9
  resP@cnMinLevelValF       = -0.9
  resP@gsnPaperOrientation  = "portrait"
  
  
  ; Set contour options for significance plot        ;
    sig_res                   = True
    sig_res@cnFillOn          = True 
    sig_res@cnLinesOn         = False 
    sig_res@cnFillMode        = "AreaFill"
    sig_res@cnFillPattern     = 17
    sig_res@cnMonoFillColor   = True
    sig_res@cnFillColor       = "black"
    
    sig_res@cnLineLabelsOn    = False
    sig_res@cnInfoLabelOn     = False
    sig_res@cnNoDataLabelOn   = False
    sig_res@gsnAddCyclic      = True 
    sig_res@cnLineDashPattern = 4
  if (ZOOM(zz).eq.1) then
    sig_res@cnFillDotSizeF    = 0.002 ;
  else
    sig_res@cnFillDotSizeF    = 0.004
  end if

  tres               =  True
  tres@txFontHeightF = 0.02
  tres@txFontColor   = "black"


;========================================================================
;*******************************************
; combined plot
;*******************************************
     res@gsnStringFont  = "times-roman";  "triplex_italic" ;
     res@gsnLeftString  = "Correlation of SAOD and global SST anomalies (JJA)"
     res@gsnRightString = yrStrt+" - "+yrLast
     res@gsnRightStringFontHeightF = 0.009
     res@gsnLeftStringFontHeightF  = 0.015

     
     plot=gsn_csm_contour_map_overlay(wks,corr,sigC,res, sig_res)
     
     
  ;================= CREATE BOXES ==================================


;----Resources for the polyline              ;
  pres0                    = True
  pres0@gsLineThicknessF    = 4.
  pres0@gsLineColor        = "black" ;"skyblue" "darkgreen" "green"
  pres0@gsLineDashPattern  = 0.
  pres0@tfPolyDrawOrder    = "postDraw"

                                          ; polyline coordinates for JJA
                                  ; Amazon
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

                                  ;NEP
  lat4 = (/ 0., 0., -15., -15., 0./)
  lon4 = (/-20., 10., 10., -20., -20./)
                                  ;SWP
  lat5 = (/ -25., -25., -40., -40., -25./)
  lon5 = (/ -40., -10., -10., -40.,-40./)


  ;-------drawing the polylines -------------------------
    ;pres0@gsMarkerColor   = "green"
    pres0@gsLineLabelString  = "1"
    dum0 = gsn_add_polyline(wks,plot,lonEQ,latEQ,pres0) ; Northern Amazon
    
    pres0@gsLineLabelString  = "2"
    dum4 = gsn_add_polyline(wks,plot, lon1, lat1, pres0)  ; west africa guinea coast
    
    pres0@gsLineLabelString  = "3"
    dum8  = gsn_add_polyline(wks,plot, lon2, lat2, pres0)  ; central africa
    
    pres0@gsLineLabelString  = "4"
    dum12 = gsn_add_polyline(wks,plot, lon3, lat3, pres0)   ; SE Brazil
    
    if (ZOOM(zz).eq.1) then
    ;  e = gsn_add_text(wks,plot(0),"3",9,-4, tres)
      
    end if
   


   ;----Resources for the polyline               ;
        press0     = True 
        press0     = pres0             ;

        if(ZOOM(zz).eq.0)
          press0@gsLineLabelFontHeightF = 0.0125     ;0.0125 default  ;
        else 
          press0@gsLineLabelFontHeightF = 0.02     ;0.0125 default  ;
        end if

        if(pc.eq.1)
          press0@gsLineThicknessF   = 8.    ;
        else 
          press0@gsLineThicknessF   = 5.    ;
        end if 

        press0@gsLineColor        = "green"
        press0@gsLineDashPattern  = 1.
        press0@tfPolyDrawOrder    = "postDraw"
        press0@gsLineLabelString  = "NEP"
        press0@gsFontColor        = "green"
        press0@gsLineLabelFontColor = "white"
;
        pres1                    = press0 
        pres1                    = True 
        pres1@gsLineColor        = "green"
        pres1@gsLineLabelString  = "SWP"


    dum13 = gsn_add_polyline(wks,plot,lon4,lat4,press0)   ; NEP

     dum3 = gsn_add_polyline(wks,plot,lon5, lat5, pres1)   ; SWP
;========================================================================

                                      ; now draw all as one plot
  gsn_panel(wks,plot,(/1,1/),resP)     ;draw horizontal - 1 row, 2 columns




  end do                                    ;end pltType loop
 end do                                     ;end zoom loop

system("eog "+pltDir+pltName+".png")






















end 