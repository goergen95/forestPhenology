compileCNN = function(input_shape, res, n_vars, n_class){

model = keras::keras_model_sequential()

model %>% 
  layer_reshape(input_shape = input_shape,
                target_shape = c(res, res, n_vars)) %>%
  layer_conv_2d(filters = 64,
                kernel_size = 1,
                name = "conv1_layer1",
                activation = "relu") %>%
  layer_conv_2d(filters = 256,
                kernel_size = 3,
                name = "conv1_layer2",
                activation = "relu") %>%
  layer_conv_2d(filters = 64,
                kernel_size = 1,
                name = "conv1_layer3",
                activation = "relu")%>%
  layer_conv_2d(filters = 32,
                kernel_size = 1,
                name = "conv2_layer1",
                activation = "relu") %>%
  layer_conv_2d(filters = 128,
                kernel_size = 3,
                name = "conv2_layer2",
                activation = "relu") %>%
  layer_conv_2d(filters = 32,
                kernel_size = 1,
                name = "conv2_layer3",
                activation = "relu")%>%
  layer_dropout(0.33) %>%
  layer_max_pooling_2d(pool_size = 2, 
                       strides = 2,
                       name = "max_pool_1") %>%
  layer_conv_2d(filters = 16,
                kernel_size = 1,
                name = "conv3_layer1",
                activation = "relu") %>%
  layer_conv_2d(filters = 56,
                kernel_size = 3,
                name = "conv3_layer2",
                activation = "relu") %>%
  layer_conv_2d(filters = 16,
                kernel_size = 1,
                name = "conv3_layer4",
                activation = "relu") %>%
  layer_conv_2d(filters = 8,
                kernel_size = 1,
                name = "conv4_layer1",
                activation = "relu") %>%
  layer_conv_2d(filters = 32,
                kernel_size = 3,
                name = "conv4_layer2",
                activation = "relu") %>%
  layer_conv_2d(filters = 8,
                kernel_size = 1,
                name = "conv4_layer4",
                activation = "relu") %>%
  layer_dropout(0.33) %>%
  layer_max_pooling_2d(pool_size = 2, 
                       strides = 2,
                       name = "max_pool_2") %>%
  layer_reshape(target_shape = 32) %>%
  layer_dense(units = 16,
              activation = "relu",
              name = "dens8")%>%
  layer_dense(units = 8,
              activation = "relu",
              name = "dens9")%>%
  layer_dense(units = 4,
              activation = "relu",
              name = "dens10")%>%
  layer_dense(units = n_class,
              activation = "softmax",
              name = "output")

compile(model,loss="categorical_crossentropy",optimizer="adam",metrics="accuracy")

}



