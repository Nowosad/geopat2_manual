library(tidyverse)
library(sf)
library(raster)
library(rasterVis)
library(gridExtra)

## files prep ----------------------------------------------------------------
dir.create("tmp")
file.copy(from = "data/Augusta2011.tif", to = "tmp")
file.copy(from = "data/nlcd_colors.txt", to = "tmp")
file.copy(from = "data/geomorph.tif", to = "tmp")
file.copy(from = "data/geomorph_colors.txt", to = "tmp")

setwd("tmp/")

## the second figure ---------------------------------------------------------
geomorph = raster("geomorph.tif") %>% 
        as.factor()

rat = levels(geomorph)[[1]]
rat[["geomorph"]] = rat$ID
levels(geomorph) = rat

geomorph_colors = read_delim('geomorph_colors.txt', col_names = FALSE, delim = " ") %>% 
        mutate(hex=rgb(X2, X3, X4, , maxColorValue = 255)) %>% 
        filter(X1 %in% rat$ID)

png("../figs/geomorph_baseplot.png", width = 1000, height = 600)
plot(geomorph)
dev.off()

augusta2011 = raster("Augusta2011.tif") %>% 
        as.factor()

rat = levels(augusta2011)[[1]]
rat[["landcoveaugusta2011"]] = rat$ID
levels(augusta2011) = rat

lc_colors = read_delim('nlcd_colors.txt', col_names = FALSE, delim = " ") %>% 
        mutate(hex=rgb(X2, X3, X4, , maxColorValue = 255)) %>% 
        filter(X1 %in% rat$ID)

## the code ------------------------------------------------------------------
system("gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid50 -z 50 -f 50")
system("gpat_gridhis -i geomorph.tif -o geomorph_grid50 -z 50 -f 50")
system("gpat_segment -i Augusta2011_grid50 -i geomorph_grid50 -o multilayer_seg2.tif -v multilayer_seg2.gpkg -w 2,1")
system("gpat_segquality -i Augusta2011_grid50 -s multilayer_seg2.tif -g multilayer_seg2A_ih.tif -o multilayer_seg2A_is.tif")
system("gpat_segquality -i geomorph_grid50 -s multilayer_seg2.tif -g multilayer_seg2B_ih.tif -o multilayer_seg2B_is.tif")

## keep segmentation file --------------------------------------------------
file.copy(from = "multilayer_seg2.tif", to = "../data/", overwrite = TRUE)

## segmentation plot -------------------------------------------------------
segm = st_read("multilayer_seg2.gpkg")
detach(package:ggplot2)
raster_seg_plot2A = levelplot(augusta2011, col.regions=lc_colors$hex, margin=FALSE,
                            xlab=NULL, ylab=NULL, colorkey=FALSE, scales=list(draw=FALSE)) +
        layer(sp.lines(as(segm, "Spatial"), lwd=4, col='black'))

raster_seg_plot2B = levelplot(geomorph, col.regions=geomorph_colors$hex, margin=FALSE,
                              xlab=NULL, ylab=NULL, colorkey=FALSE, scales=list(draw=FALSE)) +
        layer(sp.lines(as(segm, "Spatial"), lwd=4, col='black'))

png("../figs/multilayer_seg2AB.png", width = 1000, height = 600)
grid.arrange(raster_seg_plot2A, raster_seg_plot2B, ncol = 2)
dev.off()

## quality plots ------------------------------------------------------------
inh2A = raster("multilayer_seg2A_ih.tif")
ins2A = raster("multilayer_seg2A_is.tif")

inh2B = raster("multilayer_seg2B_ih.tif")
ins2B = raster("multilayer_seg2B_is.tif")

in_rasters = stack(inh2A, ins2A, inh2B, ins2B)

png("../figs/segmentation_quality_multilayer2.png", width = 500, height = 700)
levelplot(in_rasters, names.attr=c("Inhomogeneity - land cover", "Isolation - land cover",
                                   "Inhomogeneity - geomorphons", "Isolation - geomorphons"))
dev.off()

## calculation of a segmentation quality -------------------------------------
seq_qual = function(inh, ins){
        1 - (inh/ins)
}

qual2A = overlay(inh2A, ins2A, fun = seq_qual)
qual2B = overlay(inh2B, ins2B, fun = seq_qual)
qual = overlay(qual2A, qual2B, fun = mean)

qual2A_fig = levelplot(qual2A, margin = FALSE, main = "Quality - land cover")
qual2B_fig = levelplot(qual2B, margin = FALSE, main = "Quality - geomorphons")
qual_fig = levelplot(qual, margin = FALSE, main = "Quality")

png("../figs/segmentation_qualityall_multilayer2.png", width = 500, height = 450)
grid.arrange(qual2A_fig, qual2B_fig, qual_fig, ncol = 1)
dev.off()

## overall quality ------------------------------------------------------------
qual_seg_value = raster::extract(qual, as(segm, "Spatial"), fun = mean, df = TRUE)
mean(qual_seg_value$layer)
# 0.7271008

## trim images ---------------------------------------------------------------
system("mogrify -trim ../figs/multilayer_seg2AB.png")
system("mogrify -trim ../figs/segmentation_quality_multilayer2.png")
system("mogrify -trim ../figs/segmentation_qualityall_multilayer2.png")

## the end --------------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)

