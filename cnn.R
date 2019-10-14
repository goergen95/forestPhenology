compileCNN = function(input_shape, res, n_vars, n_class){

model = keras::keras_model_sequential()

model %>% 
  layer_reshape(input_shape = input_shape,
                target_shape = c(res, res, n_vars)) %>%
  layer_conv_2d(filters = 32,
                kernel_size = 1,
                name = "conv1_layer1",
                activation = "relu") %>%
  layer_activation_relu(name="block1_relu1") %>%
  layer_conv_2d(filters = 32,
                kernel_size = 3,
                name = "conv1_layer2",
                activation = "relu") %>%
  layer_activation_relu(name="block1_relu2") %>%
  layer_conv_2d(filters = 32,
                kernel_size = 1,
                name = "conv1_layer3",
                activation = "relu")%>%
  layer_activation_relu(name="block1_relu3") %>%
  layer_conv_2d(filters = 16,
                kernel_size = 1,
                name = "conv2_layer1",
                activation = "relu") %>%
  layer_activation_relu(name="block1_relu4") %>%
  layer_conv_2d(filters = 16,
                kernel_size = 3,
                name = "conv2_layer2",
                activation = "relu") %>%
  layer_activation_relu(name="block1_relu5") %>%
  layer_conv_2d(filters = 16,
                kernel_size = 1,
                name = "conv2_layer3",
                activation = "relu")%>%
  layer_activation_relu(name="block1_relu6") %>%
  layer_max_pooling_2d(pool_size = 2, 
                       strides = 2,
                       name = "max_pool_1") %>%
  layer_conv_2d(filters = 8,
                kernel_size = 1,
                name = "conv3_layer1",
                activation = "relu") %>%
  layer_activation_relu(name="block1_relu7") %>%
  layer_conv_2d(filters = 8,
                kernel_size = 3,
                name = "conv3_layer2",
                activation = "relu") %>%
  layer_activation_relu(name="block1_relu8") %>%
  layer_conv_2d(filters = 8,
                kernel_size = 1,
                name = "conv3_layer4",
                activation = "relu") %>%
  layer_activation_relu(name="block1_relu9") %>%
  layer_conv_2d(filters = 4,
                kernel_size = 1,
                name = "conv4_layer1",
                activation = "relu") %>%
  layer_activation_relu(name="block1_relu10") %>%
  layer_conv_2d(filters = 4,
                kernel_size = 3,
                name = "conv4_layer2",
                activation = "relu") %>%
  layer_activation_relu(name="block1_relu11") %>%
  layer_conv_2d(filters = 4,
                kernel_size = 1,
                name = "conv4_layer4",
                activation = "relu") %>%
  layer_activation_relu(name="block1_relu12") %>%
  layer_max_pooling_2d(pool_size = 2, 
                       strides = 2,
                       name = "max_pool_2") %>%
  layer_dropout(0.5) %>%
  layer_reshape(target_shape = c(16))%>%
  layer_dense(units = n_class,
              activation = "softmax",
              name = "output")

compile(model,loss="categorical_crossentropy",optimizer="adam",metrics="accuracy")

}



