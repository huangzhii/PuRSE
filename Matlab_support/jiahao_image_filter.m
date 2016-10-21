function filtered_image = jiahao_image_filter(image)
    mask = create_mask(image);
%     mask(:,:,4) = [];
    gray_mask = rgb2gray(mask);
    binary_mask = (gray_mask > 0.1);
    tic
%     [min_x, min_y, max_x, max_y] = find_min_max(image);
%     [min_x, min_y, max_x, max_y] = find_min_max_faster(image);
    toc
    for row = 3:1:373
        for col = 3:1:1240
            a = abs(image(row,col,1) - image(row,col,2));
            b = abs(image(row,col,2) - image(row,col,3));
            c = abs(image(row,col,3) - image(row,col,1));
            if a < 15 && b < 15 && c < 15
                if image(row,col,1) < 5
                    image(row,col,1) = 5;
                end
                if image(row,col,2) < 5
                    image(row,col,2) = 5;
                end
                if image(row,col,3) < 5
                    image(row,col,3) = 5;
                end
%                 image(row,col,1) = medfilt2(image(row,col,1), [5 5]);
%                 image(row,col,2) = medfilt2(image(row,col,2), [5 5]);
%                 image(row,col,3) = medfilt2(image(row,col,3), [5 5]);
                avg_rgb = zeros(1,3);
                for val = 1:3
                    avg_rgb(val) = average(image, row, col, val);
                    image(row,col,val) = avg_rgb(val);
                end
                
%                 if filtered_points(row-1,col) == 0
%                     avg_rgb_up = zeros(1,3);
%                     filtered_points(row-1,col) = 1;
%                     for val = 1:3
%                         avg_rgb_up(val) = average(image, row-1, col, val);
%                         image(row-1,col,val) = avg_rgb_up(val);
%                     end
%                 end
%                 if filtered_points(row+1,col) == 0
%                     avg_rgb_down = zeros(1,3);
%                     filtered_points(row+1,col) = 1;
%                     for val = 1:3
%                         avg_rgb_down(val) = average(image, row+1, col, val);
%                         image(row+1,col,val) = avg_rgb_down(val);
%                     end
%                 end
%                 if filtered_points(row,col-1) == 0
%                     avg_rgb_left = zeros(1,3);
%                     filtered_points(row,col-1) = 1;
%                     for val = 1:3
%                         avg_rgb_left(val) = average(image, row, col-1, val);
%                         image(row,col-1,val) = avg_rgb_left(val);
%                     end
%                 end
%                 if filtered_points(row,col+1) == 0
%                     avg_rgb_right = zeros(1,3);
%                     filtered_points(row,col+1) = 1;
%                     for val = 1:3
%                         avg_rgb_right(val) = average(image, row, col+1, val);
%                         image(row,col+1,val) = avg_rgb_right(val);
%                     end
%                 end
%                 for val = 1:3
%                     avg_rgb(val) = average(image, row, col, val);
%                     avg_rgb_up(val) = average(image, row-1, col, val);
%                     avg_rgb_down(val) = average(image, row+1, col, val);
%                     avg_rgb_left(val) = average(image, row, col-1, val);
%                     avg_rgb_right(val) = average(image, row, col+1, val);
%                     image(row,col,val) = avg_rgb(val);
%                     image(row-1,col,val) = avg_rgb_up(val);
%                     image(row+1,col,val) = avg_rgb_down(val);
%                     image(row,col-1,val) = avg_rgb_left(val);
%                     image(row,col+1,val) = avg_rgb_right(val);
%                 end
            end
        end
    end
    image = cleanup(image);
    filtered_image = image;
%     filtered_image(:,:,4) = []; %remove distance
    filtered_image = filtered_image.*repmat(binary_mask,[1,1,3]);
end

function cleaned = cleanup(image)
    for row = 3:1:373
        prev_pixel = image(row-1,3,:);
        for col = 3:1:1240
            curr_pixel = image(row,col,:);
            next_pixel = image(row,col+1,:);
            if is_contrasting(prev_pixel, curr_pixel, next_pixel)
