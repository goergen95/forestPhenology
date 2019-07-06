# functions to apply varius sampling stratgeis accross tree objects
loadandinstall = function(mypkg) {if (!is.element(mypkg, installed.packages()[,1])){install.packages(mypkg)};
  library(mypkg, character.only = TRUE)}
libs = c("rgdal","raster","rgeos","gdalUtils","sp","magrittr")
lapply(libs,loadandinstall)


# dummy variables for development only
trees = rgdal::readOGR("data/artTrees.shp")
predictors = raster::brick("data/resampled/res25.tif")
predictors = projectRaster(predictors,crs =  proj4string(trees))
names(predictors) = readRDS("data/resampled/dates.rds") #restore tif names
category = "specID"

t <- sampleAll(predictors = predictors, trees = trees, overlap = TRUE)

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
    data$treeID  = data[,1]
    data = data[,-1]
    return(data)
    
  }else{
    
    specs = unique(trees@data[,category])
    treeRas = raster::rasterize(trees,predictors,field=category)
    names(treeRas)=category
    idRas = raster::rasterize(trees,predictors,field="ID")
    names(idRas) = "treeID"
    predictors[is.na(treeRas)] = NA
    data = na.omit(as.data.frame(predictors))
    specVals = na.omit(as.data.frame(treeRas))
    ids = na.omit(as.data.frame(idRas))
    data = cbind(data,specVals,ids)
    data[,category] = factor(data[,category],levels=unique(data[,category]),labels=levels(specs))
    return(data)
    
  }
}


sampleRand = function(predictors,trees,objectbased=TRUE,category="specID",nPix=2000,res=.25){
  
  if(!objectbased){
    
    specs = unique(trees@data[,category])
    treeRas = raster::rasterize(trees,predictors,field=category)
    treeID = raster::rasterize(trees,predictors,field="ID")
    predictors[is.na(treeRas)] = NA
    data = list()
    for (id in unique(na.omit(values(treeRas)))){
      tmpTree = treeRas
      tmpTree[tmpTree != id] = NA
      tmpPred = predictors
      tmpPred[is.na(tmpTree)] = NA
      tmpID = treeID
      tmpID[is.na(tmpTree)] = NA
      dataID = as.data.frame(sampleRandom(tmpPred,size = nPix,na.rm=TRUE,cells=TRUE))
      ID = tmpID[dataID$cell]
      dataID[,category] = specs[id]
      dataID$treeID = ID
      dataID = dataID[,-1]
      data[[id]] = dataID
    }
    data = do.call("rbind",data)
    return(data)
    
  }else{
    
    sampTree = function(object,rasters,size){
      spPoints = sp::spsample(object,n=size,type="random")
      allBuffer = rgeos::gBuffer(spPoints,byid=TRUE,width = res/2)
      
      i = 1
      while(i <= length(spPoints)){
      spBuffer = rgeos::gBuffer(spPoints[i,], byid = TRUE, width = res/2)
      issue = gIntersects(spBuffer,allBuffer,byid=TRUE)
      index = which(issue == TRUE)
      if (length(index)==1){
        i = i + 1
        next}
      index = index[-1]
      spPoints = spPoints[-index,]
      allBuffer = allBuffer[-index]
      i = i + 1
      }
      
      missing = size - length(spPoints)
      while (missing != 0){
        spAdd = sp::spsample(object,n=missing,type="random")
        spAddBuf = rgeos::gBuffer(spAdd,byid=TRUE,width=res/2)
        issue = gIntersects(spAddBuf,allBuffer,byid=TRUE)
        index = which(as.numeric(colSums(issue))>0)
        if (length(index) == 0){
          spPoints = spAdd + spPoints
          allBuffer = rgeos::gBuffer(spPoints,byid=TRUE,width = res/2)
          missing = size - length(spPoints)
        }else{
          spAdd = spAdd[-index,]
          spPoints = spAdd + spPoints
          allBuffer = rgeos::gBuffer(spPoints,byid=TRUE,width = res/2)
          missing = size - length(spPoints)
        }}
      
      
      treePixels = raster::extract(rasters,spPoints,df=TRUE,na.rm=TRUE)
      treePixels = treePixels[,-1]
      treePixels[,category] = object@data[,category]
      return(treePixels)
    }
  data = list()
  for (tree in 1:length(trees)){
    smpTree = sampTree(trees[tree,],predictors,nPix)
    smpTree$treeID = trees@data$ID[tree]
    data[[tree]] = smpTree
  }
  data = do.call("rbind",data)
  
  }
}

