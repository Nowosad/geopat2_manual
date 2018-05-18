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

## the code ------------------------------------------------------------------
system("gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid100 -z 100 -f 100")
system.time(system("gpat_segment -i Augusta2011_grid100 -o Augusta2011_seg100.tif -v Augusta2011_seg100.gpkg --lthreshold=0.1 --uthreshold=0.3 -m jsd"))
system.time(system("gpat_segment -i Augusta2011_grid100 -o Augusta2011_seg100t.tif -v Augusta2011_seg100t.gpkg --lthreshold=0.1 --uthreshold=0.3 -m tri"))

## segmentation plot -------------------------------------------------------
segm = st_read("Augusta2011_seg100.gpkg")
segm_trian = st_read("Augusta2011_seg100t.gpkg")

detach(package:ggplot2)
raster_seg_plot = levelplot(augusta2011, col.regions=lc_colors$hex, margin=FALSE,
                            xlab=NULL, ylab=NULL, colorkey=FALSE, scales=list(draw=FALSE)) +
        layer(sp.lines(as(segm, "Spatial"), lwd=4, col='black'))

raster_seg_plot_trian = levelplot(augusta2011, col.regions=lc_colors$hex, margin=FALSE,
                            xlab=NULL, ylab=NULL, colorkey=FALSE, scales=list(draw=FALSE)) +
        layer(sp.lines(as(segm_trian, "Spatial"), lwd=4, col='black'))

raster_seg_plot
raster_seg_plot_trian

## the end --------------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)
