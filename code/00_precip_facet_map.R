library(tidyverse)
library(raster)
library(rasterVis)
library(sf)
myTheme = rasterTheme(region = brewer.pal("Blues", n = 9))

## data prep ----------------------------------------------------------------
months_names = c("Jan", "Feb", "Mar", "Apr", "May", "Jun",
                 "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")

pr_files = dir("data/GBmeteoSRC/", pattern = "pr", full.names = TRUE)

prcp_stack = stack(pr_files)
names(prcp_stack) = months_names

gb = rnaturalearth::ne_countries(scale = 50, continent = "Europe", returnclass = "sf") %>%
        filter(admin %in% c("United Kingdom", "Ireland")) %>% 
        st_union() %>% 
        as("Spatial")

## ploter ------------------------------------------------------------------
png("figs/prcp.png", width = 600, height = 550)
levelplot(prcp_stack, par.settings = myTheme, at = seq(0, 300, 25)) +
        layer(sp.polygons(gb))
dev.off()
