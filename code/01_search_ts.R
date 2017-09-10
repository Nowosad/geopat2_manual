library(raster)
library(rasterVis)
library(tidyverse)

## coordinates create --------------------------------------------------------
a = osmdata::getbb("London") %>% rowMeans()
b = osmdata::getbb("Glasgow") %>% rowMeans()
c = osmdata::getbb("Cardiff") %>% rowMeans()
d = osmdata::getbb("Fort William") %>% rowMeans()
e = osmdata::getbb("Dublin") %>% rowMeans()
coordinates_gb = rbind(a, b, c, d, e) %>% as_data_frame()
write_delim(coordinates_gb, "data/coordinates_gb.txt", 
            delim = ",", col_names = FALSE)

## files prep ----------------------------------------------------------------
dir.create("tmp")
pr_files = dir("data/GBmeteoSRC/", pattern = "pr", full.names = TRUE)
file.copy(from = pr_files, to = "tmp")

file.copy(from = "data/coordinates_gb.txt", to = "tmp")

setwd("tmp/")

## the first figure ---------------------------------------------------------

## GB map with names of the selected cities


## search his calculations --------------------------------------------------
system("gpat_gridts -i GB_pr01.tif -i GB_pr02.tif -i GB_pr03.tif -i GB_pr04.tif -i GB_pr05.tif -i GB_pr06.tif -i GB_pr07.tif -i GB_pr08.tif -i GB_pr09.tif -i GB_pr10.tif -i GB_pr11.tif -i GB_pr12.tif -o GB_pr_grid -n")
system("gpat_pointsts -i GB_pr_grid -o query_signatures_ts.txt --xy_file=coordinates_gb.txt")
system("gpat_search -i GB_pr_grid -r query_signatures_ts.txt -m tsEUC")

## the second figure --------------------------------------------------------
locs = stack(c("loc_00001.tif", "loc_00002.tif", "loc_00003.tif",
               "loc_00004.tif", "loc_00005.tif"))

png("../figs/searchts_plot2.png", width = 500, height = 450)
levelplot(locs)
dev.off()

## post-clean ----------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)
