= Speichersicherheit in Rust

Der Lösungsansatz, durch eine Prüfung zur Compile-Zeit Speicherfehler zu verhindern, ist genau die Strategie, die Rust verfolgt. Die Sprache zielt darauf ab, zwei Anforderungen zu vereinen, die in der Praxis lange als schwer vereinbar galten: direkten Zugriff auf Hardware und Speicher einerseits sowie Sicherheit und ein produktives Entwicklungserlebnis andererseits. Statt Speicherfehler erst zur Laufzeit zu entdecken oder sie durch einen Garbage Collector zu kompensieren, verschiebt Rust zentrale Sicherheitsprüfungen in den Compiler.

Rust ist dabei nicht nur eine Sprachdefinition, sondern ein umfassendes Ökosystem. Neben dem Compiler #raw("rustc") gehören dazu unter anderem #raw("cargo") als Build System und Paketmanager, #raw("rustfmt") zur einheitlichen Formatierung von Quellcode sowie #raw("rust-analyzer") als Language Server für Editoren. Diese Werkzeuge sind standardmäßig Teil der Rust Installation und sollen typische Entwicklungsaufgaben von der Projekterstellung bis zur statischen Analyse abdecken. Ob das Versprechen der Sprache in der Praxis trägt, lässt sich auch an der Beliebtheit bei den Entwicklern ablesen.

Laut dem Stack Overflow Developer Survey 2025 zählt Rust erneut zu den am meisten geschätzten Programmiersprachen @noauthor_technology_nodate. Unter den Befragten, die in Rust bereits umfangreich entwickelt haben, gaben 72 Prozent an, auch im folgenden Jahr damit arbeiten zu wollen. Damit liegt Rust in diesem Ranking an erster Stelle. Zugleich erscheint Rust regelmäßig unter den Technologien, deren weiterer Einsatz besonders gewünscht wird. Solche Umfragen ersetzen keine technische Bewertung, verdeutlichen aber, dass Rust nicht nur als theoretisches Konzept wahrgenommen wird.

Entscheidend für diese Arbeit ist jedoch nicht die Popularität, sondern der Mechanismus hinter der Speichersicherheit. Nach den im vorherigen Kapitel betrachteten Fehlern Use After Free und Out of Bounds Write stellt sich die Frage, welche Sprachkonzepte Rust bereitstellt, damit derartige Fehler sicher erkannt oder gar nicht erst kompiliert werden. Im folgenden wird Schritt für Schritt dargestellt, wie Ownership, Borrowing und Lifetimes zusammenwirken, wie der Borrow Checker Dangling References zur Compilezeit ausschließt und wie Rust zusätzlich Grenzverletzungen bei Arrayzugriffen behandelt. Dabei werden die zuvor gezeigten C Beispiele in Rust nachgebaut, um die Unterschiede im konkreten Verhalten sichtbar zu machen.

== Ownership

Das erste zentrale Konzept ist Ownership. Es beschreibt ein Regelwerk, nach dem Rust Speicher verwaltet. Ownership legt fest, welche Variable für welchen Wert im Speicher verantwortlich ist. Der Compiler prüft diese Regeln zur Compilezeit. Verstöße führen zu Kompilierfehlern, nicht zu undefiniertem Verhalten zur Laufzeit. Damit unterscheidet sich Rust sowohl von Sprachen mit Garbage Collector als auch von C, in dem Allokation und Freigabe explizit erfolgen.

Ownership betrifft vor allem Daten auf dem Heap, deren Größe zur Compilezeit nicht feststeht. Entscheidend ist, dass der Compiler nachvollziehen kann, wann Speicher nicht mehr benötigt wird, und die Freigabe automatisch einplant. @tab:ownership-rules fasst die drei zentralen Ownership Regeln zusammen.

#figure(
  kind: table,
  supplement: [Tabelle],
  caption: [Die drei Ownership Regeln in Rust @noauthor_what_nodate],
)[
  #set text(size: 10.5pt)
  #show table.cell: it => {
    set par(justify: false, leading: 0.65em, spacing: 0.65em)
    set align(left)
    it
  }
  #table(
    columns: (1.2cm, 1fr),
    align: (center + horizon, left + top),
    inset: (x: 8pt, y: 6pt),
    stroke: (_, y) => (
      top: if y == 0 { 1pt + black },
      bottom: if y == 0 { 0.75pt + black } else if y == 3 { 1pt + black } else { none },
      left: none,
      right: none,
    ),
    table.header(
      table.cell(fill: luma(245))[*Regel*],
      table.cell(fill: luma(245))[*Inhalt*],
    ),
    [1], [Jeder Wert in Rust hat genau einen Owner, also einen Besitzer.],
    [2], [Es kann zu jedem Zeitpunkt nur einen Owner geben.],
    [3], [Verlässt der Owner seinen Gültigkeitsbereich, wird der Wert verworfen.],
  )
] <tab:ownership-rules>

Regel 1 und 2 verhindern, dass mehrere Stellen im Programm gleichzeitig für dieselbe Heap Allokation verantwortlich sind. Damit entfällt die Situation aus dem C Beispiel, in der zwei Zeiger auf denselben Block zeigen, die Freigabe aber nur einmal erfolgt. Regel 3 sorgt dafür, dass Speicher automatisch freigegeben wird, sobald der zugehörige Owner nicht mehr erreichbar ist.

