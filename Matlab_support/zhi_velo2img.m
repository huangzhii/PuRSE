for i=1:297
    velo = velo_dense_2011_09_26{i};
    a = floor(velo);
    b = floor(velo*100);
    c = floor(velo*10000);
    A = a;
    A(:,:,2) = b - a*100;
    A(:,:,3) = c - b*100;
    
    outputString = sprintf('./depthRGB/%d.png', i-1)
    imwrite(A,outputString,'png');
end


%%
b = imread('velo.png');