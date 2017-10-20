# grid header to grid vector
library(tidyverse)
library(sf)
library(raster)
library(rasterVis)
source("../code/99_st_make_geopat_grid.R")

## files prep ----------------------------------------------------------------
dir.create("tmp")
file.copy(from = "data/Augusta2011.tif", to = "tmp")
file.copy(from = "data/nlcd_colors.txt", to = "tmp")

setwd("tmp/")

## the code ------------------------------------------------------------------
system("gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid100 -z 100 -f 100 -n none -s ent")

## read header ---------------------------------------------------------------
header_parser = function(file_path){
        x = readLines(file_path)
        res_x = stringr::str_sub(x[5], start=6) %>% as.double()
        res_y = stringr::str_sub(x[9], start=6) %>% as.double()
        start_x = stringr::str_sub(x[4], start=6) %>% as.double()
        start_y = stringr::str_sub(x[7], start=6) %>% as.double()
        n_rows = stringr::str_sub(x[10], start=7) %>% as.integer()
        n_cols = stringr::str_sub(x[11], start=7) %>% as.integer()
        proj_4 = stringr::str_sub(x[12], start=7) %>% rgdal::showP4()
        data_frame(res_x = res_x, res_y = res_y, 
                   start_x = start_x, start_y = start_y,
                   n_rows = n_rows, n_cols = n_cols,
                   proj_4 = proj_4)
}

grid_creator = function(header){
        x1 = header$start_x
        y1 = header$start_y
        x2 = header$start_x + header$res_x * header$n_cols
        y2 = header$start_y + header$res_y * header$n_rows
        
        single_cell_creator = function(x1, y1, x2, y2){
                list(rbind(c(x1, y1), c(x1, y2), c(x2, y2), c(x2, y1), c(x1, y1)))
        }
        
        my_bb = single_cell_creator(x1, y1, x2, y2) %>% 
                st_polygon() %>% 
                st_sfc() %>% 
                st_set_crs(header$proj_4)
        
        my_grid = st_make_geopat_grid(my_bb, n = c(header$n_cols, header$n_rows))
        my_grid
}

my_grid = header_parser("Augusta2011_grid100.hdr") %>% 
        grid_creator()

# my_grid %>% st_write("lalal.gpkg", layer_options = "OVERWRITE=YES")
