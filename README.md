Badi2010
========
                
Webapplikation zur Koordination der Helfer*innen der Badi Fraubrunnen.

Die Applikation ist mit Ruby on Rails gebaut und läuft auf Heroku. Als Datenbank kommt Postgres zum Einsatz.
Für bessere Performance werden Seitenfragmente serverseitig im Cache gehalten. Hierzu verwenden wir Memcache.


0. Systemvoaussetzungen (Entwicklermaschine)
--------------------------------------------

> _Die unten aufgeführten Kommandos gehen davon aus, dass die Entwicklermaschine unter einem __Linux__-Betriebssystem läuft. <br>
> Unter __MacOS__ funktioniert vieles ähnlich und zur Installation von Systemkomponenten empfiehlt sich [Homebrew](https://brew.sh/). <br>
> Unter __Windows__ kann man auch entwickeln, aber das kann haarig werden. Viel Glück!_  

Das Versionsmanagement erfolgt mittels [Git](https://git-scm.com/).

    sudo apt install git

Nebst Ruby müssen Postgres und NodeJS installiert sein, gemäss der Datei `.tool-versions`. 
Das geht z.B. praktisch mit [asdf-vm](https://asdf-vm.com/). 
Damit kann man im besten Fall im Projektverzeichnis diesen Befehl ausführen und fertig:

    asdf install

Evtl muss dann der Postgres-Server noch gestartet werden. 
Der zweite Befehl listet alle Datenbanken in diesem Server (bzw. Cluster) auf.
 
    pg_ctl start   
    psql -l

Je nachdem kann es praktisch sein, einen eigenen Datenbank-Superuser anzulegen:

    createuser --echo --superuser $(whoami)

Die Applikation bekommt ihre eigene, lokale Development-Datenbank. Diese wird in `config/database.yml` konfiguriert. 
Damit jeder Entwickler die Hoheit über sein eigenes Setup behält, haben wir davon nur eine Beispieldatei im Repo.  

    # Gib dem User das Passwort "badifraubrunnen" gemäss config/database.yml
    createuser --echo --createdb --login --pwprompt badifraubrunnen

Um die Development-Datenbank aus dem Projektverzeichnis heraus praktisch verwenden zu können, können die entsprechenden
Umgebungsvariabeln für Postgres gesetzt werden. Dies z.B. mittels [Direnv](https://direnv.net/).

    # Datei .envrc im Projektverzeichnis mit folgendem Inhalt:
    export PGHOST=localhost
    export PGUSER=badifraubrunnen
    export PGDATABASE=badifraubrunnen_dev


Automatisierte Tests verwenden z.T. Capybara-Webkit, dieses benötigt die Entwicklerbibliotheken von Qt.
Siehe https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit#debian--ubuntu 

    sudo apt install libqt5webkit5-dev

Das Zwischenspeichern von Seitenfragmenten geschieht mithilfe von Memcache (via Dalli). 
Auf der Entwicklermaschine könnte man auch einfach einen In-Memory-Cache verwenden, aber es empfiehlt sich,
mit einem möglichst produktionsnahen Setup zu entwickeln.

    sudo apt install memcached

Allenfalls hat es noch weitere Instruktionen im `Gemfile`.

Es hat ein Setup-Skript, welches nun ausgeführt werden können sollte:

    bin/setup

Dann kann die Applikation lokal laufen gelassen werden mit:
                                                           
    bin/rails server


1. Technische Überlegungen
--------------------------

Start- und Enddatum der Saison sind implizit gegeben durch den ersten und 
letzten erstellten Tag (desselben Jahres). Evtl trotzdem als Attribut speichern.

Jeder Tag gehört zu einer Woche.
Die Organisation benutzt Wochenpläne, welche als PDF an die Helfer gemailt, 
sowie ausgedruckt und in der Badi angeschlagen werden. Jede Woche hat eine 
verantwortliche Person (Wochenverantwortliche/r). Ausserdem können Wochen en bloc
'vergeben' werden. Aus diesem Grund ist i.d.R. auch nicht die gesamte Saison von
Anfang an verfügbar, d.h. Helfer*innen können sich zu Beginn nicht überall eintragen.
Administratoren können zu diesem Zweck jede Woche einzeln aktivieren/deaktivieren.  
(Zusätzlich können nur Schichten an Tagen innerhalb der Saison aktiv sein.)

Ein Tag ist im Wesentlichen ein Kalenderdatum. Dazu gehören mehrere Schichten,
welche wiederum eine Start- und Endzeit sowie eine verantwortliche Person
(Hüter*in) haben. Die Zeiten der Schichten und deren Anzahl können zu einem
beliebigen Zeitpunkt geändert werden.

Personen können nebst ihrer Identität (inkl. Name, Adresse) auch eine oder mehrere 
Rollen haben. Diese Rollen sind meist an eine Organisationseinheit gebunden. Diese
sind im Datenmodell als separate "Saisons" abgebildet: `badi` und `kiosk`.

`staff` kann
- an mehreren Tagen hüten und für mehrere Wochen verantwortlich sein.
- seine/ihre belegten Schichten auflisten

`admin` kann
- Schichten pro Tag und deren Schichtenzeiten bearbeiten
- Das selbständige Eintragen für Helfer*innen wochenweise aktivieren/inaktivieren
- Schichten Personen zuweisen oder freigeben (Kasse, Wasseraufsicht, Pikett, ...)
- Wochen    Personen zuweisen oder freigeben (Wochenverantwortung)
- Personalien von Personen bearbeiten (inkl. Passwort)

`webmaster` kann
- alle administrativen Aufgaben für badi + kiosk ausführen

Angemeldete Benutzer*innen ohne spezielle Rolle können
- Die Planung einsehen (Saisonübersicht/Wochenansicht/Tagesansicht(/Schichtansicht))
- Eine vollständige Personenliste anzeigen
- Eigene Personalien bearbeiten
- Sich ausloggen

Nicht angemeldete Benutzer*innen können
- Die Hilfeseite anzeigen
- Die Startseite anzeigen
- Sich einloggen


2. Deployment
-------------

Es laufen zwei Instanzen der Applikation auf [Heroku](https://www.heroku.com).
Die PROD-Umgebung ist für den laufenden Betrieb gedacht. Die DEMO-Umgebung enthält keine vertraulichen Personendaten
oder Passwörter und kann für Demonstrationszwecke benutzt werden, z.B. für ein Entwickler-Portfolio.

Zur Kontrolle der Instanzen auf Heroku sollte deren CLI installiert werden. Instruktionen dazu siehe 

    https://devcenter.heroku.com/articles/heroku-cli#download-and-install

Dann einloggen und aus dem Projektverzeichnis heraus mit der bestehenden Applikation verbinden:

    heroku login
    heroku git:remote --app=badifraubrunnen --remote=prod
    heroku git:remote --app=badifraubrunnen-demo --remote=demo
    git remote -v
    
Das fügt dem lokalen Git-Repository weitere Remote-Repositories namens `prod` und `demo` hinzu.
Anschliessend kann man den aktuellen Code ganz einfach mittels Git-Push auf Heroku deployen:
                                                                                            
    git push prod

Es gibt auch viele hilfreiche Artikel hierzu im 
[Devcenter von Heroku](https://devcenter.heroku.com/articles/git#for-an-existing-heroku-app).


3. Backup und Restore
---------------------

Da die Applikation auf Heroku läuft, werden DB-Backups dort erstellt. 
Infos zu allen verfügbaren Kommandos erhält man mit 

    heroku help pg
    
So zum Beispiel

    heroku pg:backups
    heroku pg:backups:capture
    heroku pg:backups:download
    mv latest.dump db/badifraubrunnen_$(date --iso).dump
    
Um lokal mit einer produktionsnahen DB zu arbeiten, kann die DB von Heroku lokal kopiert werden.

    dropdb badifraubrunnen_dev
    heroku pg:pull ORANGE badifraubrunnen_dev


4. Saisonwechsel
----------------

Datenmodell und Benutzerkonzept sind darauf ausgelegt, nur ein einzelnes Jahr abzubilden. 
Deshalb muss alle Jahre wieder ein Entwickler den Jahreswechsel vornehmen. 
Dafür gibt es noch kein Skript, aber ungefähr so wird das aussehen: 
                                          
    $ bin/rails console
    d1 = Saison.badi.begin; d2 = Date.commercial(d1.year + 1, d1.cweek, d1.cwday)
    diff = d2 - d1 # meist äquivalent zu 52.weeks, aber manche Jahre auch 53.weeks
    Saison.all.each{ |s| s.update begin: s.begin + diff, end: s.end + diff }
    Shift.all.each{ |s| s.update person: nil, enabled: false }
    Week.all.each{ |w| w.update person: nil, enabled_saisons: "" }
    Day.all.each{ |d| d.update date: d.date + diff, admin_remarks: nil }

et voilà! :D
