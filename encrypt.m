close all;clear all;clc;
%選擇要加密圖片
image= imread('cpuinfo.png');  %讀取圖片

%..........................加密密鑰
%混沌系統
aa=36;
bb=3;
cc=28;
dd=-16;
kk=0.2;    %(加密影響小)需在-0.7到0.7之間
%初始值
IC1=0.1; 
IC2=0.2; 
IC3=0.3;
IC4=1;    %(加密影響小)

%3DMCM映射矩陣參數
%需整數且A矩陣必須有反矩陣(A1*A5*A9+A3*A4*A8+A2*A6*A7-A3*A5*A7-A1*A6*A8-A2*A4*A9不等於0)
A1=1;
A2=1;
A3=1;
A4=1;
A5=1;
A6=2;
A7=20;
A8=25;
A9=46;
%...................................................

%.........................如果匯入圖片太大須修正尺寸
[M,N]=size(image); 
if N>13500
    % 重新排列圖片的維度
    image = permute(image, [2, 1, 3]);
    % 將圖片左右翻轉
    image = fliplr(image);
end
%.................................提取RGB灰度圖
imager = image(:,:,1);
imageg = image(:,:,2);
imageb = image(:,:,3);
[M,N]=size(imager);         %將圖片大小存至變數M列、N行

%................................ 找出M與N公因數
if N > M
    smaller_num = M;
else
    smaller_num = N;
end

common_factors = [];
for i = 1:smaller_num
    if rem(N, i) == 0 && rem(M, i) == 0
        common_factors = [common_factors, i];
    end
end
nn=floor((3*M*N)^(1/3));
cf=[];
length(common_factors)

for i=1:1:length(common_factors)
    if common_factors(i)<=nn
        cf(i)=common_factors(i);
    end
end
%disp(cf)
n=max(cf)    %求n (n為最大公因數且小於nn)
m=(3*M*N)/(n^2)   %求m (m為n*n大小矩陣之數量)

% 將大矩陣切成小矩陣，以n*n大小唯一單位切割
index = 1;
for x=1:1:3
    if x==1
        a=imager;
    elseif x==2
        a=imageg;
    else
        a=imageb;
    end
    for i = 1:n:M
        for j = 1:n:N
            sub_matrix = a(i:i+n-1, j:j+n-1);
            B( :, :,index) = sub_matrix;
            index = index + 1;
        end
    end
end
index=index-1;

%.........................................渾沌系統
u=1; %混沌系統第u個row數
initial_L=[IC1 IC2 IC3 IC4]; %初始值寫成矩陣
ts=M*N/60+8000; %迭代次數

f = @(t,x) [aa*(x(2)-x(1));-x(1)*x(3)+dd*x(1)+cc*x(2);x(1)*x(2)-bb*x(3);x(1)+kk;]; %混沌系統方程式
span=[0,ts]; %迭代時間
[t,xa] = ode45(@(t,x) f(t,x), span, initial_L); %ode45解方程式
[Mxa Nxa]=size(xa);%讀取矩陣xa的大小

for i=1:3:M*N*3
    xa([u],[1])=mod((abs(xa([u],[1]))-floor(abs(xa([u],[1]))))*10^14,256);
    xa([u],[2])=mod((abs(xa([u],[2]))-floor(abs(xa([u],[2]))))*10^14,256);
    xa([u],[3])=mod((abs(xa([u],[3]))-floor(abs(xa([u],[3]))))*10^14,256);
    xa([u],[4])=mod((abs(xa([u],[4]))-floor(abs(xa([u],[4]))))*10^14,256);
    modIC1=fix(mod(xa([u],[1]),4));
    if modIC1==0
      BB=fix(xa([u],[1 2 3]));
    elseif modIC1==1
      BB=fix(xa([u],[1 2 4]));
    elseif modIC1==2
      BB=fix(xa([u],[1 3 4]));
    elseif modIC1==3
      BB=fix(xa([u],[2 3 4]));
    end
