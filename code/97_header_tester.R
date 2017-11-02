library(rgeopat2)
library(sf)
library(tidyverse)

header_filepath = system.file("rawdata/Augusta2011_grid100.hdr", package="rgeopat2")
my_grid = gpat_gridcreate(header_filepath)

grid_centroids = st_centroid(my_grid) %>%
        st_coordinates(grid_centroids) %>%
        as_data_frame() %>%
        mutate(id = seq_len(nrow(my_grid)))

ggplot() +
        geom_sf(data = my_grid) +
        geom_text(data = grid_centroids, aes(x = X, y = Y, label = id)) +
        theme_void()


my_grid_brick = gpat_gridcreate(header_filepath, brick = TRUE)

grid_centroids_brick = st_centroid(my_grid_brick) %>%
  st_coordinates(grid_centroids) %>%
  as_data_frame() %>%
  mutate(id = seq_len(nrow(my_grid_brick)))

ggplot() +
  geom_sf(data = my_grid_brick) +
  geom_text(data = grid_centroids_brick, aes(x = X, y = Y, label = id)) +
  theme_void()

