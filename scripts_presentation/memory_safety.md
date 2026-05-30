# Memory Safety

## Slide 5: What is Memory Safety? - Classification

- aber was heißt denn jetzt genau Memory Safety
- memory safety ist kein selten verwendeter Begriff, aber eine genaue Definition ist gar nicht so offensichtlich wie es erst einmal erscheinen mag
- hier geht es zunächst einmal um die memory safety eines Programms: also die Frage, ob alle Ausführungen eines Programms Memory Safe sind
- wenn jedes Programm, was man mit einer Programmiersprache erzeugen kann Memory Safe ist, dann wird auch eine Programmiersprache auch als Memory Safe bezeichnet
- eine Möglichkeit memory safety zu definieren ist zu sagen, dass ein Programm als speicher sicher gilt, wenn kein Speicher Zugriffsfehler auftritt
- als Speicherzugriffsfehler bezeichnet man einen der folgenden Fehler:
  1. Out of bounds write
  2. Out of bounds read
  3. Use After Free
  4. Use of uninitialized Memory
  5. Double Free
- wenn also einer dieser Fehler in unserem Code passieren könnte, dann ist das Programm nicht Memory Safe
- abkürzend könnte man auch sagen ein Programm gilt als Memory Safe, wenn es nicht auf auf undefinierten Speicher zugreift
- undefinierter Speicher ist Speicher, der vorher nicht explizit als Heap, Stack oder statische Daten alloziert wurde
- zwei dieser hier genannten Kategorien, bei denen genau so ein undefinierter Zugriff erfolgt, decken sich mit den häufigsten Schwachstellen, die ich zu Beginn genannt hatte
- diese würde ich hier gerne nochmal an zwei praktischen Beispielen erklären

## Slide 6-12: Practical Example 1

- zunächst wollen wir uns einmal anschauen, wie ein Use After Free Fehler zustande kommen kann
- Das Use-After-Free Problem tritt nur im Zusammenhang mit dynamischen Speicherverwaltung auf
- Das bedeutet es geht immer um Speicher, der auf dem Heap zugeteilt wurde
- die Code Beispiel werden in C sein, weil das die Sprache mit C++ zusammen ist, die am weitesten verbreitet ist trotz ihres perse speicher-unsicheren Designs was Speicherverwaltung angeht
- hier sieht mein sehr kurzes aber prägnantes Code Beispiel für das Use After Free Problem
  1. Als erstes wird ein Pointer angelegt und mittels malloc() ein Speicherbereich der Größe eines Integers reserviert
  2. Diesem reservierten Speicher wird dann direkt der Wert 21 zugewiesen
  3. Danach wird ein zweiter Pointer angelegt, der auf den selben Speicherbereich zeigt wie der erste Pointer
  4. Nun wird der Speicherbereich auf den der erste Pointer zeigt freigegeben, damit zeigen der erste und zweite Pointer auf einen nicht mehr fültigen Speicherbereich und sind damit Dangling Pointer
  5. Wie beim ersten Pointer wird nun ein dritter Pointer erstellt dem wieder mittels malloc() ein Speicher Block zugeteilt wird, in diesem Fall der gleiche Speicherblock, der zuvor mittels free() freigegeben wurde, das ist natürlich nicht immer der Fall und je nach Allokator-Algorithmus und Heap Verwaltung immer anders, aber theoretisch ist es immer möglich, dass jeder freigegebene Block beim Aufruf von malloc() wieder vergeben wird
  6. Der neu zugeteilte Speicherblock bekommt nun auch einen Wert 42 zugewiesen
  7. Nun verwenden wir den Pointer, den wir als zweites erstellt haben und der zum Erstellungszeitpunkt auf den gleichen Speicherblock wie Pointer 1 gezeigt hat, allerdings ist dieser Speicher mittlerweile freigegeben, trotzdem verwenden wir den zweiten Pointer, um diesen zu dereferenzieren. Was passiert ist, dass der Speicherblock an der Adresse, die immer noch im zweiten Pointer hinterlegt ist gelesen wird. Dieser wurde aber nach dem Freigeben neu an Pointer 3 verteilt und mit einem anderen Wert beschrieben, der dann jetzt beim Dereferenzieren von Pointer 3 mit ausgelesen wird
- Dieses Verhalten ist natürlich fatal, wenn über Pointer 3 beispielsweise vertrauliche Daten geschrieben wurden und jetzt fälschlicherweise ein Zugriff über einen anderen Pointer auf diese Daten möglich ist
- derartige Fehler passieren sehr schnell, ins besondere dann, wenn mehrere Zeiger auf den gleichen Speicher zeigen, der dann aber nur über einen der Zeiger explizit gefreed wird

## Slide 13-16: Practical Example 2

