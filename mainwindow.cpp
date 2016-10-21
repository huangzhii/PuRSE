#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <iostream>
#include <QGraphicsScene>
#include <QThread>
#include <string>
#include <opencv/cv.h>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include "zhi_transformation_x.h"


MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    x_offset = 0;
    y_offset = 0;
    z_offset = 0;
    yaw_offset = 0;
    //imgFrame = "0";
    zeroString = "0";
    frame = 25;
    timer=new QTimer(this);
    timer->start(100);
    connect(timer,SIGNAL(timeout()),this,SLOT(imageAnimation()));


}

void MainWindow::setyoffset(float val){
  y_offset = val;
}

void MainWindow::imageAnimation(){
    y_offset += 0.04;
    yaw_offset += 0.2;
    std::cout<< frame << std::endl;
    imgFrame = std::to_string( frame );
    std::string depthPath = "../gui/data/depthRGB/"+imgFrame+".png";
    while (imgFrame.length() < 10){
        imgFrame = zeroString + imgFrame;
    }
    std::string imgPath = "../gui/data/rgb/"+imgFrame+".png";
    //std::cout << imgPath << std::endl;
    img = cv::imread(imgPath);
    velo_dense = cv::imread(depthPath);
    cv::cvtColor(velo_dense, velo_dense, cv::COLOR_BGR2RGB);

    cv::Mat new_img = trans_x(x_offset, y_offset, z_offset, yaw_offset, img, velo_dense);

    //cv::namedWindow("PuRSE");
    //cv::imshow("PuRSE", img);
    //cv::waitKey(10);

    cv::cvtColor(new_img, new_img, cv::COLOR_BGR2RGB);
    QImage image = QImage((const uchar*)new_img.data, new_img.cols, new_img.rows, new_img.step, QImage::Format_RGB888);
    ui->QImgShow->setPixmap(QPixmap::fromImage(image).scaled(ui->QImgShow->size()));

    //cv::waitKey(10);
    frame++;
    if(frame > 296){
        frame = 0;
    }

    update();
}

MainWindow::~MainWindow()
{
    delete ui;
}
