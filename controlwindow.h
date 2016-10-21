#ifndef CONTROLWINDOW_H
#define CONTROLWINDOW_H

#include <QWidget>

namespace Ui {
class ControlWindow;
}

class ControlWindow : public QWidget
{
    Q_OBJECT

public:
    explicit ControlWindow(QWidget *parent = 0);
    ~ControlWindow();

public slots:
    void updateControlWindow();

private:
    Ui::ControlWindow *ui;
    QTimer *timer;
};

#endif // CONTROLWINDOW_H
