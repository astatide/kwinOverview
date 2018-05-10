#include <QObject>
#include <QCursor>
#include <QString>
#include <QGuiApplication>
//#include <QQmlApplicationEngine>
#include <QQuickView>
#include <QQmlContext>

// Shamelessly taken from https://stackoverflow.com/questions/39088835/dragging-frameless-window-jiggles-in-qml
class CursorPosProvider : public QObject
{
    Q_OBJECT
public:
    explicit CursorPosProvider(QObject *parent = nullptr) : QObject(parent)
    {
    }
    virtual ~CursorPosProvider() = default;

    Q_INVOKABLE QPointF cursorPos()
    {
        return QCursor::pos();
    }
};

#include "mouse.moc" // <----- This will make it work

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQuickView view;

    CursorPosProvider mousePosProvider;

    view.rootContext()->setContextProperty("mousePosition", &mousePosProvider);

    view.setSource(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
