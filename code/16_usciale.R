library(sf)
# library(tidyverse)
library(rgeopat2)
library(ggdendro)
library(raster)
library(rasterVis)

## files prep ----------------------------------------------------------------
dir.create("tmp")
file.copy(from = "data/Augusta2011.tif", to = "tmp")
file.copy(from = "data/nlcd_colors.txt", to = "tmp")

setwd("tmp/")

rotate_raster = flip(t(raster("Augusta2011.tif")), direction = 1)
writeRaster(rotate_raster, "Augusta2011t.tif", overwrite = TRUE)

## gpat clustering  prep -----------------------------------------------------
system("gpat_gridhis -i Augusta2011t.tif -o Augusta2011_grid30 -z 30 -f 30")
system("gpat_grd2txt -i Augusta2011_grid30 -o Augusta2011_grid30.txt")
system("gpat_distmtx -i Augusta2011_grid30.txt -o Augusta2011_matrix_grid.csv")

## r clustering -------------------------------------------------------------
dist_matrix = gpat_read_distmtx("Augusta2011_matrix_grid.csv")
hclust_result = hclust(d = dist_matrix, method = "ward.D2")
hclust_cut = cutree(hclust_result, 6)

dhc = as.dendrogram(hclust_result)
ddata = dendro_data(dhc, type = "rectangle")
library(ggplot2)
p = ggplot(segment(ddata)) + 
        geom_segment(aes(x = x, y = y, xend = xend, yend = yend)) + 
        coord_flip() + 
        scale_y_reverse(expand = c(0.2, 0)) + 
        theme_dendro()

png("dendro.png", width = 600, height = 700)
p
dev.off()

## return to map -----------------------------------------------------------
my_grid = gpat_create_grid("Augusta2011_grid30.hdr")
my_grid$class = hclust_cut

my_grid2 = my_grid %>% 
        dplyr::group_by(class) %>% 
        dplyr::summarise()

# augusta2011t = raster("Augusta2011t.tif") %>% 
#         as.factor()
# 
# rat = levels(augusta2011t)[[1]]
# rat[["landcoveaugusta2011"]] = rat$ID
# levels(augusta2011t) = rat
# 
# lc_colors = readr::read_delim('nlcd_colors.txt', col_names = FALSE, delim = " ") %>% 
#         dplyr::mutate(hex=rgb(X2, X3, X4, , maxColorValue = 255)) %>% 
#         dplyr::filter(X1 %in% rat$ID)
# 
# l_map = levelplot(augusta2011t, col.regions = lc_colors$hex, margin = FALSE,
#           xlab = NULL, ylab = NULL, colorkey = FALSE, scales = list(draw = FALSE),
#           main = "Clustering") +
#         layer(sp.polygons(as(my_grid2, "Spatial"), lwd = 1, col = 'black',
#                           fill = my_grid2$class, alpha = 1))

png("cluster_map.png", width = 600, height = 700)
plot(my_grid2, main = "Clusters")
dev.off()

## clean --------------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)