Ein Gültigkeitsbereich (Scope) ist der Programmabschnitt, in dem eine Variable gültig ist. Sie beginnt mit der Deklaration und endet, wenn der Scope verlassen wird. Regel 3 greift in mehreren typischen Situationen:

+ *Ende eines Blocks:* Schließt ein Block mit geschweiften Klammern, enden die darin deklarierten Variablen. Ihre Werte werden verworfen.
+ *Neue Zuweisung an denselben Owner:* Wird einer besitzenden Variable ein neuer Wert zugewiesen, wird der bisherige Wert sofort verworfen, noch bevor der neue Wert übernommen wird.
+ *Übergabe an eine Funktion:* Wird ein Wert an eine Funktion übergeben, kann die Ownership dabei in den Funktionsaufruf wechseln. Verlässt der Wert den ursprünglichen Scope, wird er dort verworfen. Die genaue Semantik dieser Übergabe wird im folgenden Abschnitt behandelt.

Verlässt ein Owner seinen Gültigkeitsbereich, ruft Rust automatisch die Funktion #raw("drop()") auf. Für Typen wie #raw("String") oder #raw("Box<T>") enthält #raw("drop()") die Logik zur Freigabe des Heap Speichers. Das Muster entspricht dem in C++ bekannten Konzept Resource Acquisition Is Initialization (RAII), bei dem Ressourcen am Ende ihrer Lebensdauer automatisch freigegeben werden @noauthor_what_nodate.

Für die Speichersicherheit ergeben sich daraus zwei unmittelbare Vorteile gegenüber C. Erstens muss Heap Speicher nicht mehr manuell mit #raw("free()") freigegeben werden. Der Compiler fügt die Freigabe an den korrekten Stellen ein. Zweitens kann eine Freigabe nicht vergessen werden, solange das Programm kompiliert. Vergessene #raw("free()") Aufrufe und damit verbundene Speicherlecks entfallen in dieser Form. Ob auch Use After Free vollständig ausgeschlossen ist, hängt zusätzlich davon ab, wie Ownership zwischen Variablen übertragen und temporär ausgeliehen wird. Darauf gehen die folgenden Abschnitte ein.

== Übertragung von Ownership

Regel 2 verlangt, dass es zu jedem Zeitpunkt nur einen Owner gibt. Die Frage ist, wie sich Ownership von einer Variable auf eine andere überträgt, wenn Heap Daten beteiligt sind. Bei Werten fester Größe auf dem Stack ist der Fall unkritisch. Wird etwa einer zweiten Variablen ein Integer zugewiesen, wird der Wert kopiert. Danach existieren zwei unabhängige Variablen mit demselben Inhalt. Beide können ihren Gültigkeitsbereich unabhängig verlassen, ohne Konflikte bei der Speicherfreigabe.

Bei Heap Allokationen ist die Situation anders. @lst:transfer-ownership zeigt ein minimales Beispiel mit #raw("Box::new(42)"). #raw("Box<T>") ist ein Smart Pointer, der einen Wert auf dem Heap hält. In Zeile 2 wird #raw("pointer_1") zum Owner dieses Blocks. Zeile 3 überträgt die Ownership auf #raw("pointer_2"). Entscheidend ist, was danach mit #raw("pointer_1") geschieht. Im Gegensatz zu C entsteht hier kein zweiter Zeiger auf dieselbe Adresse. Stattdessen wird die Ownership verschoben.

#let transfer-code = read("listings/transfer_ownership/main.rs")

#figure(
  supplement: [Quelltext],
  caption: [Übertragung von Ownership mit #raw("Box<T>") in Rust],
)[
  #set text(size: 10pt)
  #set par(justify: false)
  #block(
    fill: luma(248),
    inset: 12pt,
    radius: 4pt,
    width: 100%,
    {
      show raw.where(block: true): set text(size: 10pt)
      show raw.where(block: true): set block(spacing: 0pt, above: 0pt, below: 0pt)
      show raw.line: it => table(
        columns: (2.2em, 1fr),
        align: (right + horizon, left + horizon),
        stroke: none,
        inset: (x: 0pt, y: 0pt),
        column-gutter: 0.8em,
        [#text(fill: luma(120))[#it.number]], [#it.body],
      )
      raw(block: true, lang: "rust", transfer-code)
    },
  )
] <lst:transfer-ownership>

Grundsätzlich lassen sich drei Varianten der Übergabe unterscheiden, wenn #raw("pointer_1") seine Besitzrechte an #raw("pointer_2") abgeben soll. @fig:transfer-methods stellt sie für einen #raw("i32") Wert mit dem Inhalt 42 dar, der auf dem Heap liegt.

#figure(
  image("assets/transfer_ownership_methods.svg", width: 100%),
  caption: [Deep Copy, Shallow Copy und Move bei der Ownership Übergabe @noauthor_what_nodate],
) <fig:transfer-methods>

Bei einem *Deep Copy* wird der gesamte Inhalt der Heap Allokation dupliziert. Zusätzlich entsteht ein zweiter Zeiger auf den neuen Block. Beide Variablen besitzen danach jeweils eigenen Speicher mit identischem Inhalt.

