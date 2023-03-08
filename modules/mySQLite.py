from PySide6.QtSql import QSqlQuery
from PySide6.QtCore import QStandardPaths, QDateTime
from datetime import datetime




def connecDataBase(mydb, name):
    dir = QStandardPaths.writableLocation(QStandardPaths.AppLocalDataLocation)

    mydb.setDatabaseName(dir + "/" + name + ".sqlite")
    if not mydb.open():
        print("Database Error: {}".format(mydb.lastError().databaseText()))

def changeDatabase(mydb, name):
    dir = QStandardPaths.writableLocation(QStandardPaths.AppLocalDataLocation)
    mydb.close()
    mydb.setDatabaseName(dir + "/" + name + ".sqlite")
    if not mydb.open():
        print("Database Error: {}".format(mydb.lastError().databaseText()))


def createTable(mydb):
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
            chanel VARCHAR(20),
            ip_adress VARCHAR(17),
            user_agent VARCHAR(80)
        )
        """
    ):
        print("Qquery.exec() - Error!")
        print("Database Error: {}".format(query.lastError().databaseText()))
    else:
        print("Création de la table evenements, dans {}.".format(mydb.databaseName()))


def insertRecords(mydb, domaine, records, table):
    nbErr = 0
    nbOk = 0
    query = QSqlQuery()
    dir = QStandardPaths.writableLocation(QStandardPaths.AppLocalDataLocation)

    # On se connecte à la base de donnée du domaine
    mydb.setDatabaseName(dir + "/" + domaine + ".sqlite")
    if not mydb.open():
        print("Database Error: {}".format(mydb.lastError().databaseText()))

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


def createQueryForListe(liste, table):
    query = "INSERT INTO {} VALUES(".format(table)
    for element in liste:
        if type(element) is int:
            query += " {},".format(element)
        else:
            query += " '{}',".format(element)

    query = query[: -1]
    query += ")"
    print("Query <{}> ".format(query))
    return query




def listPosition(mydb, domaine):
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
        print("Sélection OK")
        while query.next():
            print("On ajoute <{}> à la liste des positions.".format(query.value(0)))
            listReceiver.append(query.value(0))
        query.finish()
    return listReceiver


def firstDate(mydb, domaine):
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
            print("Min start_time of connexions : <{}>".format(query.value(0)) )
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
            print("Min date_time of evenements : <{}>".format(query.value(0)) )
            # date_time_evenements = datetime.fromisoformat (query.value(0))
            date_time_evenements = QDateTime.fromString(query.value(0),"yyyy-MM-dd hh:mm:ss")
        query.finish()
    if (date_time_connexions < date_time_evenements) :
        dates.append(date_time_connexions)
    else:
        dates.append(date_time_evenements)

        #########################################`
        # SELECTION de la plus grande date
        #########################################
        if not query.exec(
            """
            SELECT DISTINCT MAX(start_time) FROM connexions
            """
        ):
            print("Database Error: {}".format(query.lastError().databaseText()))
        else:
            while query.next():
                print("MAX start_time of connexions : <{}>".format(query.value(0)) )
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
                print("MAX date_time of evenements : <{}>".format(query.value(0)) )
                # date_time_evenements = datetime.fromisoformat (query.value(0))
                date_time_evenements = QDateTime.fromString(query.value(0),"yyyy-MM-dd hh:mm:ss")
            query.finish()
        if (date_time_connexions < date_time_evenements) :
            dates.append(date_time_connexions)
        else:
            dates.append(date_time_evenements)

    return(dates)







