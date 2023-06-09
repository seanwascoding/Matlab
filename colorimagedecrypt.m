function output = colorimagedecrypt(name)

% 讀取加密圖像
cuboid = imread('C:\Users\Sean\Desktop\vscode\project\image2\encryption\'+name+'.png');
load("C:\Users\Sean\Desktop\vscode\project\image2\key\"+name+".mat","m","n");

% 分割图像为三个矩阵（通道）
red_channel = cuboid(:, :, 1);
green_channel = cuboid(:, :, 2);
blue_channel = cuboid(:, :, 3);

format long;

%
N=ceil((m*n*3)^(1/3));
%size1=N^3-m*n*3; %所需填充的亂數數量
phi = randi([0, 255], N, N, N,'uint8'); % 生成N x N x N隨機矩陣
M=ceil((N*N*N/3)^(1/2));
    j=1;
    n1=1;
    n2=0;
for k=1:N
  for i=M*M*3-n1*N*N+1:M*M*3-n2*N*N   
    phi(j)=cuboid(i);
    j=j+1;
  end
    n1=n1+1;
    n2=n2+1;
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

 for i=N^3:-1:1
    index_1D = i;
    [x, y, z] = ind2sub(size(phi), index_1D); %將phi轉為x,y,z三維度的座標
    old=[x; y; z];
    %A*old=new ,old = A \ new;
    for j=1:t
    new = mod(A*old,N);
    old=new;
    end
    new=new+1;
        % 將三維座標（x, y, z）轉換為一維座標    %here
        xnew=new(1);
        ynew=new(2);
        znew=new(3);


  index_1Ds = sub2ind(size(phi), xnew, ynew, znew);
  phi([i index_1Ds])=phi([index_1Ds i]);
 end

 XR = randi([0, 255], 1, m*n,'uint8'); % 生成容器
 XG = randi([0, 255], 1, m*n,'uint8'); % 生成
 XB = randi([0, 255], 1, m*n,'uint8'); % 生成

%step3
%size1=N^3-m*n*3; %所需填充的亂數數量
%填充進phi這個立方體內
    j=1;
for i=N^3-m*n+1:N^3      
    XR(j)=phi(i);
    j=j+1;
end
    j=1;
for i=N^3-2*m*n+1:N^3-m*n
    XG(j)=phi(i);
    j=j+1;
end
    j=1;
for i=N^3-3*m*n+1:N^3-2*m*n
    XB(j)=phi(i);
    j=j+1;
end
%
%%%%%%%%%%%%%%%555以上OK%%%%%%%%%%%%%%%%%%%

 Ir = randi([0, 255], m,n,'uint8'); % 生成容器
 Ig = randi([0, 255], m,n,'uint8'); % 生成
 Ib = randi([0, 255], m,n,'uint8'); % 生成
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
    %for j=1:m*n
    xLRnew=a*xLRold*(1-xLRold)+b*(xLGold^2)*xLRold+c*(xLBold^3);
    xLGnew=a*xLGold*(1-xLGold)+b*(xLBold^2)*xLGold+c*(xLRold^3);
    xLBnew=a*xLBold*(1-xLBold)+b*(xLRold^2)*xLBold+c*(xLGold^3);
    xLRold=xLRnew;
    xLGold=xLGnew;
    xLBold=xLBnew;
    %end
    Ir(i)=mod(round(xLRold*10^k),256);   %XLR'
    Ig(i)=mod(round(xLGold*10^k),256);   %XLG'
    Ib(i)=mod(round(xLBold*10^k),256);   %XLB'
end

 red_channel = randi([0, 255], m,n,'uint8'); % 生成容器
 green_channel = randi([0, 255], m,n,'uint8'); % 生成
 blue_channel = randi([0, 255], m,n,'uint8'); % 生成
for i=1:m*n
    red_channel(i)=bitxor(XR(i),Ir(i));
    green_channel(i)=bitxor(XG(i),Ig(i));
    blue_channel(i)=bitxor(XB(i),Ib(i));
end


combined_image = cat(3, red_channel,green_channel,blue_channel);


imwrite(combined_image,'C:\Users\Sean\Desktop\vscode\project\image2\decrypt\'+name+'.png');  %解密照片任何格式圖檔都可以


output="colorimagedecrypt working";

end