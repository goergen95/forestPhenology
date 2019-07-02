# functions to apply varius sampling stratgeis accross tree objects
loadandinstall = function(mypkg) {if (!is.element(mypkg, installed.packages()[,1])){install.packages(mypkg)};
  library(mypkg, character.only = TRUE)}
libs = c("rgdal","raster","rgeos","gdalUtils")
lapply(libs,loadandinstall)


# dummy variables for development only
trees = rgdal::readOGR("data/artTrees.shp")
predictors = raster::brick("data/resampled/res25.tif")
predictors = projectRaster(predictors,crs =  proj4string(trees))
category = "specID"

# function to get all pixels in tree object to data.frame
# two functionalities are implemented for the case of (non-)overlapping
# trees. If trees do not overlap, the extraction of training data is significantly
# faster
sampleAll = function(predictors,trees,overlap=FALSE,category="specID"){
  
  if (overlap){
    
    data = raster::extract(predictors,trees,na.rm=TRUE,df = TRUE)
    for (id in data$ID){
      data[which(data$ID == id),category] = trees@data[which(trees$ID == id),category] 
    }
    data  = data[,-1]
    return(data)
    
  }else{
    
    specs = unique(trees@data[,category])
    treeRas = raster::rasterize(trees,predictors,field=category)
    predictors[is.na(treeRas)] = NA
    data = na.omit(as.data.frame(predictors))
    specVals = na.omit(as.data.frame(treeRas))
    for (id in unique(specVals[,1])){
      data[which(specVals==id),category] = as.factor(specs[id])
    }
    return(data)
    
  }
}
