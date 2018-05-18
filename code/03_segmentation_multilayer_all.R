library(tidyverse)
library(sf)
library(raster)
library(rasterVis)

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
system("gpat_segment -i Augusta2011_grid50 -i geomorph_grid50 -o multilayer_seg1.tif -v multilayer_seg1.gpkg")
system("gpat_segquality -i Augusta2011_grid50 -s multilayer_seg1.tif -g multilayer_seg1A_ih.tif -o multilayer_seg1A_is.tif")
system("gpat_segquality -i geomorph_grid50 -s multilayer_seg1.tif -g multilayer_seg1B_ih.tif -o multilayer_seg1B_is.tif")

## keep segmentation file --------------------------------------------------
file.copy(from = "multilayer_seg1.tif", to = "../data/")

## segmentation plot -------------------------------------------------------
segm = st_read("multilayer_seg1.gpkg")
detach(package:ggplot2)
raster_seg_plot1A = levelplot(augusta2011, col.regions=lc_colors$hex, margin=FALSE,
                            xlab=NULL, ylab=NULL, colorkey=FALSE, scales=list(draw=FALSE)) +
        layer(sp.lines(as(segm, "Spatial"), lwd=4, col='black'))

raster_seg_plot1B = levelplot(geomorph, col.regions=geomorph_colors$hex, margin=FALSE,
                              xlab=NULL, ylab=NULL, colorkey=FALSE, scales=list(draw=FALSE)) +
        layer(sp.lines(as(segm, "Spatial"), lwd=4, col='black'))

png("../figs/multilayer_seg1A.png", width = 1000, height = 600)
raster_seg_plot1A
dev.off()

png("../figs/multilayer_seg1B.png", width = 1000, height = 600)
raster_seg_plot1B
dev.off()

## quality plots ------------------------------------------------------------
inh1A = raster("multilayer_seg1A_ih.tif")
ins1A = raster("multilayer_seg1A_is.tif")

inh1B = raster("multilayer_seg1B_ih.tif")
ins1B = raster("multilayer_seg1B_is.tif")

in_rasters = stack(inh1A, ins1A, inh1B, ins1B)

png("../figs/segmentation_quality_multilayer.png", width = 500, height = 700)
levelplot(in_rasters, names.attr=c("Inhomogeneity - land cover", "Isolation - land cover",
                                   "Inhomogeneity - geomorphons", "Isolation - geomorphons"))
dev.off()

## calculation of a segmentation quality -------------------------------------
seq_qual = function(inh, ins){
        1 - (inh/ins)
}

qual1A = overlay(inh1A, ins1A, fun = seq_qual)
qual1B = overlay(inh1B, ins1B, fun = seq_qual)
qual = overlay(qual1A, qual1B, fun = mean)

png("../figs/segmentation_qualityall_multilayer_landcover.png", width = 500, height = 450)
levelplot(qual1A, margin = FALSE, main = "Quality - land cover")
dev.off()

png("../figs/segmentation_qualityall_multilayer_geomorph.png", width = 500, height = 450)
levelplot(qual1B, margin = FALSE, main = "Quality")
dev.off()

png("../figs/segmentation_qualityall_multilayer.png", width = 500, height = 450)
levelplot(qual, margin = FALSE, main = "Quality")
dev.off()

## overall quality ------------------------------------------------------------
qual_seg_value = raster::extract(qual, as(segm, "Spatial"), fun = mean, df = TRUE)
mean(qual_seg_value$layer)

## trim images ---------------------------------------------------------------
system("mogrify -trim ../figs/segmentation_quality_multilayer.png")
system("mogrify -trim ../figs/segmentation_qualityall_multilayer_landcover.png")
system("mogrify -trim ../figs/segmentation_qualityall_multilayer_geomorph.png")
system("mogrify -trim ../figs/segmentation_qualityall_multilayer.png")

## the end --------------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)

