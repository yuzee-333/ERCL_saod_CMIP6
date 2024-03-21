;copy_VarCoords(gpcc(0:dimsizes(hdata_names)-1,:,:),rgDATA)
sstDATA!0 = "model"
prDATA!0  = "model"
printVarSummary(rgDATA)




;===============================================================
;===============================================================
;***********************************************
;---Save to a netcdf file, in the current directory
;***********************************************

 if (WRITE_RESULTS)
     ptho = diro+filo
     system("/bin/rm -f "+ptho)
     ncdf = addfile(ptho,"c")

     fAtt = True
     fAtt@title         = "Mean rainfall and mean SST from CMIP6 Models"

     if(scenario(sce).eq."HISTORICAL") then
     fAtt@source_name   = "CMIP6 historical runs"
     else
     fAtt@source_name   = "CMIP6 SSP585 runs"
     end if

     fAtt@source_URL    = "https://esgf-node.llnl.gov/projects/cmip6/"
     fAtt@source        = "Accessed from Levante Supercomputer, Hamburg, Germany"
     fAtt@Conventions   = "None"
     fAtt@creation_date = systemfunc("date")
     fileattdef(ncdf,fAtt)            ; copy file attributes

;    filedimdef(ncdf,"time",-1,True) ; make time an UNLIMITED dimension
     ncdf->mean_sst     = sstDATA
     ncdf->mean_rain    = prDATA

 print("-----------------nc file for "+region(cb)+" DONE----------------------")
end if



 ;************************************************
 ; Create plot
 ;************************************************
 ; graphics
      pltType = "png"        ;or "png"       ; send graphics to PNG file
      pltDir  = "/home/yuzee/nclfolder/RESULTS/Global_mean_maps/"               ; dir to which plots are sent
      pltName = "model1_precip_"+yrStrt+"-"+yrLast
    pltPath= pltDir+pltName+"."+pltType
    nplots = 2

    wks    = gsn_open_wks(pltType, pltDir+pltName)
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
   ;res@cnFillMode           = "RasterFill" ; Raster Mode
    res@cnLineLabelsOn       =  False       ; Turn off contour lines
    res@cnFillPatterns       = True

    res@cnLevelSelectionMode    =  "AutomaticLevels"

    res@lbOrientation             = "vertical"   ; vertical label barb's
    res@lbLabelFontHeightF        = 0.012        ; change font size
    res@pmLabelBarWidthF          =  0.1
    res@pmLabelBarOrthogonalPosF  = -0.01    ; move a bit to left

    res@mpFillOn                  = False
   ; res@mpCenterLonF             = 220.         ; don't split Africa

    res@tiMainString              = "Global mean Annual rainfall : "+yrStrt+"-"+yrLast
 ;  res@gsnCenterString           = "Areal Mean="+sprintf("%4.2f",  prcAvg)+" mm/mon"
    res@gsnPaperOrientation       = "portrait"


    plot    = gsn_csm_contour_map(wks,prc_ann, res)

 ;   res@tiMainString              = "Global precipitation Anomalies : "+yrStrt+"-"+yrLast
 ;   plot    = gsn_csm_contour_map(wks,GPCC(0,:,:), res)

 ;   res@tiMainString              = "JJA Precip Anomalies : "+yrStrt+"-"+yrLast
 ;   plot    = gsn_csm_contour_map(wks,gpcc(0,:,:), res)



    resP                      = True     ; plot mods desired
    resP@gsnMaximize          = True     ; make ps/eps/pdf large

    resP@cnFillOn             = True     ; turn on color fill
    resP@cnLinesOn            = False    ; turn of contour lines
   ;resP@cnFillMode           = "RasterFill" ; Raster Mode
    resP@cnLineLabelsOn       =  False       ; Turn off contour lines
    resP@cnFillPatterns       = True

    resP@cnLevelSelectionMode    = "AutomaticLevels"
   ; resP@cnLevels                = (/10,12.5,15,17.5,20,22.5,25,27.5,30,32.5,35,37.5,\
   ;                               40,42.5,45,47.5,50,52.5,55,57.5,60,62.5,65,67.5,70,72.5,\
   ;                               75,77.5,80,82.5,85,87.5,90,92.5,95,97.5,100,200,300,400,500,600/) ; "mm/day"

    resP@lbOrientation        = "vertical"   ; vertical label barb's
    resP@lbLabelFontHeightF   = 0.008        ; change font size
    resP@pmLabelBarWidthF     =  0.2
    resP@pmLabelBarOrthogonalPosF = -0.01    ; move a bit to left

    resP@mpFillOn             = False
    resP@mpMinLatF            = latSp         ; zoom in on map
    resP@mpMaxLatF            = latNp
    resP@mpMinLonF            = lonLp
    resP@mpMaxLonF            = lonRp
   ; resP@mpCenterLonF         = 220.         ; don't split Africa

    resP@tiMainString         = "South Atlantic mean Annual rainfall : "+yrStrt+"-"+yrLast
    resP@tiMainFontHeightF    = 0.02
 ;  resP@gsnCenterString      = "Areal Mean="+sprintf("%4.2f",  prcAvg)+" mm/yr"


    resP@gsnPaperOrientation  = "portrait"
    plot    = gsn_csm_contour_map(wks,prc_ann, resP)




    end if                                        ;WRITE_RESULTS

    delete(hdataT)
    delete(hdata)
    delete(latS)
    delete(latN)
    delete(lonL)
    delete(lonR)
    delete(hdata_names)
    delete(rgDATA)
    delete(rgvalsi)
    delete(siglev)
    delete(siglevi)
    delete(rgyave)
    delete(rgxave)
    delete(rgnptx)
    delete(rgsde)
    delete(rgtstat)
    delete(rgexvar)
    delete(rgcorr)
    delete(rstatp)

