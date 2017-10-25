library(raster)
library(rasterVis)
library(tidyverse)
library(sf)
library(rnaturalearth)

## coordinates create --------------------------------------------------------
# a = osmdata::getbb("London") %>% rowMeans()
# b = osmdata::getbb("Glasgow") %>% rowMeans()
# c = osmdata::getbb("Cardiff") %>% rowMeans()
# d = osmdata::getbb("Fort William") %>% rowMeans()
# e = osmdata::getbb("Dublin") %>% rowMeans()
# coordinates_gb = rbind(a, b, c, d, e) %>% as_data_frame()
# write_delim(coordinates_gb, "data/coordinates_gb.txt",
#             delim = ",", col_names = FALSE)

## files prep ----------------------------------------------------------------
dir.create("tmp")
pr_files = dir("data/GBmeteoSRC/", pattern = "pr", full.names = TRUE)
file.copy(from = pr_files, to = "tmp")

file.copy(from = "data/coordinates_gb.txt", to = "tmp")

setwd("tmp/")

## the first figure ---------------------------------------------------------
coord_gb = read.csv("coordinates_gb.txt", header = FALSE) %>% 
        mutate(id = c("1.London", "2.Glasgow", "3.Cardiff", "4.Fort William", "5.Dublin")) %>% 
        st_as_sf(., coords = c("V1", "V2"))

europe = ne_countries(scale = 50, continent = "Europe", returnclass = "sf")
gb = europe %>% filter(admin %in% c("United Kingdom", "Ireland"))

library(tmap)
tmap_gb = tm_shape(gb) +
        tm_polygons() +
        tm_shape(coord_gb) +
        tm_dots(size = 0.25) +
        tm_text("id", auto.placement = TRUE)

save_tmap(tmap_gb, filename = "../figs/searchts_plot1.png",
          height = 600, width = 390, scale = 0.5)

## search his calculations --------------------------------------------------
system("gpat_gridts -i GB_pr01.tif -i GB_pr02.tif -i GB_pr03.tif -i GB_pr04.tif -i GB_pr05.tif -i GB_pr06.tif -i GB_pr07.tif -i GB_pr08.tif -i GB_pr09.tif -i GB_pr10.tif -i GB_pr11.tif -i GB_pr12.tif -o GB_pr_grid -n")
system("gpat_globnorm -i GB_pr_grid -o GB_pr_grid_norm")
system("gpat_pointsts -i GB_pr_grid_norm -o query_signatures_ts.txt --xy_file=coordinates_gb.txt")
system("gpat_search -i GB_pr_grid_norm -r query_signatures_ts.txt -m tsEUC")

system("gpat_gridts -i GB_pr01.tif -i GB_pr02.tif -i GB_pr03.tif -i GB_pr04.tif -i GB_pr05.tif -i GB_pr06.tif -i GB_pr07.tif -i GB_pr08.tif -i GB_pr09.tif -i GB_pr10.tif -i GB_pr11.tif -i GB_pr12.tif -o GB_pr_grid")
system("gpat_globnorm -i GB_pr_grid -o GB_pr_grid_norm")
system("gpat_pointsts -i GB_pr_grid_norm -o query_signatures_ts.txt --xy_file=coordinates_gb.txt")
system("gpat_search -i GB_pr_grid_norm -r query_signatures_ts.txt -m tsEUC")

system("gpat_gridts -i GB_pr01.tif -i GB_pr02.tif -i GB_pr03.tif -i GB_pr04.tif -i GB_pr05.tif -i GB_pr06.tif -i GB_pr07.tif -i GB_pr08.tif -i GB_pr09.tif -i GB_pr10.tif -i GB_pr11.tif -i GB_pr12.tif -o GB_pr_grid")
system("gpat_pointsts -i GB_pr_grid -o query_signatures_ts.txt --xy_file=coordinates_gb.txt")
system("gpat_search -i GB_pr_grid -r query_signatures_ts.txt -m tsEUC")

system("gpat_gridts -i GB_pr01.tif -i GB_pr02.tif -i GB_pr03.tif -i GB_pr04.tif -i GB_pr05.tif -i GB_pr06.tif -i GB_pr07.tif -i GB_pr08.tif -i GB_pr09.tif -i GB_pr10.tif -i GB_pr11.tif -i GB_pr12.tif -o GB_pr_grid -n")
system("gpat_pointsts -i GB_pr_grid -o query_signatures_ts.txt --xy_file=coordinates_gb.txt")
system("gpat_search -i GB_pr_grid -r query_signatures_ts.txt -m tsEUC")

system("gpat_gridts -i GB_pr01.tif -i GB_pr02.tif -i GB_pr03.tif -i GB_pr04.tif -i GB_pr05.tif -i GB_pr06.tif -i GB_pr07.tif -i GB_pr08.tif -i GB_pr09.tif -i GB_pr10.tif -i GB_pr11.tif -i GB_pr12.tif -o GB_pr_grid -n")
system("gpat_pointsts -i GB_pr_grid -o query_signatures_ts.txt --xy_file=coordinates_gb.txt")
system("gpat_search -i GB_pr_grid -r query_signatures_ts.txt -m euc")
#how to input two time-series at once???

## the second figure --------------------------------------------------------
locs = stack(c("loc_00001.tif", "loc_00002.tif", "loc_00003.tif",
               "loc_00004.tif", "loc_00005.tif"))

# png("../figs/searchts_plot2.png", width = 500, height = 450)
levelplot(locs, names.attr=c("1.London", "2.Glasgow", "3.Cardiff", "4.Fort William", "5.Dublin"),
          margin=FALSE, xlab=NULL, ylab=NULL, scales=list(draw=FALSE))
# dev.off()

system("mogrify -trim ../figs/searchts_plot2.png")

## post-clean ----------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)
