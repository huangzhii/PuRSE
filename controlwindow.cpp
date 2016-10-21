#include "controlwindow.h"
#include "mainwindow.h"
#include "ui_controlwindow.h"
#include <iostream>

ControlWindow::ControlWindow(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::ControlWindow)
{
    ui->setupUi(this);
    QPixmap logo("../gui/data/logo.png");
    ui->logolabel->setPixmap(logo);
    ui->logolabel->setScaledContents(true);
    QPixmap keyimg("../gui/data/keyimg.png");
    ui->keyboardimg->setPixmap(keyimg);
    ui->keyboardimg->setScaledContents(true);

    timer=new QTimer(this);
    timer->start(100);
    connect(timer,SIGNAL(timeout()),this,SLOT(updateControlWindow()));
}
void ControlWindow::updateControlWindow(){

    //std::cout << MainWindow::getyoffset() << std::endl;
    ui->horizontalmove->setText("0");
    ui->yawchange->setText("0");
    update();
}

ControlWindow::~ControlWindow()
{
    delete ui;
}
