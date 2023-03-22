from PySide6.QtSql import QSqlQuery
from PySide6.QtCore import QStandardPaths, QDateTime



def changeDatabase(mydb, name):
    dir = QStandardPaths.writableLocation(QStandardPaths.AppLocalDataLocation)
    mydb.close()
    mydb.setDatabaseName(dir + "/" + name + ".sqlite")
    if not mydb.open():
        print("Database Error: {}".format(mydb.lastError().databaseText()))


def queryCreateTable(mydb, domaine):
    """ Création des tables connexions et evenements dans la bse de donnée du domaine

    Cette fonction crée les tables connexions et evnements dans la base de donnée
    domaine qui est créé.

    Parameters
    ----------
    mydb :
        La référence à la base de donnée
    domaine :
        Le nom du domaine qui donnera son nom à la BDD

    Returns
    -------
        Rien pour le moment
    """

    dir = QStandardPaths.writableLocation(QStandardPaths.AppLocalDataLocation)

    mydb.setDatabaseName(dir + "/" + domaine + ".sqlite")
    if not mydb.open():
        print("Database Error: {}".format(mydb.lastError().databaseText()))

    query = QSqlQuery()
    if not query.exec(
        """
        CREATE TABLE connexions (
            id INTEGER PRIMARY KEY  UNIQUE NOT NULL,
            start_time CARACTERE(20) NOT NULL,
            end_time CARACTERE(20),
            receiver VARCHAR(20),
            user VARCHAR(20),
            channel VARCHAR(20),
            audio TINYINT,
            video TINYINT,
            video1  TINYINT,
            usb TINYINT,
            usb1 TINYINT,
            serial TINYINT,
            exclusive TINYINT,
            audio_multicast TINYINT,
            video_multicast TINYINT,
            video1_multicast TINYINT,
            audio_broadcast_ip VARCHAR(17),
            audio_broadcast_ip2 VARCHAR(17),
            video_broadcast_ip VARCHAR(17),
            video_broadcast_ip2 VARCHAR(17),
            video1_broadcast_ip VARCHAR(17),
            video1_broadcast_ip2 VARCHAR(17),
            audio1 TINYINT,
            audio2 TINYINT,
            audio1_multicast TINYINT,
            audio2_multicast TINYINT,
            audio1_broadcast_ip VARCHAR(17),
            audio1_broadcast_ip2 VARCHAR(17),
            audio2_broadcast_ip VARCHAR(17),
            audio2_broadcast_ip2 VARCHAR(17)
        )
        """
    ):
        print("query.exec() - Error!")
        print("Database Error: {}".format(query.lastError().databaseText()))
    else:
        print("Création de la table connexions, dans {}.".format(mydb.databaseName()))


    if not query.exec(
        """
        CREATE TABLE evenements (
            id INTEGER PRIMARY KEY  UNIQUE NOT NULL,
            datetime CARACTERE(20) NOT NULL,
            event CARACTERE(60),
            detail VARCHAR(80),
            receiver VARCHAR(20),
            transmiter VARCHAR(20),
            user VARCHAR(20),
            channel VARCHAR(20),
            ip_adress VARCHAR(17),
            user_agent VARCHAR(80)
        )
        """
    ):
        print("Qquery.exec() - Error!")
        print("Database Error: {}".format(query.lastError().databaseText()))
    else:
        pass
        # print("Création de la table evenements, dans {}.".format(mydb.databaseName()))

    # TODO : Il faudrait retourner les comptes rendu à l'ihm



