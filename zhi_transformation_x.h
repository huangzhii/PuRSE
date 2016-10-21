#ifndef ZHI_TRANSFORMATION_X_H
#define ZHI_TRANSFORMATION_X_H

#endif // ZHI_TRANSFORMATION_X_H

#include <math.h>
#include <iostream>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>





cv::Mat trans_x(double x_offset, double y_offset, double z_offset, double yaw_offset, cv::Mat img, cv::Mat velo_dense);
cv::Mat median_filter(cv::Mat img);
int anti_out_of_border_u(int val);
int anti_out_of_border_v(int val);
