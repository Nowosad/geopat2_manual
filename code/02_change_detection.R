library(raster)
library(rasterVis)
library(tidyverse)

## files prep ----------------------------------------------------------------
dir.create("tmp")
file.copy(from = "data/Augusta2011.tif", to = "tmp")
file.copy(from = "data/Augusta2006.tif", to = "tmp")

setwd("tmp/")

## create a first figure ----------------------------------------------------
# two images (2006 and 2011)

## calculate the change ------------------------------------------------------
system("gpat_gridhis -i Augusta2006.tif -o Augusta2006_grid50 -z 50 -f 50")
system("gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid50 -z 50 -f 50")
system("gpat_compare -i Augusta2006_grid50 -i Augusta2011_grid50 -o Augusta0611_compared.tif")

## the diff figure -----------------------------------------------------------
change_det = raster("Augusta0611_compared.tif")

png("../figs/change_det.png", width = 500, height = 450)
levelplot(change_det, margin = FALSE)
dev.off()

## clean --------------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)