- neben dem User-After-Free ist der Out-of-bounds Write eben auch ein riesiges Problem
- auch hier kann man mit ein paar Code Zeilen zeigen wie es zu so einem Fehler kommen kann
  1. Als erstes wird einer Variable var angelegt und ihr der Wert 5 zugewießen
  2. dann ein Array der Länge 2 angelegt und beide Elemente des Arrays mit dem Wert 2 initialisiert
  3. Nun wird eine Funktion aufgerufen, die einen Pointer also das Array und einen Index annimmt, diese Funktion schreibt den Wert 99 in das Elemente mit angegebenem Index im Array ohne zu prüfen, ob dieser Index valide ist. Was jetzt genau im Speicher passiert ist zunächst einmal undefiniert und hängt stark vom Format ab in dem die Variable und das Array auf dem Stack abgelegt wurden (das ist nämlich Compilerabhängig). Beim GNU Compiler findet man aber das hier gezeigte Format vor. Ein Stack auf den die Elemente mit absteigender Adresse gestapelt werden. Beim Schreiben außerhalb vom validen Bereich des Arrays wird der Pointer so inkrementiert, dass dieser auf den Speicherbereich der Variable zeigt und diese manipuliert
  4. Beim printen der Variablem var auf die Konsole wird dann auch nicht wie erwartet 5 sondern 99 ausgegeben
- wenn man denkt, naja eine Variable verändert, das kann ja nicht so schlimm sein
- Dann muss man sich einmal vorstellen, dass statt dieser Variable dort ein Array liegt, der Funktionespointer enthält, manipuliert man hier geschickt eine Adresse, so kann man schnell Code ausführen, den man als Angreifer platziert hat

## Slide 17: Consequences

Beide Verhalten sind hinsichtlicht Sicherheit von Software äußerst problematisch aus folgenden Gründen:

1. Integrätet der Daten geht verloren:
    - Über die Dangling Pointer aus dem Use-After-Free Beispiel kann man sensible Daten im Heap lesen oder auch manipulieren auf die eigentlich kein Zugriff bestehen sollte
    - genauso lässt sich über den out-of-bounds write Speicher auf dem Stack ändern
2. Verfügbarkeit von einem Service kann durch Software Crash eingeschränkt sein:
    - Es gibt etwas, was sich Chunk-Consolidierung nennt, dabei werden freigegebene und benachbarte Speicherblöcke im Heap zu größeren Blöcken zusammengeführt um die Fragementierung zu reduzieren
    - Falls das nach einem free passieren sollte, wird beim nächsten Memory Zugriff über einen Dangling Pointer das Programm crashen, da die Chunk Informationen nicht mehr valide sind
    - wenn durch den out-of-bounds write zufällig ein return adresse eine funktion überschrieben wird, kann auch hierdurch das Programm abstürzen

## Slide 18: Soluation Approaches

ich denke, warum Speicher Sicherheit ein Problem ist, ist durch die Beispiele jetzt klar geworden
aber wie kann man die Probleme den vermeiden?
Dafür gibt es im wesentlichen drei Ansätze, die sich durchgesetzt haben:

1. Die Verwendung von Programmiersprachen mit automatischen Speicherverwaltung
   - mit der populärste Ansatz
   - hier hat der Entwickler garnicht die Möglichkeit Speicher selbst zu verwalten
   - dabei wird Speicher von einem Garbage Collector zur Laufzeit analysiert, verwaltet und freigegeben
   - Python, Java und JavaScript verwenden diese Art von Speicherverwaltung (wenn auch nicht auf die genau gleiche Art und Weise)
   - funktioniert äußerst zuverlässig, aber kostet immens Performance zur Laufzeit
2. Instrumentierung bestehenden unsicherer Programme, um Fehler zur Laufzeit ausfindig zu machen
   - in potentiell Speicher unsichere Programme werden beim Compilieren Instruktionen eingefügt, welche zur Laufzeit ungültige Speicherzugriffe bemerken können
   - dafür sind zusätzliche Tools wie ASan (AdressSanatizer) oder Valgrind nötig, wenn man C/C++ Code besser absichern möchte
   - beide sehr populären Tools erkennen Fehler nicht zu 100%
   - je höher die Erkennungsrate ist desto höher sind die Kosten hinsichtlich Performance
   - Aber auch Programmiersprachen wie Rust bieten hier auch Möglichkeiten, um bei bspw. Out-of-bounds Zugriffe das Programm sicher abstürzen zu lassen, statt einfach illegal auf den Speicher zuzugreifen
3. Programmiersprachen, die durch ihren Compiler zur Compilezeit auf Memory Safety geprüft werden
   - potentielle Speicher Fehler werden garnicht kompiliert -> so kann es garnicht zu Fehlern kommen
   - und es gibt keine Runtime Overhead -> quasi optimale Performance
   - dafür sind aber einige neue Regeln und Konzepte notwendig
   - Rust bietet so eine Lösung an, die wir uns im folgenden anschauen werden
