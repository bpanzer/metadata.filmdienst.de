# metadata.filmdienst.de
Add-on für [Kodi](https://github.com/xbmc), das Filminfos und Bewertungen von [Filmdienst.de](https://www.filmdienst.de/) holt.

## Installation
Da dieses Add-on nicht im offiziellen Kodi-Repository verfügbar ist, muss man zunächst die Installation von Add-ons aus unbekannten Quellen erlauben:
Settings -> System -> Add-ons: "Unknown Sources" aktivieren

Dann lässt sich dieses Add-on so installieren:
Menü "Add-ons" -> Add-on-Browser (Kreis mit Kartons, links oben) -> Install from zip file -> zip-Archiv von den Releases auswählen

Der Inhalt des zip-Archivs lässt sich leicht überprüfen. Es enthält keinen ausführbaren Code, sondern letztlich nur einige reguläre Ausdrücke in der Datei filmdienst.de.xml. Das ist unten unter "Entwicklung" beschrieben.


## Nutzung
Um Filme mit diesem Add-on zu scrapen, muss man es für das Verzeichnis, in dem die Filme liegen, auswählen:
Settings → Library → Videos -> Kontextmenü des entsprechenden Verzeichnisses -> Scraper.
Falls dort bereits Filme liegen und mit einem anderen Add-on gescrapt wurden, muss man diese Daten vorher verwerfen, indem man dort „This directory contains“ einmal auf "None" setzt, Ok wählt und dann diese Einstellung wieder auf "Movies" setzt und den Scraper auswählt. 

## Einschränkungen und offene Punkte

## Entwicklung
