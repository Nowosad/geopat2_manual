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
system("gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid200 -z 200 -f 200")

## new grids ------------------------------------------------------------------
header_filepath = "Augusta2011_grid100.hdr"
my_grid = gpat_gridcreate(header_filepath)
my_grid_brick = gpat_gridcreate(header_filepath, brick = TRUE)

header_filepath200 = "Augusta2011_grid200.hdr"
my_grid200 = gpat_gridcreate(header_filepath200)

detach(package:ggplot2)
augusta1 = levelplot(augusta2011, col.regions=lc_colors$hex, margin=FALSE,
                       xlab=NULL, ylab=NULL, colorkey=FALSE, scales=list(draw=FALSE),
                       main = "The rectangular grid topology (size and shift: 100)")

augusta2 = levelplot(augusta2011, col.regions=lc_colors$hex, margin=FALSE,
                     xlab=NULL, ylab=NULL, colorkey=FALSE, scales=list(draw=FALSE),
                     main = "The brick wall topology (size and shift: 100)")

augusta3 = levelplot(augusta2011, col.regions=lc_colors$hex, margin=FALSE,
                     xlab=NULL, ylab=NULL, colorkey=FALSE, scales=list(draw=FALSE),
                     main = "The rectangular grid topology (size and shift: 200)")

grid1plot = augusta1 + 
        layer(sp.polygons(as(my_grid, "Spatial"), lwd=4, col='black'))
grid1plot

grid2plot = augusta2 + 
        layer(sp.polygons(as(my_grid_brick, "Spatial"), lwd=4, col='black'))
grid2plot

grid3plot = augusta3 + 
        layer(sp.polygons(as(my_grid200, "Spatial"), lwd=4, col='black'))
grid3plot

library(gridExtra)
grid_plot = arrangeGrob(grid1plot, grid2plot, grid3plot, ncol = 1)

ggsave("../figs/topology.png", grid_plot, width = 6.44, height = 7.85)
## the end --------------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)
