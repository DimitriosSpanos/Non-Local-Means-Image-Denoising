clear all 
close all
clc

image_filename = 'house64.png';
f_image_filename = 'filtered_image.txt';

% -------------------------------------------------
%             
%           Input Image(RGB, png format)
%
% -------------------------------------------------

% image normalizer
normImg = @(I) (I - min(I(:))) ./ max(I(:) - min(I(:)));

image = imread(image_filename, 'png');
image = rgb2gray(image); 
image = mat2gray(image);
image = normImg(image);
figure('Name','Original Image');
imagesc(image); axis image;
colormap gray;


% -------------------------------------------------
%             
%            Image with Gaussian Noise
%
% -------------------------------------------------

noiseParams = {'gaussian', 0, 0.001};
image = imnoise( image, noiseParams{:} );
figure('Name','Image with Noise');
imagesc(image); axis image;
colormap gray;

% -------------------------------------------------
%             
%            Convert Image to txt file
%
% -------------------------------------------------

fid = fopen('image.txt','wt');
for ii = 1:size(image,1)
    fprintf(fid,'%g\t',image(ii,:));
    fprintf(fid,'\n');
end
fclose(fid);


% !!!Proceed only if you run the Non Local Means!!! %

fprintf("Press any key if filtered image is ready.\n");
pause;

% -------------------------------------------------
%             
%            Convert txt to Filtered Image
%
% -------------------------------------------------

filename1 = f_image_filename;
delimiterIn = ' ';
headerlinesIn = 0;
filtered_image = importdata(filename1,delimiterIn,headerlinesIn);

figure('Name','Filtered Image');
imagesc(filtered_image); axis image;    
colormap gray;


figure('Name','Noise');
imagesc(filtered_image - image); axis image;
colormap gray;

