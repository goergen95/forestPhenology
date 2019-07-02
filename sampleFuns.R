# functions to apply varius sampling stratgeis accross tree objects
loadandinstall = function(mypkg) {if (!is.element(mypkg, installed.packages()[,1])){install.packages(mypkg)};
  library(mypkg, character.only = TRUE)}
libs = c("rgdal","raster","rgeos","gdalUtils")
lapply(libs,loadandinstall)


# dummy variables for development only
trees = rgdal::readOGR("data/artTrees.shp")
predictors = raster::brick("data/resampled/res25.tif")
category = "specID"

# function to get all pixels in tree object to data.frame
# two functionalities are implemented for the case of (non-)overlapping
# trees. If trees do not overlap, the extraction of training data is significantly
# faster
overlap = TRUE

if (overlap){
  data = raster::extract(predictors,trees,na.rm=TRUE)
  
}else{
  treeRas = raster::rasterize(trees,predictors,field=category)
  plot(treeRas)
}