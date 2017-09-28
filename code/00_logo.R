library(raster)
library(sf)
library(rasterVis)

## files prep ----------------------------------------------------------------
dir.create("tmp")
file.copy(from = "data/Augusta2011.tif", to = "tmp")
file.copy(from = "data/coordinates.txt", to = "tmp")
file.copy(from = "data/nlcd_colors.txt", to = "tmp")
file.copy(from = "data/Augusta2006.tif", to = "tmp")

setwd("tmp/")

# 1. searchpanel
## search his calculations --------------------------------------------------
system("gpat_gridhis -i Augusta2011.tif -o grid -s cooc -z 50 -f 50 -n pdf")
system("gpat_pointshis -i Augusta2011.tif -o query_signatures.txt -s cooc -z 50 -n pdf --xy_file=coordinates.txt")
system("gpat_search -i grid -r query_signatures.txt")
locs = stack(c("loc_00002.tif"))

searchmap = levelplot(locs, main = c("Search"), margin=FALSE,
                      xlab=NULL, ylab=NULL, scales=list(draw=FALSE),
                      colorkey = FALSE)

searchmap

# 2. change detection panel
system("gpat_gridhis -i Augusta2006.tif -o Augusta2006_grid100 -z 100 -f 100")
system("gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid100 -z 100 -f 100")
system("gpat_compare -i Augusta2006_grid100 -i Augusta2011_grid100 -o Augusta0611_compared.tif")
change_det = raster("Augusta0611_compared.tif")

changemap = levelplot(change_det, main = c("Change detection"), margin=FALSE,
                      xlab=NULL, ylab=NULL, scales=list(draw=FALSE),
                      colorkey = FALSE, par.settings=GrTheme())

changemap

# 3. segmentation panel
augusta2011 = raster("Augusta2011.tif") %>% 
        as.factor()

rat = levels(augusta2011)[[1]]
rat[["landcoveaugusta2011"]] = rat$ID
levels(augusta2011) = rat

lc_colors = readr::read_delim('nlcd_colors.txt', col_names = FALSE, delim = " ") %>% 
        dplyr::mutate(hex=rgb(X2, X3, X4, , maxColorValue = 255)) %>% 
        dplyr::filter(X1 %in% rat$ID)
system("gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid100 -z 100 -f 100")
system("gpat_segment -i Augusta2011_grid100 -o Augusta2011_seg100.tif -v Augusta2011_seg100.shp --lthreshold=0.1 --uthreshold=0.3")

segm = st_read("Augusta2011_seg100.shp")
detach(package:ggplot2)
segmentmap = levelplot(augusta2011, col.regions=lc_colors$hex, margin=FALSE,
                            xlab=NULL, ylab=NULL, colorkey=FALSE, scales=list(draw=FALSE),
                       main = "Segmentation") +
        layer(sp.lines(as(segm, "Spatial"), lwd=4, col='black'))

segmentmap

# 4. clustering panel (fake)
system("gpat_segment -i Augusta2011_grid100 -o Augusta2011_seg100.tif -v Augusta2011_seg100.shp --lthreshold=0.1 --uthreshold=0.3 --size=100")
system("gpat_polygon -i Augusta2011.tif -e Augusta2011_seg100.tif -o Augusta2011_psign.txt")
system("gpat_distmtx -i Augusta2011_psign.txt -o Augusta2011_matrix_seg.csv")

dist_matrix = read.csv("Augusta2011_matrix_seg.csv")[, -1] %>% as.dist()
hclust_result = hclust(d = dist_matrix, method = "ward.D")
plot(hclust_result)

classes_df = cutree(hclust_result, k = 4) %>% 
        data.frame(names = names(.), class = .) %>% 
        dplyr::mutate(segment_id = row_number())
classes_df
library(tidyverse)
segm2 = left_join(segm, classes_df, by = "segment_id")
segm2
plot(segm2)

segm3 = segm2 %>% 
        group_by(class) %>% 
        summarise()

detach(package:ggplot2)
clustermap = levelplot(augusta2011, col.regions=lc_colors$hex, margin=FALSE,
                       xlab=NULL, ylab=NULL, colorkey=FALSE, scales=list(draw=FALSE),
                       main = "Clustering") +
        layer(sp.polygons(as(segm3, "Spatial"), lwd=4, col='black', fill=segm3$class, alpha = 0.25))

clustermap

## merge images --------------------------------------------------------------
library(gridExtra)
allmaps = arrangeGrob(searchmap, changemap, segmentmap, clustermap)

png("../figs/logo.png", width = 877, height = 598)
plot(allmaps)
dev.off()
## trim images ---------------------------------------------------------------
system("mogrify -trim ../figs/logo.png")

## the end --------------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)
