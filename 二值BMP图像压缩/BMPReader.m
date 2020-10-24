function [bmp_data]=BMPReader(strPathName)
    
    fFile = fopen(strPathName, 'rb');
    [data, count] = fread(fFile);
    %bmp 小端方式(little endian)
    nOffset=1;
    bfType=0;%424dH
    for i = 1:2
        bfType = bfType + bitshift(data(nOffset+i-1), (i-1)*8);
    end
    if bfType~=19778
        disp("error");
    end
    nOffset=nOffset+2;
    bfSize = 0;
    for i = 1:4
        bfSize = bfSize + bitshift(data(nOffset+i-1), (i-1)*8);
    end
    nOffset=nOffset+4+4;%4个保留
    bfOffBits=0;%54 即从文件头到位图数据需偏移54字节
    for i = 1:4
        bfOffBits = bfOffBits + bitshift(data(nOffset+i-1), (i-1)*8);
    end
    nOffset=nOffset+4;
    %位图信息头
    nOffset=nOffset+4;
    biWidth=0;
    for i = 1:4
        biWidth = biWidth + bitshift(data(nOffset+i-1), (i-1)*8);
    end
    nOffset=nOffset+4;
    biHeight=0;
    for i = 1:4
        biHeight = biHeight + bitshift(data(nOffset+i-1), (i-1)*8);
    end
    nOffset=nOffset+4;
    nOffset=nOffset+2;
    biBitCount=0;
    for i = 1:2
        biBitCount = biBitCount + bitshift(data(nOffset+i-1), (i-1)*8);
    end
    nOffset=nOffset+2;
    biCompression=0;
    for i = 1:4
        biCompression = biCompression + bitshift(data(nOffset+i-1), (i-1)*8);
    end
    nOffset=nOffset+4;
    biSizeImage=0;
    for i = 1:4
        biSizeImage = biSizeImage + bitshift(data(nOffset+i-1), (i-1)*8);
    end
    nOffset=nOffset+4;
    nOffset=nOffset+4;
    nOffset=nOffset+4;
    biClrUsed=0;
    for i = 1:4
        biClrUsed = biClrUsed + bitshift(data(nOffset+i-1), (i-1)*8);
    end
    nOffset=nOffset+4;
    biClrImportant=0;
    for i = 1:4
        biClrImportant = biClrImportant + bitshift(data(nOffset+i-1), (i-1)*8);
    end
    
    %% 位图信息
    if biBitCount ~=1 || biCompression ~=0 || biClrUsed ~= 0
        disp("未实现");
        return;
    end
    % 0比特填充
    %int iLineByteCnt = (((m_iImageWidth * m_iBitsPerPixel) + 31) >> 5) << 2;
    iLineByteCnt=4*ceil(((biWidth*biBitCount)/32));
    if iLineByteCnt*8==biWidth
        skip=0;
    else
        % skip = 4 - ((m_iImageWidth * m_iBitsPerPixel)>>3) & 3;
        skip =4-bitand(ceil(biWidth*biBitCount/8),3);
    end
    % 二值化
    nOffset=bfOffBits+1;
    data_dec=data(nOffset:end);
    data_bin=int2bin(data_dec);
    [m,n] = size(data_bin);
    data_bin = reshape(data_bin.',[1 m*n]);
    % 图像数据
    img_data = zeros(biHeight,biWidth);
    bitOffset=1;
    for i=1:biHeight
        for j=1:biWidth
            img_data(i,j)=data_bin(bitOffset);
            bitOffset=bitOffset+1;
        end
        bitOffset=bitOffset+skip*8;% 之前错误在-1，间隔8比特填充
    end
    
    %% bmp格式存储是从图片的下到上
    img_data=flipud(img_data);
    imshow(img_data, []);
    bmp_data=cell(1,1);
    bmp_data{1}.bfOffBits=bfOffBits;
    bmp_data{1}.bfSize=bfSize;
    bmp_data{1}.bfType=bfType;
    bmp_data{1}.biBitCount=biBitCount;
    bmp_data{1}.biCompression=biCompression;
    bmp_data{1}.biHeight=biHeight;
    bmp_data{1}.biWidth=biWidth;
    bmp_data{1}.img_data=img_data;
    bmp_data{1}.biSizeImage=biSizeImage;
    bmp_data{1}.iLineByteCnt=iLineByteCnt;
    bmp_data{1}.skip=skip;
    bmp_data{1}.data=data;
    bmp_data{1}.data_bin=data_bin;
    %close file
    fclose(fFile);
end