%做bitxor運算
    B(i)=bitxor(BB(1,1), B(i));
    B(i+1)=bitxor(BB(1,2),B(i+1));
    B(i+2)=bitxor(BB(1,3),B(i+2));
    u=u+1;
    if u>Mxa
        u=1;
    end
end

%.......................將n*n*m個矩陣轉成n*n*n*k大小的矩陣
k=m/n;
mm=0;
if (k == floor(k))==1    %如果k是整數，n*n*n大小的矩陣可以切k個
    sub_sub_matrices = zeros(n, n, n, k);
    for i=1:k
        sub_sub_matrices(:, :, :, i) = B(:, :, (i-1)*n+1 : i*n);
    end
else    %如果k不是整數，n*n*n大小的矩陣要切k+1個
    sub_sub_matrices = zeros(n, n, n, floor(k)+1);
    for i=1:floor(k)+1
       if i==floor(k)+1
           sub_sub_matrices(:, :, 1:mm, i) = B(:,:, (i-1)*n+1 : m);
       else
           if i==floor(k)
               mm=m-i*n;    %計算n倍數之多出行數
           end
           sub_sub_matrices(:, :, :, i) = B(:,:, (i-1)*n+1 : i*n);
       end
    end
end

%...............3DMDM加密
matrix_3DMCM=sub_sub_matrices(:, :, :, :);
A=[A1 A2 A3;A4 A5 A6;A7 A8 A9];    %映射矩陣
   for ii=1:k
        B1=sub_sub_matrices(:, :, :, ii);
        for z=1:n
            for y=1:n
                for x=1:n
                    C=int32(mod(A*[x;y;z],n))+1;
                    reg=B1(C(1),C(2),C(3));
                    B1(C(1),C(2),C(3))=B1(x,y,z);
                    B1(x,y,z)=reg;
                end
            end
        end
        matrix_3DMCM(:,:,:,ii)=B1;
    end


%...................................從n*n*n*k轉回n*n*m
k=m/n;
mm=0;
if (k == floor(k))==1    %如果k是整數，n*n*n大小的矩陣可以切k個
    nnm_matrices = zeros(n, n, m);
    for i=1:k
        nnm_matrices(:, :, (i-1)*n+1 : i*n) = matrix_3DMCM(:, :, :,i);
    end
else    %如果k不是整數，n*n*n大小的矩陣要切k+1個
    nnm_matrices = zeros(n, n, m);
    for i=1:floor(k)+1
       if i==floor(k)+1
           nnm_matrices(:, :, (i-1)*n+1:m) = matrix_3DMCM(:, :, 1:mm,i);
       else
           if i==floor(k)
               mm=m-i*n;    %計算n倍數之多出行數
           end
           nnm_matrices(:, :, (i-1)*n+1 : i*n) = matrix_3DMCM(:, :, :,i);
       end
    end
end


% 小矩陣組回大矩陣，以n*n大小唯一單位排列
index = 1;
for x=1:1:3    %從red開始排，排完後換green，最後blue
    if x==1
        a=imager;
    elseif x==2
        a=imageg;
    else
        a=imageb;
    end
    for i = 1:n:M
        for j = 1:n:N
            a(i:i+n-1, j:j+n-1)=nnm_matrices(:,:,index);
            index = index + 1;
        end
    end
    if x==1
        cimager=a;
    elseif x==2
        cimageg=a;
    else
        cimageb=a;
    end
end

%將三色灰度圖合成一個彩色圖顯示出來
colorImage = cat(3, uint8(cimager), uint8(cimageg), uint8(cimageb));
%imshow(colorImage)
% imtool(uint8(colorImage))


% figure
% subplot(2,2,1);imhist(uint8(cimager))
% subplot(2,2,2);imhist(uint8(cimageg))
% subplot(2,2,3);imhist(uint8(cimageb))


% 將加密後的圖片保存到文件
imwrite(colorImage, 'encrypted_image.png');
