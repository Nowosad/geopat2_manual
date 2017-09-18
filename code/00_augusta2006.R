library(raster)

augusta2006_all = raster("~/Tmp/nlcd_2006_landcover_2011_edition_2014_10_10/nlcd_2006_landcover_2011_edition_2014_10_10.img")
augusta2011 = raster("data/Augusta2011.tif")

augusta2006 = crop(augusta2006_all,
     augusta2011)

resample(augusta2006,
         augusta2011,
         method = "ngb",
         filename = "data/Augusta2006.tif",
         datatype = "INT1U", 
         overwrite = TRUE)
