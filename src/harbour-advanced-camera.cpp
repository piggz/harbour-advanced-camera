#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <QQuickView>
#include <QGuiApplication>
#include <QQmlContext>

#include <sailfishapp.h>
#include "effectsmodel.h"
#include "exposuremodel.h"

int main(int argc, char *argv[])
{
    // SailfishApp::main() will display "qml/harbour-advanced-camera.qml", if you need more
    // control over initialization, you can use:
    //
    //   - SailfishApp::application(int, char *[]) to get the QGuiApplication *
    //   - SailfishApp::createView() to get a new QQuickView * instance
    //   - SailfishApp::pathTo(QString) to get a QUrl to a resource file
    //   - SailfishApp::pathToMainQml() to get a QUrl to the main QML file
    //
    // To display the view, call "show()" (will show fullscreen on device).

    QGuiApplication *app = SailfishApp::application(argc, argv);

    qmlRegisterType<EffectsModel>("uk.co.piggz.harbour_advanced_camera", 1, 0, "EffectsModel");
    qmlRegisterType<ExposureModel>("uk.co.piggz.harbour_advanced_camera", 1, 0, "ExposureModel");

    QQuickView *view = SailfishApp::createView();

    view->setSource(SailfishApp::pathTo("qml/harbour-advanced-camera.qml"));
    view->show();

    return app->exec();
}
