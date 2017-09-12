library(sf)
library(raster)
library(rasterVis)
library(tidyverse)

## files prep ----------------------------------------------------------------
dir.create("tmp")
file.copy(from = "data/Augusta2011.tif", to = "tmp")
file.copy(from = "data/nlcd_colors.txt", to = "tmp")

setwd("tmp/")

## gpat clustering  prep -----------------------------------------------------
system("gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid50 -z 50 -f 50")
system("gpat_grd2txt -i Augusta2011_grid50 -o Augusta2011_grid50.txt")
system("gpat_distmtx -i Augusta2011_grid50.txt -o Augusta2011_matrix2.csv")

## r clustering -------------------------------------------------------------
dist_matrix = read.csv("Augusta2011_matrix2.csv")[, -1] %>% as.dist()
hclust_result = hclust(d = dist_matrix, method = "ward.D")
plot(hclust_result)

## return to map -----------------------------------------------------------

## clean --------------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)