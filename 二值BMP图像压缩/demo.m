%% Initial code environment.
clear;clc;dbstop if error

%% 获取bmp图像信息
bmp_data=BMPReader("binary_image.bmp");
% bmp_data=BMPReader("BMP.bmp");
bmp_compression=BMPCompression(bmp_data);
bmp_decompression=BMPDecompression("my.mybmp");

%% 测试 解压效果
data=imread("my.bmp");
imshow(data,[]);




