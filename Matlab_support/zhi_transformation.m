function new_img = zhi_transformation(x_offset, y_offset, z_offset, yaw_offset, img, velo, velo_img, calib)
    fx = calib.P_rect{1,2}(1,1);
    fy = calib.P_rect{1,2}(2,2);
    cx = calib.P_rect{1,2}(1,3);
    cy = calib.P_rect{1,2}(2,3);
    new_img = zeros(375,1242,5); % 5 columns: r,g,b,depth,distance
    for i=1:size(velo_img,1);
        u = round(velo_img(i,1)); % x in imshow
        v = round(velo_img(i,2)); % y in imshow
        [u v] = anti_out_of_border(u, v);
        rgb = img(v,u,:);
        x = velo(i,1);
        y = velo(i,2);
        z = velo(i,3);
        % in camera geometry, x_new is acutally z, y_new is actually -x,
        % z_new is actually -y.
        x_new = x + x_offset;
        y_new = - (y + y_offset);
        z_new = - (z + z_offset);
        if (yaw_offset ~= 0)
            theta = yaw_offset / 180 * pi;
            x_new2 = sqrt(y_new^2 + x_new^2) * cos(theta - atan(y_new/x_new));
            y_new2 = -x_new2 * tan(theta - atan(y_new/x_new));
            x_new = x_new2;
            y_new = y_new2;
        end
        distance_new = sqrt(x_new^2 + y_new^2 + z_new^2);
        u_new = round((y_new * fx)/x_new + cx);
        v_new = round((z_new * fy)/x_new + cy);
        [u_new v_new] = anti_out_of_border(u_new, v_new);
        new_img(v_new, u_new, :) = zhi_closer_data_point(rgb, x_new, new_img(v_new, u_new, :), distance_new);
    end
    new_img = zhi_img_filter(new_img, img, x_offset, y_offset, z_offset, yaw_offset, fx, fy, cx, cy);
    new_img(:,:,4:5) = [];
    new_img = uint8(new_img);
    disp('Done');
end


function new_img = zhi_img_filter(new_img, img, x_offset, y_offset, z_offset, yaw_offset, fx, fy, cx, cy)
    row = size(new_img, 1);
    col = size(new_img, 2);
    dataGroup = [];
    for v = 1:row
        for u = 1:col
            if (new_img(v,u,1)~=0 && new_img(v,u,2)~=0 && new_img(v,u,3)~=0)
                dataGroup = [dataGroup; [u v]];
            end
        end
    end
    for v = 1:row
        for u = 1:col
            if (new_img(v,u,1)==0 && new_img(v,u,2)==0 && new_img(v,u,3)==0)
                % void pixel. Need to be filled in.
                % step 1: Find point cloud of Lidar.
                X2 = nearest_depth(dataGroup, new_img, v, u); % average the nearest available depth
                Y2 = (u-cx)*X2/fx; % no need to round.
                Z2 = (v-cy)*X2/fy; % no need to round.
                % step 2: Transform to Original point cloud.
                X2 =  X2 - x_offset;
                Y2 =  Y2 + y_offset;
                Z2 =  Z2 - z_offset;
                if (yaw_offset ~= 0)
                    theta = - yaw_offset / 180 * pi;
                    x_new2 = sqrt(Y2^2 + X2^2) * cos(theta - atan(Y2/X2));
                    y_new2 = -x_new2 * tan(theta - atan(Y2/X2));
                    X2 = x_new2;
                    Y2 = y_new2;
                end
                % step 3: Find RGB value.
                u2 = round((Y2 * fx)/X2 + cx);
                v2 = round((Z2 * fy)/X2 + cy);
                [u2 v2] = anti_out_of_border(u2, v2);
                rgb2 = img(v2,u2,:);
                % step 4: fill the new_img by using rgb2
                new_img(v,u,1:3) = rgb2;
            end
        end
    end
end

function depth = nearest_depth(dataGroup, new_img, v_in, u_in)
    index = dsearchn(dataGroup,[u_in v_in]);
    uvIndex = dataGroup(index, :);
    u = uvIndex(1,1);
    v = uvIndex(1,2);
    depth = new_img(v,u,4);
    if depth == 0
        depth = 999;
    end
end

function depth = average_depth(dataGroup, new_img, v_in, u_in)
    
    index = dsearchn(dataGroup,[u_in v_in]);
    uvIndex = dataGroup(index, :);
    u = uvIndex(1,1);
    v = uvIndex(1,2);
    depth = new_img(v,u,4);
    if depth == 0
        depth = 999;
    end
end

function [u, v] = anti_out_of_border(u, v)
    if (u > 1242)
        u = 1242;
    end
    if (u < 1)
        u = 1;
    end
    if (v > 375)
        v = 375;
    end
    if (v < 1)
        v = 1;
    end
end