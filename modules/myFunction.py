import os
import glob
import shutil
from PySide6.QtCore import QStandardPaths
from modules.mySQLite import queryCreateTable, queryInsertRecords, \
    queryListPosition, queryGetDates, queryAnalyseCnx, queryAnalyseDeviceStatus, queryImportDeviceStatus
import zipfile
import csv
from datetime import datetime

from PySide6.QtCore import QDateTime


def checkSetting(backend, settings, mydb):
    """ Vérification des prérequis

    Cette fonction permet :
        - de vérifier si l'application a déjà été lancée. Si ce n'est pas le cas on crée l'environement par défaut
        - de lire et d'envoyer à l'IHM les paramètres qui sont sauvegardés

    Parameters
    ----------
    backend : QObjet instancié
        Lien entre les modules QML et le code Python
    settings :
        Les paramètres de l'application qui sont enregistrés d'une session à l'autre
    mydb :
        La référence à la base de donnée

    Returns
    -------
        Rien

    emet les signaux
    ----------------
        setColor(couleur)               envoie la couleur sauvegardée, si la couleur à déjà été enregistrée
        setMode(mode)                   envoie le mode sauvegardé, si le mode a déjà été enregistré
        setDomaine(domaine)             envoie le domaine de travail qui est enregistré
        initDomaines(domaines, domaine) envoie la liste des domaines et le domaine de travail sui sont enregistrés
        setRetention(retention)         envoie la liste des durées de retention des données du domaine sélectionné
        setListPositions(positions)     envoie la liste des positions du domaine sélectionné
        setDates(dates)                 envoie les dates de début et de fin connues dans la bdd du domaine sélectionné
    """


    # On vérifie si le dossier de travail FileExists
    # S'il n'existe pas c'est probablement le premier lancement de l'application, alors on crée le domaine sandBox
    # et on initialise la liste des domaines, le mode par défaut.
    # Pour être compatible MACOS et Windows il faut changer l'algorithme
    # Sous Windows le dossier worki,g_dir est créé automatiquement...
    # On teste dans les settings Si la liste des domaine existe.
    """
    if (platform.system() == "Darwin"):
        if not (os.path.isdir(working_dir)):
            os.makedirs(working_dir)
    """
    domaines = settings.value("Domaines")
    if (domaines is None):
        createDomaine(backend, settings, mydb, "sandBox")
        settings.setValue("DomaineActif", "sandBox")
        settings.setValue("Mode", 0)

    # On récupère la couleur et le mode de l'application
    # couleur = settings.value("Couleur")
    # if couleur is not None:
        # print("Couleur : {}".format(couleur))
    #     backend.setColor.emit(couleur)
    mode = settings.value("Mode")
    if mode is not None:
        # print("Mode : {}".format(mode))
        backend.setMode.emit(mode)

    # Lecture du domaine actif
    domaine = settings.value("DomaineActif")
    # print("domaine actif : {}".format(domaine))
    backend.setDomaine.emit(domaine)

    # Lecture des domaines
    domaines = settings.value("Domaines")
    backend.initDomaines.emit(domaines, domaine)

    settings.beginGroup(domaine)
    retention = {"CnxValue": settings.value("RetensionCnxValue"),
                 "CnxUnit": settings.value("RetensionCnxUnit"),
                 "EvtValue": settings.value("RetensionEvtValue"),
                 "EvtUnit": settings.value("RetensionEvtUnit"),
                 "BddValue": settings.value("RetensionBddValue"),
                 "BddUnit": settings.value("RetensionBddUnit")}

    color = settings.value("Couleur")
    settings.endGroup()

    backend.setRetention.emit(retention)

    backend.setColor.emit(color)

    """ Lecture dans la base de données """
    # Mise à jour de la liste des getPosition
    backend.setListPositions.emit(queryListPosition(mydb, domaine))

    # Mise à jour des dates pour le selectDate
    backend.setDates.emit(getDates(mydb, settings))


