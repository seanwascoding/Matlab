function output = colorimageencrypt(name)

    % 讀取彩色圖像
    image = imread('C:\Users\Sean\Desktop\vscode\project\image2\image\'+name+'.png');  %原始照片任何格式圖檔都可以
    format long;
    
    % 检查图像是否为 M*N*3 彩色图像
    [m, n, channels] = size(image);
    if channels ~= 3
        disp('Error: 图像不是 M*N*3 彩色图像');
        return;
    end
    
    % 分割图像为三个矩阵（通道）
    red_channel = image(:, :, 1);
    green_channel = image(:, :, 2);
    blue_channel = image(:, :, 3);
    %XL'
    Ir=red_channel;
    Ig=green_channel;
    Ib=blue_channel;
    
    %key1
    xLRold=0.312;
    xLGold=0.413;
    xLBold=0.526;
    a=3.58;
    b=0.011;
    c=0.012;
    k=14;
    %
    for i=1:m*n
        xLRnew=a*xLRold*(1-xLRold)+b*(xLGold^2)*xLRold+c*(xLBold^3);
        xLGnew=a*xLGold*(1-xLGold)+b*(xLBold^2)*xLGold+c*(xLRold^3);
        xLBnew=a*xLBold*(1-xLBold)+b*(xLRold^2)*xLBold+c*(xLGold^3);
        xLRold=xLRnew;
        xLGold=xLGnew;
        xLBold=xLBnew;
        Ir(i)=mod(round(xLRold*10^k),256);   %XLR'
        Ig(i)=mod(round(xLGold*10^k),256);   %XLG'
        Ib(i)=mod(round(xLBold*10^k),256);   %XLB'
    end
    
     XR = randi([0, 255], m,n,'uint8'); % 生成容器
     XG = randi([0, 255], m,n,'uint8'); % 生成
     XB = randi([0, 255], m,n,'uint8'); % 生成
    
    %XOR
    for i=1:m*n
        XR(i)=bitxor(red_channel(i),Ir(i));
        XG(i)=bitxor(green_channel(i),Ig(i));
        XB(i)=bitxor(blue_channel(i),Ib(i));
    end
    
    
    %step3
    
    N=ceil((m*n*3)^(1/3));
    %size1=N^3-m*n*3; %所需填充的亂數數量
    phi = randi([0, 255], N, N, N,'uint8'); % 生成N x N x N隨機矩陣
    %填充進phi這個立方體內
        j=1;
    for i=N^3-m*n+1:N^3           
        phi(i)=XR(j);
        j=j+1;
    end
        j=1;
    for i=N^3-2*m*n+1:N^3-m*n
        phi(i)=XG(j);
        j=j+1;
    end
        j=1;
    for i=N^3-3*m*n+1:N^3-2*m*n
        phi(i)=XB(j);
        j=j+1;
    end
    
    
    %key 2
    t=10;
    %step4
    ax=1;
    ay=2;
    az=3;
    bx=4;
    by=5;
    bz=6;
    A=[ax*az*by+1,az,ay+ax*az+ax*ay*az*by;bz+ax*by+ax*az*by*bz,az*bz+1,ax+ay*bz+ax*ay*by+ax*az*bz+ax*ay*az*by*bz;by+ax*bx*by,bx,ax*bx+ay*by+ax*ay*bx*by+1];
      for i=1:N^3
        index_1D = i;
        [x, y, z] = ind2sub(size(phi), index_1D); %將phi轉為x,y,z三維度的座標
        old=[x; y; z];
        for j=1:t
        new = mod(A*old,N);
        old=new;
        end
        new=new+1;   %若出現0無法換行，加1做補償
      
            % 將三維座標（x, y, z）轉換為一維座標    %here
            xnew=new(1);
            ynew=new(2);
            znew=new(3);
            %{
            if xnew==0||ynew==0||znew==0
                new=[1;1;1];
                xnew=new(1);
                ynew=new(2);
                znew=new(3);
            end
            %}
      index_1Ds = sub2ind(size(phi), xnew, ynew, znew);
      phi([i index_1Ds])=phi([index_1Ds i]);
     end
    
    
    %step5
    M=ceil((N*N*N/3)^(1/2));
    %size2=M*M*3-N^3;
    cuboid = randi([0, 255], M,M,3,'uint8');
    
    %從左至右，從下至上，N*N*N填充至M*M*3
        j=1;
        n1=1;
        n2=0;
    for k=1:N
      for i=M*M*3-n1*N*N+1:M*M*3-n2*N*N   
        cuboid(i)=phi(j);
        j=j+1;
      end
        n1=n1+1;
        n2=n2+1;
    end
    
    save("C:\Users\Sean\Desktop\vscode\project\image2\key\"+name,"m","n");
    imwrite(cuboid,'C:\Users\Sean\Desktop\vscode\project\image2\encryption\'+name+'.png');   %加密圖檔必須是bmp檔


    output="colorimageencrypt working";

end