library(raster)
library(rgdal)
library(ggplot2)
library(caret)
photos = list.files("../data/",pattern=".tif",full.names = TRUE)
photos = lapply(photos,stack)
rem4=function(x){
  #remove the 4th band from each tif
  tmp=x[[-4]]
  return(tmp)
}
photos=lapply(photos, rem4)
trees = readOGR("../results/trees.shp")
trees$treeID = as.factor(trees$treeID)
trees$ID = 1:length(trees)
ext = bbox(trees)
cropTifs = function(x){
  tmp = crop(x,ext)
  return(tmp)
}
photos = lapply(photos, cropTifs)


maske = photos[[1]]
resTifs = function(x){
  tmp = resample(x,maske)
  return(tmp)
}
photos = lapply(photos,resTifs)
photos = stack(photos)


# get raster values for trees
treeRas = rasterize(trees,photos[[1]],field= "ID")
photos = stack(photos,treeRas)
treeVals = photos[!is.na(treeRas)]
green = treeVals[,seq(2,23,by=4)]
green = as.data.frame(green)
green[,"ID"] = treeVals[,26]
green$species = NA
for( id in unique(green$ID)){
  green[green$ID==id,"species"] = trees$specID[trees$ID==id]
}
class1 = colMeans(green[green$species==1,],na.rm = T) 
class2 = colMeans(green[green$species==2,],na.rm = T) 
class3 = colMeans(green[green$species==3,],na.rm = T) 
plot(class1[1:6],type = "l")
plot(class2[1:6],type = "l")
plot(class3[1:6],type = "l")
greenData = rbind(class1,class2,class3)
greenData = as.data.frame(t(greenData))[1:6,]
greenData$data = 1:6
ggplot(data=greenData)+
  geom_line(aes(x=data,y=class1,color="red"))+
  geom_line(aes(x=data,y=class2,color="blue"))+
  geom_line(aes(x=data,y=class3,color="green"))

