; FOR MANUSCRIPT
; To average the Regression coefficient values...MMM
;----extract values from NC file generated above and write to csv ----

scenario = (/"HISTORICAL", "FUTURE"/)
do sce=0, dimsizes(scenario)-1,1

TEST_OVER = True
season = "JJA"

region = (/"Northern_Amazon","Guinea_Coast","Central_Africa","SE_Brazil"/)
do cb=0,dimsizes(region)-4,1

if(scenario(sce).eq."HISTORICAL") then
    yrStrt = 1950
    yrLast = 2014
    diro = "/home/yuzee/nclfolder/RESULTS/07manuscript/"
    filo = "iregression2_models_"+region(cb)+"_"+season+"_"+yrStrt+"_"+yrLast+".nc"
    else
    yrStrt = 2015
    yrLast = 2079
    diro = "/home/yuzee/nclfolder/RESULTS/07manuscript/"
    filo = "iregression_proj_mod_"+region(cb)+"_"+season+"_"+yrStrt+"_"+yrLast+".nc"
end if


textf = addfile(diro+filo, "r")
;"----------->>>>>>>>>>>>>>>>>>>>>>" ;extracting the values from the nc file created above

  arry1 = textf ->rgDATA(:)
  a1    = dim_avg_n(arry1, (0))    ;average of model b values, the MMM
  printMinMax(a1, True)

  arry2 = textf ->rgiDATA(:)
  a2    = dim_avg_n(arry2, (0))
  printMinMax(a2, True)

  arry3 = textf ->prob(:)
  a3    = dim_avg_n(arry3, (0))
  printMinMax(a3, True)

  arry4 = textf ->alpha(:)
  a4    = dim_avg_n(arry4, (0))
  printMinMax(a4, True)

  arry5 = textf ->stdpri(:)
  a5    = dim_avg_n(arry5, (0))
  printMinMax(a5, True)

  arry6 = textf ->stdsaodi(:)
  print("arry6 is ")
  printMinMax(arry6, True)
  a6    = dim_avg_n(arry6, (0))
  printMinMax(a6, True)

  arry7 = textf ->sde(:)
  a7    = dim_avg_n(arry7, (0))
  printMinMax(a7, True)

  arry8 = textf ->tval(:)
  a8    = dim_avg_n(arry8, (0))
  printMinMax(a8, True)

  arry9 = textf ->exvar(:)
  a9    = dim_avg_n(arry9, (0))
  printMinMax(a9, True)

  arry10 = textf ->corr(:)
  a10    = dim_avg_n(arry10, (0))
  printMinMax(a10, True)

  arry11 = textf ->pvalcorr(:)
  a11    = dim_avg_n(arry11, (0))
  printMinMax(a11, True)


  a12    = stddev(arry1)        ;standard deviation of r values
  printMinMax(a12, True)

if (TEST_OVER)



;------write to table --------------
 if(scenario(sce).eq."HISTORICAL") then
   fileName  = "immm_regV2hist_"+season+"_"+region(cb)+".csv"
   csvdir    = "/home/yuzee/nclfolder/RESULTS/07manuscript/"
              ;creating header names
   col1 = "Model_name"
   col2 = "b"
   col3 = "a-intercept"
   col4 = "prob"
   col5 = "alpha"
   col6 = "pri_std"
   col7 = "saod_std"
   col8 = "mmm_stddev"
   col9 = "std_error"
   col10 = "t"
   col11 = "r_squared"
   col12 = "r"
   col13 = "p"
  else
  fileName  = "immm_regV2proj_"+season+"_"+region(cb)+".csv"
  csvdir    = "/home/yuzee/nclfolder/RESULTS/07manuscript/"
      ;creating header names
    col1 = "Model_name"
    col2 = "b"
    col3 = "a-intercept"
    col4 = "prob"
    col5 = "alpha"
    col6 = "pri_std_proj"
    col7 = "saod_std_proj"
    col8 = "mmm_stddev"
    col9 = "std_error_proj"
    col10 = "t_proj"
    col11 = "r_squared_proj"
    col12 = "r_proj"
    col13 = "p_proj"
  end if

wad       = csvdir+fileName
header = [/col1, col2, col3, col4, col5, col6, col7, col8, col9, col10, col11, col12, col13/]
formatt = "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s, %s, %s"

write_table(wad, "w", header, formatt)  ;create header


;varname = region(cb)+"_AMME"
varname = "AMME"                                ;All MultiModel Ensemble
 var1 = a1
 var2 = a2
 var3 = a3
 var4 = a4
 var5 = a5
 var6 = a6
 varx = a12
 var7 = a7
 var8 = a8
 var9 = a9
 var10 = a10
 var11 = a11

; print(var1)
 alist = [/varname,var1, var2, var3, var4, var5, var6,varx, var7,var8, var9, var10, var11/]
 format = "%s,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g"


 write_table(wad, "a", alist, format)  ;"a"ppend values to table created in line 408

  end if
 end do
 print("--------------"+scenario(sce)+" done-------------------------------------")
 end do
