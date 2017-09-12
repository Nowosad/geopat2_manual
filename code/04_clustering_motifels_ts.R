library(raster)
library(rasterVis)
library(tidyverse)

## clean --------------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)
