function output = gray(name)

    image = imread(name);

    gray_image=rgb2gray(image); %transfer to gray photo

    imwrite(gray_image, name);
    
    output='Gray Transfer';
   
end