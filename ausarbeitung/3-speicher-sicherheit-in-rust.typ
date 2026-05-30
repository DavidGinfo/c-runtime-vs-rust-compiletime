= Rust's Approach

== Slide 19: Why use Rust?

- Rust verspricht die Lösung für die Kombination zweier bislang nicht kombinierbarer Programmier Herausforderungen zu sein
- Volle Hardware und Speicher Kontrolle ohne auf Sicherheit und Entwicklererlebnis zu verzichten
- Rust bietet neben dem herzstück dem Rust Compiler auch viele andere Entwicklungswerkzeuge wie Formatter, Language Server und Paket Manager an
- Scheinbar sind das auch keine leeren Versprechen
- Zumindest wenn man den stackoverflow statistiken vertraut
- Dort ist Rust seit Jahren die beliebteste aufstrebende Programmiersprache
- Über 72% der Entwickler, die angefangen haben Rust zu verwenden, verwenden es auch über die nächsten Jahre hinweg weiter
- aber was muss diese Programmiersprache jetzt bieten, damit die vorgestellten Speicher Fehler sicher erkannt oder abgefangen werden?
- Das schauen wir uns jetzt Stück für Stück an

== Slide 20: Ownership Rules

- Menge an Regeln, die dafür sorgen, dass der Speicher, den ein Programm nutzt sicher verwaltet wird
- Diese Regeln gelten zu Compile Zeit, es bedarf also keinen Garbage Collector
- Die Ownership regelt die Besitzrechte von Daten im Speicher
- dafür gelten die folgende Regeln:
  1. Jeder Wert in Rust hat einen Besitzer einen Owner, in diesem Beispiel ist buffer_owner jetzt der aktuelle Besitzer
  2. Es kann immer nur einen Besitzer gleichzeitg geben, ab dem Punkte wo another_buffer_owner der Besitzer wird ist buffer_owner kein Besitzer mehr
  3. Wenn der Besitzer out-of-scope also nicht mehr sichtbar ist, dann wird der Wert verworfen, out of scope kann in Rust durch verschiedene Konstrukte passieren:
     - Gültigkeitsbereich wird verlassen da Block mit geschweiften Klammern zu Ende ist
     - würde man buffer_owner einen neuen Wert mittels Box::new(...) zuweisen würde wir der vorherige Wert auch verworfen
     - würde man buffer_owner als Parameter in eine Funktion geben, dann verlässt dieser auch den aktuellen Scope
- immer wenn ein Besitzer den Gültigkeitsbereich verlässt, dann wird durch Rust automatisch der drop() Aufruf eingefügt, um den Wert zu verwerfen
- diese Regeln bringen einen enormen Vorteil für die Entwicklung:
  - der Entwickler muss nicht manuell Speicher wieder freigeben, die Instruktionen dafür fügt der Rust Compiler von alleine ein
  - Somit kann das Freigeben von Speicher auch nicht vergessen werden

== Slide 21: Transfer of Ownership

- Regel 2, also das es nur einen Besitzer gleichzeitig geben darf, wird auf eine bestimmte Art und Weise realisiert
- würde es sich nicht um Speicher handeln, der auf dem Heap alloziert wurde sondern auf dem Stack, dann wäre der Sachverhalt klar
- die Daten würden einfach kopiert werden, Bsp: let var1 = 42; let var2 = var1; danach existieren zwei Variablen mit dem gleichen Wert
- aber ausgehend von diesem Beispiel: let buffer_owner = Box::new(42); let another_buffer_owner = buffer_owner;
- was genau passiert mit s1, wenn s1 die Besitzrechte abgeben muss?
- es kann sich bei dynamischen Größen auf dem Heap schnell im große Datenmenge handeln, wodurch viel Speicher Overhead und Performance Einbuse durch das Kopieren passieren würde
- daher is die Frage? Ist Kopieren wirklich die beste Idee?

== Slide 22: Transfer Methods

- prinizipiell gibt es drei verschiedene Möglichkeiten wie die Besitzübergabe von s1 nach s2 passieren könnte:
  1. Deep Copy: Dabei wird der gesamte Inhalt der Speicher Einheit, die auf dem Heap allooziert ist kopiert und zusätzlich auch noch der darauf zeigende Pointer kopiert
  2. Shallow Copy: Hier wirde nur der Pointer kopiert, dieser zeigt aber auf die selbe Speicheradresse der Daten im Heap, diese müssen also nicht kopiert werden
  3. Move: Hierbei wird zunächst auch der Pointer kopiert, dann aber im Gegensatz zum Shallow Copy der Zeiger s1 gelöscht, sodass nach einem Move nach wie vor nur ein Zeiger auf eine Speicherzelle zeigt
