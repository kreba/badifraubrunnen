Badi2010
========

0. Systemvoaussetzungen (Entwicklermaschine)
--------------------------------------------

Das gem pg für postgresql-Datenbanken (Heroku nutzt 9.1) benötigt einen lokalen Postgres-Server:
sudo aptitude install postgresql-9.1 postgresql-server-dev-9.1

Die Bilder für die Saisonübersicht werden mit RMagick erstellt, was ein lokales ImageMagick benötigt:
sudo aptitude install libmagickwand-dev

Die Javascript-Funktionalitäten benötigen offenbar eine lokale Runtime:
sudo aptitude install nodejs

Das Zwischenspeichern von Seitenfragmenten geschieht mithilfe von memcached (via Dalli):
sudo aptitude install memcached

Ausserdem sollten git, rvm und der heroku-toolbelt installiert werden:
sudo aptitude install git
Siehe https://rvm.io/rvm/install/
Siehe https://devcenter.heroku.com/articles/quickstart

Eine IDE hab ich bisher nicht benutzt.


1. Technische Überlegungen
--------------------------

Start- und Enddatum der Saison sind implizit gegeben durch den ersten und 
letzten erstellten Tag (desselben Jahres). Evtl trotzdem als Attribut speichern.

Jeder Tag gehört zu einer Woche.
Die Organisation benutzt Wochenpläne, welche als PDF an die Helfer gemailt, 
sowie ausgedruck und in der Badi angeschlagen werden. Jede Woche hat eine 
verantwortliche Person (Wochenverantwortliche/r). Ausserdem können Wochen en
bloc 'vergeben' werden. Aus diesem Grund soll auch nicht die gesamte Saison von
anfang an verfügbar sein, d.h. Tage sollen 'inaktiviert' werden können, nachdem
sie erstellt wurden.
Evtl. explizite und implizite inaktivierung. Explizit durch Administrator
(Datenbankattribut für Schichten; Sammelaktion für Tag); implizit durch Datum
(z.B. von heute bis zum 1.7.09; Eigenschaften einer 'Saison').

Ein Tag ist im wesentlichen ein Kalenderdatum. Dazu gehören mehrere Schichten,
welche wiederum eine Start- und Endzeit sowie eine verantwortliche Person
(Hüter/in) haben. Die Zeiten der Schichten und deren Anzahl sollen zu einem
beliebigen Zeitpunkt geändert werden können. (evtl. halbautomatisch, d.h. für
mehrere Schichten/Tage/Wochen gleichzeitig)

Personen können nebst ihrer Identität (inkl. Name, Adresse) auch
mehrere Rollen haben.

Für die Badi:
staff kann
- an mehreren Tagen hüten und für mehrere Wochen verantwortlich sein.
- seine/ihre belegten Schichten auflisten

admin kann
- Saison-Daten festlegen (nur badi)
- Schichten pro Tag und deren Schichtenzeiten bearbeiten (nur badi)
- Tage explizit inaktivieren (nur badi) (Schichteneigenschaft; Sammelaktion pro Tag)
- Schichten Personen zuweisen oder freigeben
- Wochen    Personen zuweisen oder freigeben
- Personalien von badiStaff-Personen bearbeiten (inkl. Passwort)

Die Rollen staff und admin gibt es auch für den Kiosk, jedoch auf einem separaten
Satz Schichten (Eigenschaft badi/kiosk als attribut der shiftinfos). Badi und
Kiosk sind (in der DB persistierte) instanzen eines Saison-Objekts

webmaster kann
- alle administrativen Aufgaben für badi + kiosk ausführen


Ohne spezielle Rolle kann jeder angemeldete Benutzer
- Die Planung einsehen (Saisonübersicht/Wochenansicht/Tagesansicht(/Schichtansicht))
- Eine vollständige Personenliste anzeigen (evtl. einschränken gem. Rollen?)
- Eigene Personalien bearbeiten
- Sich ausloggen

Ohne Anmeldung kann Jede/r
- Die Hilfeseite anzeigen
- Die Startseite anzeigen
- Sich einloggen


2. Wie setze ich eine Saison auf?
---------------------------------
Erst sicherstellen, dass "ApplicationController.year" das richtige Jahr zurückgibt (und ggf. die Rails-Konsole neu starten!)
Dann in der "script/console production":
- evtl. vorhandene Daten mittels "Week.destroy_all" vernichten
- (19..37).each{|n| Week.create!( number: n )}
- [1,12,6,3,32,33,35].each{|n| Saison.long_days.each{|day| Shift.create!(shiftinfo_id: n, day_id: day.id); day.save!}}
- [26,27,28,29,30,33,36].each{|n| Saison.short_days.each{|day| Shift.create!(shiftinfo_id: n, day_id: day.id); day.save!}}
- Saison.kiosk.update_attributes( begin: "2012-05-05", end: "2012-09-16" )
-  Saison.badi.update_attributes( begin: "2012-05-05", end: "2012-09-16" )

Achtung: Alle Schichten sind standardmässig aktiviert.
Dies kann aber z.B. mittels "Week.all.each{|w| w.disable(Saison.badi)}" bequem geändert werden.

et voilà! :D
