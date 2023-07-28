function output = gray(name)

    image = imread('C:\Users\Sean\Desktop\vscode\project\'+name);

    gray_image=rgb2gray(image); %transfer to gray photo

    imwrite(gray_image, 'C:\Users\Sean\Desktop\vscode\project\'+name);
    
    output='Gray Transfer';
   
end