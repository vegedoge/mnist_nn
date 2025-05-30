# Hardware CNN Design for Mnist

## 1. Build Project

```tcl
cd <your_project_folder>
cd scripts
source ./create_project.tcl

```

## 2. Project Architecture

### folders

+ mnist_nn: the folder for vivado project, not tracked by git.
+ scripts: include the script for building this vivado project.
+ source: includes design files, testbench and mem_files(weights and inputs) for the project.

### design files

+ **top.v**: the high level inter-connection for all components.
+ **conv_layer_1.v**: the convulution steps, including one sub-component for buffering, and 8 sub-components for calculation.  
  *output: 28x28x8*
+ **conv1_buf.v**: buffer for conv1. It can buffer the 3x3 window needed.
+ **conv1_calc.v**: computation unit corresponding to 8 kernels, use loaded weights to mul-add(xnor+popcount for BNN) the window input.
+ **max_pooling.v**: 2x2 maxpooling to shrink the output size.  
  *output: 14x14x8*
+ **conv_layer_2.v**: the convulution steps, including one sub-component for buffering, and 16 sub-components for calculation.  
  *output: 14x14x16*
+ **conv2_buf.v**: buffer for conv1. It can buffer the 3x3 window needed.
+ **conv2_calc_1...8.v**: 8 computation units corresponding to 8 channels, in each unit load 16 kernels weights to mul-add(xnor+popcount for BNN) the window input.  
+ **max_pooling.v**: 2x2 maxpooling to shrink the output size.  
  *output: 7x7x16*
+ **fc_layer.v**: fully connected layer, transform the 7x7x16 inputs into 10 outputs.
+ **comparator.v**: popcount comparison for the 10 output, to find the highest value as selected output.