def createDomaine(backend, settings, mydb, name):
    """ Création d'un domaine de travail

    Cette fonction permet de créer un nouveau domaine de travail.
    On mets en place :
        - les répertoires de travail ppur ce domaine
        - la nouvelle base de données pour ce domaine
    On enregistre les valeurs par défaut des durées de rétention

    Parameters
    ----------
    backend : QObjet instancié
        Lien entre les modules QML et le code Python
    settings :
        Les paramètres de l'application qui sont enregistrés d'une session à l'autre
    mydb :
        La référence à la base de donnée
    name :
        Le nom du nouveau domaine de travail

    Returns
    -------
        0 si OK
        1 si on détecte que le domaine est déjà existant.

    emet les signaux
    ----------------
        setDomaines(domaines)             envoie la liste des domaines de travail qui sont enregistrés
    """

    working_dir = QStandardPaths.writableLocation(QStandardPaths.AppLocalDataLocation)
    try:
        os.makedirs(working_dir + "/" + name + "/importCnx")
        os.makedirs(working_dir + "/" + name + "/importEvt")

    except FileExistsError:
        # print("Le domaine {} a déjà été créé.".format(name))
        return 1

    else:
        queryCreateTable(mydb, name)

        settings.beginGroup(name)
        settings.setValue("RetensionCnxValue", 3)
        settings.setValue("RetensionCnxUnit", "mois")
        settings.setValue("RetensionEvtValue", 3)
        settings.setValue("RetensionEvtUnit", "mois")
        settings.setValue("RetensionBddValue", 12)
        settings.setValue("RetensionBddUnit", "mois")
        settings.setValue("Couleur", 17) # Grey
        settings.endGroup()
        domaines = settings.value("Domaines")
        if (domaines is None):
            domaines = []
        domaines.append(name)
        settings.setValue("Domaines", domaines)
        backend.setDomaines.emit(domaines)
        return 0

def removeDomaine(backend, settings, mydb, name):
    """ Suppression d'un domaine de travail

    Cette fonction permet de supprimer un  domaine de travail.
    On efface :
        - les répertoires de travail du domaine
        - la  base de données du domaine
        - les valeurs enregistrées des durées de rétention du domaine

    Parameters
    ----------
    backend : QObjet instancié
        Lien entre les modules QML et le code Python
    settings :
        Les paramètres de l'application qui sont enregistrés d'une session à l'autre
    mydb :
        La référence à la base de donnée
    name :
        Le nom du domaine de travail à supprimer

    Returns
    -------
        Rien

    emet les signaux
    ----------------
        setDomaines(domaines)             envoie la liste des domaines de travail qui sont enregistrés
    """

    working_dir = QStandardPaths.writableLocation(QStandardPaths.AppLocalDataLocation)
    shutil.rmtree(working_dir + "/" + name)

    mydb.setDatabaseName(working_dir + "/" + name + ".sqlite")
    if not mydb.open():
        print("Database Error: {}".format(mydb.lastError().databaseText()))


    mydb.removeDatabase(name)
    # On efface le fichier .sqlite
    os.remove(working_dir + "/" + name + ".sqlite")

    # Mise à jour des settings
    settings.beginGroup(name)
    settings.remove("RetensionCnxValue")
    settings.remove("RetensionCnxUnit")
    settings.remove("RetensionEvtValue")
    settings.remove("RetensionEvtUnit")
    settings.remove("RetensionBddValue")
    settings.remove("RetensionBddUnit")
    settings.remove("Couleur")
    settings.endGroup()


    domaines = settings.value("Domaines")
    domaines.remove(name)
    settings.setValue("Domaines", domaines)
    backend.setDomaines.emit(domaines)


