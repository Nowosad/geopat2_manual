library(raster)
library(tidyverse)
library(rasterVis)
library(sf)

## files prep ----------------------------------------------------------------
dir.create("tmp")
file.copy(from = "data/Augusta2011.tif", to = "tmp")
file.copy(from = "data/coordinates.txt", to = "tmp")
file.copy(from = "data/nlcd_colors.txt", to = "tmp")

setwd("tmp/")

## the first figure ---------------------------------------------------------
coords = read.csv("coordinates.txt", header = FALSE) %>% 
        mutate(id = row_number()) %>% 
        st_as_sf(., coords = c("V1", "V2"))
augusta2011 = raster("Augusta2011.tif") %>% 
        as.factor()

rat = levels(augusta2011)[[1]]
rat[["landcoveaugusta2011"]] = rat$ID
levels(augusta2011) = rat

lc_colors = read_delim('nlcd_colors.txt', col_names = FALSE, delim = " ") %>% 
        mutate(hex=rgb(X2, X3, X4, , maxColorValue = 255)) %>% 
        filter(X1 %in% rat$ID)

detach(package:ggplot2)
raster_point_plot = levelplot(augusta2011, col.regions=lc_colors$hex, margin=FALSE,
                            xlab=NULL, ylab=NULL, colorkey=FALSE, scales=list(draw=FALSE)) +
        layer(sp.points(as(coords, "Spatial"), pch = 20, cex = 3, col = "black")) +
        layer(sp.text(coordinates(as(coords, "Spatial")), txt = coords$id, 
                      pos = 3, col="black", cex = 3))

png("../figs/searchhis_plot1.png", width = 1000, height = 600)
raster_point_plot
dev.off()

## search his calculations --------------------------------------------------
system("gpat_gridhis -i Augusta2011.tif -o grid -s fdec -z 64 -f 64 -n pdf")
system("gpat_gridhis -i Augusta2011.tif -o grid2 -s sdec -z 64 -f 64 -n pdf")
system("gpat_pointshis -i Augusta2011.tif -o query_signatures.txt -s fdec -z 64 -n pdf --xy_file=coordinates.txt")
system("gpat_pointshis -i Augusta2011.tif -o query_signatures2.txt -s sdec -z 64 -n pdf --xy_file=coordinates.txt")
system("gpat_search -i grid -r query_signatures.txt")
system("gpat_search -i grid2 -r query_signatures2.txt")

## clean ---------------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)

