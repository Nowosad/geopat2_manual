library(sf)
library(raster)
library(rasterVis)
library(tidyverse)

## files prep ----------------------------------------------------------------
dir.create("tmp")
file.copy(from = "data/Augusta2011.tif", to = "tmp")
file.copy(from = "data/nlcd_colors.txt", to = "tmp")

setwd("tmp/")

## temp solution 2 ----------------------------------------------------------
system("gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid100 -z 100 -f 100 -s cooc")
system("gpat_segment -i Augusta2011_grid100 -o Augusta2011_seg100.tif -v Augusta2011_seg100.gpkg --lthreshold=0.1 --uthreshold=0.3")
system("gdalwarp -tr 30 30 Augusta2011_seg100.tif Augusta2011_seg100_res.tif")
system("gpat_polygon -i Augusta2011.tif -e Augusta2011_seg100_res.tif -o Augusta2011_psign.txt -s cooc")
# search
system("gpat_search -i Augusta2011_grid100 -r Augusta2011_psign.txt")

## the second figure --------------------------------------------------------
locs = stack(dir(pattern = "^[cat].*tif$"))

# png("../figs/searchhis_plot2.png", width = 500, height = 450)
levelplot(
        locs,
        margin = FALSE,
        xlab = NULL,
        ylab = NULL,
        scales = list(draw = FALSE)
)
# dev.off()

## trim images --------------------------------------------------------------
# system("mogrify -trim ../figs/searchhis_plot2.png")

# gpat_pointsts -i grid -o query_signatures.txt --xy_file=coordinates.txt

## clean ---------------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)

