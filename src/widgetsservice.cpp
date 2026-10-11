#include "widgetsservice.h"

#include <QApplication>
#include <QEvent>
#include <QIcon>
#include <QScreen>
#include <QWindow>

#include <KWindowSystem>
#include <KX11Extras>

WidgetsService::WidgetsService(QObject *parent)
    : QObject(parent)
{
    m_clock = m_menu.addAction(tr("Relógio"));
    m_clock->setCheckable(true);
    connect(m_clock, &QAction::toggled, this, [this](bool on) {
        updateTray();
        Q_EMIT widgetToggled(QStringLiteral("clock"), on);
    });

    m_weather = m_menu.addAction(tr("Previsão do Tempo"));
    m_weather->setCheckable(true);
    connect(m_weather, &QAction::toggled, this, [this](bool on) {
        updateTray();
        Q_EMIT widgetToggled(QStringLiteral("weather"), on);
    });

    m_location = m_menu.addAction(tr("Escolher local do clima…"));
    connect(m_location, &QAction::triggered, this, &WidgetsService::chooseLocationRequested);

    m_menu.addSeparator();
    connect(m_menu.addAction(tr("Central de Widgets…")), &QAction::triggered,
            this, &WidgetsService::showCenterRequested);
    connect(m_menu.addAction(tr("Fechar widgets")), &QAction::triggered, qApp, &QCoreApplication::quit);

    m_tray.setIcon(QIcon::fromTheme(QStringLiteral("cs-desklets"),
                                    QIcon::fromTheme(QStringLiteral("preferences-desktop"))));
    m_tray.setToolTip(tr("Widgets"));
    m_tray.setContextMenu(&m_menu);
    // A plain click opens the Widget Center; the menu has the per-widget switches
    // Monitors plugged in or out, or another one made primary: move the widgets along
    connect(qApp, &QGuiApplication::primaryScreenChanged, this, &WidgetsService::primaryScreenChanged);
    connect(qApp, &QGuiApplication::screenAdded, this, &WidgetsService::primaryScreenChanged);
    connect(qApp, &QGuiApplication::screenRemoved, this, &WidgetsService::primaryScreenChanged);

    connect(&m_tray, &QSystemTrayIcon::activated, this, [this](QSystemTrayIcon::ActivationReason reason) {
        if (reason == QSystemTrayIcon::Trigger || reason == QSystemTrayIcon::DoubleClick)
            Q_EMIT showCenterRequested();
    });
}

QString WidgetsService::primaryScreenName() const
{
    const QScreen *screen = QGuiApplication::primaryScreen();
    return screen ? screen->name() : QString();
}

void WidgetsService::keepOffTaskbar(QWindow *window)
{
    if (!window || !KWindowSystem::isPlatformX11() || m_offTaskbar.contains(window))
        return;
    // Qt rewrites _NET_WM_STATE whenever it maps the window, so the state is
    // (re)applied once the window is actually on screen, on every show
    m_offTaskbar.insert(window);
    window->installEventFilter(this);
    connect(window, &QObject::destroyed, this, [this, window] { m_offTaskbar.remove(window); });
    if (window->isExposed())
        KX11Extras::setState(window->winId(), NET::SkipTaskbar | NET::SkipPager | NET::SkipSwitcher);
}

bool WidgetsService::eventFilter(QObject *object, QEvent *event)
{
    if (event->type() == QEvent::Expose) {
        auto *window = static_cast<QWindow *>(object);
        if (window->isExposed())
            KX11Extras::setState(window->winId(), NET::SkipTaskbar | NET::SkipPager | NET::SkipSwitcher);
    }
    return QObject::eventFilter(object, event);
}

void WidgetsService::setWidgetEnabled(const QString &name, bool enabled)
{
    QAction *action = name == QLatin1String("clock") ? m_clock
                    : name == QLatin1String("weather") ? m_weather : nullptr;
    if (!action || action->isChecked() == enabled)
        return;
    const QSignalBlocker blocker(action);  // coming from the settings: don't echo it back
    action->setChecked(enabled);
    updateTray();
}

void WidgetsService::updateTray()
{
    m_location->setEnabled(m_weather->isChecked());
    // The icon stands for the active widgets: none active, no icon
    m_tray.setVisible(m_clock->isChecked() || m_weather->isChecked());
}