def queryInsertRecords(mydb, domaine, records, table):
    """ Enregistrement des données dans une des tables de la base de données

    Cette fonction enregistre dans une des tables de la base de données du domaine selectionné
    l'ensemble des données de la liste records.
        - 30 données pour la table connexions
        - 10 données pour la table evenements


    Parameters
    ----------
    mydb :
        La référence à la base de donnée
    domaine :
        Le nom du domaine qui correspond au nom de la BDD
    records :
        La liste qui contient l'ensemble des données à enregistrer dans la base de données
    table :
        Le nom de la table qui doit recevoir les requettes ('connexions' ou 'evenements')

    Returns
    -------
    nbOk :
        Le nombre d'enregistrement qui ont été effectués dans la bdd
    nbErr :
        Le nombre d'enegistreent qui ont echoués
    """

    nbErr = 0
    nbOk = 0
    query = QSqlQuery()
    dir = QStandardPaths.writableLocation(QStandardPaths.AppLocalDataLocation)

    # On se connecte à la base de donnée du domaine
    mydb.setDatabaseName(dir + "/" + domaine + ".sqlite")
    if not mydb.open():
        print("Database Error: {}".format(mydb.lastError().databaseText()))

    # Pour la table connexion, il faut supprimer les  anciennes connexions qui ont eu la date de fin forcée
    # pour pouvoir les mettre à jour avec les nouvelles données.

    if (table == "connexions") :
        if not query.exec(
            """
            DELETE FROM connexions WHERE end_time = "2100-01-01 00:00:00";
            """
        ):
            print("Qquery.exec() - Error!")
            print("Database Error: {}".format(query.lastError().databaseText()))
        else:
            print("Suppression des anciennes connexions non closes")

    for row in records:
        my_query = createQueryForListe(row, table)
        if not query.exec("""{}""".format(my_query)):
            nbErr += 1
        else:
            nbOk += 1

    print("Records OK : {}".format(nbOk))
    print("Records KO : {}".format(nbErr))
    mydb.close()
    return nbOk, nbErr


def createQueryForListe(donnees, table):
    """ Création d'un requette SQL pour enregistrer des données d'une table

    Cette fonction crée la requette SQL pour une table donnée.
    L'ensemble des colonnes de la tables doit être passé avec le bon ordonnancement.
    On particularise la requette pour les données de type entier (int)

    Parameters
    ----------
    donnees :
        Tous les champs de la table
    table :
        Le nom de la table qui doit recevoir les requettes ('connexions' ou 'evenements')

    Returns
    -------
    query :
        La requette SQL
    """
    query = "INSERT INTO {} VALUES(".format(table)
    for element in donnees:
        if type(element) is int:
            query += " {},".format(element)
        else:
            query += " '{}',".format(element)

    query = query[: -1]
    query += ")"
    # print("Query <{}> ".format(query))
    return query




def queryListPosition(mydb, domaine):
    """ Retour de la liste des receivers (ALIF-R) existants dans la base de données

    Cette fonction récupère dans la base de données la liste des receivers connus.

    Parameters
    ----------
    mydb :
        La référence à la base de donnée
    domaine :
        Le nom du domaine

    Returns
    -------
    listReceiver :
        La liste des ALIF-R présents dans la base de données du domaine
    """

    query = QSqlQuery()
    dir = QStandardPaths.writableLocation(QStandardPaths.AppLocalDataLocation)
    listReceiver = []
    # On se connecte à la base de donnée du domaine
    mydb.setDatabaseName(dir + "/" + domaine + ".sqlite")
    if not mydb.open():
        print("Database Error: {}".format(mydb.lastError().databaseText()))

    if not query.exec(
        """
        SELECT DISTINCT receiver FROM connexions UNION SELECT DISTINCT receiver FROM evenements
        WHERE  NOT CAST(receiver AS INTEGER) >= 0 ORDER by receiver
        """
    ):
        print("Qquery.exec() - Error!")
        print("Database Error: {}".format(query.lastError().databaseText()))
    else:
        # print("Sélection OK")
        while query.next():
            # print("On ajoute <{}> à la liste des positions.".format(query.value(0)))
            listReceiver.append(query.value(0))
        query.finish()
    return listReceiver


