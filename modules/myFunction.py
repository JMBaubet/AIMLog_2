import os
import glob
import shutil
from PySide6.QtCore import QStandardPaths
from modules.mySQLite import connecDataBase, createTable, insertRecords, listPosition, firstDate, queryAnalyseCnx, queryAnalyseEvt
import zipfile
import csv
from datetime import datetime



def checkSetting(backend, settings, mydb):
    working_dir = QStandardPaths.writableLocation(QStandardPaths.AppLocalDataLocation)

    # On vérifie si le dossier de travail FileExists
    # S'il n'existe pas c'est probablement le premier lancement de l'pplication, alors on crée le domaine sandBox
    # et on initialise la liste des domaines
    if not (os.path.isdir(working_dir)):
        os.makedirs(working_dir)
        createDomaine(backend, settings, mydb, working_dir, "sandBox")
        # Ajout le 07 mars 2023
        settings.setValue("DomaineActif", "sandBox")

    """
        # mise en commentaire le 07 mars 2023
        domaine = []
        if settings.value("Domaines") is None:
            domaine.append("sandBox")
            settings.setValue("DomaineActif", "sandBox")
            # print("Mise a jour du domaine actif : {}".format("sandBox"))
        else:
            if not "sandBox" in domaine:
                domaine.append("sandBox")
        # print("domaine : <{}>".format(domaine))
        settings.setValue("Domaines", domaine)
    """
    # On récupère la couleur et le mode de l'application
    couleur = settings.value("Couleur")
    if not couleur is None:
        # print("Couleur : {}".format(couleur))
        backend.setColor.emit(couleur)
    mode = settings.value("Mode")
    if not mode is None:
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
    settings.endGroup()

    backend.setRetention.emit(retention)

    # Mise à jour de la liste des getPosition

    backend.setListPositions.emit(listPosition(mydb, domaine))

    # Lecture des dates
    backend.setDates.emit(firstDate(mydb, domaine))

    # print(retention["BddUnit"])


def createDomaine(backend, settings, mydb, dossier, name):
    os.makedirs(dossier + "/" + name + "/importCnx")
    os.makedirs(dossier + "/" + name + "/importEvt")
    connecDataBase(mydb, name)
    createTable(mydb)

    settings.beginGroup(name)
    settings.setValue("RetensionCnxValue", 3)
    settings.setValue("RetensionCnxUnit", "mois")
    settings.setValue("RetensionEvtValue", 3)
    settings.setValue("RetensionEvtUnit", "mois")
    settings.setValue("RetensionBddValue", 12)
    settings.setValue("RetensionBddUnit", "mois")
    settings.endGroup()

    domaines = settings.value("Domaines")
    if (domaines is None):
        domaines = []
    domaines.append(name)
    settings.setValue("Domaines", domaines)
    backend.setDomaines.emit(domaines)


def removeDomaine(backend, settings, mydb, dossier, name):
    shutil.rmtree(dossier + "/" + name)

    connecDataBase(mydb, name)
    mydb.removeDatabase(name)

    settings.beginGroup(name)
    settings.remove("RetensionCnxValue")
    settings.remove("RetensionCnxUnit")
    settings.remove("RetensionEvtValue")
    settings.remove("RetensionEvtUnit")
    settings.remove("RetensionBddValue")
    settings.remove("RetensionBddUnit")
    settings.endGroup()

    # On efface le fichier .sqlite
    os.remove(dossier + "/" + name + ".sqlite")

    domaines = settings.value("Domaines")
    domaines.remove(name)
    settings.setValue("Domaines", domaines)
    return domaines


def retentionChanged(settings, domaine,  bdd_duree, bdd_unite, cnx_duree, cnx_unite, evt_duree, evt_unite):
    retention = {"CnxValue": cnx_duree,
                 "CnxUnit": cnx_unite,
                 "EvtValue": evt_duree,
                 "EvtUnit": evt_unite,
                 "BddValue": bdd_duree,
                 "BddUnit": bdd_unite}

    settings.beginGroup(domaine)
    if ((settings.value("RetensionCnxValue") == retention["CnxValue"]) and
        (settings.value("RetensionCnxUnit") == retention["CnxUnit"] ) and
        (settings.value("RetensionEvtValue") == retention["EvtValue"]) and
        (settings.value("RetensionEvtUnit") == retention["EvtUnit"]) and
        (settings.value("RetensionBddValue") == retention["BddValue"]) and
        (settings.value("RetensionBddUnit") ==retention["BddUnit"]) ):
        change_retention = False
    else:
        change_retention = True
    settings.endGroup()
    return change_retention


