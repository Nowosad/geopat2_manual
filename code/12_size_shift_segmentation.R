library(tidyverse)
library(sf)
library(raster)
library(rasterVis)
library(rgeopat2)


## files prep ----------------------------------------------------------------
dir.create("tmp")
file.copy(from = "data/Augusta2011.tif", to = "tmp")
file.copy(from = "data/nlcd_colors.txt", to = "tmp")

setwd("tmp/")

## the first figure ---------------------------------------------------------
augusta2011 = raster("Augusta2011.tif") %>% 
        as.factor()

rat = levels(augusta2011)[[1]]
rat[["landcoveaugusta2011"]] = rat$ID
levels(augusta2011) = rat

lc_colors = read_delim('nlcd_colors.txt', col_names = FALSE, delim = " ") %>% 
        mutate(hex=rgb(X2, X3, X4, , maxColorValue = 255)) %>% 
        filter(X1 %in% rat$ID)

## the code ------------------------------------------------------------------
system("gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid100d -z 11 -f 11")
system("gpat_segment -i Augusta2011_grid100d -o Augusta2011_seg100.tif -v Augusta2011_seg100.gpkg --lthreshold=0.1 --uthreshold=0.3")
system("gpat_grd2txt -i Augusta2011_grid100d -o Augusta2011_grid100d.txt")

system("gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid100e -z 100 -f 100")
system("gpat_segment -i Augusta2011_grid100e -o Augusta2011_seg100.tif -v Augusta2011_seg100.gpkg --lthreshold=0.1 --uthreshold=0.3")
system("gpat_grd2txt -i Augusta2011_grid100e -o Augusta2011_grid100e.txt")

## segmentation plot -------------------------------------------------------
segm = st_read("Augusta2011_seg100.gpkg")
detach(package:ggplot2)
raster_seg_plot = levelplot(augusta2011, col.regions=lc_colors$hex, margin=FALSE,
                            xlab=NULL, ylab=NULL, colorkey=FALSE, scales=list(draw=FALSE)) +
        layer(sp.lines(as(segm, "Spatial"), lwd=4, col='black'))

# png("../figs/augusta2011_seg.png", width = 1000, height = 600)
raster_seg_plot
# dev.off()

## grd to text ----------------------------------------------------------------------

grd_to_txt = function(grd_path = "Augusta2011_grid100d.txt"){
        header_remover = function(x){
                new_vector = x %>% 
                        gsub("(?<=\\[)(.*)(?=>)", "", ., perl = TRUE) %>% 
                        gsub("\\[> ", "", ., perl = TRUE)
        }
        
        read_lines(grd_path) %>% map(~header_remover(.)) %>% 
                flatten() %>% 
                write_lines(., "Augusta2011_grid100c.txt")
        
        read_csv("Augusta2011_grid100c.txt", col_names = FALSE) 
}

gd = grd_to_txt("Augusta2011_grid100d.txt")
ge = grd_to_txt("Augusta2011_grid100e.txt")

## the end --------------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)

