library(raster)
library(rasterVis)
library(tidyverse)

## files prep ----------------------------------------------------------------
dir.create("tmp")
file.copy(from = "data/Augusta2011.tif", to = "tmp")
file.copy(from = "data/coordinates.txt", to = "tmp")

setwd("tmp/")

## the first figure ---------------------------------------------------------
augusta2011 = raster("Augusta2011.tif")
coords = read.csv("coordinates.txt", header = FALSE)

png("../figs/searchhis_plot1.png", width = 1000, height = 600)
plot(augusta2011)
points(coords$V1, coords$V2, add = TRUE, cex = 2, pch = 19)
# how to add numbers
dev.off()

## search his calculations --------------------------------------------------
system("gpat_gridhis -i Augusta2011.tif -o grid -s cooc -z 50 -f 50 -n pdf")
system("gpat_pointshis -i Augusta2011.tif -o query_signatures.txt -s cooc -z 50 -n pdf --xy_file=coordinates.txt")
system("gpat_search -i grid -r query_signatures.txt")

## the second figure --------------------------------------------------------
locs = stack(c("loc_00001.tif", "loc_00002.tif", "loc_00003.tif",
               "loc_00004.tif", "loc_00005.tif"))

png("../figs/searchhis_plot2.png", width = 500, height = 450)
levelplot(locs)
dev.off()

# gpat_pointsts -i grid -o query_signatures.txt --xy_file=coordinates.txt

setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)
