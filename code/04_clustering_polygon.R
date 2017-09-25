library(sf)
library(raster)
library(rasterVis)
library(tidyverse)

## files prep ----------------------------------------------------------------
dir.create("tmp")
file.copy(from = "data/Augusta2011.tif", to = "tmp")
file.copy(from = "data/Augusta2011_seg100.tif", to = "tmp")
file.copy(from = "data/nlcd_colors.txt", to = "tmp")

setwd("tmp/")

## gpat clustering  prep -----------------------------------------------------
system("gpat_polygon -i Augusta2011.tif -e Augusta2011_seg100.tif -o Augusta2011_psign.txt")
system("gpat_distmtx -i Augusta2011_psign.txt -o Augusta2011_matrix_seg.csv")

## r clustering -------------------------------------------------------------
dist_matrix = read.csv("Augusta2011_matrix4.csv")[, -1] %>% as.dist()
hclust_result = hclust(d = dist_matrix, method = "ward.D")
plot(hclust_result)

## return to map -----------------------------------------------------------

## clean --------------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)
