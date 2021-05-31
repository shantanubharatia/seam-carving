%Algorithm for showing 1 seam

img1=imread('charles_original.png');
img3=img1;
img2=rgb2gray(img1);
for i=1:size(img2,1)
    for j=1:size(img2,2)
        if(Ycoor(i)==j)
            img3(size(img2, 1)+1-i, j, 1)=255;
            img3(size(img2, 1)+1-i, j, 2)=0;
            img3(size(img2, 1)+1-i, j, 3)=0;
        end
    end
end
figure
imshow(img3)
