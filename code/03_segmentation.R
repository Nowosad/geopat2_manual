library(raster)
library(rasterVis)
library(tidyverse)

## files prep ----------------------------------------------------------------
dir.create("tmp")
file.copy(from = "data/Augusta2011.tif", to = "tmp")

setwd("tmp/")

## the first figure ---------------------------------------------------------
augusta2011 = raster("Augusta2011.tif")

png("../figs/augusta2011_baseplot.png", width = 1000, height = 600)
plot(augusta2011)
dev.off()


setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)
