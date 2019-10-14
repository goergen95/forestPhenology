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

n_pixel = dim(data[[1]])[1]
n_vars = dim(data[[1]])[2]


index = caret::createDataPartition(trees@data$specID, p = 0.2)

x_training = data[c(index$Resample1)]
x_testing = data[-index$Resample1]
K = keras::backend()
x_train = lapply(x_training, unlist)
x_train = unlist(x_train)
x_train = matrix(x_train, nrow=length(index$Resample1))

y = keras::to_categorical(as.numeric(trees$specID)-1, 2)
y_training = y[index$Resample1, ]
y_testing = y[-index$Resample1, ]


history = fit(model, x_train, y_training, batch_size = 10, epochs = 300)



data = as.data.frame(data)
data = data[!is.na(data$z),]







dummy = trees_buffer@data[,c("id","specID")]
data$class = "NO"
for (i in unique(dummy$id)){
  ind = which(data$z == i)
  data$class[ind] = as.character(dummy$specID[dummy$id == i][1])
  print(i)
}

length(data$class[data$z == 4])


model = keras::keras_model_sequential()
model %>% layer_conv_2d(filters = 100,
                        input_shape = c(16, 16, 139),
                        kernel_size = 3,
                        name = "block1_conv1") %>%
  layer_activation_relu(name="block1_relu1") %>%
  layer_conv_2d(filters = 80,
                kernel_size = 3,
                name = "block_1_conv2") %>%
  layer_activation_relu(name="block1_relu2") %>%
  #layer_max_pooling_2d(strides=2,
   #                    pool_size = 5,
   #                    name="block1_max_pool1") %>%
  
  layer_conv_2d(filters = 40,
                kernel_size = 3,
                name = "block2_conv1") %>%
  layer_activation_relu(name="block2_relu1") %>%
  layer_conv_2d(filters = 20,
                kernel_size = 3,
                name = "block2_conv2") %>%
  layer_activation_relu(name="block2_relu2") %>%
  # layer_max_pooling_2d(strides=2,
  #                      pool_size = 5,
  #                      name="block2_max_pool1") %>%
  
  # exit block
  layer_global_max_pooling_2d(name="exit_max_pool") %>%
  layer_dropout(rate=0.5) %>%
  layer_dense(units = 2, activation = "softmax")

compile(model, loss="categorical_crossentropy", optimizer="adam", metrics="accuracy")

index = caret::createDataPartition(data$z, times = 1, p = 0.5)
train = data[index$Resample1,]
test = data[-index$Resample1,]


K = keras::backend()
x_train = as.matrix(data[,1:139])
#x = K$expand_dims(x_train, axis = 2L)
x_train = K$eval(x)
data$class = as.factor(data$class)
y_train = keras::to_categorical(as.numeric(data$class)-1, length(unique(data$class)))  


history = fit(model, x_train, y_train, batch_size = 10, epochs = 300)

                    