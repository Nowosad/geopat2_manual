library(rgeopat2)
library(sf)
library(tidyverse)
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

## new grids ------------------------------------------------------------------
header_filepath = "Augusta2011_grid100.hdr"
my_grid = gpat_gridcreate(header_filepath)
my_grid_brick = gpat_gridcreate(header_filepath, brick = TRUE)

detach(package:ggplot2)
augusta1 = levelplot(augusta2011, col.regions=lc_colors$hex, margin=FALSE,
                       xlab=NULL, ylab=NULL, colorkey=FALSE, scales=list(draw=FALSE),
                       main = "The rectangular grid topology (size and shift: 100)")

augusta2 = levelplot(augusta2011, col.regions=lc_colors$hex, margin=FALSE,
                     xlab=NULL, ylab=NULL, colorkey=FALSE, scales=list(draw=FALSE),
                     main = "The brick wall topology (size and shift: 100)")

grid1plot = augusta1 + 
        layer(sp.polygons(as(my_grid, "Spatial"), lwd=4, col='black'))
grid1plot

grid2plot = augusta2 + 
        layer(sp.polygons(as(my_grid_brick, "Spatial"), lwd=4, col='black'))
grid2plot

## the end --------------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)