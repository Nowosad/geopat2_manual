library(raster)
library(rasterVis)
library(tidyverse)
library(sf)

## files prep ----------------------------------------------------------------
dir.create("tmp")
file.copy(from = "data/Augusta2011.tif", to = "tmp")

setwd("tmp/")

## the first figure ---------------------------------------------------------
augusta2011 = raster("Augusta2011.tif")

png("../figs/augusta2011_baseplot.png", width = 1000, height = 600)
plot(augusta2011)
dev.off()

## the code ------------------------------------------------------------------
system("gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid50 -z 50 -f 50")
system("gpat_segment -i Augusta2011_grid50 -o Augusta2011_seg50.tif -v Augusta2011_seg50.shp")
system("gpat_segquality -i Augusta2011_grid50 -s Augusta2011_seg50.tif -g Augusta2011_seg50_inh.tif -o Augusta2011_seg50_ins.tif")

## segmentation plot -------------------------------------------------------
segm = st_read("Augusta2011_seg50.shp")

## quality plot ------------------------------------------------------------
inh = raster("Augusta2011_seg50_inh.tif")
ins = raster("Augusta2011_seg50_ins.tif")

## calculation of a segmentation quality

## the end --------------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)