def retentionChanged(settings, domaine, bdd_duree, bdd_unite, cnx_duree, cnx_unite, evt_duree, evt_unite):
    """ Modification des paramètre de retention des données

    Cette fonction vérifie si les paramètres de retention ont été modifiés pour un domaine.
    Elle renvoie True si un des enregistrements a été modifié (Pour désactive le bouton de l'IHM)

    Parameters
    ----------
    settings :
        Les paramètres de l'application qui sont enregistrés d'une session à l'autre
    doamine :
        Le nom du domaine concerné par les paramètres de rétention
    bdd_duree, bdd_unite, cnx_duree, cnx_unite, evt_duree, evt_unite
        Les paramètres de retention du domaine

    Returns
    -------
        True si un des paramètres a été modifés

    """

    retention = {"CnxValue": cnx_duree,
                 "CnxUnit": cnx_unite,
                 "EvtValue": evt_duree,
                 "EvtUnit": evt_unite,
                 "BddValue": bdd_duree,
                 "BddUnit": bdd_unite}

    settings.beginGroup(domaine)
    if ((settings.value("RetensionCnxValue") == retention["CnxValue"]) and
            (settings.value("RetensionCnxUnit") == retention["CnxUnit"]) and
            (settings.value("RetensionEvtValue") == retention["EvtValue"]) and
            (settings.value("RetensionEvtUnit") == retention["EvtUnit"]) and
            (settings.value("RetensionBddValue") == retention["BddValue"]) and
            (settings.value("RetensionBddUnit") == retention["BddUnit"])):
        change_retention = False
    else:
        change_retention = True
    settings.endGroup()
    return change_retention


def backupRetention(settings, domaine, bdd_duree, bdd_unite, cnx_duree, cnx_unite, evt_duree, evt_unite):
    """ Sauvegarde dans les settings des paramètre de retention des données

    Cette fonction enregistre dans les settings  les paramètres de retention ont été modifiés pour un domaine.

    Parameters
    ----------
    settings :
        Les paramètres de l'application qui sont enregistrés d'une session à l'autre
    doamine :
        Le nom du domaine concerné par les paramètres de rétention
    bdd_duree, bdd_unite, cnx_duree, cnx_unite, evt_duree, evt_unite
        Les paramètres de retention du domaine

    Returns
    -------
       Rien

    """

    settings.beginGroup(domaine)
    settings.setValue("RetensionCnxValue", cnx_duree)
    settings.setValue("RetensionCnxUnit", cnx_unite)
    settings.setValue("RetensionEvtValue", evt_duree)
    settings.setValue("RetensionEvtUnit", evt_unite)
    settings.setValue("RetensionBddValue", bdd_duree)
    settings.setValue("RetensionBddUnit", bdd_unite)
    settings.endGroup()


def loadRetention(settings, domaine):
    """ Récupération des données de rétention

    Cette fonction permet de lire dans les settings les données de rétention  du domaine de travail.
    Parameters
    ----------
    settings :
        Les paramètres de l'application qui sont enregistrés d'une session à l'autre
    domaine :
        Le nom du domaine correspondant

    Returns
    -------
        un dictionnaire contenant les données de rétention
    """

    settings.beginGroup(domaine)

    retention = {"CnxValue": settings.value("RetensionCnxValue"),
                 "CnxUnit": settings.value("RetensionCnxUnit"),
                 "EvtValue": settings.value("RetensionEvtValue"),
                 "EvtUnit": settings.value("RetensionEvtUnit"),
                 "BddValue": settings.value("RetensionBddValue"),
                 "BddUnit": settings.value("RetensionBddUnit")}
    settings.endGroup()
    # print("Retention : <{}>".format(retention))
    return retention


def checkConnexionFile(backend, settings):
    """ Récupération de la liste des fichiers log de connexions

    Cette fonction permet de lister pour le domaine actif, la liste des fichiers de log de type connexions
    qui ont été déposés dans l'espace de travail

    Parameters
    ----------
    backend : QObjet instancié
        Lien entre les modules QML et le code Python
    settings :
        Les paramètres de l'application qui sont enregistrés d'une session à l'autre

    Returns
    -------
        Rien

    emet les signaux
    ----------------
        setFile(file, domaine)             envoie la liste des fichiers  qui sont disponibles
    """

    # Lecture du domaine actif
    domaine = settings.value("DomaineActif")
    # On  liste les fichiers présents dans le répertoire
    working_dir = QStandardPaths.writableLocation(QStandardPaths.AppLocalDataLocation)
    os.chdir(working_dir + "/" + domaine + "/importCnx")
    file = glob.glob("*.*")
    file.sort(reverse=True)
    backend.setFile.emit(file, domaine)


