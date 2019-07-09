loadandinstall = function(mypkg) {if (!is.element(mypkg, installed.packages()[,1])){install.packages(mypkg)};
  library(mypkg, character.only = TRUE)}
libs = c("rgdal","raster","stringr","rgeos")
lapply(libs,loadandinstall)

# create artificial trees
trees = rgdal::readOGR("data/trees.shp")
trees$treeID = as.factor(trees$treeID)
trees$ID = 1:length(trees)
treesBuff = rgeos::gBuffer(trees, byid=TRUE, width = 2.5)
rgdal::writeOGR(treesBuff, dsn = "data/artTrees.shp",driver="ESRI Shapefile",layer="artTrees", overwrite_layer = TRUE)





