# This Python file uses the following encoding: utf-8
import sys  # import os
from enum import Enum
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QObject, Slot, Signal
from PySide6.QtCore import QSettings  # from PySide6.QtCore import QStandardPaths
from PySide6.QtSql import QSqlDatabase
from PySide6.QtCore import QStandardPaths, QDateTime

from modules.myFunction import checkSetting, createDomaine, removeDomaine, retentionChanged
from modules.myFunction import backupRetention, loadRetention, checkConnexionFile, checkEventFile
from modules.myFunction import supprimeFile, inmportCnxToBdd, inmportEvtToBdd, lanceAnalyse
from modules.mySQLite import changeDatabase, listPosition, firstDate

import rc_icons  # Utile pour avoir les icons dans le menu de gauche


class Backend(QObject):


    file_connexion = []
    file_event = []

    def __init__(self, settings):
        QObject.__init__(self)

    class TypeMsg(Enum):  # Pour amélioration voir https://stackoverflow.com/questions/27004250/pyqt5-qml-exporting-enum
        Debug = 0
        Info = 1
        Warning = 2
        Error = 3
        Critical =4


    # definition des signaux
    setDatabase = Signal(str)
    setBddDir = Signal(str)
    setMsg = Signal(str, int)           # main.qml
    setFile = Signal(list, str)         # QML/myWidgets/ImportFiles
    affichePreferences = Signal()
    initDomaines = Signal(list, str)    # QML/myWidgets/ChoixDomaine.qml
    setDomaines = Signal(list)          # QML/myWidgets/ChoixDomaine.qml
    setDomaine = Signal(str)            # main.qml, QML/myWidgets/preference.qml
    setRetention = Signal("QVariant")   # QML/myWidgets/ChoixDomaine.qml
    changeRetention = Signal(bool)      # QML/myWidgets/ChoixDomaine.qml
    changeDomaine = Signal(bool)        # QML/myWidgets/ChoixDomaine.qml
    setColor = Signal(int)              # main.qml
    setMode = Signal(int)               # main.qml
    setNbFileCnx = Signal(int)          # QML/myWidgets/connexion.qml
    resetSelection = Signal()
    setNbFileEvt = Signal(int)          # QML/myWidgets/evenement.qml
    setDate = Signal(int, int, int, str)
    setHeure = Signal(int, int)
    setListPositions = Signal(list)     # pages/home.qml
    setSelectedPosition = Signal()      # pages/home.qml
    setDates = Signal(list)             # QML/myWidgets/SelectDate
    setData = Signal(list, str)              # QML/MyWidgets/Connexions.qml
    setHeureSelect = Signal(QDateTime, str)           # main.qml


    #    setNoWorkingDir = Signal() # main.qml, QML/pages/preference.qml

    @Slot(int)
    def selectionMode(self, mode):
        settings.setValue("Mode", mode)
        self.setMode.emit(mode)


    @Slot()
    def lireCnxFile(self):
        checkConnexionFile(backendWindow, settings)
        self.file_connexion.clear()
        self.setNbFileCnx.emit(len(self.file_connexion))

    @Slot()
    def lireEvtFile(self):
        checkEventFile(backendWindow, settings)
        self.file_event.clear()
        self.setNbFileEvt.emit(len(self.file_event))


    @Slot(str)
    def newDomaine(self, name):
        print("creation du domaine : {}".format(name))
        createDomaine(backendWindow,
                      settings,
                      mydb,
                      QStandardPaths.writableLocation(QStandardPaths.AppLocalDataLocation),
                      name)
        # TODO
        # Il faut mettre un message dans le bottom

    @Slot(str)
    def preselectDomaine(self, name):
        if settings.value("DomaineActif") == name:
            bouton_valide = False
        else:
            # Il faut valider les boutons supprimer et selectionner
            bouton_valide = True
        self.changeDomaine.emit(bouton_valide)
        self.setRetention.emit(loadRetention(settings, name))
        # Il faut lire les settings du domaine pour mettre à jour les paramètres



    @Slot(str)
    def selectDomaine(self, name):
        changeDatabase(mydb, name)
        settings.setValue("DomaineActif", name)
        self.changeDomaine.emit(False)
        self.setDomaine.emit(name)
        # Il faut mettre à jour les chmaps dates et la liste des position dans preference.qml
        self.setListPositions.emit(listPosition(mydb, name))
        self.setDates.emit(firstDate(mydb, name))


    @Slot(str)
    def delDomaine(self, name):
        print("suppression du domaine : {}".format(name))
        self.setDomaines.emit(removeDomaine(backendWindow,
                              settings,
                              mydb,
                              QStandardPaths.writableLocation(QStandardPaths.AppLocalDataLocation),
                              name))

    @Slot(str, int, str, int, str, int, str)
    def checkRetention(self, domaine, bddDuree, bddUnite, cnxDuree, cnXUnite, evtDuree, evtUnite):
        self.changeRetention.emit(
            retentionChanged(settings, domaine, bddDuree, bddUnite, cnxDuree, cnXUnite, evtDuree, evtUnite))

    @Slot(str, int, str, int, str, int, str)
    def saveRetention(self, domaine, bdd_duree, bdd_unite, cnx_duree, cnx_unite, evt_duree, evt_unite):
        backupRetention(settings, domaine, bdd_duree, bdd_unite, cnx_duree, cnx_unite, evt_duree, evt_unite)

    @Slot(int)
    def selectionColor(self, color):
        print("On sauvegarde la couleur : {}".format(color))
        settings.setValue("Couleur", color)
        self.setColor.emit(color)

    @Slot(str, bool)
    def changeSelectFileCnx(self, fichier, etat):
        # print("changeSelectFileCnx : Fichier : <{}>, Etat : <{}>".format(fichier, etat))
        if etat :
            self.file_connexion.append(fichier)
        else :
            self.file_connexion.remove(fichier)
        # print("Nombre de fichier : <{}>".format(len(self.file_connexion)))
        self.setNbFileCnx.emit(len(self.file_connexion))


    @Slot(str, bool)
    def changeSelectFileEvt(self, fichier, etat):
        print("changeSelectFileEvt : Fichier : <{}>, Etat : <{}>".format(fichier, etat))
        if etat :
            self.file_event.append(fichier)
        else :
            self.file_event.remove(fichier)
        print("Nombre de fichier : <{}>".format(len(self.file_event)))
        self.setNbFileEvt.emit(len(self.file_event))

    @Slot(int)
    def delCnxFile(self, nbFile):
        erreur = 0
        message = ""
        # print("delCnxFile : nbFichier : <{}>".format(nbFile))
        # print("list des fichiers : <{}>".format(self.file_connexion))
        if len(self.file_connexion) != nbFile :
            # on a un problème, il faut prévenir l'opérateur
            message = "Le nombre de fichiers sélectionnés ne semble pas correct !"
            erreur = 2
        else :

            for fichier in self.file_connexion:
                # print("on traite  {} de la liste des fichiers sélectionnés".format(fichier))
                erreur, message = supprimeFile(backendWindow, fichier)
                if not erreur:
                    if len(self.file_connexion) > 1 :
                        message = "les fichiers ont été supprimés."
                    else:
                        message = "Le fichier a été supprimé."
        self.file_connexion.clear()
        self.setMsg.emit(message, erreur)
        checkConnexionFile(backendWindow, settings)
        self.setNbFileCnx.emit(len(self.file_connexion))


    @Slot(int)
    def delEvtFile(self, nbFile):
        erreur = 0
        message = ""
        # print("delEvtFile : nbFichier : <{}>".format(nbFile))
        # print("list des fichiers : <{}>".format(self.file_connexion))
        if len(self.file_event) != nbFile :
            # on a un problème, il faut prévenir l'opérateur
            message = "Le nombre de fichiers sélectionnés ne semble pas correct !"
            erreur = 2
        else :
            for fichier in self.file_event:
                # print("on traite  {} de la liste des fichiers sélectionnés".format(fichier))
                erreur, message = supprimeFile(backendWindow, fichier)
                if not erreur:
                    if len(self.file_event) > 1 :
                        message = "les fichiers ont été supprimés."
                    else:
                        message = "Le fichier a été supprimé."
        self.file_event.clear()
        self.setNbFileEvt.emit(len(self.file_event))
        self.setMsg.emit(message, erreur)
        checkEventFile(backendWindow, settings)



    @Slot(int)
    def importCnxFile(self, nbFile):
        # print("importCnxFile : nbFichier : <{}>".format(nbFile))
        # print("list des fichiers : <{}>".format(self.file_connexion))
        if len(self.file_connexion) != nbFile :
            # on a un problème, il faut prévenir l'opérateur
            self.setMsg.emit("On a un problème..", self.TypeMsg.Error)
            pass
        else :
            for fichier in self.file_connexion:
                erreur, message = inmportCnxToBdd(settings, mydb, fichier)
                # if not erreur:
                #    if len(self.file_event) > 1 :
                #        message = "les fichiers ont été impotés."
                #    else:
                #        message = "Le fichier a été importé."
        self.file_connexion.clear()
        self.setMsg.emit(message, erreur)
        self.resetSelection.emit()
        checkConnexionFile(backendWindow, settings)
        self.setNbFileCnx.emit(len(self.file_connexion))


    @Slot(int)
    def importEvtFile(self, nbFile):
        # print("importEvtFile : nbFichier : <{}>".format(nbFile))
        # print("list des fichiers : <{}>".format(self.file_connexion))
        if len(self.file_event)  != nbFile :
            # on a un problème, il faut prévenir l'opérateur
            self.setMsg.emit("On a un problème..", self.TypeMsg.Error)
            pass
        else :
            for fichier in self.file_event:
                erreur, message = inmportEvtToBdd(settings, mydb, fichier)
                # if not erreur:
                #    if len(self.file_event) > 1 :
                #        message = "les fichiers ont été impotés."
                #    else:
                #        message = "Le fichier a été importé."
        self.file_event.clear()
        self.setMsg.emit(message, erreur)
        self.resetSelection.emit()
        checkEventFile(backendWindow, settings)
        self.setNbFileEvt.emit(len(self.file_connexion))

    @Slot(int, int, int, str)
    def dateSelected(self, jour, mmois, annee, dateText):
        self.setDate.emit(jour, mmois, annee, dateText)

    @Slot(int, int)
    def heureSelected(self, heure, minute):
        self.setHeure.emit(heure, minute)


    @Slot(str, int)
    def sendMessage(self, message, level):
        self.setMsg.emit(message, level)

    @Slot()
    def selectSite(self):
        self.setSelectedPosition.emit()


    @Slot(QDateTime, str)
    def analyse(self, myDate, position):

        # print("date : {}".format(myDate.date() ))
        # print("heure : {}".format(myDate.time() ))
        listCnx, listEvt = lanceAnalyse(settings, mydb, myDate, position)
        self.setData.emit(listCnx, position)
        # self.setData.emit(listCnx, listEvt)


    @Slot(int, QDateTime)
    def moveCurseur(self, x, dateEvent):
        # print("PoisitionX : {}".format(x))
        dateCurseur = dateEvent.addSecs(x - 940)
        # print("Heure sélectionnée : {}".format(dateCurseur.toString("HH.mm.ss") ))
        self.setHeureSelect.emit(dateCurseur, dateCurseur.toString("HH.mm.ss"))



####################################@@
# main.py
####################################@@
if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    # Définition de l'environnement pour l'archivage des paramètres
    app.setOrganizationName("Adder")
    #    app.setOrganizationDomain("lfpg.aviation-civile.gouv.fr")
    app.setApplicationName("AIMLog2")

    mydb = QSqlDatabase.addDatabase("QSQLITE")

    # Get Context
    settings = QSettings()
    backendWindow = Backend(settings)
    engine.rootContext().setContextProperty("backend", backendWindow)

    # Load QML file
    qml_file = Path(__file__).resolve().parent / "qml/main.qml"
    engine.load(qml_file)
    if not engine.rootObjects():
        print("Fichier <{}> non trouvé".format("qml/main.qml"))
        sys.exit(-1)

    checkSetting(backendWindow, settings, mydb)

    # checkConnexionFile(backendWindow, settings)

    sys.exit(app.exec())