def checkEventFile(backend, settings):
    """ Récupération de la liste des fichiers log d'évènement

    Cette fonction permet de lister pour le domaine actif, la liste des fichiers de log de type évènement
    qui ont été déposés dans l'espace de travail

    Parameters
    ----------
    backend : QObjet instancié
        Lien entre les modules QML et le code Python
    settings :
        Les paramètres de l'application qui sont enregistrés d'une session à l'autre

    Returns
    -------
        Rien

    emet les signaux
    ----------------
        setFile(file, domaine)             envoie la liste des fichiers qui sont disponibles
    """

    # Lecture du domaine actif
    domaine = settings.value("DomaineActif")
    # On  liste les fichiers présents dans le répertoire
    working_dir = QStandardPaths.writableLocation(QStandardPaths.AppLocalDataLocation)
    os.chdir(working_dir + "/" + domaine + "/importEvt")
    file = glob.glob("*.*")
    file.sort(reverse=True)
    backend.setFile.emit(file, domaine)


def supprimeFile(fichier):
    """ suppression d'un fichier

    Cette fonction permet de supprimer le fichier passé en paramètre
    Parameters
    ----------
    fichier :
        Le nom complet du fichier en absolu

    Returns
    -------
        erreur : le niveau d'erreur pour afficher le message à l'opérateur dans couleur ad'hoc .
        message : le message d'erreur à afficher à l'opérateur en cas de problème.

    """

    message = ""
    erreur = 0
    try:
        os.remove(fichier)
    except OSError as e:
        erreur = 3
        message = message + "Error: {} - {}. ".format(e.filename, e.strerror)
    if not erreur:
        message = ""

    return erreur, message


