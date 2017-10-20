st_make_geopat_grid = function (x,
          cellsize = c(diff(st_bbox(x)[c(1, 3)]), 
                          diff(st_bbox(x)[c(2,4)]))/n, 
          offset = st_bbox(x)[c(1,4)], 
          n = c(10, 10)) {

        bb = st_bbox(x)
        n = rep(n, length.out = 2)
        nx = n[1]
        ny = n[2]
        xc = seq(offset[1], bb[3], length.out = nx + 1)
        yc = seq(offset[2], bb[2], length.out = ny + 1)

        ret = vector("list", nx * ny)
        square = function(x1, y1, x2, y2){
                st_polygon(list(matrix(c(x1, x2, x2, x1, x1, y1, y1, y2, y2, y1), 5)))  
        } 
        for (i in 1:nx) {
                for (j in 1:ny) {
                        ret[[(j - 1) * nx + i]] = square(xc[i], yc[j], xc[i + 1], yc[j + 1])
                }
        }

        st_sfc(ret, crs = st_crs(x))
}

## code test ---------------------------------------------------------------------
# library(sf)
# nc = st_read(system.file("shape/nc.shp", package="sf"))
# 
# my_grid = st_make_geopat_grid(nc) %>% 
#         st_as_sf(data.frame(id = 1:100), .)
# 
# grid_centroids = st_centroid(my_grid) %>% 
#         st_coordinates(grid_centroids) %>% 
#         as_data_frame() %>% 
#         mutate(id = 1:100)
# 
# ggplot() +
#         geom_sf(data = my_grid) + 
#         geom_text(data = grid_centroids, aes(x = X, y = Y, label = id)) + 
#         theme_void()

