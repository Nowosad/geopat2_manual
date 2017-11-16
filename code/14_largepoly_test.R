## files prep ----------------------------------------------------------------
dir.create("tmp")
file.copy(from = "data/Augusta2011.tif", to = "tmp")

setwd("tmp/")

## temp solution 1 ----------------------------------------------------------
system("gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid100 -z 100 -f 100")
system("gpat_segment -i Augusta2011_grid100 -o Augusta2011_seg100.tif -v Augusta2011_seg100.shp --lthreshold=0.1 --uthreshold=0.3 --size=100")
system("gpat_polygon -i Augusta2011.tif -e Augusta2011_seg100.tif -o Augusta2011_psign.txt -s 'ent' -n none")

##  new gpat version lower test-------------------------------------------------
system("gpat_polygon -i Augusta2011.tif -e Augusta2011_seg100.tif -o Augusta2011_psign.txt -s 'ent' -n none -m 30")

## gpat clustering  prep -----------------------------------------------------
system("gdalwarp -tr 1 1 Augusta2011.tif Augusta20111.tif")
system("gpat_gridhis -i Augusta20111.tif -o Augusta20111_grid100 -z 100 -f 100")
system("gpat_segment -i Augusta20111_grid100 -o Augusta20111_seg100.tif -v Augusta20111_seg100.shp --lthreshold=0.1 --uthreshold=0.3 --size=100")
system("gpat_polygon -i Augusta20111.tif -e Augusta20111_seg100.tif -o Augusta20111_psign.txt -s 'ent' -n none")

## new gpat version ---------------------------------------------------------
system("gpat_polygon -i Augusta20111.tif -e Augusta20111_seg100.tif -o Augusta20111_psign.txt -s 'ent' -n none -m 16000")

## clean --------------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)
