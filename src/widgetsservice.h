#pragma once

#include <QAction>
#include <QMenu>
#include <QObject>
#include <QSet>
#include <QSystemTrayIcon>

class QWindow;

// The running instance: D-Bus entry point (a second launch shows the Widget
// Center) and the status bar icon that groups the active widgets
class WidgetsService : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "com.lingmo.Widgets")
    // The widgets sit on the primary monitor (QScreen::name, as in Qt.application.screens)
    Q_PROPERTY(QString primaryScreenName READ primaryScreenName NOTIFY primaryScreenChanged)

public:
    explicit WidgetsService(QObject *parent = nullptr);

    // Desktop widgets belong to the desktop, not to the dock or Alt+Tab
    Q_INVOKABLE void keepOffTaskbar(QWindow *window);
    // Keeps the status bar menu in sync with the settings (name: "clock", "weather")
    Q_INVOKABLE void setWidgetEnabled(const QString &name, bool enabled);

    QString primaryScreenName() const;

public Q_SLOTS:
    void showCenter() { Q_EMIT showCenterRequested(); }

Q_SIGNALS:
    void showCenterRequested();
    void chooseLocationRequested();
    void widgetToggled(const QString &name, bool enabled);
    void primaryScreenChanged();

protected:
    bool eventFilter(QObject *object, QEvent *event) override;

private:
    void updateTray();

    QSet<QWindow *> m_offTaskbar;
    QSystemTrayIcon m_tray;
    QMenu m_menu;
    QAction *m_clock;
    QAction *m_weather;
    QAction *m_location;
};