- das Problem beider Copy Varianten ist, dass nach dem Kopieren auf jeden Fall mehr Zeiger vorhanden sind als davor, das bedeutet automatisch ein größerer Aufwand beim freigeben von Speicherzellen
- Shallow Copy hat zusätzlich noch das Problem, dass es extrem anfällig für Dangling Pointer ist, also Zeiger, die auf einen bereits freigegebenen Speicherbereich zeigen

== Slide 23: Move Semantics

- Rust setzt standardmäßig bei der Übergabe einer Ownership IMMER auf Move
- um genau die Probleme, die durch Copy entstehen können zu vermeiden
- Speicher kann dadurch nicht fälschlicherweise doppelt freigegeben werden, da der Speicher immer nur in Verwendung eines einzige Besitzers ist
- Kopieren ist zwar immer noch möglich in Rust, aber nur durch das explizite Aufrufen einer Clone() Funktion

== Slide 24: Borrowing

- was macht man nun aber, wenn man nicht immer die Besitzrechte zu einem Wert überall mit durchreichen möchte
- bspw. bei Funktionsaufrufen könnte es nützlich sein auf einen Wert zuzugreifen ohne sich auch noch um die Ownership zu kümmern
- dafür gibt es Referenzen -> eine Adresse, an der sich ein Pointer befindet, der auf Speicherbereich zeigt
- um eine Referenz anzulegen muss man sich die Besitzrechte dafür leihen, im Code geschieht das über das kaufnmännische UND Zeichen, die Funktion increment bekommt also eine Referenz auf var übergeben
- das Erstellen so einer Referenz nennt man in Rust Borrowing -> Wert verwenden ohne Ownership zu übergeben
- es gibt auch nach dem Erstellen einer Referenz nur einen Owner
- Durch Borrowing ist es also hier im Code Beispiel möglich die Variable var zu inkrementieren ohne die Besitzrechte zu übergeben
- Referenzen sind per default immutable also unveränderbar
- es ist aber möglich auch veränderbare Referenzen anzulegen, das geschieht aber wieder nur explizit
- falls eine Referenz aber als veränderbar markiert ist, kann es abseits von dieser Referenz keine anderen geben
- ganz nach dem Konzept: wenn geschrieben wird, dann gibt es nur diesen einen Writer, falls nur gelesen wird, kann es auch mehrere lesende Referenzen geben
- dieses Konzept verhindert zusätzlich noch eine ganz andere große Fehlerquelle nämlich Data Races, um die soll es hier jetzt aber nicht weiter gehen
- Dadurch das es möglich ist sich die Zugriffsrechte auf Daten auszuleihen, könnte man meinen es sei auch wieder möglich Dangling Reference zu provozieren
- da ohne zusätzliche Absicherung eine Referenz theoretisch ohne zugehörige valide Daten existieren könnte

== Slide 25: Lifetimes and Borrow Checker

- Aber auch hier bietet der Rust Compiler ein Konzept, um diese Dangling References zu Compilezeit vollständig zu verhindern
- dafür gibt es in Rust sogenannte Lifetimes
- Lifetimes geben an für wie lange oder über welchen Programmteil hinweg Variablen gültig sind
- hier veranschaulicht durch die Pfeile, die zeigen in welchem Teil die Referenz und der Wert gültig sind
- Der Wert ist zum zugriffzeitpunkt per println über die Referenz nicht mehr gültig
- das wird durch den Borrow Checker erkannt
- der borrow Checker überprüft die Lebenszeiten und vergleicht diese, um herauszufinden, ob alle Ausleigen valide sind
- da die Lebenszeit des Variable value hier kürzer ist als die der Referenz, meldet der Borrow Checker einen Fehler zur Compilezeit
- dadurch können Dangling References vollständig zur Compilezeit erkannt werden

== Slide 26: Prevention of Use after Free

