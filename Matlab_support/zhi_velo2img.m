for i=1:297
    velo = velo_dense_2011_09_26{i};
    a = floor(velo);
    b = floor(velo*100);
    c = floor(velo*10000);
    c = c - b*100;
    b = b - a*100;
    A = uint8(a);
    A(:,:,2) = uint8(b);
    A(:,:,3) = uint8(c);
    
    outputString = sprintf('../data/depthRGB/%d.png', i-1)
%     A(1,1,:)
%     imwrite(A,outputString,'png');
    imwrite(A,outputString);
end


%%
b = imread('../data/depthRGB/0.png');
depth = double(b(1,1,1)) + double(double(b(1,1,2))/100) + double(double(b(1,1,3)))/10000

c = imread('../data/png16depth/1.png');