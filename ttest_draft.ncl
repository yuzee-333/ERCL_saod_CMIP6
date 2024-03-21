 ;
 ;
 begin
 
 X = (/27,20,21,26,27,31,24,21,20,19,23,24,28,19,24,29,18,20,17,31,20,25,28,21,27/)  ; treated
 Y = (/21,22,15,12,21,16,19,15,22,24,19,23,13,22,20,24,18,20/)                       ; control

  siglvl  = 0.05
  aveX    = avg (X)             ; 23.6    ; dim_avg_n (X,0)
  aveY    = avg (Y)             ; 19.222
  varX    = variance (X)        ; 17.083  ; dim_variance_n (X,0)
  varY    = variance (Y)        ; 13.477
  sX      = dimsizes (X)        ; 25
  sY      = dimsizes (Y)        ; 18
                                                   ; Following not used; FYI only
  diffXY  = aveX - aveY                            ; 4.378
  print(diffXY)

  iflag   = True                                   ; population variance similar
  tval_opt= False                                  ; p-value only
  prob = ttest(aveX,varX,sX, aveY,varY,sY, iflag, True) 

  if (prob.lt.siglvl) then
   print("difference is significant")
  end if
  print(prob)
  
;prob will be a scalar containing the significance. It will range between zero and one. If prob < siglvl, then the null hypothesis (means are from the same population) is rejected and the alternative hypothesis is accepted.\
delete(tval_opt)

;If tval_opt is set to True:
  
  tval_opt = True
  probt = ttest(aveX,varX,sX, aveY,varY,sY, iflag, True) 
  print(probt)

;then probt will be a 1D array of length two where probt(0) will contain the probability and probt(1) will contain the t-value.
  printVarSummary(probt)
  
  ;Variable: prob
  ;Type: float
  ;Total Size: 8 bytes
  ;          2 values
  ;Number of Dimensions: 2
  ;Dimensions and sizes:	[2] x [1]
  ;Coordinates: 
  ;(0,0)	0.0007473998        ;  p-value
  ;(1,0)	3.658246            ;  t-value
  
  
  end 