def backupRetention(settings, domaine,  bdd_duree, bdd_unite, cnx_duree, cnx_unite, evt_duree, evt_unite):
    settings.beginGroup(domaine)
    settings.setValue("RetensionCnxValue", cnx_duree)
    settings.setValue("RetensionCnxUnit", cnx_unite)
    settings.setValue("RetensionEvtValue", evt_duree)
    settings.setValue("RetensionEvtUnit", evt_unite)
    settings.setValue("RetensionBddValue", bdd_duree)
    settings.setValue("RetensionBddUnit", bdd_unite)
    settings.endGroup()


def loadRetention(settings, domaine):
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
    # Lecture du domaine actif
    domaine = settings.value("DomaineActif")
    # On  liste les fichiers présents dans le répertoire
    working_dir = QStandardPaths.writableLocation(QStandardPaths.AppLocalDataLocation)
    os.chdir(working_dir + "/" + domaine + "/importCnx")
    file = glob.glob("*.zip")
    file.sort(reverse=True)
    backend.setFile.emit(file, domaine)


def checkEventFile(backend, settings):
    # Lecture du domaine actif
    domaine = settings.value("DomaineActif")
    # On  liste les fichiers présents dans le répertoire
    working_dir = QStandardPaths.writableLocation(QStandardPaths.AppLocalDataLocation)
    os.chdir(working_dir + "/" + domaine + "/importEvt")
    file = glob.glob("*.zip")
    file.sort(reverse=True)
    backend.setFile.emit(file, domaine)


def supprimeFile(backend, fichier):
    message = ""
    erreur = 0
    try:
        os.remove(fichier)
    except OSError as e:
        erreur = 3
        message = message  + "Error: {} - {}. ".format(e.filename, e.strerror)

    if not erreur :
        message = ""

    return erreur, message


def inmportCnxToBdd(settings, bdd, fichier):
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
            if len(file_names) > 1:
                message = "On a plus d'un fichier dans l'archive"
                erreur = 3
            for file_name in file_names:
                # print("Liste des fichiers : <{}>".format(file_name))
                myzip.extract(file_name, QStandardPaths.writableLocation(QStandardPaths.TempLocation))
                my_csv_file = QStandardPaths.writableLocation(QStandardPaths.TempLocation) + "/" + file_name

    except zipfile.BadZipFile:
        message = "le fichier n'est pas un zip !"
        erreur = 3

    if erreur != 0:
        return erreur, message



    records = []
    date_futur = "2100-01-01 00:00:00"

    with open(my_csv_file, ) as my_file:
        content = csv.reader(my_file, delimiter=',')
        lines = list(content)
        # print("We have {} lines".format(len(lines)))
        # print(lines[0])
        # print(lines[1])
        # connexion_id_ref = int(lines[1][0])
        int(lines[1][0]) # La première ligne contient le nomm des champs
        # try:
        #     start_time_ref = datetime.strptime(lines[1][1], "%Y-%m-%d %H:%M:%S")
        # except ValueError:
        #     print("Erreur dans la date de début de fichier !")

        for i in range(1, len(lines)):  # On lit les lignes du fichier csv
            connexion_id = int(lines[i][0])
            # if connexion_id[i - 1] < connexion_id_ref:
            #     print("Erreur, un id_con est mal ordonné dans le fichier CSV ! sur la ligne {}".format(i))
            #     connexion_id_ref = connexion_id[i - 1]
            try:
                start_time = datetime.strptime(lines[i][1], "%Y-%m-%d %H:%M:%S")
                start_time = lines[i][1]
                # if start_time[i - 1] < start_time_ref:
                #     print("Erreur la start_time de la ligne {} est inférieur à la référence !".format(i))
                #     start_time_ref = start_time[i - 1]
            except ValueError:
                start_time = date_futur
                print("Erreur de format dans la date de début de connexion sur la ligne {}".format(i))
            try:
                end_time = datetime.strptime(lines[i][2], "%Y-%m-%d %H:%M:%S")
                end_time = lines[i][2]
            except ValueError:
                end_time = date_futur

            record = [connexion_id, start_time, end_time, lines[i][3], lines[i][4], lines[i][5],
                     int(lines[i][6]), int(lines[i][7]), int(lines[i][8]), int(lines[i][9]), int(lines[i][10]),
                     int(lines[i][11]), int(lines[i][12]), int(lines[i][13]), int(lines[i][14]), int(lines[i][15]),
                     lines[i][16], lines[i][17], lines[i][18], lines[i][19], lines[i][20], lines[i][21],
                     int(lines[i][22]), int(lines[i][23]), int(lines[i][24]), int(lines[i][25]),
                     lines[i][26], lines[i][27], lines[i][28], lines[i][29] ]

            # print(record)
            records.append(record)
            # print(records)

    # On ferme le fichier
    my_file.close()
    # on supprime le fichier extrait du zip
    os.remove(my_csv_file)


    nbOk, nbErr = insertRecords(bdd, domaine, records, "connexions")

    if not nbOk:
        message = "Aucun enregistrement n'a été importé !"
        level = 2
    elif nbOk == 1:
        message = "1 enregistrement importé dans la base de données"
        level = 1
    else:
        message = "{} enregistrements importés dans la base de données".format(nbOk)
        level = 1
    return level, message