Bei einem *Shallow Copy* wird nur der Zeiger kopiert. #raw("pointer_1") und #raw("pointer_2") verweisen dann auf dieselbe Heap Adresse. Der Inhalt wird nicht dupliziert. Diese Variante entspricht dem Verhalten aus dem C Beispiel in @lst:uaf, in dem #raw("buffer_ptr2") auf denselben Block zeigt wie #raw("buffer_ptr1").

Bei einem *Move* wird der Zeiger zunächst ebenfalls übertragen. Im Unterschied zum Shallow Copy wird #raw("pointer_1") danach ungültig. Es existiert weiterhin nur ein Owner. Der ausgegraute Eintrag in @fig:transfer-methods symbolisiert diese Ungültigkeit.

Beide Copy Varianten erhöhen die Zahl der Zeiger auf Heap Speicher. Beim Freigeben muss nachvollziehbar sein, welcher Zeiger verantwortlich ist und wann #raw("drop()") aufgerufen wird. Andernfalls drohen Speicherlecks oder doppelte Freigabe. Ein Shallow Copy ist besonders fehleranfällig, weil mehrere Zeiger auf denselben Block zeigen können. Gibt einer der Owner den Speicher frei, werden die verbleibenden Zeiger zu Dangling Pointern. Genau dieses Muster begünstigt Use After Free in C.

Rust wählt für Heap Typen standardmäßig *Move Semantics* @noauthor_what_nodate. Nach #raw("let pointer_2 = pointer_1") gilt #raw("pointer_1") als bewegt und darf nicht mehr verwendet werden. Der Compiler lehnt weiteren Zugriff ab. Damit bleibt Regel 2 erhalten und Double Free wird vermieden, weil nur #raw("pointer_2") beim Verlassen des Scopes #raw("drop()") auslöst.

Kopieren ist in Rust weiterhin möglich, aber nur bewusst und explizit. Dafür nutzt Rust sogenannte Traits. Ein Trait beschreibt Verhalten, das ein Typ bereitstellen kann, vergleichbar mit einer Schnittstelle in anderen Sprachen. Ob ein Typ bei Zuweisung kopiert oder verschoben wird, hängt davon ab, welche Traits er implementiert.

Der Aufruf von #raw(".clone()") erzeugt einen Deep Copy, sofern der Typ das #raw("Clone") Trait implementiert. Für #raw("Box<T>") ist das gegeben. Der Preis ist der zusätzliche Speicher und die Laufzeit für das Duplizieren. Typen mit dem #raw("Copy") Trait werden hingegen stillschweigend kopiert, statt bewegt zu werden. Das gilt für einfache Werte fester Größe auf dem Stack @noauthor_what_nodate. Heap Typen wie #raw("Box<T>") implementieren #raw("Copy") nicht, weil sie Ressourcen freigeben müssen und das #raw("Drop") Trait nutzen. Deshalb greift bei ihnen standardmäßig Move Semantics.

== Borrowing

Move Semantics löst das Problem mehrerer Owner auf dem Heap, schränkt aber den Zugriff ein. Soll ein Wert in einer Funktion genutzt werden, ohne die Ownership abzugeben, reicht reines Verschieben nicht aus. Typischerweise müsste der Wert nach dem Aufruf zurückgegeben werden, damit er im aufrufenden Code weiter existiert. Genau das vermeidet Rust mit Referenzen und Borrowing.

Eine Referenz ist eine Adresse, über die auf einen Wert zugegriffen werden kann, ohne diesen zu besitzen @noauthor_references_nodate. Im Gegensatz zu einem rohen Zeiger in C garantiert Rust, dass eine Referenz während ihrer Gültigkeit auf einen des Wert passenden Typs zeigt. Das Anlegen einer Referenz heißt Borrowing. Der Owner bleibt unverändert und es gibt weiterhin genau einen Owner, zusätzlich existiert eine temporäre Zugriffsberechtigung.

@lst:borrowing zeigt das Prinzip anhand einer einfachen Funktion #raw("increment"). In Zeile 1 bis 3 wird #raw("value") als veränderbare Referenz auf einen #raw("i32") deklariert. Das kaufmännische Und #raw("&") kennzeichnet den Referenztyp. In Zeile 2 wird über den Dereferenzierungsoperator #raw("*") der Wert am Ziel der Referenz erhöht. In Zeile 6 wird #raw("var_pointer") als veränderbar deklariert und mit #raw("Box::new(42)") ein Integer auf dem Heap alloziert. Zeile 7 übergibt #raw("&mut var_pointer") an #raw("increment"). Die Ownership von #raw("var_pointer") bleibt im aufrufenden #raw("main"), obwohl der Wert in der Funktion geändert wird.

#let borrowing-code = read("listings/borrowing/main.rs")

#figure(
  supplement: [Quelltext],
  caption: [Borrowing mit veränderbarer Referenz @noauthor_references_nodate],
)[
  #set text(size: 10pt)
  #set par(justify: false)
  #block(
    fill: luma(248),
    inset: 12pt,
    radius: 4pt,
    width: 100%,
    {
      show raw.where(block: true): set text(size: 10pt)
      show raw.where(block: true): set block(spacing: 0pt, above: 0pt, below: 0pt)
      show raw.line: it => table(
        columns: (2.2em, 1fr),
        align: (right + horizon, left + horizon),
        stroke: none,
        inset: (x: 0pt, y: 0pt),
        column-gutter: 0.8em,
        [#text(fill: luma(120))[#it.number]], [#it.body],
      )
      raw(block: true, lang: "rust", borrowing-code)
    },
  )
] <lst:borrowing>