%                 image(row,col,1) = 0;
%                 image(row,col,2) = 255;
%                 image(row,col,3) = 0;
                avg_rgb = zeros(1,3);
                for val = 1:3
                    avg_rgb(val) = average(image, row, col, val);
                    image(row,col,val) = avg_rgb(val);
                end
            end
            prev_pixel = curr_pixel;
        end
    end
    cleaned = image;
end

function bool = is_contrasting(prev_pixel, curr_pixel, next_pixel)
    if curr_pixel(:,:,1) < 60 && curr_pixel(:,:,2) < 60 && curr_pixel(:,:,3) < 60
        threshold = 120;
    elseif curr_pixel(:,:,1) > 230 && curr_pixel(:,:,2) > 230 && curr_pixel(:,:,3) > 230
        threshold = 200;
    else
        threshold = 280;
    end
    sum_1 = prev_pixel(:,:,1) + prev_pixel(:,:,2) + prev_pixel(:,:,3);
    sum_2 = curr_pixel(:,:,1) + curr_pixel(:,:,2) + curr_pixel(:,:,3);
    sum_3 = next_pixel(:,:,1) + next_pixel(:,:,2) + next_pixel(:,:,3);
    bool = abs(sum_1 - sum_2) > threshold && abs(sum_2 - sum_3) > threshold;
end

function mask = create_mask(image)
    se = strel('diamond', 20);
    se2 = strel('diamond', 22);
    for rgb = 1:3
        image(:,:,rgb) = imdilate(image(:,:,rgb), se);
    end
    for rgb = 1:3
        image(:,:,rgb) = imerode(image(:,:,rgb), se2);
    end
    mask = image;
%     mask(:,:,4) = [];
%     imshow(mask)
end

function [min_x, min_y, max_x, max_y] = find_min_max_faster(image)
    min_x = 360;
    min_y = 640;
    max_x = 360;
    max_y = 640;
    min_col = 1;
    max_col = 1280;
    
    %finding max_x
    for row = 720:-1:1
        col = 1280;
        while col > min_col
            if image(row,col,4) ~= 0
                if row < min_y
                    min_y = row;
                elseif row > max_y
                    max_y = row;
                elseif col < min_x
                    min_x = col;
                elseif col > max_x
                    max_x = col;
                    min_col = max_x;
                end
            end
            col = col - 1;
        end
    end
    
    %finding min_x
    for row = 1:720
        col = 1;
        while col < max_col
            if image(row,col,4) ~= 0
                if row < min_y
                    min_y = row;
                elseif row > max_y
                    max_y = row;
                elseif col < min_x
                    min_x = col;
                    max_col = min_x;
                end
            end
            col = col + 1;
        end
    end
    
    min_x = max(3, min_x);
    min_y = max(3, min_y);
    max_x = min(1240, max_x);
    max_y = min(373, max_y);
end

function [min_x, min_y, max_x, max_y] = find_min_max(image)
    min_x = 360;
    min_y = 640;
    max_x = 360;
    max_y = 640;
    for row = 1:720
        for col = 1:1280
            if image(row,col,4) ~= 0
                if row < min_y
                    min_y = row;
                elseif row > max_y
                    max_y = row;
                elseif col < min_x
                    min_x = col;
                elseif col > max_x
                    max_x = col;
                end
%             elseif isnan(image(row,col,1))
%                 for val = 1:3
%                     image(row,col,val) = 0;
            end
        end
    end
%     min_x = max(2, min_x)
%     min_y = max(2, min_y)
%     max_x = min(1279, max_x)
%     max_y = min(719, max_y)
    min_x = max(3, min_x);
    min_y = max(3, min_y);
    max_x = min(1240, max_x);
    max_y = min(373, max_y);
end


function avg_val = average(image, row, col, rgb)
%finds the average red, blue, or green value in a surrounding 5x5 matrix
    avg_val = 0;
    num_data = 0;
    %loop through a 5x5 matrix around the point
    for r = row-2:row+2
        for c = col-2:col+2
            if r ~= 0 && c ~= 0 && image(r,c,1) > 10 && image(r,c,2) > 10 && image(r,c,3) > 10
                avg_val = avg_val + image(r,c,rgb);
                num_data = num_data + 1;
            end
        end
    end
    if num_data ~= 0
        avg_val = round(avg_val / num_data);
    else
        avg_val = 0;
    end
end