close all;
clc
% Load the image
I = imread('TestImgResized.jpg');
% figure; imshow(I);
%% Segmentation of objects based on edge detection and kmeans clustering
% Sharpen the image so that the edges are highlighted in the image
Isharp = imsharpen(I);
% Convert to gray-scale
Igray = rgb2gray(Isharp);
% Find the edges
Iedge = edge(Igray); % Output of edge() is a Binary image
% figure; imshow(Iedge);

% Find the properties of connected components (objects) in the binary image
stats = regionprops('table',Iedge,'Centroid','Area');
% % Get the centers and radii of the objects
% centers = stats.Centroid(:,1:2);
% radii = sqrt(stats.Area./pi);
% figure; imshow(I);
% % Plot the circles
% hold on
% viscircles(centers,radii);
% hold off

% Use k-means to form clusters from the isolated regions
nObjects = 13; % Number of objects to detect
[~,C] = kmeans(stats.Centroid,nObjects,'Replicates',5);
rObject = 15; % Radius of object
% centers = C;
% radii = ones(nObjects,1)*rObject;
% % Plot the circles
% hold on
% viscircles(centers,radii);
% hold off

RedObject = []; GreenObject = []; BlueObject = []; YellowObject = []; WhiteObject = [];
threshold = 100;
% Detect the color
for i = 1 : nObjects
    % Find the red, blue, green component for each cluster
    IObject = imcrop(Isharp,[C(i,1)-rObject,C(i,2)-rObject,2*rObject,2*rObject]);
    %figure; imshow(IObject);
    % Find the dominant component
    RGB = sum(sum(IObject))/(size(IObject,1)*size(IObject,2));
    if (RGB(1) > threshold && RGB(1) > RGB(2) && RGB(1) > RGB(3))
        if (RGB(2) < threshold)
            % Red Object
            RedObject = [RedObject; C(i,:)];
        elseif (RGB(3) < threshold)
            % Yellow Object
            YellowObject = [YellowObject; C(i,:)];
        else
            % White/Transparent Object
            WhiteObject = [WhiteObject; C(i,:)];
        end
    elseif (RGB(2) > threshold && RGB(2) > RGB(1) && RGB(2) > RGB(3))
        % Green Object
        GreenObject = [GreenObject; C(i,:)];
    elseif (RGB(3) > threshold && RGB(3) > RGB(1) && RGB(3) > RGB(2))
        % Blue Object
        BlueObject = [BlueObject; C(i,:)]; 
    end
end
% Display the objects
fprintf("Number of red pins: %d\n", size(RedObject,1));
fprintf("Number of green pins: %d\n", size(GreenObject,1));
fprintf("Number of blue pins: %d\n", size(BlueObject,1));
fprintf("Number of yellow pins: %d\n", size(YellowObject,1));
fprintf("Number of white or transparent pins: %d\n", size(WhiteObject,1));
figure; imshow(I);
hold on
for i = 1 : size(RedObject,1)
    viscircles(RedObject(i,:),rObject,'Color','r');
end
for i = 1 : size(GreenObject,1)
    viscircles(GreenObject(i,:),rObject,'Color','g');
end
for i = 1 : size(BlueObject,1)
    viscircles(BlueObject(i,:),rObject,'Color','b');
end
for i = 1 : size(YellowObject,1)
    viscircles(YellowObject(i,:),rObject,'Color','y');
end
for i = 1 : size(WhiteObject,1)
    viscircles(WhiteObject(i,:),rObject,'Color','w');
end