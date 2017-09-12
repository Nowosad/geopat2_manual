library(tidyverse)
library(sf)
library(raster)
library(rasterVis)

## files prep ----------------------------------------------------------------
dir.create("tmp")
file.copy(from = "data/Augusta2011.tif", to = "tmp")
file.copy(from = "data/nlcd_colors.txt", to = "tmp")

setwd("tmp/")

## the first figure ---------------------------------------------------------
augusta2011 = raster("Augusta2011.tif") %>% 
        as.factor()

rat = levels(augusta2011)[[1]]
rat[["landcoveaugusta2011"]] = rat$ID
levels(augusta2011) = rat

lc_colors = read_delim('nlcd_colors.txt', col_names = FALSE, delim = " ") %>% 
        mutate(hex=rgb(X2, X3, X4, , maxColorValue = 255)) %>% 
        filter(X1 %in% rat$ID)

png("../figs/augusta2011_baseplot.png", width = 1000, height = 600)
plot(augusta2011)
dev.off()

## the code ------------------------------------------------------------------
system("gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid50 -z 50 -f 50")
system("gpat_segment -i Augusta2011_grid50 -o Augusta2011_seg50.tif -v Augusta2011_seg50.shp --lthreshold=0.12 --uthreshold=0.35")
system("gpat_segquality -i Augusta2011_grid50 -s Augusta2011_seg50.tif -g Augusta2011_seg50_inh.tif -o Augusta2011_seg50_ins.tif")

## keep segmentation file --------------------------------------------------
file.copy(from = "Augusta2011_seg50.tif", to = "../data/")

## segmentation plot -------------------------------------------------------
segm = st_read("Augusta2011_seg50.shp")
raster_seg_plot = levelplot(augusta2011, col.regions=lc_colors$hex, margin=FALSE,
                       xlab=NULL, ylab=NULL, colorkey=FALSE, scales=list(draw=FALSE)) +
        layer(sp.lines(as(segm, "Spatial"), lwd=4, col='black'))
raster_seg_plot

## quality plots ------------------------------------------------------------
inh = raster("Augusta2011_seg50_inh.tif")
ins = raster("Augusta2011_seg50_ins.tif")

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