Referenzen sind standardmäßig unveränderbar. Ein Aufruf wie #raw("change(&s)") mit #raw("&String") erlaubt nur Lesezugriff. Soll der Zielwert geändert werden, ist eine mutable Referenz nötig, erkennbar an #raw("&mut") im Typ und beim Aufruf. Wie in @lst:borrowing muss #raw("var_pointer") dann ebenfalls als #raw("mut") deklariert sein. Damit Borrowing speichersicher bleibt, gelten zusätzliche Regeln @noauthor_references_nodate:

+ Zu jedem Zeitpunkt ist entweder genau eine veränderbare Referenz auf einen Wert erlaubt, oder beliebig viele unveränderbare Referenzen.
+ Referenzen müssen immer auf gültige Daten zeigen.

Die erste Regel lässt sich als Schreib-Lese-Trennung lesen. Existiert eine schreibende Referenz, darf keine zweite Referenz auf denselben Wert gleichzeitig aktiv sein, weder schreibend noch lesend. Existieren nur lesende Referenzen, sind mehrere parallel zulässig. Der Compiler lehnt Code ab, der zwei mutable Referenzen auf dieselbe Variable anlegt, oder der gleichzeitig liest und schreibt.

In nebenläufigen Programmen schützt dieselbe Logik vor Data Races, also gleichzeitigem Zugriff mehrerer Threads auf dieselben Daten, von dem mindestens einer schreibt. Data Races führen zu undefiniertem Verhalten. Rust erkennt viele davon bereits zur Compilezeit. Eine vertiefte Betrachtung der Nebenläufigkeit liegt außerhalb des Fokus dieser Arbeit.

Borrowing wirft zunächst eine ähnliche Frage auf wie bei Zeigern in C. Wenn nur ausgeliehen wird, könnte eine Referenz theoretisch auf Daten zeigen, deren Owner längst nicht mehr existiert. Solche Dangling References wären Use After Free in neuer Form. Wie Rust das mithilfe des Borrow Checkers verhindert, wird im folgenden Abschnitt erläutert.

== Lifetimes und Borrow Checker

Borrowing allein reicht nicht aus, um Dangling References auszuschließen. Entscheidend ist zusätzlich, wie lange eine Referenz gültig bleiben darf @noauthor_references_nodate @noauthor_validating_nodate. Dafür führt Rust Lifetimes ein. Eine Lifetime beschreibt den Gültigkeitsbereich, in dem eine Referenz auf valide Daten zeigen darf. In den meisten Fällen leitet der Compiler Lifetimes automatisch ab. Werden Referenzen jedoch so verknüpft, dass die Gültigkeit unklar wäre, bricht die Kompilierung ab.

Der Borrow Checker ist die Compilezeitkomponente, die Ownership, Borrowing und Lifetimes gemeinsam prüft. Er vergleicht die Lebensdauer von Werten und Referenzen. Eine Referenz darf nicht länger existieren als der Wert, auf den sie zeigt. Verstöße werden als Kompilierfehler gemeldet, bevor ein Programm ausführbar entsteht. @lst:lifetimes zeigt ein absichtlich fehlerhaftes Beispiel.

#let lifetimes-code = read("listings/lifetimes_borrow_checker/main.rs")

#figure(
  supplement: [Quelltext],
  caption: [Ungültige Referenz über den Gültigkeitsbereich hinaus @noauthor_validating_nodate],
)[
  #set text(size: 10pt)
  #set par(justify: false)
  #block(
    fill: luma(248),
    inset: 12pt,
    radius: 4pt,
    width: 100%,
    {
      show raw.where(block: true): set text(size: 10pt)
      show raw.where(block: true): set block(spacing: 0pt, above: 0pt, below: 0pt)
      show raw.line: it => table(
        columns: (2.2em, 1fr),
        align: (right + horizon, left + horizon),
        stroke: none,
        inset: (x: 0pt, y: 0pt),
        column-gutter: 0.8em,
        [#text(fill: luma(120))[#it.number]], [#it.body],
      )
      raw(block: true, lang: "rust", lifetimes-code)
    },
  )
] <lst:lifetimes>

Der zeitliche Ablauf im Quelltext lässt sich entlanglesen. Drei Begriffe sollten dabei getrennt bleiben: die Variable #raw("reference"), der Wert #raw("value") und die Ausleihe, die #raw("reference") von #raw("value") übernimmt. Der Borrow Checker prüft, ob die Ausleihe nicht über das Ende von #raw("value") hinausreicht @noauthor_validating_nodate.

Die Funktion #raw("main") umschließt den gesamten Code. Gleich zu Beginn wird darin #raw("reference") angelegt, zunächst noch ohne zugewiesenen Wert. Als Variable bleibt sie bis zum Ende der Funktion gültig. Solange sie uninitialisiert ist, enthält sie noch keine Ausleihe. Ein innerer Block mit geschweiften Klammern eröffnet einen kürzeren Scope. Darin entsteht #raw("value") mit dem Inhalt 5 auf dem Stack. #raw("value") existiert nur, solange dieser Block aktiv ist. Beim Schließen des Blocks wird der Wert automatisch verworfen und der zugehörige Speicher freigegeben.

