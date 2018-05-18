library(tidyverse)
library(sf)
library(raster)
library(rasterVis)

## files prep ----------------------------------------------------------------
dir.create("tmp")
file.copy(from = "data/Augusta2011.tif", to = "tmp")
file.copy(from = "data/nlcd_colors.txt", to = "tmp")

setwd("tmp/")

## the code ------------------------------------------------------------------
system("gpat_gridhis -i Augusta2011.tif -o Augusta2011_grid100 -z 100 -f 100 -n none -s ent")
system("gpat_grd2txt -i Augusta2011_grid100 -o Augusta2011_grid100.txt")

grid100 = read_lines("Augusta2011_grid100.txt")

header_remover = function(x){
        new_vector = x %>% 
                gsub("(?<=\\[)(.*)(?=>)", "", ., perl = TRUE) %>% 
                gsub("\\[> ", "", ., perl = TRUE)
}

grid100 %>% map(~header_remover(.)) %>% 
        flatten() %>% 
        write_lines(., "Augusta2011_grid100c.txt")

grid100c = read_csv("Augusta2011_grid100c.txt", col_names = FALSE)

## the end --------------------------------------------------------------------
setwd("..")
unlink("tmp", recursive = TRUE, force = TRUE)

