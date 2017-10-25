library(raster)
library(rasterVis)
library(tidyverse)
library(sf)

## create points -------------------------------------------------------------
# download.file(url = "http://download.geonames.org/export/dump/cities15000.zip",
#               destfile = "data/worldcities.zip")
# 
# unzip("data/worldcities.zip", exdir = "data")
# 
# system("cut -f2,5,6,9,15 data/cities15000.txt > data/cities_clean.txt")
# 
# world_cities = read_delim("data/cities_clean.txt", delim="\t", col_names = FALSE) %>% 
#         filter(X4 %in% c("GB", "IE")) %>% 
#         filter(X5 > 100000) %>% 
#         select(X3, X2) %>% 
#         write_csv("data/GB_cities.csv", col_names = FALSE)
        
# r = raster("data/GBmeteoSRC/GB_pr01.tif")
# plot(r)
# points(world_cities$X3, world_cities$X2)

## files prep ----------------------------------------------------------------
dir.create("tmp")
pr_files = dir("data/GBmeteoSRC/", pattern = "pr", full.names = TRUE)
file.copy(from = pr_files, to = "tmp")
file.copy(from = "data/GB_cities.csv", to = "tmp")
setwd("tmp/")

## gpat_calc ----------------------------------------------------------------
system("gpat_gridts -i GB_pr01.tif -i GB_pr02.tif -i GB_pr03.tif -i GB_pr04.tif -i GB_pr05.tif -i GB_pr06.tif -i GB_pr07.tif -i GB_pr08.tif -i GB_pr09.tif -i GB_pr10.tif -i GB_pr11.tif -i GB_pr12.tif -o GB_pr_grid -n")
system("gpat_pointsts -i GB_pr_grid -o GB_pr_points.txt --xy_file=GB_cities.csv")
system("gpat_distmtx -i GB_pr_points.txt -o GB_pr_distmat.csv -m tsEUC")

file.copy(from = "GB_pr_distmat.csv", to = "../data/")
## r clustering -------------------------------------------------------------
library(sf)
library(tmap)
library(rgeopat2)
dist_file = read.csv("GB_pr_distmat.csv")[, -1]
dist_matrix = as.dist(dist_file)
hclust_result = hclust(d = dist_matrix, method = "ward.D2")
plot(hclust_result, labels = FALSE)

sel_points = read.csv("GB_cities.csv", header = FALSE) 
sel_points$class = as.factor(cutree(hclust_result, k = 4))

sel_points_st = st_as_sf(sel_points, coords = c("V1", "V2"))

tmap_gb = tm_shape(british_isles) +
        tm_polygons() +
        tm_shape(sel_points_st) +
        tm_dots(col = "class", size = 0.25, title = "Class: ")

tmap_gb

## create a plot
png("../figs/clustering_example_motifels_ts1.png", width = 400, height = 500)
plot(hclust_result, labels=FALSE, xlab="", sub="")
rect.hclust(hclust_result, k = 4, border = "blue")
dev.off()

png("../figs/clustering_example_motifels_ts2.png", width = 400, height = 500)
tm_shape(british_isles) +
        tm_polygons() +
        tm_shape(sel_points_st) +
        tm_dots(col = "class", size = 0.25, title = "Class: ") + 
        tm_layout(frame = FALSE)
dev.off()

## clean --------------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)