Noch innerhalb des Blocks wird #raw("reference") über #raw("&value") eine Referenz auf #raw("value") zugewiesen. In diesem kurzen gemeinsamen Zeitraum sind Owner und Ausleihe gleichzeitig gültig. #raw("value") besitzt den Wert 5, #raw("reference") speichert dessen Adresse. Die Ausleihe ist deshalb gültig, weil der referenzierte Wert noch existiert. Sobald der innere Block endet, ist #raw("value") nicht mehr vorhanden. Die Variable #raw("reference") dagegen besteht weiter im äußeren Scope. Die zuvor gespeicherte Ausleihe darf jedoch nicht über das Ende von #raw("value") hinaus gelten. Ab diesem Punkt würde #raw("reference") auf bereits freigegebenen Speicher zeigen. Es entsteht eine Dangling Reference.

Am Ende der Funktion greift #raw("println!") auf #raw("reference") zu. Zu diesem Zeitpunkt existiert #raw("value") nicht mehr. Der Zugriff würde Speicher lesen, der nicht mehr zum ursprünglichen Owner gehört. Das entspricht dem Use After Free Muster, hier jedoch über eine Referenz statt über einen rohen Zeiger.

Der Borrow Checker erkennt diesen Widerspruch zur Compilezeit. #raw("reference") als Variable lebt länger als #raw("value"). Die gültige Ausleihe in #raw("reference") darf höchstens so lange gelten wie der Owner. Da die Referenz nach dem Verwerfen von #raw("value") erneut genutzt wird, reicht die Ausleihe zu weit. Der Compiler bricht mit einem Fehler ab und verhindert die Erstellung eines ausführbaren Programms. Damit lassen sich Dangling References zur Compilezeit ausschließen, solange der Code den Regeln von Ownership und Borrowing folgt. Im folgenden Abschnitt wird gezeigt, wie dieselben Mechanismen konkret einen Use After Free Fehler verhindern, wie er zuvor in C auftrat.

== Verhinderung von Use After Free

Die bisherigen Konzepte lassen sich an dem Heap Beispiel aus @lst:uaf nachvollziehen. Dort reserviert #raw("malloc()") Speicher für einen Integer, ein zweiter Zeiger verweist per Shallow Copy auf dieselbe Adresse, und #raw("free()") gibt den Block frei. Der anschließende Zugriff über den verbleibenden Zeiger ist ein Use After Free. @lst:uaf-rust baut dasselbe Muster in Rust nach. Ziel ist nicht ein lauffähiges Programm, sondern die Frage, ob der Compiler den Fehler zulässt.

#let uaf-rust-code = read("listings/use_after_free/main.rs")

#figure(
  supplement: [Quelltext],
  caption: [Use After Free Muster in Rust parallel zu @lst:uaf],
)[
  #set text(size: 10pt)
  #set par(justify: false)
  #block(
    fill: luma(248),
    inset: 12pt,
    radius: 4pt,
    width: 100%,
    {
      show raw.where(block: true): set text(size: 10pt)
      show raw.where(block: true): set block(spacing: 0pt, above: 0pt, below: 0pt)
      show raw.line: it => table(
        columns: (2.2em, 1fr),
        align: (right + horizon, left + horizon),
        stroke: none,
        inset: (x: 0pt, y: 0pt),
        column-gutter: 0.8em,
        [#text(fill: luma(120))[#it.number]], [#it.body],
      )
      raw(block: true, lang: "rust", uaf-rust-code)
    },
  )
] <lst:uaf-rust>

Gleich zu Beginn wird mit #raw("Box::new(42)") ein Integer auf dem Heap alloziert. #raw("Box<T>") ist ein Smart Pointer, der einen Wert auf dem Heap hält und beim Verlassen des Scopes automatisch #raw("drop()") aufruft. #raw("buffer_owner") wird damit zum Owner des Heap Blocks. Für Typen mit fester Größe wie #raw("i32") wäre ein Stack Wert oft ausreichend. #raw("Box<T>") wird hier dennoch eingesetzt, um strukturell an @lst:uaf anzuknüpfen, in dem ebenfalls Heap Speicher explizit reserviert wird.

Im C Beispiel entsteht der zweite Zugriffspfad durch eine Shallow Copy. #raw("buffer_ptr2") zeigt auf dieselbe Adresse wie #raw("buffer_ptr1"), ohne dass ein neuer Block reserviert wird. In Rust ist ein derartiger zweiter Owner für #raw("Box<T>") nicht zulässig. Move Semantics verhindern, dass zwei Variablen gleichzeitig denselben Heap Block besitzen @noauthor_what_nodate. Stattdessen leiht #raw("buffer_borrow") den Owner über #raw("&buffer_owner") aus. Die Ownership bleibt bei #raw("buffer_owner"), zusätzlich existiert eine unveränderbare Referenz @noauthor_references_nodate.

