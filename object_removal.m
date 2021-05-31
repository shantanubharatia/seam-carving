%Unfinished

img1=imread('Couple.png');
img2=rgb2gray(img1);
figure
imshow(img1);
[Yin,Xin]=ginput();
E=diff(img2);


c=50
X=[];
Y=[];
M=[];

M=cost(E, X, Y, sum(M(:)), Xin, Yin);
[Xcoor,Ycoor]=min_detection(M);
X(:, 1)=Xcoor';
Y(:, 1)=Ycoor';
for i=1:size(img1,1)
    for j=1:size(img1,2)
        in = inpolygon(i,j,Xin,Yin);
        if(in==1)
            M(i,j)=0;
            %display('hello');
        end
    end
end
    
for i=2:c
    %display(i);
    M=cost(E, X, Y, sum(M(:)), Xin, Yin);
    
    
    [Xcoor,Ycoor]=min_detection(M);
    %M= ignore_seam(M,Xcoor,Ycoor);
    X(:, i)=Xcoor';
    Y(:, i)=Ycoor';
end

plot_seam(img1, X, Y);


img4 = zeros(size(img1,1),size(img1,2)-c,3);
for i=1:size(X,1)
    Y2=Y(i,:);
    Y2=sort(Y2);
    k = 1;
    for j=1:size(img1,2)
        if(k==size(Y2,2)+1)
            img4(size(img1,1)-i+1,j-k,:)= img1(size(img1,1)-i+1,j,:);
            if(j-k > 300)
                disp(j-k);
            end
        elseif(Y2(k)~=j)
            img4(size(img1,1)-i+1,j-k+1,:)= img1(size(img1,1)-i+1,j,:); 
            %disp(j-k+1);
        elseif(Y2(k)==j)
            k = k + 1;
            %disp(k);
        end
    end    
end
img5=rgb2gray(uint8(img4));









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
            if (minimum2==M(i, index))
                index=index;
                Xcoor=[Xcoor i];
                Ycoor=[Ycoor index];
            elseif(minimum2==M(i, index-1))
                index=index-1;
                Xcoor=[Xcoor i];
                Ycoor=[Ycoor index];
            end
        else
            minimum2=min([M(i, index-1), M(i, index), M(i, index+1)]);
            if (minimum2==M(i, index))
                index=index;
                Xcoor=[Xcoor i];
                Ycoor=[Ycoor index];
            elseif(minimum2==M(i, index-1))
                index=index-1;
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

function M=cost(f, X, Y, max, Xin, Yin)
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
                in = inpolygon(i,j,Xin,Yin);
                if(in==0)
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
end


