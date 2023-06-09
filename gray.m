function output = gray(name)

    image = imread('C:\Users\Sean\Desktop\vscode\project\image\image\'+name+'.png');

    gray_image=rgb2gray(image); %transfer to gray photo

    imwrite(gray_image, 'C:\Users\Sean\Desktop\vscode\project\image\gray\'+name+'.png');
    
    output='Gray Transfer';
   
end