import sys
from PySide6.QtCore import QObject, Slot, Signal
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

class Backend(QObject):

    @Slot(str)
    def run_command(self, text):
        print(f"Command received from UI: {text}")

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    backend = Backend()
    engine.rootContext().setContextProperty("backend", backend)

    engine.load("app/ui/main.qml")

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())