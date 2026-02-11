import sys
import os
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from backend.bridge import BackendBridge

app = QApplication(sys.argv)

engine = QQmlApplicationEngine()

bridge = BackendBridge()
engine.rootContext().setContextProperty("backend", bridge)

qml_file = os.path.join(os.path.dirname(__file__), "ui", "main.qml")
engine.load(qml_file)

if not engine.rootObjects():
    sys.exit(-1)

sys.exit(app.exec())