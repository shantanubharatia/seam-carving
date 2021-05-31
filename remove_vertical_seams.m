%Code for removing vertical seams (width reduction)

clc
clear all

img1=imread('charles_original.png');
img2=rgb2gray(img1);

% E=diff(img2);
% M=cost(E);
% [Xcoor,Ycoor]=min_detection(M);
% img_col_rem=remove(img1, Xcoor, Ycoor);
% img_gray=rgb2gray(img_col_rem)

img_gray=img2;
img_col_rem=img1;

%FOR REMOVING 100 COLUMNS
for i=1:100
    display(i);
    E=diff(img_gray);
    M=cost(E);
    [Xcoor,Ycoor]=min_detection(M);
    img_col_rem=remove(img_col_rem, Xcoor, Ycoor);
    img_gray=rgb2gray(img_col_rem);
end

imshow(img1);
figure;
imshow(img_col_rem);

function Y=diff(img_input)
    img=double(img_input);
    img3=zeros(size(img, 1), size(img, 2));
    for i=1:size(img, 1)-1
        for j=1:size(img, 2)-1
            img3(i,j)=abs(img(i,j)-img(i+1,j))+abs(img(i,j)-img(i, j+1));
        end
    end
    img3(size(img, 1), :)=img3(size(img, 1)-1, :);
    img3(:, size(img, 2))=img3(:, size(img, 2)-1);
    Y=uint8(img3);
end

function Y=cost(f)
    e=double(f);
    Y = zeros(size(e, 1), size(e, 2));
    for i=1:size(e, 1)
        for j=1:size(e, 2)
            if(i==1)
                Y(i,j)=e(i,j);
            elseif(j==1)
                Y(i,j)=e(i,j) + min([Y(i-1,j),Y(i-1,j+1)]);
            elseif(j==size(e,2))
                Y(i,j)=e(i,j) + min([Y(i-1,j-1),Y(i-1,j)]);
            else
                Y(i,j)=e(i,j) + min([Y(i-1,j-1),Y(i-1,j),Y(i-1,j+1)]);
            end
        end
    end
end

function [X, Y] = min_detection(M)
    Xcoor=[];
    Ycoor=[];
    
    minimum=min(M(size(M, 1), :));
    index=find(M(size(M,1),:)==minimum);
    index=index(1);
    Xcoor=[Xcoor size(M,1)];
    Ycoor=[Ycoor index];
    for i=size(M,1)-1:-1:1
        if(index==1)
            minimum2=min([M(i, index), M(i, index+1)]);
            if (minimum2==M(i, index))
                index=index;
                Xcoor=[Xcoor i];
                Ycoor=[Ycoor index];
            else
                index=index+1;
                Xcoor=[Xcoor i];
                Ycoor=[Ycoor index];
            end
        elseif(index==size(M,2))
            minimum2=min([M(i, index-1), M(i, index)]);
            if(minimum2==M(i, index-1))
                index=index-1;
                Xcoor=[Xcoor i];
                Ycoor=[Ycoor index];
            elseif (minimum2==M(i, index))
                index=index;
                Xcoor=[Xcoor i];
                Ycoor=[Ycoor index];
            end
        else
            minimum2=min([M(i, index-1), M(i, index), M(i, index+1)]);
            if(minimum2==M(i, index-1))
                index=index-1;
                Xcoor=[Xcoor i];
                Ycoor=[Ycoor index];
            elseif (minimum2==M(i, index))
                index=index;
                Xcoor=[Xcoor i];
                Ycoor=[Ycoor index];
            else
                index=index+1;
                Xcoor=[Xcoor i];
                Ycoor=[Ycoor index];
            end
        end
    end
    X=Xcoor;
    Y=Ycoor;
end

function img_final = remove (img, X, Y)
    for i=size(img, 1):-1:1
       temp1=img(i, :, 1);
       temp2=img(i, :, 2);
       temp3=img(i, :, 3);
       temp1(Y(size(img,1)+1-i))=[];
       temp2(Y(size(img,1)+1-i))=[];
       temp3(Y(size(img,1)+1-i))=[];    
       img_final(i, :, 1)=temp1;
       img_final(i, :, 2)=temp2;
       img_final(i, :, 3)=temp3;
    end
end