def inmportCnxToBdd(settings, mydb, fichier):
    """ Préparation de l'importation d'un fichier zip de type connexions pour la base de données

    Cette fonction permet :
        - d'extraire le fichier csv du ficheir zip
        - de mettre dans une liste les données de connexions pour les importer dans la base de données
        - de supprimer les connexions en cours
        - de lancer l'importation dans la base de données

    Parameters
    ----------
    settings :
        Les paramètres de l'application qui sont enregistrés d'une session à l'autre
    mydb :
        La référence à la base de donnée
    fichier :
        Le fichier a extraire et à importer dans le base de données.

    Returns
    -------
        erreur : le niveau d'erreur pour afficher le message à l'opérateur dans la couleur ad'hoc .
        message : le message d'erreur à afficher à l'opérateur. On lui précise le nombre d'enregistrement effectué.

    """

    domaine = settings.value("DomaineActif")
    working_dir = QStandardPaths.writableLocation(QStandardPaths.AppLocalDataLocation) + "/" + domaine + "/importCnx/"
    fichier = working_dir + fichier
    # print("fichier : <{}>".format(fichier))
    # print("dossier temporaire 1 : <{}>".format(QStandardPaths.writableLocation(QStandardPaths.TempLocation)))

    # on decompresse le fichier .zip
    erreur = 0
    message = ""
    try:
        with zipfile.ZipFile(fichier, "r") as myzip:
            file_names = myzip.namelist()
            if len(file_names) > 1:  # Normalement d'rchive est constituée d'un seul fichier.
                message = "On a plus d'un fichier dans l'archive"
                erreur = 3
            for file_name in file_names:
                # on teste que l'on bien un fichier de type connexions et non pas un fichier de type event
                if file_name[0:11] != "connection_" :
                    message = "Le fichier zip sélectionné n'est pas de type connection !"
                    erreur = 3
                # print("Liste des fichiers : <{}>".format(file_name))
                myzip.extract(file_name, QStandardPaths.writableLocation(QStandardPaths.TempLocation))
                my_csv_file = QStandardPaths.writableLocation(QStandardPaths.TempLocation) + "/" + file_name

    except zipfile.BadZipFile:
        message = "Le fichier n'est pas un zip !"
        erreur = 3

    if erreur != 0:
        return erreur, message

    records = []
    date_futur = "2100-01-01 00:00:00"

    with open(my_csv_file, ) as my_file:
        content = csv.reader(my_file, delimiter=',')
        lines = list(content)
        int(lines[1][0])  # La première ligne contient le nomm des champs

        for i in range(1, len(lines)):  # On lit les lignes du fichier csv, sans la première ligne
            connexion_id = int(lines[i][0])
            try:
                start_time = datetime.strptime(lines[i][1], "%Y-%m-%d %H:%M:%S")
                start_time = lines[i][1]
            except ValueError:
                start_time = date_futur
                print("Erreur de format dans la date de début de connexion sur la ligne {}".format(i)) #
            try:
                end_time = datetime.strptime(lines[i][2], "%Y-%m-%d %H:%M:%S")
                end_time = lines[i][2]
            except ValueError: # La connexion est toujours en cours. La date de fin n'est pas connue. On met le 01/01/2100 pour avoir une date valide.
                # print("On met la date future..")
                # print("end_time non valide : <{}>".format(end_time))
                end_time = date_futur

            record = [connexion_id, start_time, end_time, lines[i][3], lines[i][4], lines[i][5],
                      int(lines[i][6]), int(lines[i][7]), int(lines[i][8]), int(lines[i][9]), int(lines[i][10]),
                      int(lines[i][11]), int(lines[i][12]), int(lines[i][13]), int(lines[i][14]), int(lines[i][15]),
                      lines[i][16], lines[i][17], lines[i][18], lines[i][19], lines[i][20], lines[i][21],
                      int(lines[i][22]), int(lines[i][23]), int(lines[i][24]), int(lines[i][25]),
                      lines[i][26], lines[i][27], lines[i][28], lines[i][29]]

            # print(record)
            records.append(record)  # Dans records nous avons l'ensemble des données du ficheir csv.
            # print(records.length)

    # On ferme le fichier csv
    my_file.close()
    # on supprime le fichier extrait du zip
    os.remove(my_csv_file)



    nbOk, nbErr = queryInsertRecords(mydb, domaine, records, "connexions")

    if not nbOk:
        message = "Aucun enregistrement n'a été importé !"
        level = 2
    elif nbOk == 1:
        message = "1 enregistrement a été importé dans la base de données"
        level = 1
    else:
        message = "{} enregistrements ont été importés dans la base de données".format(nbOk)
        level = 1
    return level, message


