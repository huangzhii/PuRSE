function new_data_point = zhi_closer_data_point(rgb_new, x_new, data_point_old, d_new)
    d_old = data_point_old(:,:,5);
    if d_old ~= 0 && d_new - d_old > 0
        new_data_point = data_point_old;
    else
        rgb_with_dist_new = rgb_new; %new rgb
        rgb_with_dist_new(:,:,4) = x_new; %add new depth
        rgb_with_dist_new(:,:,5) = d_new; %add new distance
        new_data_point = rgb_with_dist_new;
    end
end