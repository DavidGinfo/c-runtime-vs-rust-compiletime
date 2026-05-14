# Memory Safety

## Slide 5: What is Memory Safety? - Classification
(Frage: What is Memory Safety? - A Classification)
(die folgenden Speicherzugriffsfehler qualifizieren ein Programm als Memory Unsafe)
(die verschiedenen Kategorien auflisten, die ein Programm als unsicher qualifizieren)

- memory safety ist kein selten verwendeter Begriff, aber eine genaue Definition ist gar nicht so offensichtlich wie es erstmal erscheinen mag
- hier geht es zunächst einmal um die memory safety eines Programms: also die Frage, ob alle Ausführungen eines Programms Memory Safe sind
- wenn jedes Programm, was man mit einer Programmiersprache erzeugen kann Memory Safe ist, dann wird auch eine Programmiersprache als Memory Safe bezeichnet
- eine möglichkeit memory safety zu definieren ist zu sagen, dass ein programm als speicher sicher gilt, wenn kein Speicher Zugriffsfehler auftritt
- als Speicherzugriffsfehler bezeichnet man einen der folgenden Fehler:
   1. Out of bounds write
   2. Out of bounds read
   3. Use After Free
   4. Use of uninitialized Memory
   5. Double Free

- wenn also einer dieser Fehler in unserem Code passieren könnte, dann ist das Programm nicht Memory Safe
- zwei dieser hier genannten Kategorien decken sich mit den häufigsten Schwachstellen, die ich zu Beginn geannt hatte
- diese würde ich hier gerne nochmal an zwei praktischen Beispielen erklären

## Slide 6-9: Practical Example 1
(Beispiel Code und schrittweise Ausführung mit Grafik daneben zeigen bis Fehler passiert)
(hier Grafik für Heap verwenden, einzelne Zellen von links nach rechts)

- zunächst wollen wir uns einmal anschauen, wie ein Use After Free Fehler zustande kommen kann
- die Code Beispiel werden in C sein, weil das die Sprache mit C++ zusammen ist, die am weitesten verbreitet ist trotz ihres perse unsicheren Designs was Speicherverwaltung angeht

- hier sieht mein sehr kurzes aber prägnantes Code Beispiel für das Use After Free Problem
  1. Als erstes wird ein Speicherbereich reserveriert und in bufferPtr1 gespeichert
  2. Dieser Speicher wird direkt danach wieder freigegeben und kann damit vom Memory Management beim nächsten allokieren neu vergeben werden: bufferPtr1 nennt man ab hier "Dangling Pointer"
  3. Das passiert auch im nächsten Schritt, wenn der selbe Speicherbereich and bufferPtr2 vergeben wird
    - wichtig ist hier: das Verhalten ist zunächste einmal undefiniert
    - falls hier nicht noch einmal der selbe Speicherbereich vergeben werden sollte (was passieren kann) kann das Programm auch abstürzen oder komplett andere Daten auf der CMD printen
  4. Jetzt kopieren wir einen String in den gerade allokieren Speicherbereich
  5. Als letztes lesen wir den Speicherbereich auf den bufferPtr1 zeigt aus und geben den Inhalt auf der Konsole aus, in diesem Fall stürzt das Programm nicht ab, da der Block auf den bufferPtr1 zeigt der gleiche ist auf den bufferPtr2 aktuell zeigt, so erhalten wir den Inhalt aus einem Speicherbereich auf den wir eigentlich gar keinen Zugriff mehr haben sollten über bufferPtr1


## Slide 10-13: Practical Example 2
(Beispiel Code und schrittweise Ausführung mit Grafik daneben zeigen bis Fehler passiert)
(hier Grafik für Stack verwenden, Stapel von oben nach unten)

- neben dem User-AFter-Free ist der Out-of-bounds Write eben auch ein riesiges Problem
- auch hier kann man mit ein paar Code Zeilen zeigen wie es zu so einem Fehler kommen kann
    1. Als erstes wird einer Variable var angelegt und ihr der Wert 5 zugewießen
    2. dann ein Array der Länge 2 angelegt
    3. nun folgen drei aufeinanderfolgende Zuweisungen des Werts 2 auf Arrayelemente
        Mit dem Problem, dass eine zuweisung zu viel erfolgt, da der Array nur Speicher für 2 Integers reserveriert hat
    4. beim printen der Variablem var auf die Konsole wird dann auch nicht wie erwartet 5 sondern 2 ausgegeben
        das liegt an der Speicheranordnung: Variablen kommen in umgekehrter Reihenfolge auf den Stack (zumindest beim GCC Compiler)
        wenn man also die Adresse nach dem obersteen Element des arrays arr[1] um eins erhöht so schreibt man den Wert dann einfach in var rein

