% This transformation use densed RGB-D.

function new_img = zhi_transformation3(x_offset, y_offset, z_offset, yaw_offset, img, velo_dense, calib)
    fx = calib.P_rect{1,2}(1,1);
    fy = calib.P_rect{1,2}(2,2);
    cx = calib.P_rect{1,2}(1,3);
    cy = calib.P_rect{1,2}(2,3);
    new_img = zeros(375,1242,5); % 5 columns: r,g,b,depth,distance
    for v=1:375
        for u=1:1242
            rgb = img(v,u,:);
            x = velo_dense(v,u); % x means depth
            y = (u-cx)*x/fx; % y means right direction
            z = (v-cy)*x/fy; % z means up direction
            
            x_new = x - x_offset;
            y_new = y - y_offset;
            z_new = z + z_offset;
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
            new_img(v_new, u_new, :) = zhi_closer_data_point(rgb, ...
                x_new, new_img(v_new, u_new, :), distance_new);
        end
    end
    new_img(:,:,4:5) = [];
%     new_img = jiahao_image_filter(new_img);
    new_img = uint8(new_img);
    disp('Done');
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