- so das waren jetzt viele theoretische Konzepte auf einmal
- jetzt wollen wir anschauen wie genau diese in der Sprache Rust zum Einsatz kommen um ein Use After Free zu verhindern
- dafür erstellen wir genau wie im Beispielcode in C eine Variabel, die Speicher für einen Integer auf dem Heap reserviert
- Box<T> ist hier ein Smart Pointer, mit dem man mittels new() einen bestimmten Wert, in unserem Fall einen Integer auf dem Heap gespeichert werden kann
- normalerweise lohnt sich das nur für Typen, die eine variable Größe haben so wie String
- wie wollen aber möglichst nah am C Beispiel bleiben und verwenden daher Box<T>
  1. In der ersten Code Zeile wir dann also nach den Ownership Regeln der Besitzer für den Wert auf dem Heap festgelegt
  2. In C haben wir dann einen zweiten Pointer festgelegt, der auf den gleichen Speicher wie Pointer 1 zeigt
       - Das ist in Rust so direk garnicht möglich, weil in C dafür ein Shallow Copy eingesetzt wird
       - Shallow Copy haben wir aber gesehen gibt es nicht so direkt in Rust
       - Um aber trotzdem Zugriff auf den Wert im Heap zu bekommen erstellen wir eine Referenz
       - buffer_borrow leiht sich also den Zugriff nur aus
  3. Wir rufen explizit drop() auf um buffer_owner zu verwerfen, untypisch in Rust drop() explizit aufzurufen, aber hier einfach für Demo Zwecke
       - Dadurch eendet die Lebenszeit von buffer_owner
  4. Nun versuchen wir den use after free Fehler zu provozieren
       - wir versuchen auf Speicher zuzugreifen, der bereits freigegeben wurde indem wir über buffer_borrow auf die Daten zugrifen wollen und diese printen wollen

== Slide 27: Prevention of Use after Free

- wir bekommen im Gegensatz zu C einen Fehler beim Kompilieren
- es ist also garnicht möglich ein Executable zu erstellen, was so einen Bug beinhaltet
- die Fehlermeldung zeigt genau das was wir gerade detailliert durchgesprochen haben
- und zusätzlich noch warum ein Fehler aufgetreten ist
- der Borrow Checker im Compiler hat nämlich detektiert, dass die Lebenszeit von buffer_borrow länger als die des ZUgehöriger Besitzers buffer_owner ist
- Das erlauben die Rust Lifetime Regeln nicht und daher wir ein Fehler angezeigt
- Zusätzlich erhält man noch den Vorschlag, was man ändern könnte, damit kein Fehler aufritt
- der Compiler schlägt ein Deep Copy mittels clone() Funktion vor und weißt auch direkt auf zusätzlich Ressourcen Kosten hin

== Slide 28: Compiletime Bounds Checking

- zu Beginn hatte ich gezeigt, dass direkt nach dem Use-After-Free Fehler der out-of-bounds write auch eine große Schwachstelle darstellt
- auch dafür bietet Rust eine bzw. um genauer zu sein zwei verschiedene Lösungsansätze an
- die am einfachsten zu erkennenden Out-of-Bounds Fehler sind die, bei denen der verwendete Index zur Compiletime schon bekannt ist
- hier im Beispiel ist beim Kompilieren zu 100% klar, dass der Index der beim Zugriff in Zeile X verwendet wird 2 ist
- Dadurch kann der Rust Compiler der Zugriff über die Array Grenzen hinweg auf jedem Fall zur Compiletime erkennen

Slide 29: Runtime Bounds Checking

- Anders sieht das aus, wenn man versucht, das C Beispiel vom Anfang in Rust zu transformieren
- In diesem Beispiel passiert der Out-Of-Bounds Write nämlich innerhalb eines Funktionsaufrufs
- die Funktion nimmt einen zur Laufzeit übergebenen Index an mit dem dann auf das Array zugegriffen wird
- zur Compilezeit sicher zu beweisen, dass so ein Fehler auftritt ist quasi unmöglich
- Daher muss ein anderes Konzept her mit dem solche Fehler keine größeren Sicherheitslücken oder Schaden anrichten können
- Rust kann solche out-of-bounds Zugriff nämlich auch feststellen aber nur zur Laufzeit
- dafür wird für jeden Index Zugriff zur Laufzeit geprüft, ob dieser innerhalb der Array Grenzen liegt
- falls dies nicht der Fall ist wird eine Panic Hook ausgeführt
- das erzeugt natürlich einen Runtime Overhead
- dieser ist aber sehr gering, da im Allgemeinen nur ein Vergleich und ein bedingter Sprung für die Überprüfung benötigt werden
- die dafür notwendigen Instruktionen generiert der Rust Compiler immer ohne dass sich der Entwickler das explizit erzwingen muss
- sobald ein out-of-bounds zugriff festgestellt wird gibt es zwei möglich panic handler je nach Einstellung
  - bei der Einstellung unwind wird der Stack abgebaut und nach Fehlerbehandlung ist eine weitere Programmausführung möglich
  - bei der Einstellung abort wird der aktuelle Prozess abgebrochen
- aber egal welche Einstellung gewählt wird, das Verhalten bei einem out-of-bounds zugriff versuch ist sicher dadurch, dass vor dem tatsächlichen Zugriff kontrolliert der Panic Handler aufgerufen wird, während in C das Verhalten in so einem Fall völlig undefiniert bleibt