## Slide 14: Consequences
(beide Punkte auflisten und jeweils die Beispiele mit Stichpunkten darunter, keine Visualisierung hier nötig)

Beide Verhalten sind hinsichtlicht Sicherheit von Software äußerst problematisch aus folgenden Gründen:
1. Integrätet von Daten geht verloren:
    - Über den Pointer bufferPtr1 kann man genauso auch den Inhalt manipulieren, der evtl. wo anders verwendet wird
    - genauso lässt sich über den out-of-bounds write Speicher auf dem Stack ändern
2. Verfügbarkeit von einem Service kann durch Software Crash eingeschränkt sein:
    - Es gibt etwas, was sich Chunk-Consolidierung nennt, dabei werden freigegebene und benachbarte Speicherblöche zu größeren Blöcken zusammengeführt
      Falls das nach einem free passieren sollte, wird beim nächsten Memory Zugriff über bufferPtr1 das Programm crashen, da die Chunk Informationen nicht mehr valide sind
    - wenn durch den out-of-bounds write zufällig ein return adresse eine funktion überschrieben wird, kann auch hierdurch das Programm abstürzen


## Slide 15: Soluation Approaches
(hier die drei Ansätze auflisten mit je kurzer Erklärung und Titel, als bsp die Programmiersprachen Icons dazu packen)

ich denke, warum Speicher Sicherheit ein Problem ist, ist durch die Beispiele jetzt klar geworden
aber wie kann man die Probleme den vermeiden?
Dafür gibt es im wesentlichen drei Ansätze, die sich durchgesetzt haben:

1. Die Verwendung von Programmiersprachen mit automatischen Speicherverwaltung
   - mit der populärste Ansatz
   - hier hat der Entwickler garnicht die Möglichkeit Speicher selbst zu verwalten
   - dabei wird Speicher wird von einem Garbage Collector zur Laufzeit analysiert, verwaltet und freigegeben
   - Python, Java und JavaScript verwenden diese Art von Speicherverwaltung (wenn auch nicht auf die genau gleiche Art und Weise)
   - funktioniert äußerst zuverlässig, aber kostet immens Performance zur Laufzeit
2. Instrumentierung bestehenden unsicherer Programm, um Fehler zur Laufzeit ausfindig zu machen
   - in potentiell Speicher unsichere Programme werden beim compilieren Instruktionen eingefügt, welche zur Laufzeit ungültige Speicherzugriffe bemerken können
   - dafür sind zusätzliche Tools wie ASan (AdressSanatizer) oder Valgrind nötig
   - beide sehr populären Tools erkennen Fehler nicht zu 100%
   - je höher die Erkennungsrate ist desto höher sind die Kosten hinsichtlich Performance
3. Programmiersprachen, die durch ihren Compiler zur Compilezeit auf Memory Safety geprüft werden
   - potentielle Speicher Fehler werden garnicht kompiliert -> so kann es garnicht zu Fehlern kommen
   - und es gibt keine Runtime Overhead -> quasi optimale Performance
   - dafür sind aber einige neue Regeln und Konzepte notwendig
   - Rust bietet so eine Lösung an, die wir uns im folgenden anschauen werden 

# Sources

1. [Memory-Safety: Chancen und Herausforderungen für die Software-Sicherheit der Zukunft](https://www.societybyte.swiss/2025/11/27/memory-safety-chancen-und-herausforderungen-fuer-die-software-sicherheit-der-zukunft/)
    Ein kurzer Bericht darüber, was Memory Safety in der modernen Software bedeutet. Interessant sind hier primär die Zitierungen.

2. [Memory Safety: An Explainer](https://cset.georgetown.edu/article/memory-safety-an-explainer/)
    Kurze Zusammenfassung was Memory Safety für Probleme mit sich bring und warum es immer noch ein großes Problem ist.

3. [What is memory safety?](http://www.pl-enthusiast.net/2014/07/21/memory-safety/)
    Einfach zu lesendender Blockeintrag in dem jemand versucht Memory Safety zu definieren.
