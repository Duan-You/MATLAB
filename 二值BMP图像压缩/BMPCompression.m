function [bmp_compression]=BMPCompression(bmp_data)
    %% 压缩
    % 压缩bmp二值图像文件原编码，产生压缩后的文件,文件后缀为.mybmp
    % 压缩data_bin中的数据
    % 压缩格式 （1标记位---0不压缩，1压缩；1数值位---0 or 1；14---数据流 or 数据个数）
    % num<=16 不压缩 15bit 存数据
    % num>16    压缩 14bit 存个数
    
    data_bin=bmp_data{1}.data_bin;
    biSizeImage=bmp_data{1}.biSizeImage;%用[m n]=size(data_bin);更具体
    compression_data=zeros(biSizeImage*8,1);%
    compression_offset=1;
    offset=1;%修改让offset指向当前
    while(offset<=biSizeImage*8)%offset够下一次计数压缩循环；2.offset超出循环条件，结束 3.offset满足循环计数，压缩时候不够长度
        num=1;
        val=data_bin(offset);
        offset=offset+1;%%
        while(offset<=biSizeImage*8 && data_bin(offset)==val && num<=2^14-1)
            num=num+1;
            offset=offset+1;
        end
        if num<=16 % num<16
            compression_data(compression_offset)=0;
            compression_offset=compression_offset+1;
            if offset>biSizeImage*8 %情况3 不会出现在 num>16 情况里
                compression_data(compression_offset : compression_offset+numel(data_bin(offset-num:end))-1)= data_bin(offset-num:end);%%;
            else
                compression_data(compression_offset : compression_offset+14)= data_bin(offset-num:offset-num+14);%%
            end
            compression_offset=compression_offset+15;
            offset=offset-num+15;
        else
            compression_data(compression_offset)=1;
            compression_offset=compression_offset+1;
            compression_data(compression_offset)=val;
            compression_offset=compression_offset+1;
            bin_num=int2bin(num);
            num_bin=numel(bin_num);
            i=0;
            while num_bin~=0
                compression_data(compression_offset+13-i)=bin_num(num_bin);
                num_bin=num_bin-1;
                i=i+1;
            end
            compression_offset=compression_offset+14;
        end
    end
    
    % 压缩结束
    compression_data=compression_data(1:compression_offset-1);
    compression_data = reshape(compression_data,8,[]);%elements are taken columnwise from X
    compression_data=compression_data.';
    [m,~]=size(compression_data);
    data_dec=zeros(m,1);
    for i=1:m
        data_dec(i)=bin2int(compression_data(i,:));
    end
    
    bfOffBits=bmp_data{1}.bfOffBits;
    data=bmp_data{1}.data;
    data=[data(1:bfOffBits);data_dec];
    compression_ratio=1-numel(data)/numel(bmp_data{1}.data);
    
    bmp_compression=cell(1,1);
    bmp_compression{1}.compression_ratio=compression_ratio;
    bmp_compression{1}.data=data;
    bmp_compression{1}.data_dec=data_dec;
    bmp_compression{1}.compression_data=compression_data;
    bmp_compression{1}.bmp_data=bmp_data;
    
    % 写文件
    fid = fopen("my.mybmp", 'w+');
    fwrite(fid,data,'uint8');
    fclose(fid);
end