library(raster)
library(rasterVis)
library(tidyverse)

## files prep ----------------------------------------------------------------
dir.create("tmp")
file.copy(from = "data/Augusta2011.tif", to = "tmp")
file.copy(from = "data/Augusta2011_sel_points.txt", to = "tmp")

setwd("tmp/")

## create random points-cells (100) ------------------------------------------
# set.seed(2017-09-12)
# augusta2011 = raster("Augusta2011.tif")
# sampleRandom(augusta2011, size = 100, xy = TRUE) %>%
#         as_data_frame() %>%
#         select(-Augusta2011) %>% 
#         write_delim("../data/Augusta2011_sel_points.txt",
#                     delim = ",",
#                     col_names = FALSE)

## create a point map -------------------------------------------------------
# point map
sel_points = read.csv("Augusta2011_sel_points.txt", header = FALSE) 
augusta2011 = raster("Augusta2011.tif")

plot(augusta2011)
points(sel_points, pch = 20, cex = 3)

## create a distmatrix -------------------------------------------------------
system("gpat_pointshis -i Augusta2011.tif -o Augusta2011_selected.txt  -s cooc -z 50 -n pdf --xy_file=Augusta2011_sel_points.txt")
system("gpat_distmtx -i Augusta2011_selected.txt -o Augusta2011_matrix.csv")

file.copy(from = "Augusta2011_matrix.csv", to = "../data/")
## clustering ----------------------------------------------------------------
dist_matrix = read.csv("Augusta2011_matrix.csv")[, -1] %>% as.dist()
hclust_result = hclust(d = dist_matrix, method = "ward.D")
plot(hclust_result)

sel_points$class = cutree(hclust_result, 5)

## back to the map -----------------------------------------------------------
plot(augusta2011)
points(sel_points, pch = 20, cex = 3, col = sel_points$class)

## clean --------------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)
