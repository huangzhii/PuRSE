#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QGraphicsScene>
#include <QTimer>
#include <string>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = 0);
    void setyoffset(float val);
    ~MainWindow();

public slots:
    void imageAnimation();

private:
    double x_offset;
    double y_offset;
    double z_offset;
    double yaw_offset; // degree
    Ui::MainWindow *ui;
    QGraphicsScene *scene;
    QPixmap image;
    int frame;
    QTimer *timer;
    std::string imgFrame;
    std::string depthFrame;
    std::string zeroString;
    cv::Mat img;
    cv::Mat velo_dense;
};

#endif // MAINWINDOW_H
