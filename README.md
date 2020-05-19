# metadata.filmdienst.de
Add-on für [Kodi](https://github.com/xbmc), das Filminfos und Bewertungen von [Filmdienst.de](https://www.filmdienst.de/) holt.

## Installation
Da dieses Add-on nicht im offiziellen Kodi-Repository verfügbar ist, muss man zunächst die Installation von Add-ons aus unbekannten Quellen erlauben:  
Settings → System → Add-ons: "Unknown Sources" aktivieren  
  
Dann lässt sich dieses Add-on so installieren:  
Menü "Add-ons" → Add-on-Browser (Kreis mit Kartons, links oben) → Install from zip file → zip-Archiv von den Releases auswählen  

Der Inhalt des zip-Archivs lässt sich leicht überprüfen. Es enthält keinen ausführbaren Code, sondern letztlich nur einige reguläre Ausdrücke in der Datei filmdienst.de.xml. Das ist unten unter "Entwicklung" beschrieben.


## Nutzung
Um Filme mit diesem Add-on zu scrapen, muss man es für das Verzeichnis, in dem die Filme liegen, auswählen:  
Settings → Library → Videos -> Kontextmenü des entsprechenden Verzeichnisses → Scraper.  
  
Falls dort bereits Filme liegen und mit einem anderen Add-on gescrapt wurden, muss man diese Daten vorher verwerfen, indem man dort „This directory contains“ einmal auf "None" setzt, Ok wählt und dann diese Einstellung wieder auf "Movies" setzt und den Scraper auswählt. 

## Einschränkungen und offene Punkte
- Es wird nur der erste Eintrag vom Genre nach Kodi importiert. Ich bin daran gescheitert, den String per rekursivem RegEx zu parsen (siehe Code). Verbesserungen sind willkommen!
- Filmdienst.de zeigt oft ein oder mehrere Fotos zu den Filmen. Allerdings sind es meist nicht die Plakate, daher importiere ich sie standardmäßig nicht. Außerdem fragt Kodi diese Bilder per HEAD-Abfrage an, worauf Filmdienst.de aber keine Bilder ausliefert. Ich habe testweise das kleine Script filmdienst.de-proxy.pl geschrieben, das die HEAD- in GET-Abfragen umwandelt. Wenn man das laufen lässt, es als HTTP-Proxy in Kodi konfiguriert und den RegEx für die Fotos einkommentiert kann so die Fotos von Filmdienst.de abholen.  
Man kann manuell Poster suchen und bei den Filmdateien ablegen. Sie müssen exakt den Namen der Film- (oder auch .nfo-)Datei enthalten: \<filmdatei\>_-poster.jpg_

## Entwicklung

Grundsätzlich hilfreiche Links:  
https://kodi.wiki/view/HOW-TO:Write_media_scrapers#GetDetails  
https://kodi.wiki/view/Scrapers  

Tipps:  
- Relevante Log-Meldungen landen im kodi.log im userdata- (Win) oder temp- (Linux) Verzeichnis
- Um die DEBUG-Log-Einträge zu bekommen wird wohl die Datei advancedsettings.xml benötigt, evtl. mit Loglevel=2 darin
- NFO-Dateien lassen sich im Einstellungen-Menü unter Media Settings → Library → Export Library exportieren bzw. erzeugen. 
- Wenn beim Scrapen NFO-Dateien vorhanden sind werden sie bevorzugt, d.h. der Scraper holt sich keine Informationen aus dem Internet.
- Wenn beim Scrapen ein falscher Film erkannt wurde, kann man ihn in der Info-Ansicht des Films mit dem Refresh-Button korrigieren bzw. den richtigen Film aus mehreren Treffern auswählen.
- Der GetDetails-Teil des Scrapers muss die einzelnen Felder in der Form ausgeben, in der sie auch im NFO-File enthalten sind.

Reguläre Ausdrücke:  
- Der Regex .*? erfasst möglichst wenig Text
- Der Regex .* erfasst möglichst viel Text (greedy)
- Es ist mir nicht gelungen, im Regex Zeilenumbrüche oder Whitespace gezielt zu berücksichtigen. Ich habe sie jeweils durch .* ersetzt.

If-then-else im Regex:  
Folgendes Konstrukt realisiert eine if-then-else-Logik. Die ist hier nötig, weil Filmdienst bei den Filmen, zu denen eine Langkritik vorhanden ist, einen Link darauf am Ende der Kurzkritik einfügt. Dieser Link soll ggf. entfernt werden, also die reine Kurzkritik ausgegeben werden.  
Dazu matcht der Regex A auf eine Kritik, die den Link zur Langkritik enthält, und leitet die Ausgabe an Regex B. Außerdem ist das clear=yes offenbar wichtig. Der Regex B matcht auf einen nicht-leeren String und leitet diesen ggf. an den umgebenden Regex zur Ausgabe. Falls der Regex B nicht matcht kommt Regex C zum Zuge, der auf einen leeren String matcht. Er leitet nochmal den Input, den Regex B erhalten hat, an den Regex D. Dieser matcht auf eine Kurzkritik (mit oder ohne Link) und leitet diese an den umgebenden Regex zur Ausgabe.  
```
<RegExp input="$$6" output="&lt;plot&gt;\1&lt;/plot&gt;" dest="5+">
	<RegExp id="A" input="$$1" output="\1" dest="7">
		<expression clear="yes">&lt;div class=&quot;col-xs-12 col-sm-offset-1 col-sm-10 col-md-offset-0 col-md-8&quot;&gt;(.*?)&lt;div class=&quot;critique-button&quot;&gt;.*?&lt;a class=&quot;btn btn-lg btn-default text-uppercase&quot; href=&quot;#kritik&quot;&gt;.*?Zur Langkritik.*?&lt;/a&gt;.*?&lt;/div&gt;</expression>
	</RegExp>
	<RegExp id="B" input="$$7" output="\1" dest="6">
		<expression>(.+)</expression>
	</RegExp>
	<RegExp id="C" input="$$7" output="$$1" dest="8">
		<expression>^$</expression>
	</RegExp>
	<RegExp id="D" input="$$8" output="\1" dest="6">
		<expression>&lt;div class=&quot;col-xs-12 col-sm-offset-1 col-sm-10 col-md-offset-0 col-md-8&quot;&gt;(.*?)&lt;/div&gt;</expression>
	</RegExp>
	<expression>(.+)</expression>
</RegExp>
```


Extraktion der Darsteller  
Die Darsteller werden auf der filmdiest.de-Seite so aufgelistet:  
```
<RegExp input="$$6" output="&lt;plot&gt;\1&lt;/plot&gt;" dest="5+">
	<RegExp id="A" input="$$1" output="\1" dest="7">
		<expression clear="yes">&lt;div class=&quot;col-xs-12 col-sm-offset-1 col-sm-10 col-md-offset-0 col-md-8&quot;&gt;(.*?)&lt;div class=&quot;critique-button&quot;&gt;.*?&lt;a class=&quot;btn btn-lg btn-default text-uppercase&quot; href=&quot;#kritik&quot;&gt;.*?Zur Langkritik.*?&lt;/a&gt;.*?&lt;/div&gt;</expression>
	</RegExp>
	<RegExp id="B" input="$$7" output="\1" dest="6">
		<expression>(.+)</expression>
	</RegExp>
	<RegExp id="C" input="$$7" output="$$1" dest="8">
		<expression>^$</expression>
	</RegExp>
	<RegExp id="D" input="$$8" output="\1" dest="6">
		<expression>&lt;div class=&quot;col-xs-12 col-sm-offset-1 col-sm-10 col-md-offset-0 col-md-8&quot;&gt;(.*?)&lt;/div&gt;</expression>
	</RegExp>
	<expression>(.+)</expression>
</RegExp>
```


Sie können mit folgenden Regex leicht extrahiert werden. Zunächst matcht der Regex A auf das umschließende `<dt>Darsteller</dt>.*?<dd>(.*?)</dd>` und gibt den Inhalt zwischen `<dd>` und `</dd>` an den Regex B weiter. Der matcht auf einen einzelnen span-Block und erzeugt die entsprechende Ausgabe. Aufgrund der Option repeat=yes ruft Kodi ihn wiederholt auf, solange es noch unbearbeitete span-Blöcke gibt.
```
<RegExp id="A" input="$$1" output="\1" dest="10">
	<expression noclean="1">&lt;dt&gt;Darsteller&lt;/dt&gt;.*?&lt;dd&gt;(.*?)&lt;/dd&gt;</expression>
</RegExp>
<RegExp id="B" input="$$10" output="&lt;actor&gt;&lt;name&gt;\1&lt;/name&gt;&lt;role&gt;\2&lt;/role&gt;&lt;/actor&gt;" dest="5+">
	<expression repeat="yes" noclean="1" trim="1">&lt;span class=&quot;credit.*?&lt;a href=&quot;/person/filme/[0-9]+&quot;&gt;(.*?)\((.*?)\).*?&lt;/a&gt;.*?&lt;/span&gt;</expression>
</RegExp>
```

