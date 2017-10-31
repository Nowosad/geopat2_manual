library(tidyverse)
library(sf)
library(raster)
library(rasterVis)
library(rgeopat2)


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
system("gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid100a -z 150 -f 100")
system("gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid100b -z 100 -f 150")
system("gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid100c -z 100 -f 50")
system("gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid100d -z 100 -f 10")

### visuals -------------------------------------------------------------------
header_filepath100a = "Augusta2011_grid100a.hdr"
header_filepath100c = "Augusta2011_grid100c.hdr"
header_filepath100d = "Augusta2011_grid100d.hdr"

my_grid100a = gpat_gridcreate(header_filepath100a)
my_grid100c = gpat_gridcreate(header_filepath100c)
my_grid100d = gpat_gridcreate(header_filepath100d)

my_grid_brick100a = gpat_gridcreate(header_filepath100a, brick = TRUE)
my_grid_brick100c = gpat_gridcreate(header_filepath100c, brick = TRUE)
my_grid_brick100d = gpat_gridcreate(header_filepath100d, brick = TRUE)

detach(package:ggplot2)
augusta = levelplot(augusta2011, col.regions=lc_colors$hex, margin=FALSE,
                     xlab=NULL, ylab=NULL, colorkey=FALSE, scales=list(draw=FALSE))

augusta + layer(sp.polygons(as(my_grid100a, "Spatial"), lwd=4, col='black'))
augusta + layer(sp.polygons(as(my_grid100c, "Spatial"), lwd=4, col='black'))
augusta + layer(sp.polygons(as(my_grid100d, "Spatial"), lwd=4, col='black'))
augusta + layer(sp.polygons(as(my_grid_brick100a, "Spatial"), lwd=4, col='black'))
augusta + layer(sp.polygons(as(my_grid_brick100c, "Spatial"), lwd=4, col='black'))
augusta + layer(sp.polygons(as(my_grid_brick100d, "Spatial"), lwd=4, col='black'))

## the end --------------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)

