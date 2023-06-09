function output = encryption(name)
 
    gray_image=imread('C:\Users\Sean\Desktop\vscode\project\image\gray\'+name+'.png');
    [M,N] = size(gray_image);
  
    x0=0.13242432454765768567975187936712983;

    %row
    colon_row_x0_tmep=zeros(N-1,M);
    
    for i=2:N
        for j=1:M
            x0=4*x0*(1-x0);
            l=mod(x0*10^14,M);
            if l==0
                l=l+1;
            end
            l_int=ceil(l);           
            colon_row_x0_tmep(i-1,j)=l_int;
            gray_image([j;l_int],i) = gray_image([l_int;j],i);      
        end
    end
    
    %colon
    row_colon_x0_tmep=zeros(M-1,N);
    for i=2:M
        for j=1:N
            x0=4*x0*(1-x0);
            l=mod(x0*10^14,N);
            if l==0
                l=l+1;
            end
            l_int=ceil(l);           
            row_colon_x0_tmep(i-1,j)=l_int;
            gray_image(i,[j;l_int]) = gray_image(i,[l_int;j]);      
        end
    end  

    %固定值
    a=36;
    b=3;
    c=28;
    d=-16;
    k=0.2;     %-0.7~0.7
    
    %初始值
    x1=0.000353454333;
    x2=0.0005345300033;
    x3=0.00534543033; 
    x4=0.00005435033;           %初始值
    initial=[x1 x2 x3 x4];      %初始值寫成矩陣
    n0=3000;                    %迭代次數
    
    %algorithm
    N=(N/3)-1;
    cycle=1;
    for i= 1:M
        for j= 0:N
            %迭代 
            if cycle<n0
                for cycle=1:n0
                    f = @(t,x) [a*(x(2)-x(1));-x(1)*x(3)+d*x(1)+c*x(2)-x(4);x(1)*x(2)-b*x(3);x(1)+k]; %混沌系統方程式
                    ts=1; span=[0,ts];            %迭代時間
                    [~,xa]=ode45(f,span,initial);
                    [o,~]=size(xa);
                    x1=xa(o,1);
                    x2=xa(o,2);
                    x3=xa(o,3);
                    x4=xa(o,4);
                    initial=[x1 x2 x3 x4];        %需要重新定義
                end
            end
    
            %ode45
            [~,xa]=ode45(f,span,initial);
            [o,~]=size(xa);
            x1=xa(o,1);
            x2=xa(o,2);
            x3=xa(o,3);
            x4=xa(o,4);
            initial=[x1 x2 x3 x4];
            
            x1_new=x1;
            x2_new=x2;
            x3_new=x3;
            x4_new=x4;  
    
            l=minus(abs(x1_new),floor(abs(x1_new)));
            x1_new = mod(l*10^14,256);
            x1_new =floor(x1_new);
            l=minus(abs(x2_new),floor(abs(x2_new)));
            x2_new = mod(l*10^14,256);
            x2_new =floor(x2_new);
            l=minus(abs(x3_new),floor(abs(x3_new)));
            x3_new = mod(l*10^14,256);
            x3_new =floor(x3_new);
            l=minus(abs(x4_new),floor(abs(x4_new)));
            x4_new = mod(l*10^14,256);
            x4_new =floor(x4_new);
                    
            %select
            x1_bar=mod(x1_new,4);
            select=[x1_new x2_new x4_new;x1_new x2_new x3_new;x1_new x3_new x4_new;x2_new x3_new x4_new];
            if x1_bar==0
                temp=zeros(1,3);
                temp(1,:)=select(1,:);
            elseif x1_bar==1
                temp=zeros(1,3);
                temp(1,:)=select(2,:);
            elseif x1_bar==2
                temp=zeros(1,3);
                temp(1,:)=select(3,:);
            elseif x1_bar==3
                temp=zeros(1,3);
                temp(1,:)=select(4,:);
            end
            
            %xor
            gray_image(i,3*j+1)=bitxor(gray_image(i,3*j+1),temp(1,1));
            gray_image(i,3*j+2)=bitxor(gray_image(i,3*j+2),temp(1,2));
            gray_image(i,3*j+3)=bitxor(gray_image(i,3*j+3),temp(1,3));
        end
    end

    save("C:\Users\Sean\Desktop\vscode\project\image\key\"+ name +".mat","row_colon_x0_tmep","colon_row_x0_tmep");

    imwrite(gray_image,'C:\Users\Sean\Desktop\vscode\project\image\encryption\'+name+'.png');

    output="Encryption working";

end