library(sf)
library(raster)
library(rasterVis)
library(tidyverse)

## files prep ----------------------------------------------------------------
dir.create("tmp")
file.copy(from = "data/Augusta2011.tif", to = "tmp")
file.copy(from = "data/nlcd_colors.txt", to = "tmp")

setwd("tmp/")

# landscape indices ---------------------------------------------------------
system("gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid100 -z 100 -f 100")
system("gpat_segment -i Augusta2011_grid100 -o Augusta2011_seg100.tif -v Augusta2011_seg100.shp --lthreshold=0.1 --uthreshold=0.3 --size=100")
system("gpat_polygon -i Augusta2011.tif -e Augusta2011_seg100.tif -o Augusta2011_lind.txt -s lind -n none")
system("gpat_polygon -i Augusta2011.tif -e Augusta2011_seg100.tif -o Augusta2011_linds.txt -s linds -n none")

## clean --------------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)
