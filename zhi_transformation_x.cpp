//This transformation use densed RGB-D.

#include "zhi_transformation_x.h"

cv::Mat trans_x(double x_offset, double y_offset, double z_offset, double yaw_offset, cv::Mat img, cv::Mat velo_dense){
    //new_img = zeros(375,1242,5); // 5 columns: r,g,b,depth,distance
    double fx = 721.5377;
    double fy = 721.5377;
    double cx = 609.5593;
    double cy = 172.854;
    double x;
    double y;
    double z;
    double x_new;
    double y_new;
    double z_new;
    double x_new2;
    double y_new2;
    double theta;
    double u_new;
    double v_new;
    double distance_new;
    cv::Mat new_img(375,1242, CV_8UC3, cv::Scalar(0,0,0));

    for (int v = 0; v <= 374; v++){
        for (int u = 0; u <= 1241; u++){
            //x = (int)velo_dense.at<cv::Vec3b>(v,u)[0]*0.256;
            x = (double)velo_dense.at<cv::Vec3b>(v,u)[0] + (double)velo_dense.at<cv::Vec3b>(v,u)[1]/100 + (double)velo_dense.at<cv::Vec3b>(v,u)[2]/10000;// x means depth
            //if ( u == 0 && v == 0 )
            //    std::cout << x << std::endl;
            y = (u-cx)*x/fx; // means right direction
            z = (v-cy)*x/fy; // means up direction
            x_new = x - x_offset;
            y_new = y - y_offset;
            z_new = z + z_offset;
            if (yaw_offset != 0){
                theta = yaw_offset / 180 * M_PI;
                x_new2 = sqrt(y_new*y_new + x_new*x_new) * cos(theta - atan(y_new/x_new));
                y_new2 = -x_new2 * tan(theta - atan(y_new/x_new));
                x_new = x_new2;
                y_new = y_new2;
            }
            distance_new = sqrt(x_new*x_new + y_new*y_new + z_new*z_new);
            u_new = round((y_new * fx)/x_new + cx);
            v_new = round((z_new * fy)/x_new + cy);
            u_new = anti_out_of_border_u(u_new);
            v_new = anti_out_of_border_v(v_new);
            new_img.at<cv::Vec3b>(v_new,u_new) = img.at<cv::Vec3b>(v,u);
        }
    }
    new_img = median_filter(new_img);
    return new_img;
}

int anti_out_of_border_u(int val){
    if (val > 1241){
        val = 1241;
    }
    if (val < 0){
        val = 0;
    }
    return val;
}
int anti_out_of_border_v(int val){
    if (val > 374){
        val = 374;
    }
    if (val < 0){
        val = 0;
    }
    return val;
}

cv::Mat median_filter(cv::Mat img){

    //cv::Mat output, res, grayimg, merged_img;
    //cv::cvtColor(img, grayimg, CV_BGR2GRAY);
    //cv::inRange(grayimg, 0, 0, output);

    cv::Mat new_img(375,1242, CV_8UC3, cv::Scalar(0,0,0));
    cv::medianBlur(img,new_img,15);
    for (int v = 0; v <= 374; v++){
        for (int u = 0; u <= 1241; u++){
            if (img.at<cv::Vec3b>(v,u) == cv::Vec3b(0,0,0)){
                img.at<cv::Vec3b>(v,u) = new_img.at<cv::Vec3b>(v,u);
            }
        }
    }

    return img;
}