Als Nächstes soll der Heap Block freigegeben werden. In C entspricht das dem Aufruf von #raw("free()"). In Rust würde #raw("buffer_owner") am Ende seines Scopes ohnehin automatisch verworfen. Zur Verdeutlichung wird #raw("drop(buffer_owner)") explizit aufgerufen. Der Aufruf beendet die Ownership und würde den Heap Speicher freigeben. Typischerweise wird #raw("drop()") in Rust nicht von Hand aufgerufen, weil der Compiler die Freigabe an den passenden Stellen einfügt. Hier dient der explizite Aufruf als bewusste Parallele zu #raw("free()") in @lst:uaf. Entscheidend ist, dass #raw("drop()") die Besitzrechte verwirft und damit einen Move darstellt.

Anschließend soll über #raw("buffer_borrow") auf den Wert zugegriffen und mit #raw("println!") ausgegeben werden. Entspräche der Ablauf dem C Programm, läge ein Zugriff auf bereits freigegebenen Speicher vor. #raw("buffer_borrow") würde dann auf einen Block zeigen, dessen Owner nicht mehr existiert, ein Use After Free Zugriffsfehler würde vorliegen.

Im Gegensatz zu C kompiliert @lst:uaf-rust nicht. Es entsteht kein ausführbares Programm, das den Fehler zur Laufzeit erst sichtbar macht. Der Borrow Checker bricht die Kompilierung bereits vor der Ausführung ab. @fig:uaf-rust-error zeigt die zugehörige Fehlermeldung.

#let uaf-error = read("listings/use_after_free/compiler_error.txt")

#figure(
  kind: "compilerausgabe",
  supplement: [Compilerausgabe],
  caption: [Kompilierfehler E0505 für @lst:uaf-rust],
)[
  #set text(size: 9pt)
  #set par(justify: false)
  #block(
    fill: luma(248),
    inset: 12pt,
    radius: 4pt,
    width: 100%,
    raw(block: true, lang: "text", uaf-error),
  )
] <fig:uaf-rust-error>

Der Compiler meldet #raw("error[E0505]: cannot move out of `buffer_owner` because it is borrowed"). Drei Stellen werden im Quelltext markiert. Beim Anlegen von #raw("buffer_borrow") entsteht eine Ausleihe auf #raw("buffer_owner"). Der anschließende Aufruf von #raw("drop(buffer_owner)") würde den Owner bewegen und den Heap Block freigeben. Später soll #raw("buffer_borrow") erneut verwendet werden. Solange die Ausleihe aktiv ist, darf #raw("buffer_owner") nicht verschoben oder verworfen werden.

Damit greift dieselbe Logik wie im Lifetime Beispiel zuvor, hier jedoch auf Heap Daten mit #raw("Box<T>"). Die Ausleihe in #raw("buffer_borrow") darf nicht über das Ende von #raw("buffer_owner") hinausreichen @noauthor_validating_nodate. Der Compiler erkennt den Konflikt bereits am Aufruf von #raw("drop()") und nicht erst beim späteren #raw("println!").

Die Fehlermeldung schlägt als mögliche Anpassung #raw("buffer_owner.clone()") vor. Damit entstünde ein Deep Copy auf dem Heap, wie in @fig:transfer-methods dargestellt. Der Compiler weist zugleich auf den zusätzlichen Ressourcenaufwand hin (#raw("if the performance cost is acceptable")). Ein solche Kopie wäre ein bewusster Ausweg, kein automatisches Verhalten wie das Shallow Copy in C.

Damit schließt Rust Use After Free in dieser Form bereits zur Compilezeit aus, solange die Ownership Regeln eingehalten werden. Im Gegensatz zu Laufzeitwerkzeugen wie AddressSanitizer @serebryany_addresssanitizer_2012 entsteht erst überhaupt kein fehlerhaftes Binary. Im nächsten Abschnitt wird betrachtet, wie Rust auch Out of Bounds Zugriffe behandelt.

== Grenzprüfung zur Compilezeit

Neben Use After Free zählt Out of Bounds Write zu den zentralen Speicherzugriffsfehlern aus @tab:memory-errors @noauthor_cwe_nodate-6. In @lst:oob wird der Fehler in C gezeigt. Dort schreibt #raw("write_arr_at_index(array, 2)") außerhalb des gültigen Arraybereichs und trifft damit benachbarten Stack Speicher, wie @fig:oob-stack veranschaulicht. In C bleibt das Verhalten undefiniert und das Programm kompiliert trotzdem.

Rust unterscheidet zwei Fälle. Liegt der verwendete Index bereits zur Compilezeit fest, kann der Compiler Grenzverletzungen oft direkt erkennen. @lst:oob-rust-compiletime baut das Muster aus @lst:oob ohne Funktionsaufruf nach. Die Struktur bleibt gleich: eine lokale Variable #raw("var"), ein Array mit zwei Elementen und ein Schreibzugriff mit Index 2.

#let oob-rust-compiletime-code = read("listings/out_of_bounds_write_compiletime/main.rs")

#figure(
  supplement: [Quelltext],
  caption: [Out of Bounds Write mit konstantem Index in Rust parallel zu @lst:oob],
)[
  #set text(size: 10pt)
  #set par(justify: false)
  #block(
    fill: luma(248),
    inset: 12pt,
    radius: 4pt,
    width: 100%,
    {
      show raw.where(block: true): set text(size: 10pt)
      show raw.where(block: true): set block(spacing: 0pt, above: 0pt, below: 0pt)
      show raw.line: it => table(
        columns: (2.2em, 1fr),
        align: (right + horizon, left + horizon),
        stroke: none,
        inset: (x: 0pt, y: 0pt),
        column-gutter: 0.8em,
        [#text(fill: luma(120))[#it.number]], [#it.body],
      )
      raw(block: true, lang: "rust", oob-rust-compiletime-code)
    },
  )
] <lst:oob-rust-compiletime>

