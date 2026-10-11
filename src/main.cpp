#include <QCommandLineParser>
#include <QDBusConnection>
#include <QDBusInterface>
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>

#include "widgetsservice.h"

static const QString DBusService = QStringLiteral("com.lingmo.Widgets");
static const QString DBusPath = QStringLiteral("/Widgets");

int main(int argc, char *argv[]) {
    // QApplication: the status bar icon's menu is a QMenu
    QApplication app(argc, argv);
    QGuiApplication::setOrganizationName("lingmoos");
    QGuiApplication::setApplicationName("lingmo-widgets");
    QGuiApplication::setDesktopFileName(QStringLiteral("lingmo-widgets"));
    // Closing the Widget Center keeps the desktop widgets running
    app.setQuitOnLastWindowClosed(false);

    QCommandLineParser parser;
    parser.addHelpOption();
    QCommandLineOption background(QStringLiteral("background"),
                                  QStringLiteral("Start with the widgets only, without the Widget Center (session autostart)"));
    parser.addOption(background);
    parser.process(app);

    // One instance: a second launch shows the running one's Widget Center
    QDBusConnection bus = QDBusConnection::sessionBus();
    if (!bus.registerService(DBusService)) {
        if (!parser.isSet(background)) {
            QDBusInterface iface(DBusService, DBusPath, DBusService, bus);
            iface.call(QStringLiteral("showCenter"));
        }
        return 0;
    }

    WidgetsService service;
    bus.registerObject(DBusPath, &service, QDBusConnection::ExportAllSlots);

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("widgetsService"), &service);
    engine.rootContext()->setContextProperty(QStringLiteral("startInBackground"), parser.isSet(background));
    engine.load(QUrl(QStringLiteral("qrc:/qml/Main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}

