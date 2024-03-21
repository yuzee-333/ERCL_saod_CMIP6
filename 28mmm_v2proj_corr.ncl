


; To average the correlation values...another MMM
;----extract values from NC file generated above and write to csv ----

TEST_OVER = True
season = "JJA"
yrStrt = 1950
yrLast = 2014

region = (/"Northern_Amazon","Guinea_Coast","Central_Africa","SE_Brazil"/)
do cb=0,dimsizes(region)-1,1

diro = "/home/yuzee/nclfolder/RESULTS/05correlation_regional/"
filo = "correlation_models_"+season+"_"+region(cb)+"_"+yrStrt+"_"+yrLast+".nc"



textf = addfile(diro+filo, "r")
;"----------->>>>>>>>>>>>>>>>>>>>>>" ;extracting the values from the nc file created above

  arry1 = textf ->rrDATA(:)
  a1    = dim_avg_n(arry1, (0))
  printMinMax(a1, True)

  arry2 = textf ->exvar(:)
  a2    = dim_avg_n(arry2, (0))
  printMinMax(a2, True)

  arry3 = textf ->reg(:)
  a3    = dim_avg_n(arry3, (0))
  printMinMax(a3, True)

  arry4 = textf ->tstat(:)
  a4    = dim_avg_n(arry4, (0))
  printMinMax(a4, True)

  arry5 = textf ->pval(:)
  a5    = dim_avg_n(arry5, (0))
  printMinMax(a5, True)

  arry6 = textf ->rlow(:)
  a6    = dim_avg_n(arry6, (0))
  printMinMax(a6, True)

  arry7 = textf ->rhi(:)
  a7    = dim_avg_n(arry7, (0))
  printMinMax(a7, True)

if (TEST_OVER)



;------write to table --------------

 fileName = "mmm_corrV2_"+season+"_"+region(cb)+".csv"
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

varname = "v2_"+region(cb)+"_MMM"
 var1 = a1
 var2 = a2
 var3 = a3
 var4 = a4
 var5 = a5
 var6 = a6
 var7 = a7


; print(var1)
 alist = [/varname,var1, var2, var3, var4, var5, var6,var7/]
 format = "%s,%g,%g,%g,%g,%g,%g,%g"


 write_table(wad, "a", alist, format)  ;"a"ppend values to table created in line 408

  end if
 end do
