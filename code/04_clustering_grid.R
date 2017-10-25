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
library(sf)
library(rgeopat2)
dist_file = read.csv("Augusta2011_matrix_grid.csv")[, -1]
dist_matrix = as.dist(dist_file)

hclust_result = hclust(d = dist_matrix, method = "ward.D2")
plot(hclust_result, labels = FALSE)
hclust_cut = cutree(hclust_result, 5)

## return to map -----------------------------------------------------------
my_grid = gpat_gridcreate("Augusta2011_grid100.hdr")
my_grid$class = hclust_cut

plot(my_grid)

## create a plot
png("../figs/clustering_example_grid1.png", width = 400, height = 300)
par(mar = c(0, 2, 1, 0))
plot(hclust_result, labels = FALSE, xlab = "", sub = "")
rect.hclust(hclust_result, k = 5, border = "blue")
dev.off()

png("../figs/clustering_example_grid2.png", width = 400, height = 300)
par(mar = c(0, 0, 1, 0))
plot(my_grid)
dev.off()

## clean --------------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)
