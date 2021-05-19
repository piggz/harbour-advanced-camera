# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-advanced-camera

CONFIG += sailfishapp

QT += multimedia

SOURCES += src/harbour-advanced-camera.cpp \
    src/effectsmodel.cpp \
    src/exposuremodel.cpp \
    src/isomodel.cpp \
    src/resolutionmodel.cpp \
    src/wbmodel.cpp \
    src/focusmodel.cpp \
    src/flashmodel.cpp \
    src/fsoperations.cpp \
    src/resourcehandler.cpp \
    src/storagemodel.cpp

DISTFILES += rpm/harbour-advanced-camera.changes.in \
    README.md \
    qml/pics/icon-m-tele-lense-active.png \
    qml/pics/icon-m-tele-lense.svg \
    qml/pics/icon-m-uwide-lense-active.png \
    qml/pics/icon-m-uwide-lense.svg \
    qml/pics/icon-m-wide-lense-active.png \
    qml/pics/icon-m-wide-lense.svg \
    rpm/harbour-advanced-camera.changes.run.in \
    rpm/harbour-advanced-camera.spec \
    rpm/harbour-advanced-camera.yaml \
    translations/*.ts \
    harbour-advanced-camera.desktop \
    qml/harbour-advanced-camera.qml \
    qml/components/DockedListView.qml \
    qml/components/IconSwitch.qml \
    qml/components/RoundButton.qml \
    qml/cover/CoverPage.qml \
    qml/pages/CameraUI.qml \
    qml/pages/GalleryUI.qml \
    qml/pages/Settings.qml \
    qml/pages/SettingsOverlay.qml


SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-advanced-camera-de.ts \
                translations/harbour-advanced-camera-es.ts \
                translations/harbour-advanced-camera-fi.ts \
                translations/harbour-advanced-camera-fr.ts \
                translations/harbour-advanced-camera-sv.ts \
                translations/harbour-advanced-camera-zh_CN.ts

HEADERS += \
    src/effectsmodel.h \
    src/exposuremodel.h \
    src/isomodel.h \
    src/resolutionmodel.h \
    src/wbmodel.h \
    src/focusmodel.h \
    src/flashmodel.h \
    src/fsoperations.h \
    src/resourcehandler.h \
    src/storagemodel.h

LIBS += -ldl