def queryGetDates(mydb, domaine):
    """ Retour les dates de debut et de fin connus dans la base de données

    Cette fonction récupère dans les tables connexions et evenements :
        - la date la plus ancienne
        - la date la plus récente
    Dans la table connexions la date de fin est mise artificiellement au 01/01/2100 lorsque
    la connexions est toujouts active à la date du backup. Il faut supprimer cette date qui
    n'a pas de sens en tant que date la plus recente.

    Parameters
    ----------
    mydb :
        La référence à la base de donnée
    domaine :
        Le nom du domaine

    Returns
    -------
    dates :
        si aucun enregistrement de trouvé une liste vide,
        sinon, la liste qui contient la date la plus récente et la date la plus ancienne.
    """

    query = QSqlQuery()
    dir = QStandardPaths.writableLocation(QStandardPaths.AppLocalDataLocation)
    dates = []

    # On se connecte à la base de donnée du domaine
    mydb.setDatabaseName(dir + "/" + domaine + ".sqlite")
    if not mydb.open():
        print("Database Error: {}".format(mydb.lastError().databaseText()))

    #########################################`
    # SELECTION de la plus petite date
    #########################################
    if not query.exec(
        """
        SELECT DISTINCT MIN(start_time) FROM connexions
        """
    ):
        print("Database Error: {}".format(query.lastError().databaseText()))
    else:
        while query.next():
            # print("Min start_time of connexions : <{}>".format(query.value(0)) )
            # date_time_connexions = datetime.fromisoformat (query.value(0))
            date_time_connexions = QDateTime.fromString(query.value(0),"yyyy-MM-dd hh:mm:ss")
        query.finish()

    if not query.exec(
        """
        SELECT DISTINCT MIN(datetime) FROM evenements
        """
    ):
        print("Database Error: {}".format(query.lastError().databaseText()))
    else:
        while query.next():
            # print("Min date_time of evenements : <{}>".format(query.value(0)) )
            # date_time_evenements = datetime.fromisoformat (query.value(0))
            date_time_evenements = QDateTime.fromString(query.value(0),"yyyy-MM-dd hh:mm:ss")
            # print("date_time_evenements is Null ? : <{}>".format(date_time_evenements.isNull()) )
        query.finish()

    if not date_time_connexions.isNull() : # si aucune date est trouvée on renvoie une liste vide
        if date_time_evenements.isNull() : # Si la table evenements est vide on ne reste pas bloqué
            dates.append(date_time_connexions)
        elif  (date_time_connexions < date_time_evenements) :
            dates.append(date_time_connexions)
        else:
            dates.append(date_time_evenements)

    #########################################`
    # SELECTION de la plus grande date
    #########################################
    if not query.exec(
        """
        SELECT DISTINCT MAX(end_time) FROM connexions WHERE end_time <> "2100-01-01 00:00:00"
        """
    ):
        print("Database Error: {}".format(query.lastError().databaseText()))
    else:
        while query.next():
            # print("MAX start_time of connexions : <{}>".format(query.value(0)) )
            # date_time_connexions = datetime.fromisoformat (query.value(0))
            date_time_connexions = QDateTime.fromString(query.value(0),"yyyy-MM-dd hh:mm:ss")
        query.finish()

    if not query.exec(
        """
        SELECT DISTINCT MAX(datetime) FROM evenements
        """
    ):
        print("Database Error: {}".format(query.lastError().databaseText()))
    else:
        while query.next():
            # print("MAX date_time of evenements : <{}>".format(query.value(0)) )
            # date_time_evenements = datetime.fromisoformat (query.value(0))
            date_time_evenements = QDateTime.fromString(query.value(0),"yyyy-MM-dd hh:mm:ss")
        query.finish()

    if not date_time_connexions.isNull() :
        if date_time_evenements.isNull() : # Si la table evenements est vide on ne reste pas bloqué
            dates.append(date_time_connexions)
        elif  (date_time_connexions < date_time_evenements) :
            dates.append(date_time_connexions)
        else:
            dates.append(date_time_evenements)

    return(dates)