#raw("var") wird mit dem Wert 5 angelegt. Das Array #raw("array") hat den Typ #raw("[i32; 2]") und damit genau zwei Elemente. Gültige Indizes reichen von 0 bis 1. Der Ausdruck #raw("array[2] = 99") verwendet dagegen den Index 2. Damit liegt derselbe logische Fehler vor wie in @lst:oob, nur ohne separate Hilfsfunktion.

Entscheidend ist, dass sowohl die Arraylänge als auch der Index hier Konstanten sind. Der Compiler kennt beide Werte bereits beim Übersetzen des Programms. Er kann deshalb statisch prüfen, ob der Zugriff innerhalb der Arraygrenzen liegt. In @lst:oob wird der Index erst als Funktionsparameter übergeben. Für diesen direkten Zugriff mit konstantem Index reicht diese Information zur Compilezeit aus. @lst:oob-rust-compiletime kompiliert nicht. @fig:oob-rust-compiletime-error zeigt die Fehlermeldung.

#let oob-compiletime-error = read("listings/out_of_bounds_write_compiletime/compiler_error.txt")

#figure(
  kind: "compilerausgabe",
  supplement: [Compilerausgabe],
  caption: [Kompilierfehler für @lst:oob-rust-compiletime],
)[
  #set text(size: 9pt)
  #set par(justify: false)
  #block(
    fill: luma(248),
    inset: 12pt,
    radius: 4pt,
    width: 100%,
    raw(block: true, lang: "text", oob-compiletime-error),
  )
] <fig:oob-rust-compiletime-error>

Der Compiler meldet #raw("error: this operation will panic at runtime"). Markiert wird der Zugriff #raw("array[2] = 99"). Durch die Meldung #raw("index out of bounds: the length is 2 but the index is 2") wird deutlich, dass der Schreibzugriff bei jeder Ausführung außerhalb der Grenzen liegt. Standardmäßig wird dies über die Lint Regel #raw("unconditional_panic") abgelehnt, wie die Anmerkung #raw("#[deny(unconditional_panic)] on by default") zeigt.

Damit entsteht kein ausführbares Programm, das den Fehler erst zur Laufzeit sichtbar macht. Der Out of Bounds Write aus @lst:oob, der in C stillschweigend #raw("var") überschreiben kann, wird bereits vor der Ausführung gestoppt. Im Gegensatz zu Use After Free, das der Borrow Checker über Ownership und Lifetimes verhindert, greift hier eine statische Analyse des Arrayzugriffs. Der Fall setzt voraus, dass Index und Arraygröße zur Compilezeit bekannt sind. Wird der Index erst zur Laufzeit übergeben, reicht diese Prüfung allein nicht aus.

== Grenzprüfung zur Laufzeit

@lst:oob-rust-compiletime zeigte den einfachen Fall mit konstantem Index. Strukturell näher an @lst:oob liegt @lst:oob-rust-runtime. Dort erfolgt der Schreibzugriff in der Funktion #raw("write_slice"), die ein Slice #raw("&mut [i32]") und einen Index vom Typ #raw("usize") entgegennimmt. Der Index wird beim Aufruf übergeben und ist für den Compiler zum Übersetzungszeitpunkt keine feste Konstante mehr. Ob #raw("write_slice(&mut array, 2)") tatsächlich außerhalb der Grenzen liegt, lässt sich deshalb nicht mehr sicher zur Compilezeit entscheiden.

#let oob-rust-runtime-code = read("listings/out_of_bounds_write_runtime/main.rs")

#figure(
  supplement: [Quelltext],
  caption: [Out of Bounds Write mit Laufzeitindex in Rust parallel zu @lst:oob],
)[
  #set text(size: 10pt)
  #set par(justify: false)
  #block(
    fill: luma(248),
    inset: 12pt,
    radius: 4pt,
    width: 100%,
    {
      show raw.where(block: true): set text(size: 10pt)
      show raw.where(block: true): set block(spacing: 0pt, above: 0pt, below: 0pt)
      show raw.line: it => table(
        columns: (2.2em, 1fr),
        align: (right + horizon, left + horizon),
        stroke: none,
        inset: (x: 0pt, y: 0pt),
        column-gutter: 0.8em,
        [#text(fill: luma(120))[#it.number]], [#it.body],
      )
      raw(block: true, lang: "rust", oob-rust-runtime-code)
    },
  )
] <lst:oob-rust-runtime>

In #raw("main") entstehen wieder #raw("var") mit dem Wert 5 und ein Array mit zwei Elementen. Der Aufruf #raw("write_slice(&mut array, 2)") entspricht dem Aufruf von #raw("write_arr_at_index(array, 2)") in @lst:oob. Innerhalb von #raw("write_slice") führt #raw("arr[index] = 99") den eigentlichen Schreibzugriff aus. Anders als in @lst:oob-rust-compiletime kompiliert dieses Programm, weil der Index zur Compilezeit nicht als fest verletzt erkennbar ist.

