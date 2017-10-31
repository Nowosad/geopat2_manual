library(rgeopat2)
library(sf)
library(tidyverse)

test_grid = function(x1, y1, x2, y2, n_cols, n_rows, brick = FALSE){
        single_cell_creator = function(x1, y1, x2, y2){
                list(rbind(c(x1, y1), c(x1, y2), c(x2, y2), c(x2, y1), c(x1, y1)))
        }
        
        my_bb = single_cell_creator(x1, y1, x2, y2) %>%
                st_polygon() %>%
                st_sfc()
        
        my_grid = rgeopat2:::gpat_st_make_grid(my_bb,
                                    n = c(n_cols, n_rows),
                                    brick = brick)
        my_grid
}

## fig1 -------------------------------------------------------------------------
a1 = test_grid(0, 0, 2, 2, 4, 4)
a2 = test_grid(0, 0, 2, 2, 8, 8, TRUE)

png("figs/topology1.png", width = 800, height = 500)
par(mfrow=c(1, 2), mar = c(0, 0, 2, 0)) 
plot(a1, main = "Rectangular\ntopology")
plot(a2, main = "Brick\ntopology")
dev.off()

## fig2 ---------------------------------------------------------------------------
a3 = test_grid(0, 0, 2, 2, 4, 4)
a4 = test_grid(0, 0, 2, 2, 4, 4, TRUE)

png("figs/topology2.png", width = 550, height = 200)
par(mfrow=c(1, 3), adj = 0, mar = c(0, 0, 1, 0)) 
plot(a3, main = "A", lwd = 2)
plot(a3, lwd = 0.5, main = "B", adj = 0)
plot(a4, add = TRUE, lwd = 2)
plot(a4, main = "C", lwd = 2)
dev.off()


