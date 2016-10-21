#include "mainwindow.h"
#include "controlwindow.h"
#include <QApplication>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
//#include <opencv2\opencv.hpp>
#include <iostream>
#include <string>
#include "zhi_transformation_x.h"

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    MainWindow w;
    ControlWindow c;
    w.show();
    //w.setyoffset(-2);
    c.show();

    return a.exec();
}