def inmportEvtToBdd(settings, mydb, fichier):
    """ Préparation de l'importation d'un fichier zip de type event pour la base de données

    Cette fonction permet :
        - d'extraire le fichier csv du ficheir zip
        - de mettre dans une liste les données d'évènement pour les importer dans la base de données
        - de lancer l'importation dans la base de données

    Parameters
    ----------
    settings :
        Les paramètres de l'application qui sont enregistrés d'une session à l'autre
    mydb :
        La référence à la base de donnée
    fichier :
        Le fichier a extraire et à importer dans le base de données.

    Returns
    -------
        erreur : le niveau d'erreur pour afficher le message à l'opérateur dans la couleur ad'hoc .
        message : le message d'erreur à afficher à l'opérateur. On lui précise le nombre d'enregistrement effectué.

    """

    domaine = settings.value("DomaineActif")
    working_dir = QStandardPaths.writableLocation(QStandardPaths.AppLocalDataLocation) + "/" + domaine + "/importEvt/"
    fichier = working_dir + fichier
    # print("fichier : <{}>".format(fichier))
    # print("dossier temporaire 1 : <{}>".format(QStandardPaths.writableLocation(QStandardPaths.TempLocation)))

    # on decompresse le fichier .zip
    erreur = 0
    message = ""
    try:
        with zipfile.ZipFile(fichier, "r") as myzip:
            file_names = myzip.namelist()
            if len(file_names) > 1: # Normalement d'rchive est constituée d'un seul fichier.
                message = "On a plus d'un fichier dans l'archive"
                erreur = 3
            for file_name in file_names:
                # on teste que l'on bien un fichier de type event et non pas un fichier de type connection
                if file_name[0:6] != "event_" :
                    message = "Le fichier zip sélectionné n'est pas de type event !"
                    erreur = 3
                # print("Liste des fichiers : <{}>".format(file_name))
                myzip.extract(file_name, QStandardPaths.writableLocation(QStandardPaths.TempLocation))
                my_csv_file = QStandardPaths.writableLocation(QStandardPaths.TempLocation) + "/" + file_name

    except zipfile.BadZipFile:
        message = "le fichier n'est pas un zip !"
        erreur = 3

    if erreur != 0:
        return erreur, message

    records = []
    date_futur = "2100-01-01 00:00:00"  # pas nécessaire dans le fichier event

    with open(my_csv_file, ) as my_file:
        content = csv.reader(my_file, delimiter=',')
        lines = list(content)
        int(lines[1][0])  # La première ligne contient le nomm des champs

        for i in range(1, len(lines)):  # On lit les lignes du fichier csv, sans la première ligne
            connexion_id = int(lines[i][0])
            try:
                start_time = datetime.strptime(lines[i][1], "%Y-%m-%d %H:%M:%S")
                start_time = lines[i][1]
            except ValueError:
                start_time = date_futur
                print("Erreur de format dans la date de début de connexion sur la ligne {}".format(i))

            record = [connexion_id, start_time, lines[i][2], lines[i][3], lines[i][4],
                      lines[i][5], lines[i][6], lines[i][7], lines[i][8], lines[i][9]]

            # print(record)
            records.append(record)
            # print(records.length)

    # On ferme le fichier
    my_file.close()
    # on supprime le fichier extrait du zip
    os.remove(my_csv_file)

    nbOk, nbErr = queryInsertRecords(mydb, domaine, records, "evenements")

    # Si NbOK > 0 i faut mettre a jour la table device status
    if nbOk > 0 :
        importDeviceStatus(mydb, domaine)

    if not nbOk:
        message = "Aucun enregistrement n'a été importé !"
        level = 2
    elif nbOk == 1:
        message = "1 enregistrement a été importé dans la base de données"
        level = 1
    else:
        message = "{} enregistrements ont été importés dans la base de données".format(nbOk)
        level = 1
    return level, message


def lanceAnalyse(settings, mydb, date, position):
    """ Lance l'analyse des données pour une position donnée à partir des informations de la base de données

    Cette fonction permet :
        - lance l'analyse des données de connexion pour une position données à une date/heure donnée
        - lance l'analyse des données d'évènement pour une position données à une date/heure donnée

    Parameters
    ----------
    settings :
        Les paramètres de l'application qui sont enregistrés d'une session à l'autre
    mydb :
        La référence à la base de donnée
    fichier :
        Le fichier a extraire et à importer dans la base de données.

    Returns
    -------
        listCnx : une liste qui contient les listes suivantes  [[start_time], [end-time], [channel_name], [user_name]]
        listEtatCnx :  une liste qui contient les listes suivantes  [[start_time], [end-time], [nombre]]
        listEvt : A définir.

    """
    domaine = settings.value("DomaineActif")
    listCnx, firstTimeCnx = queryAnalyseCnx(mydb, domaine, date, position)
    # listEvt = queryAnalyseEvt(mydb, domaine, date)
    listEtatCnx, firstTimeDev = queryAnalyseDeviceStatus(mydb, domaine, date, position)

    # print("firstTimeCnx : {}".format(firstTimeCnx))
    # print("firstTimeDev : {}".format(firstTimeDev))
    date_time_firstTimeCnx = QDateTime.fromString(firstTimeCnx, "yyyy-MM-dd hh:mm:ss")
    date_time_firstTimeDev = QDateTime.fromString(firstTimeDev, "yyyy-MM-dd hh:mm:ss")

    # On calcule la plus petite date pour de device
    if (date_time_firstTimeCnx < date_time_firstTimeDev) :
        debut = date_time_firstTimeCnx
    else:
        debut = date_time_firstTimeDev



    return listCnx, listEtatCnx, debut


