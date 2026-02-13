import sys
import os
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from backend.bridge import BackendBridge
from backend.user_db import UserDatabase as Database
from backend.system_db import SystemDatabase

app = QApplication(sys.argv)
system_db = SystemDatabase()
db = Database()

engine = QQmlApplicationEngine()

bridge = BackendBridge()
engine.rootContext().setContextProperty("backend", bridge)
engine.rootContext().setContextProperty("system_db", system_db)
engine.rootContext().setContextProperty("db", db)

qml_file = os.path.join(os.path.dirname(__file__), "ui", "main.qml")
engine.load(qml_file)

if not engine.rootObjects():
    sys.exit(-1)

sys.exit(app.exec())