#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <QQuickView>
#include <QGuiApplication>
#include <QQmlContext>
#include <QSortFilterProxyModel>

#include <sailfishapp.h>
#include "effectsmodel.h"
#include "exposuremodel.h"
#include "isomodel.h"
#include "resolutionmodel.h"
#include "wbmodel.h"
#include "focusmodel.h"
#include "flashmodel.h"
#include "fsoperations.h"
#include "resourcehandler.h"

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
    qmlRegisterType<IsoModel>("uk.co.piggz.harbour_advanced_camera", 1, 0, "IsoModel");
    qmlRegisterType<ResolutionModel>("uk.co.piggz.harbour_advanced_camera", 1, 0, "ResolutionModel");
    qmlRegisterType<WbModel>("uk.co.piggz.harbour_advanced_camera", 1, 0, "WhiteBalanceModel");
    qmlRegisterType<FocusModel>("uk.co.piggz.harbour_advanced_camera", 1, 0, "FocusModel");
    qmlRegisterType<FlashModel>("uk.co.piggz.harbour_advanced_camera", 1, 0, "FlashModel");
    qmlRegisterType<FSOperations>("uk.co.piggz.harbour_advanced_camera", 1, 0, "FSOperations");

    ResolutionModel resolutionModel;
    QSortFilterProxyModel sortedResolutionModel;
    sortedResolutionModel.setSourceModel(&resolutionModel);
    sortedResolutionModel.setSortRole(ResolutionModel::ResolutionMpx);
    sortedResolutionModel.sort(0, Qt::DescendingOrder);

    QQuickView *view = SailfishApp::createView();

    ResourceHandler handler;
    handler.acquire();

    view->rootContext()->setContextProperty("modelResolution", &resolutionModel);
    view->rootContext()->setContextProperty("sortedModelResolution", &sortedResolutionModel);
    view->setSource(SailfishApp::pathTo("qml/harbour-advanced-camera.qml"));

    QObject::connect(view, &QQuickView::focusObjectChanged, &handler,
                     &ResourceHandler::handleFocusChange);

    view->show();

    return app->exec();
}