def inmportEvtToBdd(settings, bdd, fichier):
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
            if len(file_names) > 1:
                message = "On a plus d'un fichier dans l'archive"
                erreur = 3
            for file_name in file_names:
                # print("Liste des fichiers : <{}>".format(file_name))
                myzip.extract(file_name, QStandardPaths.writableLocation(QStandardPaths.TempLocation))
                my_csv_file = QStandardPaths.writableLocation(QStandardPaths.TempLocation) + "/" + file_name

    except zipfile.BadZipFile:
        message = "le fichier n'est pas un zip !"
        erreur = 3

    if erreur != 0:
        return erreur, message


    records = []
    date_futur = "2100-01-01 00:00:00" # pas nécessaire dans le fichier event

    with open(my_csv_file, ) as my_file:
        content = csv.reader(my_file, delimiter=',')
        lines = list(content)
        # print("We have {} lines".format(len(lines)))
        # print(lines[0])
        # print(lines[1])
        # connexion_id_ref = int(lines[1][0])
        int(lines[1][0]) # La première ligne contient le nomm des champs
        # try:
        #     start_time_ref = datetime.strptime(lines[1][1], "%Y-%m-%d %H:%M:%S")
        # except ValueError:
        #     print("Erreur dans la date de début de fichier !")

        for i in range(1, len(lines)):  # On lit les lignes du fichier csv
            connexion_id = int(lines[i][0])
            # if connexion_id[i - 1] < connexion_id_ref:
            #     print("Erreur, un id_con est mal ordonné dans le fichier CSV ! sur la ligne {}".format(i))
            #     connexion_id_ref = connexion_id[i - 1]
            try:
                start_time = datetime.strptime(lines[i][1], "%Y-%m-%d %H:%M:%S")
                start_time = lines[i][1]
                # if start_time[i - 1] < start_time_ref:
                #     print("Erreur la start_time de la ligne {} est inférieur à la référence !".format(i))
                #     start_time_ref = start_time[i - 1]
            except ValueError:
                start_time = date_futur
                print("Erreur de format dans la date de début de connexion sur la ligne {}".format(i))

            record = [connexion_id, start_time, lines[i][2], lines[i][3], lines[i][4],
                     lines[i][5], lines[i][6], lines[i][7], lines[i][8], lines[i][9] ]

            # print(record)
            records.append(record)
            # print(records)

    # On ferme le fichier
    my_file.close()
    # on supprime le fichier extrait du zip
    os.remove(my_csv_file)


    nbOk, nbErr = insertRecords(bdd, domaine, records, "evenements")

    if not nbOk:
        message = "Aucun enregistrement n'a été importé !"
        level = 2
    elif nbOk == 1:
        message = "1 enregistrement importé dans la base de données"
        level = 1
    else:
        message = "{} enregistrements importés dans la base de données".format(nbOk)
        level = 1
    return level, message



def lanceAnalyse(settings, mydb, date, position):
    domaine = settings.value("DomaineActif")
    listCnx = queryAnalyseCnx(mydb, domaine, date, position)
    listEvt = queryAnalyseEvt(mydb, domaine, date)
    return listCnx, listEvt








