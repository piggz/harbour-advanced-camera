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
    src/exposuremodel.cpp

DISTFILES += qml/harbour-advanced-camera.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-advanced-camera.changes.in \
    rpm/harbour-advanced-camera.changes.run.in \
    rpm/harbour-advanced-camera.spec \
    rpm/harbour-advanced-camera.yaml \
    translations/*.ts \
    harbour-advanced-camera.desktop \
    qml/pages/CameraUI.qml \
    qml/components/RoundButton.qml

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-advanced-camera-de.ts

HEADERS += \
    src/effectsmodel.h \
    src/exposuremodel.h
