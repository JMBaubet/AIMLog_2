# This Python file uses the following encoding: utf-8
import sys
import os
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from PySide6.QtCore import QObject, Slot, Signal
from PySide6.QtCore import QSettings
from PySide6.QtCore import QStandardPaths

from PySide6.QtSql import QSqlDatabase

import rc_icons # Utile pour avoir les icons dans le menu de gauche

class CheckSetting():
    def __init__(self, backend, settings):

        dir = QStandardPaths.writableLocation(QStandardPaths.AppLocalDataLocation)
        #print("Dossier de trvail : {}".format(dir))
        if not (os.path.isdir(dir)):
            os.makedirs(dir)
            os.makedirs(dir + "/sandBox/importCnx")
            os.makedirs(dir + "/sandBox/importEvt")

        # On récupère la couleur et le mode de l'application
        couleur = settings.value("Couleur")
        if not couleur is None:
            print("Couleur : {}".format(couleur))
            backend.setColor.emit(couleur)
        mode = settings.value("Mode")
        if not mode is None:
            print("Mode : {}".format(mode))
            backend.setMode.emit(mode)

        # Vérification de la déclaration des repertoires
        check = 1
        nameDossierConnexions = settings.value("cnx/dir")
        if not nameDossierConnexions is None:
            print("Dossier des connexions : {}".format(nameDossierConnexions))
            backend.setConnexionDir.emit(nameDossierConnexions)
        else:
            check = 0

        nameDossierEvenements = settings.value("evt/dir")
        if not nameDossierEvenements is None:
            print("Dossier des evenements : {}".format(nameDossierEvenements))
            backend.setEvenementDir.emit(nameDossierEvenements)
        else:
            check = 0

        nameDossierBdd = settings.value("bdd/dir")
        if not nameDossierBdd is None:
            print("Dossier des bases de données : {}".format(nameDossierBdd))
            backend.setBddDir.emit(nameDossierBdd)
        else:
            check = 0

        if check == 0 : # Il y-a au moins unparamètre non défini, il faut afficher la page preferences
            backend.affichePreferences.emit()



class Backend(QObject):
    def __init__(self, settings):
        QObject.__init__(self)


    # definition des signaux
    setDatabase = Signal(str)
#    setConnexionDir = Signal(str)
#    setEvenementDir = Signal(str)
    setBddDir = Signal(str)
    affichePreferences = Signal()
    setColor = Signal(int) # main.qml
    setMode = Signal(int)  # main.qml
#    setNoWorkingDir = Signal() # main.qml, QML/pages/preference.qml



    @Slot(str)
    def selectDatabase(self, myDatabase):
        print("Sélection de la bdd : {}".format(myDatabase))
        self.setDatabase.emit("<b>{}</b>".format(myDatabase))

    @Slot(str)
    def sauveDossierConnexions(self, nomDossier, settings):
        settings.setValue("cnx/dir", nomDossier)

    """
    # Sélection du dossier de travail.
    @Slot(str)
    def workingDir(self, dossier): # QML/pages/preference.qml
        settings.setValue("workingDir", dossier)
        # On vérifie si ce dossier est vide
        if len(os.listdir(dossier)):
            print("Dossier nom vide")
            # On refuse le changement et on le signal
            self.setNoWorkingDir.emit()
        else:
            # Le dossier est vide.
            # Il faut céer les dossiers importCnx et ImportEvt, ainsi que la base de dnnées bac à sable
             self.setBddDir.emit(dossier)
    """

    @Slot(int)
    def selectionColor(self, color):
        settings.setValue("Couleur", color)
        self.setColor.emit(color)

    @Slot(int)
    def selectionMode(self, mode):
        settings.setValue("Mode", mode)
        self.setMode.emit(mode)


####################################@@
# main.py
####################################@@
if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    # Définition de l'environnement pour l'archivage des paramètres
    app.setOrganizationName("Adder")
#    app.setOrganizationDomain("lfpg.aviation-civile.gouv.fr")
    app.setApplicationName("AIMLog 2")
    settings = QSettings()

    # Get Context
    backendWindow = Backend(settings)
    engine.rootContext().setContextProperty("backend", backendWindow)

    # Load QML file
    qml_file = Path(__file__).resolve().parent / "qml/main.qml"
#    qml_file = Path(__file__).resolve().parent / "qml/myWidgets/MySpinBox.qml"
    engine.load(qml_file)
    if not engine.rootObjects():
        sys.exit(-1)

    CheckSetting(backendWindow, settings)
    sys.exit(app.exec())

