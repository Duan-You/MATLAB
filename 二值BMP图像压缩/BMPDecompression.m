function [bmp_decompression]=BMPDecompression(strPathName)
    
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
    nOffset=nOffset+4;
    biSizeImage=0;
    for i = 1:4
        biSizeImage = biSizeImage + bitshift(data(nOffset+i-1), (i-1)*8);
    end
    % 二值化
    nOffset=bfOffBits+1;
    data_dec=data(nOffset:end);
    data_bin=int2bin(data_dec);
    [m,n] = size(data_bin);
    data_bin = reshape(data_bin.',[1 m*n]);
    decompression_data=zeros(1,biSizeImage*8);%可能填充
    decompression_offset=1;
    for i=1:16:m*n
        if data_bin(i)==1
            val=data_bin(i+1);
            num = bin2dec(num2str(data_bin(i+2:i+15)));
            decompression_data(decompression_offset:decompression_offset+num-1)=val;
            decompression_offset=decompression_offset+num;
        else
            decompression_data(decompression_offset:decompression_offset+14)=data_bin(i+1:i+15);
            decompression_offset=decompression_offset+15;
        end
    end
    decompression_data=decompression_data(1:biSizeImage*8);
    
    % 0比特填充
    %int iLineByteCnt = (((m_iImageWidth * m_iBitsPerPixel) + 31) >> 5) << 2;
    iLineByteCnt=4*ceil(((biWidth*biBitCount)/32));
    if iLineByteCnt*8==biWidth
        skip=0;
    else
        % skip = 4 - ((m_iImageWidth * m_iBitsPerPixel)>>3) & 3;
        skip =4-bitand(ceil(biWidth*biBitCount/8),3);
    end
    
    data_bin=decompression_data;
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
    img_data=flipud(img_data);
    imshow(img_data, []);
    
    % 解压结束
    decompression_data = reshape(decompression_data,8,[]);%elements are taken columnwise from X
    decompression_data=decompression_data.';
    [m,~]=size(decompression_data);
    de_data_dec=zeros(m,1);
    for i=1:m
        de_data_dec(i)=bin2int(decompression_data(i,:));
    end
    
    bmp_decompression=cell(1,1);
    bmp_decompression{1}.decompression_data=decompression_data;
    bmp_decompression{1}.data_dec=data_dec;
    bmp_decompression{1}.data_bin=data_bin;
    bmp_decompression{1}.de_data_dec=de_data_dec;
    
    % 写文件
    data=[data(1:bfOffBits);de_data_dec];
    fid = fopen("my.bmp", 'w+');
    fwrite(fid,data,'uint8');
    fclose(fid);
    
    fclose(fFile);
end