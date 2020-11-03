%% Initial code environment.
clear;clc;dbstop if error

%% 获取bmp图像信息
bmp_data=BMPReader("BMP.bmp");

%% 压缩
% 压缩bmp二值图像文件原编码，产生压缩后的文件,文件后缀为.mybmp
% 采用行程编码无损压缩：16位，第一位标记位，若为1，第二位则为数值为，之后14位为个数。
%                                       否则，2-16位为像素值。
bmp_compression=BMPCompression(bmp_data);

%% 解压
% 解压.mybmp二值图像文件，恢复.bmp图像
bmp_decompression=BMPDecompression("my.mybmp");

%% 测试 解压效果
disp("原始图像大小：(单位KB)");
disp(bmp_data{1}.bfSize/1024);
disp("压缩图像大小：(单位KB)");
disp(bmp_compression{1}.bfSize/1024);
disp(bmp_compression{1}.compression_ratio*100);
disp("图像压缩百分比");
disp(bmp_compression{1}.compression_ratio*100);
data=imread("my.bmp");
imshow(data,[]);




