% Input arguments:
% base_dir .... absolute path to sequence base directory (ends with _sync)
% calib_dir ... absolute path to directory that contains calibration files

close all; dbstop error; clc;
disp('======= KITTI DevKit Demo =======');

% options (modify this to select your sequence)

base_dir  = '../../../2011_09_26_drive_0015_sync/2011_09_26/2011_09_26_drive_0015_sync';
calib_dir = '../../../2011_09_26_calib/2011_09_26';
load('velo_dense_2011_09_26');
cam       = 2; % 0-based index
frame     = 165; % 0-based index 199 or 165

% load calibration
calib = loadCalibrationCamToCam(fullfile(calib_dir,'calib_cam_to_cam.txt'));
Tr_velo_to_cam = loadCalibrationRigid(fullfile(calib_dir,'calib_velo_to_cam.txt'));

% compute projection matrix velodyne->image plane
R_cam_to_rect = eye(4);
R_cam_to_rect(1:3,1:3) = calib.R_rect{1};
P_velo_to_img = calib.P_rect{cam+1}*R_cam_to_rect*Tr_velo_to_cam;

% load and display image
img = imread(sprintf('%s/image_%02d/data/%010d.png',base_dir,cam,frame));
fig = figure('Position',[20 100 size(img,2) size(img,1)]); axes('Position',[0 0 1 1]);
% img = img - 255;
imshow(img); hold on;

% load velodyne points

fid = fopen(sprintf('%s/velodyne_points/data/%010d.bin',base_dir,frame),'rb');
velo = fread(fid,[4 inf],'single')';
velo = velo(1:5:end,:); % remove every 5th point for display speed
fclose(fid);

% remove all points behind image plane (approximation
idx = velo(:,1)<5;
velo(idx,:) = [];

% project to image plane (exclude luminance)
velo_img = project(velo(:,1:3),P_velo_to_img);

% plot points
cols = jet;
for i=1:size(velo_img,1)
  col_idx = round(64*5/velo(i,1)); % define color. velo(i,1) represent distance
  plot(velo_img(i,1),velo_img(i,2),'*','LineWidth',1,'MarkerSize',3,'Color',cols(col_idx,:));
end

%% Part 2
velo_dense = velo_dense_2011_09_26{frame};
% offset represent camera itself offset
x_offset = 0;
y_offset = 1;
z_offset = 0;
% yaw offset: clockwise represent positive angle.
yaw_offset = 0;

tic
new_img = zhi_transformation3(x_offset, y_offset, z_offset, ...
    yaw_offset, img, velo_dense, calib);
toc

figure;
imshow(new_img);
axis on;

%% Part 3 video
clc;
h = figure;
imshow(img);
myVideo = VideoWriter('departing.avi');
uncompressedVideo = VideoWriter('departing.avi', 'Uncompressed AVI');
movegui(h, 'onscreen');
rect = get(h,'Position'); 
rect(1:2) = [0 0];
myVideo.FrameRate = 5;  % Default 30
myVideo.Quality = 100;    % Default 75
open(myVideo);

y_departure = 0:0.04:2.0;
yaw_change = 0:0.3:15;

for frame = 1:50
    frame
    img = imread(sprintf('%s/image_%02d/data/%010d.png',base_dir,cam,frame));
    % load velodyne points
    velo_dense = velo_dense_2011_09_26{frame};
    new_img = zhi_transformation3(0, y_departure(frame), 0, yaw_change(frame), img, velo_dense, calib);
    imshow(new_img);
    title(sprintf('shift right %8.2f m, yaw angle change %8.2f degree.', y_departure(frame), yaw_change(frame)));
    hold off;
    movegui(h, 'onscreen');
    drawnow;
    writeVideo(myVideo,getframe(gcf,rect));
end
close(myVideo);

clc;
h = figure;
imshow(img);
myVideo = VideoWriter('normal.avi');
uncompressedVideo = VideoWriter('normal.avi', 'Uncompressed AVI');
movegui(h, 'onscreen');
rect = get(h,'Position'); 
rect(1:2) = [0 0];
myVideo.FrameRate = 5;  % Default 30
myVideo.Quality = 100;    % Default 75
open(myVideo);
for frame = 1:50
    frame
    img = imread(sprintf('%s/image_%02d/data/%010d.png',base_dir,cam,frame));
    imshow(img);
    title(sprintf('shift right 0 m, yaw angle change 0 degree.'));
    hold off;
    movegui(h, 'onscreen');
    drawnow;
    writeVideo(myVideo,getframe(gcf,rect));
end
close(myVideo);



