# This Python file uses the following encoding: utf-8
import sys
from enum import Enum

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QObject, Slot, Signal
from PySide6.QtCore import QSettings  # from PySide6.QtCore import QStandardPaths
from PySide6.QtSql import QSqlDatabase
from PySide6.QtCore import QDateTime


from modules.myFunction import checkSetting, createDomaine, removeDomaine, retentionChanged
from modules.myFunction import backupRetention, loadRetention, checkConnexionFile, checkEventFile
from modules.myFunction import supprimeFile, inmportCnxToBdd, inmportEvtToBdd, lanceAnalyse
from modules.mySQLite import queryListPosition, queryGetDates

import rc_icons  # nécessaire pour avoir accès aux ressources
import rc_qml


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
        Critical = 4

    # definition des signaux
    setDatabase = Signal(str)
    setBddDir = Signal(str)
    setMsg = Signal(str, int)  # main.qml
    setFile = Signal(list, str)  # QML/myWidgets/ImportFiles
    affichePreferences = Signal()
    initDomaines = Signal(list, str)  # QML/myWidgets/ChoixDomaine.qml
    setDomaines = Signal(list)  # QML/myWidgets/ChoixDomaine.qml
    setDomaine = Signal(str)  # main.qml, QML/myWidgets/preference.qml
    setRetention = Signal("QVariant")  # QML/myWidgets/ChoixDomaine.qml
    changeRetention = Signal(bool)  # QML/myWidgets/ChoixDomaine.qml
    changeDomaine = Signal(bool)  # QML/myWidgets/ChoixDomaine.qml
    setColor = Signal(int)  # main.qml
    setMode = Signal(int)  # main.qml
    setNbFileCnx = Signal(int)  # QML/myWidgets/connexion.qml
    resetSelection = Signal()
    setNbFileEvt = Signal(int)  # QML/myWidgets/evenement.qml
    setDate = Signal(int, int, int, str)
    setHeure = Signal(int, int)
    setListPositions = Signal(list)  # pages/pgAnalyse.qml
    setSelectedPosition = Signal()  # pages/pgAnalyse.qml
    resetDataAnalyse = Signal() # pages/pgAnalyse.qml
    setDates = Signal(list)  # QML/myWidgets/SelectDate
    setData = Signal(list, str, QDateTime, QDateTime, QDateTime)  # QML/MyWidgets/Connexions.qml
    setHeureSelect = Signal(QDateTime, str)  # main.qml

    #    setNoWorkingDir = Signal() # main.qml, QML/pages/preference.qml

    @Slot(int)
    def selectionMode(self, mode):
        """ Mode Sombre ou Clair de l'IHM.

        Cette fonction permet de changer le mode d'affichage de l'IHM.
        Le mode sélectionné est enregistré dans les settings de l'application.

        Parameters
        ----------
        mode : entier
            Le mode : 0 Claire, 1 Sombre, 2 System

        Returns
        -------

        Emet les signaux
        --------------
            setMode avec le nouveau mode sélectionné
        """

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
        # print("creation du domaine : {}".format(name))
        if (createDomaine(backendWindow, settings, mydb, name) == 0) :
            self.setMsg.emit("Le domaine {} a été créé.".format(name), 1)
        else:
            self.setMsg.emit("Le domaine {} éxiste déjà.".format(name), 2)


    @Slot(str)
    def preselectDomaine(self, name):
        # print("nom du domaine : <{}>".format(name))
        if settings.value("DomaineActif") == name:
            bouton_valide = False
        else:
            # Il faut valider les boutons supprimer et selectionner
            bouton_valide = True
        self.changeDomaine.emit(bouton_valide)
        self.setRetention.emit(loadRetention(settings, name))
        # Il faut lire les settings du domaine pour mettre à jour les paramètres

    @Slot(str)
    def selectDomaine(self, domaine):
        # changeDatabase(mydb, domaine)
        settings.setValue("DomaineActif", domaine)
        self.changeDomaine.emit(False)
        self.setDomaine.emit(domaine)

        settings.beginGroup(domaine)
        color = settings.value("Couleur")
        settings.endGroup()
        # print("Couleur lue pour le domaine {} : <{}>".format(domaine, color))
        self.setColor.emit(color)


        # On met à jour les champs dates et la liste des positions dans pgPref.qml
        self.setListPositions.emit(queryListPosition(mydb, domaine))
        self.setDates.emit(queryGetDates(mydb, domaine))

        # Reinitialisation de la pgAnalyse (Date selectionnee, heure selectionnee, et masque du schema en cours)
        self.resetDataAnalyse.emit()

    @Slot(str)
    def delDomaine(self, name):
        # print("suppression du domaine : {}".format(name))
        removeDomaine(backendWindow, settings, mydb, name)
        self.setMsg.emit("le domaine {} a été suppirmé.".format(name), 1)

    @Slot(str, int, str, int, str, int, str)
    def checkRetention(self, domaine, bddDuree, bddUnite, cnxDuree, cnXUnite, evtDuree, evtUnite):
        self.changeRetention.emit(
            retentionChanged(settings, domaine, bddDuree, bddUnite, cnxDuree, cnXUnite, evtDuree, evtUnite))

    @Slot(str, int, str, int, str, int, str)
    def saveRetention(self, domaine, bdd_duree, bdd_unite, cnx_duree, cnx_unite, evt_duree, evt_unite):
        backupRetention(settings, domaine, bdd_duree, bdd_unite, cnx_duree, cnx_unite, evt_duree, evt_unite)

    @Slot(int)
    def selectionColor(self, color):
        # Lecture du domaine actif
        domaine = settings.value("DomaineActif")
        settings.beginGroup(domaine)
        settings.setValue("Couleur", color)
        settings.endGroup()
        # print("On enregistre la couleur <{}> pour le domaine {}.".format(color, domaine))
        self.setColor.emit(color)

    @Slot(str, bool)
    def changeSelectFileCnx(self, fichier, etat):
        # print("changeSelectFileCnx : Fichier : <{}>, Etat : <{}>".format(fichier, etat))
        if etat:
            self.file_connexion.append(fichier)
        else:
            self.file_connexion.remove(fichier)
        # print("Nombre de fichier : <{}>".format(len(self.file_connexion)))
        self.setNbFileCnx.emit(len(self.file_connexion))

    @Slot(str, bool)
    def changeSelectFileEvt(self, fichier, etat):
        print("changeSelectFileEvt : Fichier : <{}>, Etat : <{}>".format(fichier, etat))
        if etat:
            self.file_event.append(fichier)
        else:
            self.file_event.remove(fichier)
        print("Nombre de fichier : <{}>".format(len(self.file_event)))
        self.setNbFileEvt.emit(len(self.file_event))

    @Slot(int)
    def delCnxFile(self, nbFile):
        erreur = 1
        message = ""
        # print("delCnxFile : nbFichier : <{}>".format(nbFile))
        # print("list des fichiers : <{}>".format(self.file_connexion))
        if len(self.file_connexion) != nbFile:
            # on a un problème, il faut prévenir l'opérateur
            message = "Le nombre de fichiers sélectionnés ne semble pas correct !"
            erreur = 2
        else:

            for fichier in self.file_connexion:
                # print("on traite  {} de la liste des fichiers sélectionnés".format(fichier))
                erreur, message = supprimeFile(fichier)
                if not erreur:
                    erreur = 1
                    if len(self.file_connexion) > 1:
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
        if len(self.file_event) != nbFile:
            # on a un problème, il faut prévenir l'opérateur
            message = "Le nombre de fichiers sélectionnés ne semble pas correct !"
            erreur = 2
        else:
            for fichier in self.file_event:
                # print("on traite  {} de la liste des fichiers sélectionnés".format(fichier))
                erreur, message = supprimeFile(fichier)
                if not erreur:
                    erreur = 1
                    if len(self.file_event) > 1:
                        message = "les fichiers ont été supprimés."
                    else:
                        message = "Le fichier a été supprimé."
        self.file_event.clear()
        self.setNbFileEvt.emit(len(self.file_event))
        self.setMsg.emit(message, erreur)
        checkEventFile(backendWindow, settings)

    @Slot(int,str)
    def importCnxFile(self, nbFile, domaine):
        # print("importCnxFile : nbFichier : <{}>".format(nbFile))
        # print("list des fichiers : <{}>".format(self.file_connexion))
        if len(self.file_connexion) != nbFile:
            # on a un problème, il faut prévenir l'opérateur
            self.setMsg.emit("On a un problème..", self.TypeMsg.Error)
            pass
        else:
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
        # On met à jour les dates sélectionnables
        self.setDates.emit(queryGetDates(mydb, domaine))
        # On met à jour la liste des positions
        self.setListPositions.emit(queryListPosition(mydb, domaine))


    @Slot(int, str)
    def importEvtFile(self, nbFile,domaine):
        # print("importEvtFile : nbFichier : <{}>".format(nbFile))
        # print("list des fichiers : <{}>".format(self.file_connexion))
        if len(self.file_event) != nbFile:
            # on a un problème, il faut prévenir l'opérateur
            self.setMsg.emit("On a un problème..", self.TypeMsg.Error)
            pass
        else:
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
        # On met à jour les dates sélectionnables
        self.setDates.emit(queryGetDates(mydb, domaine))

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
        dateDebut = myDate.addSecs(-900)
        dateFin = myDate.addSecs(299)
        self.setData.emit(listCnx, position, myDate, dateDebut, dateFin)
        # self.setData.emit(listCnx, listEvt)

    @Slot(int, QDateTime)
    def moveCurseur(self, x, dateEvent):
        # print("PoisitionX : {}".format(x))
        dateCurseur = dateEvent.addSecs(x - 900)
        # print("Heure sélectionnée : {}".format(dateCurseur.toString("HH.mm.ss") ))
        self.setHeureSelect.emit(dateCurseur, dateCurseur.toString("HH:mm:ss"))


####################################@@
# main.py
####################################@@
if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    # Définition de l'environnement pour l'archivage des paramètres
    app.setOrganizationName("Adder")
    #  app.setOrganizationDomain("lfpg.aviation-civile.gouv.fr")
    app.setApplicationName("AIMLog2")

    mydb = QSqlDatabase.addDatabase("QSQLITE")

    # Get Context
    settings = QSettings()
    backendWindow = Backend(settings)
    engine.rootContext().setContextProperty("backend", backendWindow)

    # Load QML file
    engine.load("qrc:/QML/main.qml") # voir : https://stackoverflow.com/questions/58035550/pyinstaller-and-qml-files
    if not engine.rootObjects():
        print("Fichier <{}> non trouvé".format("qml/main.qml"))
        sys.exit(-1)

    checkSetting(backendWindow, settings, mydb)

    # checkConnexionFile(backendWindow, settings)

    sys.exit(app.exec())
