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
system("gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid100 -z 100 -f 100")
system("gpat_segment -i Augusta2011_grid100 -o Augusta2011_seg100.tif -v Augusta2011_seg100.gpkg --lthreshold=0.1 --uthreshold=0.3")
system("gpat_segquality -i Augusta2011_grid100 -s Augusta2011_seg100.tif -g Augusta2011_seg100_ih.tif -o Augusta2011_seg100_is.tif")

## keep segmentation file --------------------------------------------------
file.copy(from = "Augusta2011_seg100.tif", to = "../data/")

## segmentation plot -------------------------------------------------------
segm = st_read("Augusta2011_seg100.gpkg")
detach(package:ggplot2)
raster_seg_plot = levelplot(augusta2011, col.regions=lc_colors$hex, margin=FALSE,
                       xlab=NULL, ylab=NULL, colorkey=FALSE, scales=list(draw=FALSE)) +
        layer(sp.lines(as(segm, "Spatial"), lwd=4, col='black'))

png("../figs/augusta2011_seg.png", width = 1000, height = 600)
raster_seg_plot
dev.off()

## quality plots ------------------------------------------------------------
inh = raster("Augusta2011_seg100_ih.tif")
ins = raster("Augusta2011_seg100_is.tif")

in_rasters = stack(inh, ins)

png("../figs/segmentation_quality.png", width = 500, height = 700)
levelplot(in_rasters, names.attr=c("Inhomogeneity", "Isolation"))
dev.off()

## calculation of a segmentation quality -------------------------------------
seq_qual = function(inh, ins){
        1 - (inh/ins)
}

qual = overlay(inh, ins, fun = seq_qual)

png("../figs/segmentation_qualityall.png", width = 500, height = 450)
levelplot(qual, margin = FALSE, main = "Quality")
dev.off()

## overall quality ------------------------------------------------------------
# cellStats(qual, "mean", na.rm = TRUE)

qual_seg_value = raster::extract(qual, as(segm, "Spatial"), fun = mean, df = TRUE)
mean(qual_seg_value$layer)

## trim images ---------------------------------------------------------------
system("mogrify -trim ../figs/segmentation_qualityall.png")
system("mogrify -trim ../figs/segmentation_quality.png")

## the end --------------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)

