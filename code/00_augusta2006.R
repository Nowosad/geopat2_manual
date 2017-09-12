library(raster)

augusta2006_all = raster("~/Tmp/nlcd_2006_landcover_2011_edition_2014_10_10/nlcd_2006_landcover_2011_edition_2014_10_10.img")
augusta2011 = raster("data/Augusta2011.tif")

crop(augusta2006_all,
                   augusta2011,
                   filename = "data/Augusta2006.tif",
                   datatype = "INT1U")
