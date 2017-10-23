library(sf)
library(raster)
library(rasterVis)
library(tidyverse)
library(rgeopat2)

## files prep ----------------------------------------------------------------
dir.create("tmp")
file.copy(from = "data/Augusta2011.tif", to = "tmp")
file.copy(from = "data/nlcd_colors.txt", to = "tmp")

setwd("tmp/")

## gpat clustering  prep -----------------------------------------------------
system("gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid100 -z 100 -f 100")
system("gpat_grd2txt -i Augusta2011_grid100 -o Augusta2011_grid100.txt")
system("gpat_distmtx -i Augusta2011_grid100.txt -o Augusta2011_matrix_grid.csv")

## r clustering -------------------------------------------------------------
dist_matrix = read.csv("Augusta2011_matrix_grid.csv")[, -1] %>% as.dist()
hclust_result = hclust(d = dist_matrix, method = "ward.D")
plot(hclust_result)
hclust_cut = cutree(hclust_result, 5)

## return to map -----------------------------------------------------------
my_classes = data.frame(class = hclust_cut)

my_grid = gpat_gridcreate("Augusta2011_grid100.hdr")
my_grid = st_as_sf(my_classes, my_grid)

plot(my_grid)

## clean --------------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)
