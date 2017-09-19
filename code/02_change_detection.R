library(raster)
library(rasterVis)
library(tidyverse)

## files prep ----------------------------------------------------------------
dir.create("tmp")
file.copy(from = "data/Augusta2011.tif", to = "tmp")
file.copy(from = "data/Augusta2006.tif", to = "tmp")
file.copy(from = "data/nlcd_colors.txt", to = "tmp")

setwd("tmp/")

## create a first figure ----------------------------------------------------
# two images (2006 and 2011)

augusta2011 = raster("Augusta2011.tif") %>% 
        as.factor()

augusta2006 = raster("Augusta2006.tif") %>% 
        as.factor()

rat = levels(augusta2011)[[1]]
rat[["landcoveaugusta"]] = rat$ID

levels(augusta2011) = rat
levels(augusta2006) = rat

lc_colors = read_delim('nlcd_colors.txt', col_names = FALSE, delim = " ") %>% 
        mutate(hex=rgb(X2, X3, X4, , maxColorValue = 255)) %>% 
        filter(X1 %in% c(rat$ID))

augusta_stack = stack(augusta2006, augusta2011)

png("../figs/change_det_two_maps.png", width = 800, height = 300)
levelplot(augusta_stack, col.regions=lc_colors$hex, margin=FALSE,
          xlab=NULL, ylab=NULL, colorkey=FALSE, scales=list(draw=FALSE))
dev.off()

## calculate the change ------------------------------------------------------
system("gpat_gridhis -i Augusta2006.tif -o Augusta2006_grid50 -z 50 -f 50")
system("gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid50 -z 50 -f 50")
system("gpat_compare -i Augusta2006_grid50 -i Augusta2011_grid50 -o Augusta0611_compared.tif")

## the diff figure -----------------------------------------------------------
change_det = raster("Augusta0611_compared.tif")

png("../figs/change_det.png", width = 600, height = 450)
levelplot(change_det, margin = FALSE)
dev.off()

system("mogrify -trim ../figs/change_det.png")

## clean --------------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)
