%Code for removing vertical and horizontal seams (width and height reduction)

clc
clear all

img1=imread('charles_original.png');
img2=rgb2gray(img1);

%FOR REMOVING 100 ROWS AND 100 COLUMNS
r=50;
c=0;
[T,C]=T_Calculation(img1,r,c);

imshow(img1, 'InitialMagnification', 100)
figure
imshow(C{r+1,c+1}, 'InitialMagnification', 100)

% E=diff(img2);
% M=cost(E);
% [Xcoor,Ycoor]=min_detection(M);
% img_col_rem=remove(img1, Xcoor, Ycoor);
% img_gray=rgb2gray(img_col_rem)



function [T,C]=T_Calculation(img1,r,c)
    T=zeros(r+1, c+1);
    % T(1,1)=0;
    C=cell(r+1, c+1);
    for i=1:r+1
        for j=1:c+1
            display(i);
            display(j);
            if(i==1 && j==1)
                T(i,j)=0;
                C{i,j}=img1;
            else
                if(i==1)
                    img_left=C{i,j-1};
                    img_left_2=rgb2gray(img_left);
                    E=diff(img_left_2);
                    M1=cost_vert(E);
                    minimum1=min(M1(size(M1, 1), :));
                    [Xcoor,Ycoor]=min_detection_vert(M1);
                    img_col_rem=remove_vert(img_left, Xcoor, Ycoor);
                    T(i,j)=T(i,j-1)+minimum1;
                    C{i,j}=img_col_rem;
                elseif(j==1)
                    img_top=C{i-1,j};
                    img_top_2=rgb2gray(img_top);
                    E=diff(img_top_2);
                    M2=cost_hori(E);
                    minimum2=min(M2(:,size(M2, 2)));
                    [Xcoor,Ycoor]=min_detection_hori(M2);
                    img_row_rem=remove_hori(img_top, Xcoor, Ycoor);
                    T(i,j)=T(i-1,j)+minimum2;
                    C{i,j}=img_row_rem;
                else
                    %From Left
                    img_left=C{i,j-1};
                    img_left_2=rgb2gray(img_left);
                    E=diff(img_left_2);
                    M1=cost_vert(E);
                    minimum1=min(M1(size(M1, 1), :));
    %                 [Xcoor,Ycoor]=min_detection_vert(M1);
    %                 img_col_rem=remove_vert(img_left, Xcoor, Ycoor);

                    %From Column
                    img_top=C{i-1,j};
                    img_top_2=rgb2gray(img_top);
                    E=diff(img_top_2);
                    M2=cost_hori(E);
                    minimum2=min(M2(:,size(M2, 2)));
    %                 [Xcoor,Ycoor]=min_detection_hori(M2);
    %                 img_row_rem=remove_hori(img_top, Xcoor, Ycoor);

                    check_top=T(i-1,j)+minimum2;
                    check_left=T(i, j-1)+minimum1;
                    if(check_top<=check_left)
                        [Xcoor,Ycoor]=min_detection_hori(M2);
                        img_row_rem=remove_hori(img_top, Xcoor, Ycoor);
                        T(i,j)=check_top;
                        C{i,j}=img_row_rem;
                    else
                        [Xcoor,Ycoor]=min_detection_vert(M1);
                        img_col_rem=remove_vert(img_left, Xcoor, Ycoor);
                        T(i,j)=check_left;
                        C{i,j}=img_col_rem;
                    end
                    %Freeing up Memory
                    if(i>2)
                        C{i-2,j}=0;
                    end
                end
            end
        end
    end

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

function Y=cost_vert(f)
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

function [X, Y] = min_detection_vert(M)
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

function img_final = remove_vert (img, X, Y)
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

function Y=cost_hori(f)
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




function [X, Y] = min_detection_hori(M)
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



function img_final = remove_hori (img, X, Y)
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
