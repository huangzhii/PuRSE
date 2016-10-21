close all; dbstop error; clc;
disp('======= Sparse 2 Dense start =======');
base_dir  = '../../../2011_09_26_drive_0015_sync/2011_09_26/2011_09_26_drive_0015_sync';
calib_dir = '../../../2011_09_26_calib/2011_09_26';
cam       = 2; % 0-based index
frame     = 199; % 0-based index 199 or 165

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
img = img - 255;
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
disp('======= Sparse 2 Dense Finished =======');
%% Densification
disp('======= Densification Start =======');
tic
velo_img_with_depth = [velo_img    velo(:,1)];
[u2 v2 depth2] = griddata(velo_img_with_depth(:,1),velo_img_with_depth(:,2), ...
        velo_img_with_depth(:,3),linspace(1,1242,1242)',linspace(1,375,375),'v4');
toc
velo_img_with_depth = [velo_img velo(:,2)];
[u2 v2 y2] = griddata(velo_img_with_depth(:,1),velo_img_with_depth(:,2), ...
        velo_img_with_depth(:,3),linspace(1,1242,1242)',linspace(1,375,375),'v4');
toc
velo_img_with_depth = [velo_img velo(:,3)];
[u2 v2 z2] = griddata(velo_img_with_depth(:,1),velo_img_with_depth(:,2), ...
        velo_img_with_depth(:,3),linspace(1,1242,1242)',linspace(1,375,375),'v4');
toc
disp('======= Densification Finished =======');



figure;
mesh(y2(:,:),  depth2(:,:), z2(:,:));
grid on;
hold on;
scatter3(0,0,0);

figure;
scatter3(velo(:,2), velo(:,3), velo(:,1),...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',[0 .75 .75])
grid on;
hold on;
scatter3(0,0,0);
%%
% plot points
tic
cols = jet;
for i=1:4:375
    for j = 1:4:1242
      col_idx = round(64*5/velo_img_with_depth_densed(i,j)); % define color. velo(i,1) represent distance
      if col_idx > 64
          col_idx = 64;
      end
      if col_idx < 1
          col_idx = 1;
      end
      plot(j,i, ...
          '*','LineWidth',1,'MarkerSize',3,'Color',cols(col_idx,:));
    end
end
toc






%%
% plot points
cols = jet;
for i=1:size(velo_img,1)
  col_idx = round(64*5/velo(i,1)); % define color. velo(i,1) represent distance
  plot(velo_img(i,1),velo_img(i,2),'*','LineWidth',1,'MarkerSize',3,'Color',cols(col_idx,:));
end
disp('======= Plot finished =======');