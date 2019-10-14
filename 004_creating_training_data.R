source("forestPhenology/000_setup.R")
source("forestPhenology/fun/sampleFuns.R")
#Creating training data
ncores = parallel::detectCores()-1

res = c("res5","res10","res15","res25")
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


trees = readOGR("data/trees_buffer.shp")
trees$ID = 1:length(trees)
# trees to list for parallel processing
treesLS = lapply(1:length(trees), function(x){
  y = trees[x,]
  return(y)
})

# extract data for each tree in parallel
data = parallel::mclapply(treesLS, function(x){
  tmp = crop(SES, x)
  tmp = as.data.frame(tmp)
  return(tmp)
}, mc.cores = ncores)

data2 = Matrix::

n_pixel = dim(data[[1]])[1]
n_vars = dim(data[[1]])[2]
n_class = 2
input_shape = n_pixel * n_vars
res = sqrt(n_pixel)


index = caret::createDataPartition(trees@data$specID, p = 0.5)

x_training = data[c(index$Resample1)]
x_testing = data[-index$Resample1]
K = keras::backend()
x_train = unlist(x_training)
x_train = matrix(x_train, nrow=length(index$Resample1))
x_test = unlist(x_testing)
x_test = matrix(x_test, nrow=length(trees$specID)-length(index$Resample1))

x_train = scale(x_train)
x_test = scale(x_test)



y = keras::to_categorical(as.numeric(trees$specID)-1, 2)
y_training = y[index$Resample1, ]
y_testing = y[-index$Resample1, ]


model = compileCNN(input_shape = input_shape,
                  n_vars = n_vars,
                  n_class = n_class,
                  res = res)

history = fit(model, x_train, y_training, batch_size = 10, epochs = 100)
pred = predict(model, x_test)

pred = lapply(1:nrow(pred), function(x){
  which.max(pred[x,])
})
pred = unlist(pred)
class = as.factor(c("BUR", "EIT"))
pred = class[pred]
obsv = trees$specID[-index$Resample1]

caret::confusionMatrix(pred, obsv)

data = as.data.frame(data)
data = data[!is.na(data$z),]