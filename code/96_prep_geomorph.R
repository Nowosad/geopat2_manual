library(gdalUtils)

align_rasters(unaligned = "../../../data/US_geom_JJ/us_geom.tif",
              reference = "data/Augusta2011.tif",
              dstfile = "data/geomorph.tif")
