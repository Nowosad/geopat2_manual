library(tidyverse)
library(sf)
library(raster)
library(rasterVis)

## files prep ----------------------------------------------------------------
dir.create("tmp")
file.copy(from = "data/Augusta2011.tif", to = "tmp")
file.copy(from = "data/nlcd_colors.txt", to = "tmp")
file.copy(from = "data/geomorph.tif", to = "tmp")

setwd("tmp/")

## the first figure ---------------------------------------------------------

## the code ------------------------------------------------------------------
system("gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid100 -z 100 -f 100")
system("gpat_gridhis -i geomorph.tif -o geomorph_grid100 -z 100 -f 100")
system("gpat_segment -i Augusta2011_grid100 -i geomorph_grid100 -o multilayer_seg2.tif -v multilayer_seg2.tif.gpkg -w 2,1")
system("gpat_segquality -i Augusta2011_grid100 -s multilayer_seg2.tif -g Augusta2011_seg100_ih.tif -o Augusta2011_seg100_is.tif")
system("gpat_segquality -i geomorph_grid100 -s multilayer_seg2.tif -g geomorph_seg100_ih.tif -o geomorph_seg100_is.tif")

system("gpat_segment -i geomorph_grid100 -i Augusta2011_grid100 -o multilayer_seg3.tif -v multilayer_seg3.tif.gpkg")

## keep segmentation file --------------------------------------------------
file.copy(from = "multilayer_seg2.tif", to = "../data/")

## segmentation plot -------------------------------------------------------

## quality plots ------------------------------------------------------------


## calculation of a segmentation quality -------------------------------------
seq_qual = function(inh, ins){
        1 - (inh/ins)
}

qual = overlay(inh, ins, fun = seq_qual)

## overall quality ------------------------------------------------------------

## trim images ---------------------------------------------------------------


## the end --------------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)