def getDates(mydb, settings):
    """ retourne les dates limites en fonction de la durée de rétention de la base de données

    Cette fonction permet :
        - de mettre à jour les dates séletionnables en fonction du contenu de la base de données,
        et en fonction de la durée de rétention des données dans la base de donnée.

    Parameters
    ----------
    mydb :
        La référence à la base de donnée
    settings :
        Les paramètres de l'application qui sont enregistrés d'une session à l'autre

    Returns
    -------
    dates :
        si aucun enregistrement de trouvé une liste vide,
        sinon, la liste qui contient :
            la date la plus ancienne connues dans la BDD ou si plus récente la date limite de durée de rétention de la BDD
            la date la plus récente connue dans ls BDD.
    """

    domaine = settings.value("DomaineActif")

    settings.beginGroup(domaine)
    retention = {"CnxValue": settings.value("RetensionCnxValue"),
                 "CnxUnit": settings.value("RetensionCnxUnit"),
                 "EvtValue": settings.value("RetensionEvtValue"),
                 "EvtUnit": settings.value("RetensionEvtUnit"),
                 "BddValue": settings.value("RetensionBddValue"),
                 "BddUnit": settings.value("RetensionBddUnit")}
    settings.endGroup()

    # Lecture des dates sotchées dans la base de données
    dates = queryGetDates(mydb, domaine)
    today = QDateTime.currentDateTime()

    if retention["BddUnit"] == "ans" :
        firstDate = today.addYears( 0 - retention["BddValue"])
    elif retention["BddUnit"] == "mois" :
        firstDate = today.addMonths(0 - retention["BddValue"])
    elif retention["BddUnit"] == "jours" :
        firstDate = today.addDays(0 - retention["BddValue"])
    if len(dates) > 0 :
        if (firstDate > dates[0]) :
            # print(" on limite les dates")
            dates[0] = firstDate
    return dates

def checkBadFile(settings):
    """ retourne un flag si des fichiers de type inconnu présents dans les dossier de transfert

    Cette fonction permet :
        - de signaler si des fichiers autre que des fichiers .zip sont présents dans les dossiers :
            - importCnx et importEvt de tous les domaines connus

    Parameters
    ----------
    settings :
        Les paramètres de l'application qui sont enregistrés d'une session à l'autre

    Returns
    -------
    badFile :
        si au moins un fichier a été trouvé : true
        sinon : false
    """
    badFile = False
    working_dir = QStandardPaths.writableLocation(QStandardPaths.AppLocalDataLocation)
    domaines = settings.value("Domaines")
    if domaines is not None:
        for domaine in domaines :
            # On  liste les fichiers présents dans le répertoire
            os.chdir(working_dir + "/" + domaine + "/importCnx")
            files = glob.glob("*")
            for file in files :
                if file[-4:] != ".zip" :
                    badFile = True
                    print("myFunction.py, checkBadFile, dossier Cnx : Fichier inatendu dans le domaine {} : {}".format( domaine, file))
                    break
            if badFile : break
            os.chdir(working_dir + "/" + domaine + "/importEvt")
            files = glob.glob("*")
            for file in files :
                if file[-4:] != ".zip" :
                    badFile = True
                    print("myFunction.py, checkBadFile, dossier Evt : Fichier inatendu dans le domaine {} : {}".format( domaine, file))
                    break
    return badFile


def importDeviceStatus(mydb, domaine):
    queryImportDeviceStatus(mydb, domaine)



