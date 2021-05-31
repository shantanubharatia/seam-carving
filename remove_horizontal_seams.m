%Code for removing horizontal seams (height reduction)

clc
clear all

img1=imread('charles_original.png');
img2=rgb2gray(img1);
% E=diff(img2);
% M=cost(E);
% [Xcoor,Ycoor]=min_detection(M);
% img_row_rem=remove(img1, Xcoor, Ycoor);
% img_gray=rgb2gray(img_row_rem)

img_gray=img2;
img_row_rem=img1;

%FOR REMOVING 100 ROWS
for i=1:100
    
    E=diff(img_gray);
    M=cost(E);
    [Xcoor,Ycoor]=min_detection(M);
    img_row_rem=remove(img_row_rem, Xcoor, Ycoor);
    img_gray=rgb2gray(img_row_rem);
end



imshow(img1);
figure;
imshow(img_row_rem);





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
    for j=1:size(e, 2)
        for i=1:size(e, 1)
            if(j==1)
                Y(i,j)=e(i,j);
            elseif(i==1)
                Y(i,j)=e(i,j) + min([Y(i,j-1),Y(i+1,j-1)]);
            elseif(i==size(e,1))
                Y(i,j)=e(i,j) + min([Y(i,j-1),Y(i-1,j-1)]);
            else
                Y(i,j)=e(i,j) + min([Y(i,j-1),Y(i-1,j-1),Y(i+1,j-1)]);
            end
        end
    end
end




function [X, Y] = min_detection(M)
    Xcoor=[];
    Ycoor=[];
    
    minimum=min(M(:,size(M, 2)));
    index=find(M(:,size(M, 2))==minimum);
    index=index(1);
    Xcoor=[Xcoor index];
    Ycoor=[Ycoor size(M,2)];
    for i=size(M,2)-1:-1:1
        if(index==1)
            minimum2=min([M(index, i), M(index+1, i)]);
            if (minimum2==M(index, i))
                index=index;
                Xcoor=[Xcoor index];
                Ycoor=[Ycoor i];
            else
                index=index+1;
                Xcoor=[Xcoor index];
                Ycoor=[Ycoor i];
            end
        elseif(index==size(M,1))
            minimum2=min([M(index-1, i), M(index, i)]);
            if(minimum2==M(index-1, i))
                index=index-1;
                Xcoor=[Xcoor index];
                Ycoor=[Ycoor i];
            elseif (minimum2==M(index, i))
                index=index;
                Xcoor=[Xcoor index];
                Ycoor=[Ycoor i];
            end
        else
            minimum2=min([M(index-1, i), M(index, i), M(index+1, i)]);
            if(minimum2==M(index-1, i))
                index=index-1;
                Xcoor=[Xcoor index];
                Ycoor=[Ycoor i];
            elseif (minimum2==M(index, i))
                index=index;
                Xcoor=[Xcoor index];
                Ycoor=[Ycoor i];
            else
                index=index+1;
                Xcoor=[Xcoor index];
                Ycoor=[Ycoor i];
            end
        end
    end
    X=Xcoor;
    Y=Ycoor;
end



function img_final = remove (img, X, Y)
    for i=size(img, 2):-1:1
       temp1=img(:, i, 1);
       temp2=img(:, i, 2);
       temp3=img(:, i, 3);
       temp1(X(size(img,2)+1-i))=[];
       temp2(X(size(img,2)+1-i))=[];
       temp3(X(size(img,2)+1-i))=[];    
       img_final(:, i, 1)=temp1;
       img_final(:, i, 2)=temp2;
       img_final(:, i, 3)=temp3;
    end
end
