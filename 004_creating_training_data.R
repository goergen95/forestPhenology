#Creating training data
RGB = raster::stack(list.files("data/resampled", pattern=res[3], full.names=TRUE))
RGB_names = readRDS("data/resampled/names_RGB_stack.rds")
names(RGB) = RGB_names

IND = raster::stack(list.files("data/indices", pattern=res[3], full.names=TRUE))
IND_names = readRDS("data/indices/names_indices_stack.rds")
names(IND) = IND_names

SES = raster::stack(list.files("data/season", pattern=res[3], full.names=TRUE))
SES_names = readRDS("data/season/season_names.rds")
names(SES) = SES_names

predictors = stack(RGB,IND,SES)

data  = sampleAll(predictors, trees, overlap=TRUE,category="specID")
data2 = sampleAll(predictors,trees,overlap=FALSE,category="specID")
data3 = sampleRand(predictors=predictors,trees=trees,objectbased=FALSE,category="specID",nPix=1000,res=0.12)
data4 = sampleRand(predictors,trees,objectbase=TRUE,category="specID",nPix=50,res=0.12)