Zur Laufzeit prüft Rust vor jedem Zugriff auf #raw("arr[index]"), ob der Index innerhalb der Slice Grenzen liegt. Liegt er außerhalb, bricht das Programm kontrolliert ab, statt undefiniertes Verhalten auszulösen. Rust kann diese Grenzverletzungen bei Arrayzugriffen zur Laufzeit erkennen, während die zentrale Speichersicherheit über Compilezeitprüfungen erreicht wird. @fig:oob-rust-runtime-panic zeigt die Meldung bei Ausführung von @lst:oob-rust-runtime.

#let oob-runtime-panic = read("listings/out_of_bounds_write_runtime/panic_output.txt")

#figure(
  kind: "laufzeitmeldung",
  supplement: [Laufzeitmeldung],
  caption: [Panic Ausgabe für @lst:oob-rust-runtime],
)[
  #set text(size: 9pt)
  #set par(justify: false)
  #block(
    fill: luma(248),
    inset: 12pt,
    radius: 4pt,
    width: 100%,
    raw(block: true, lang: "text", oob-runtime-panic),
  )
] <fig:oob-rust-runtime-panic>

Der Laufzeitfehler beginnt mit #raw("thread 'main' panicked at main.rs:2:5"). Als Ursache nennt die Meldung #raw("index out of bounds: the len is 2 but the index is 2"). Der Panic tritt in #raw("write_slice") auf, noch bevor der ungültige Schreibzugriff ausgeführt wird. #raw("var") bleibt deshalb unverändert bei 5. In @lst:oob würde dagegen der Wert 99 ausgegeben, weil C den benachbarten Speicher stillschweigend überschreibt.

Diese Prüfung erfolgt automatisch. Der Rust Compiler fügt die nötigen Grenzchecks beim Übersetzen ein, ohne dass sie im Quelltext sichtbar werden müssen. Der zusätzliche Laufzeitaufwand bleibt gering, typischerweise genügen ein Vergleich und ein bedingter Sprung. Im Gegensatz zu nachträglicher Instrumentierung wie AddressSanitizer sind die Checks fester Bestandteil der normalen Programmausführung in Rust, nicht nur von Testbuilds.

Nach der Erkennung eines Out of Bounds Zugriffs übernimmt die Rust Laufzeitumgebung die Panic Behandlung. Standardmäßig ist #raw("panic = \"unwind\"") gesetzt. Dabei wird der Stack abgebaut und der Prozess beendet. Mit #raw("panic = \"abort\"") endet der Prozess ohne den Stack davor abzubauen @noauthor_panic_nodate. In beiden Fällen wird der ungültige Speicherzugriff verhindert, bevor er ausgeführt wird. Das Verhalten ist damit vorhersehbar und nicht undefiniert wie in C.

Damit ergänzt die Laufzeitprüfung die Compilezeitanalyse aus dem vorherigen Abschnitt. Fehler mit konstantem Index werden bereits beim Kompilieren abgelehnt. Fehler mit dynamischem Index werden zur Laufzeit abgefangen. Zusammen mit Ownership, Borrowing und Lifetimes bildet Rust so mehrere Schutzschichten gegen die in Kapitel 2 betrachteten Speicherfehler.

== Formale Sicherheitsnachweise

Die gezeigten Beispiele verdeutlichen das praktische Verhalten des Compilers und der Laufzeitumgebung. Offen bleibt, ob die zugrunde liegenden Regeln auch allgemein tragen. Laut @hicks_what_2014 gilt eine Programmiersprache erst dann als speichersicher, wenn jedes in ihr erzeugbare Programm speichersicher ist. Rust erlaubt jedoch #raw("unsafe") Blöcke, in denen typisierte Garantien bewusst außer Kraft gesetzt werden können, etwa für die Interaktion mit C Code oder für hardwarenahe Optimierungen @noauthor_unsafety_nodate.

Forschung adressiert diese Lücke zwischen Sprachversprechen und formaler Absicherung. @jung_rustbelt_2018 stellen mit RustBelt den ersten formalen und maschinell geprüften Sicherheitsbeweis für eine realistische Teilmenge von Rust vor. Die Autoren modellieren das ownershipbasierte Typsystem und zeigen, dass Programme innerhalb dieses Modells speichersicher bleiben. Entscheidend ist die Erweiterbarkeit des Beweises. Viele Standardbibliotheken nutzen intern #raw("unsafe") Code. RustBelt formuliert dafür Verifikationsbedingungen, die eine Bibliothek erfüllen muss, damit sie als sichere Erweiterung der Sprache gilt. Für zentrale Bibliotheken des Rust Ökosystems wurde diese Prüfung durchgeführt @jung_rustbelt_2018.

Damit ist Rusts Speichersicherheit nicht nur eine Behauptung der Entwickler, sondern für einen klar abgegrenzten Kern wissenschaftlich untersucht. Der Beweis deckt nicht automatisch jedes Rust Programm ab, insbesondere wenn #raw("unsafe") Code unsauber eingesetzt wird. Für den in dieser Arbeit betrachteten sicheren Teil der Sprache, der ohne #raw("unsafe") auskommt, stützt RustBelt jedoch die Wirksamkeit der zuvor erläuterten Konzepte.
