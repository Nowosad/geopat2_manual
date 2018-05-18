library(tidyverse)
library(sf)
library(raster)
library(rasterVis)

## files prep ----------------------------------------------------------------
dir.create("tmp")
pr_files = dir("data/GBmeteoSRC/", pattern = "pr", full.names = TRUE)
file.copy(from = pr_files, to = "tmp")

setwd("tmp/")

## norm data ------------------------------------------------------------------
system("gpat_gridts -i GB_pr01.tif -i GB_pr02.tif -i GB_pr03.tif -i GB_pr04.tif -i GB_pr05.tif -i GB_pr06.tif -i GB_pr07.tif -i GB_pr08.tif -i GB_pr09.tif -i GB_pr10.tif -i GB_pr11.tif -i GB_pr12.tif -o GB_pr_grid -n")
system("gpat_segment -i GB_pr_grid -o GB_pr_seg.tif -v GB_pr_seg.gpkg -m tsEUC --lthreshold=0.5 --uthreshold=1")
system("gpat_segquality -i GB_pr_grid -s GB_pr_seg.tif -g GB_pr_seg_ih.tif -o GB_pr_seg_is.tif -m tsEUC")

## segmentation plot -------------------------------------------------------
segm = st_read("GB_pr_seg.gpkg")

library(tmap)
segplot = tm_shape(segm) +
        tm_polygons()

save_tmap(segplot, filename = "../figs/ts_seg.png",
          height = 500, width = 390, scale = 0.5)

## quality plots ------------------------------------------------------------
inh = raster("GB_pr_seg_ih.tif")
ins = raster("GB_pr_seg_is.tif")

in_rasters = stack(inh, ins)

png("../figs/ts_segmentation_ihis.png", width = 800, height = 300)
levelplot(in_rasters, names.attr=c("Inhomogeneity", "Isolation"))
dev.off()

## calculation of a segmentation quality -------------------------------------
seq_qual = function(inh, ins){
        1 - (inh/ins)
}

qual = overlay(inh, ins, fun = seq_qual)

png("../figs/ts_segmentation_qualityall.png", width = 500, height = 450)
levelplot(qual, margin = FALSE, main = "Quality")
dev.off()

## overall quality ------------------------------------------------------------
# cellStats(qual, "mean", na.rm = TRUE)

qual_seg_value = raster::extract(qual, as(segm, "Spatial"), fun = mean, df = TRUE)
mean(qual_seg_value$layer, na.rm = TRUE)

## image trim ----------------------------------------------------------------
system("mogrify -trim ../figs/ts_segmentation_ihis.png")
system("mogrify -trim ../figs/ts_segmentation_qualityall.png")

## the end --------------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)