def queryAnalyseCnx(mydb, domaine, date, position):
    """ Retour des informations de connexion pour une position données autour d'une date & heure

    Cette fonction realise les actions suivantes :
        - Calcul des date de début et de fin  entre -15 minutes et + 5 minutes de l'heure donnée
        - Une requette à la base de données pour récupérer uniquement les données utiles

    Parameters
    ----------
    mydb :
        La référence à la base de donnée
    domaine :
        Le nom du domaine
    date:
        Date autour de laquelle on récupère les informations de connexion
    position:
        Nom de la position sur laquelle on recupère les connexions établies

    Returns
    -------
    listCnx :
        une double liste sous la forme [[start_time, end_time, channel, user], ..., [start_time, end_time, channel, user]]
    """

    heure_debut = date.addSecs(-15 * 60)
    heure_fin = date.addSecs(5 * 60)

    query = QSqlQuery()
    dir = QStandardPaths.writableLocation(QStandardPaths.AppLocalDataLocation)
    listCnx = []
    cnx = []

    # Connexion à la base de donnée du domaine
    mydb.setDatabaseName(dir + "/" + domaine + ".sqlite")
    if not mydb.open():
        print("Database Error: {}".format(mydb.lastError().databaseText()))

    my_query =  "SELECT start_time, end_time, channel, user FROM connexions WHERE receiver like '{}' AND ".format(position)
    my_query += "end_time >= '{}' AND start_time <= '{}' ".format(heure_debut.toString("yyyy-MM-dd hh:mm:ss"), heure_fin.toString("yyyy-MM-dd hh:mm:ss"))

    # print("query : <{}>".format(my_query))

    if not query.exec("""{}""".format(my_query)):
        print("Database Error: {}".format(query.lastError().databaseText()))
    else:
        while query.next():
            cnx.append(query.value("start_time"))
            cnx.append(query.value("end_time"))
            cnx.append(query.value("channel"))
            cnx.append(query.value("user"))
            listCnx.append(cnx)
            #print("MySQLite : On ajoute : <{}> ".format(cnx))
            cnx=[]
        query.finish()
    # print("MySQLite : listCnx : <{}> ".format(listCnx))
    return listCnx


def queryAnalyseEvt(mydb, domaine, date):
    query = QSqlQuery()
    dir = QStandardPaths.writableLocation(QStandardPaths.AppLocalDataLocation)
    listEvt = []
    evt = []
    # On se connecte à la base de donnée du domaine
    mydb.setDatabaseName(dir + "/" + domaine + ".sqlite")
    if not mydb.open():
        print("Database Error: {}".format(mydb.lastError().databaseText()))

    heure_debut = date.addSecs(-15 * 60)
    heure_fin = date.addSecs(5 * 60)

    # end_time >= heure_debut && start_time <= heure_fin
    my_query =  "SELECT datetime, event, detail, receiver, transmiter, user, channel, ip_adress  FROM evenements WHERE  "
    my_query += "datetime >= '{}' AND datetime <= '{}' ".format(heure_debut.toString("yyyy-MM-dd hh:mm:ss"), heure_fin.toString("yyyy-MM-dd hh:mm:ss"))

    # print("query : <{}>".format(my_query))

    if not query.exec("""{}""".format(my_query)):
        print("Database Error: {}".format(query.lastError().databaseText()))
    else:
        while query.next():
            evt.append(query.value("datetime"))
            evt.append(query.value("event"))
            evt.append(query.value("detail"))
            evt.append(query.value("receiver"))
            evt.append(query.value("transmiter"))
            evt.append(query.value("user"))
            evt.append(query.value("channel"))
            evt.append(query.value("ip_adress"))
            # print(evt)
            listEvt.append(evt)
        query.finish()
#    for element in listEvt:
#        print("evenement : {}".format(element))
    return listEvt









