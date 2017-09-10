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
system("gpat_segment -i GB_pr_grid -o GB_pr_seg.tif -v GB_pr_seg.shp -m tsEUC")
system("gpat_segquality -i GB_pr_grid -s GB_pr_seg.tif -g GB_pr_seg_inh.tif -o GB_pr_seg_ins.tif -m tsEUC")

## segmentation plot -------------------------------------------------------
segm = st_read("GB_pr_seg.shp")
segplot = tmap::qtm(segm)
segplot

## quality plots ------------------------------------------------------------
inh = raster("GB_pr_seg_inh.tif")
ins = raster("GB_pr_seg_ins.tif")

inh_plot = levelplot(inh, margin = FALSE, main = "Inhomogeneity")
inh_plot

ins_plot = levelplot(ins, margin = FALSE, main = "Isolation")
ins_plot

## calculation of a segmentation quality -------------------------------------
seq_qual = function(inh, ins){
        1 - (inh/ins)
}

qual = overlay(inh, ins, fun = seq_qual)
qual_plot = levelplot(qual, margin = FALSE, main = "Quality")
qual_plot

## overall quality ------------------------------------------------------------
cellStats(qual, "mean", na.rm = TRUE)

## the end --------------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)
