library(tidyverse)
library(sf)
library(raster)
library(rasterVis)

## files prep ----------------------------------------------------------------
dir.create("tmp")
file.copy(from = "data/Augusta2011.tif", to = "tmp")

setwd("tmp/")

## the code ------------------------------------------------------------------
system("gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid100 -z 100 -f 100 -s prod")
system("gpat_grd2txt -i Augusta2011_grid100 -o Augusta2011_grid100.txt")

system("gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid100 -z 100 -f 100  -n none -s linds")
system("gpat_grd2txt -i Augusta2011_grid100 -o Augusta2011_grid_linds.txt")

system("gpat_segment -i Augusta2011_grid100 -o Augusta2011_seg100.tif -v Augusta2011_seg100.gpkg --lthreshold=0.1 --uthreshold=0.3")
system("gdalwarp -tr 30 30 Augusta2011_seg100.tif Augusta2011_seg100_res.tif")
system("gpat_polygon -i Augusta2011.tif -e Augusta2011_seg100_res.tif -o Augusta2011_poly100.txt")

# test reader -------------------------------------------------------------
library(rgeopat2)




## the end --------------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)
