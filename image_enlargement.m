% clc
% clear all

img1=imread('dolphin.png');
%img1=uint8(new_img);
img2=rgb2gray(img1);
imshow(img1);
E=diff(img2);

%No of columns to be enlarged
c=50;
X=[];
Y=[];
M=[];
for i=1:c
    display(i);
    M=cost(E, X, Y, sum(M(:)));
    [Xcoor,Ycoor]=min_detection(M);
    %M= ignore_seam(M,Xcoor,Ycoor);
    X(:, i)=Xcoor';
    Y(:, i)=Ycoor';
end

plot_seam(img1, X, Y);

new_img=zeros(size(img1, 1), size(img1, 2)+c, 3);

for i=1:size(X,1)
    Y2=Y(i,:);
    Y2=sort(Y2);
    k=1;
    for j=1:size(img1, 2)   
        if(k==size(Y2,2)+1)
            new_img(size(img1,1)+1-i,j+k-1,:)=img1(size(img1,1)+1-i,j,:);
        elseif(j<Y2(1,k))
            new_img(size(img1,1)+1-i,j+k-1,:)=img1(size(img1,1)+1-i,j,:);
        else
            %new_img(size(img1,1)+1-i,j+k-1,:)=(img1(size(img1,1)+1-i,j,:)+img1(size(img1,1)+1-i,j+1,:))/2;
            if(j==1)
                new_img(size(img1,1)+1-i,j+k-1,:)=img1(size(img1,1)+1-i,j,:);
            elseif(j==size(img1,2))
                new_img(size(img1,1)+1-i,j+k-1,:)=img1(size(img1,1)+1-i,j,:);
            else
                %new_img(size(img1,1)+1-i,j+k-1,:)=img1(size(img1,1)+1-i,j-1,:);
                new_img(size(img1,1)+1-i,j+k-1,:)=(double(img1(size(img1,1)+1-i,j-1,:))+double(img1(size(img1,1)+1-i,j+1,:)))/2;
            end
            new_img(size(img1,1)+1-i,j+k,:)=img1(size(img1,1)+1-i,j,:);
            k=k+1;
        end
    end
end

img1_g=rgb2gray(img1);
new_img_g=rgb2gray(uint8(new_img));
figure;
imshow(uint8(new_img));




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


function M=cost(f, X, Y, max)
    e=double(f);
    M = zeros(size(e, 1), size(e, 2));
    
    for i=1:size(X,1)
        for j=1:size(X,2)
            M(X(i,j),Y(i,j))=max;
        end
    end
            
    
    for i=1:size(e, 1)
        for j=1:size(e, 2)
            if(M(i,j)==0)
                if(i==1)
                    M(i,j)=e(i,j);
                elseif(j==1)
                    M(i,j)=e(i,j) + min([M(i-1,j),M(i-1,j+1)]);
                elseif(j==size(e,2))
                    M(i,j)=e(i,j) + min([M(i-1,j-1),M(i-1,j)]);
                else
                    M(i,j)=e(i,j) + min([M(i-1,j-1),M(i-1,j),M(i-1,j+1)]);
                end
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


function M= ignore_seam(M,Xcoor,Ycoor)
    for i=1:size(M,1)
        for j=1:size(M,2)
            if(Ycoor(i)==j)
                M(size(M, 1)+1-i, j)=max(M(:))+1;
            end
        end
    end
end

function plot_seam(img1, X, Y)
    %Number of seams is number of columns in x
    seams=size(Y,2);
    for i=1:seams
        for j=1:size(img1, 1)
            for k=1:size(img1, 2)
                if(Y(j,i)==k)
                    img1(size(img1, 1)+1-j, k, 1)=255;
                    img1(size(img1, 1)+1-j, k, 2)=0;
                    img1(size(img1, 1)+1-j, k, 3)=0;
                end
            end
        end
    end
    figure;
    imshow(img1);
end



% %Checking repition of seams
% for i=1:size(X)
%     [ii,jj,kk]=unique(Y(i, :))
%     out=ii(histc(kk,1:numel(ii))>1)
%     if(size(out)>0)
%         display('Found Error');
%         break;
%     end
% end
