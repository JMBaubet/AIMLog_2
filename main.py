# This Python file uses the following encoding: utf-8
import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from PySide6.QtCore import QObject, Slot, Signal

import rc_icons

class Backend(QObject):
    def __init__(self):
        QObject.__init__(self)

    setDatabase = Signal(str)

    @Slot(str)
    def selectDatabase(self, myDatabase):
        print("Sélection de la bdd : {}".format(myDatabase))
        self.setDatabase.emit("<b>{}</b>".format(myDatabase))



if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    # Définition de l'environnement pour l'archivage des paramètres
    app.setOrganizationName("SNA-RP/CDG")
    app.setOrganizationDomain("lfpg.aviation-civile.gouv.fr")
    app.setApplicationName("AIMLog_2")

    # Get Context
    backendWindow = Backend()
    engine.rootContext().setContextProperty("backend", backendWindow)

    # Load QML file
    qml_file = Path(__file__).resolve().parent / "qml/main.qml"
    engine.load(qml_file)
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())

