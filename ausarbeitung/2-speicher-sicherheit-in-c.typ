= Speichersicherheit als zentrales Sicherheitsproblem

#set figure(supplement: [Abbildung])

Bevor die Speichersicherheitsprobleme im Detail betrachtet werden, lohnt sich ein Blick auf die zugrunde liegende Statistik. Dafür wird zunächst erläutert, wie die CWE Schwachstellen erfasst, bewertet und in Kategorien einteilt. So lässt sich nachvollziehen, welche Bedeutung Speichersicherheit in den Auswertungen tatsächlich einnimmt. Anschließend wird der Begriff Speichersicherheit präzisiert. Die beiden zuvor genannten Schwachstellen werden anhand kurzer C Beispiele nachvollzogen. Dabei wird Schritt für Schritt gezeigt, wie Use After Free und Out of Bounds Write in der Praxis entstehen können und warum solche Fehler in Sprachen mit manueller Speicherverwaltung besonders leicht auftreten. Zum Abschluss des Kapitels werden die sicherheitsrelevanten Konsequenzen dieser Fehler betrachtet. Darauf aufbauend werden gängige Lösungsansätze vorgestellt, um damit den Übergang zum folgenden Kapitel vorzubereiten, in dem Rusts Ansatz zur Compilezeitprüfung von Speichersicherheit im Mittelpunkt steht.

== Erfassung und Bewertung von Schwachstellen

In der Einleitung wurde bereits die Common Weakness Enumeration (CWE) eingeführt, eine Sammlung, die verschiedene Softwareschwachstellen auflistet und definiert. Um vergleichbare Fehlerklassen zu erfassen, werden abstrakte Schwachstellen definiert und auf tatsächlich dokumentierte Sicherheitslücken abgebildet. Diese Zuordnung geht auf die Idee einer gemeinsamen Schwachstellenkatalogisierung zurück @mann_towards_nodate.

Die dokumentierten Einzelfälle werden als Common Vulnerabilities and Exposures (CVEs) bezeichnet. Sie stammen aus einer öffentlich zugänglichen Datenbank, in der Softwarefehler erfasst werden. Ein CVE kann eingereicht werden, wenn eine Schwachstelle beschrieben und einer CVE Nummer zugeordnet werden kann. Die Vergabe erfolgt über sogenannte CVE Numbering Authorities (CNAs), zu denen unter anderem große Technologieunternehmen wie Microsoft und Google gehören @noauthor_cwe_nodate-3. Die Datenbasis ist nicht vollständig, da nicht jeder Fehler veröffentlicht wird. Aufgrund der breiten Beteiligung gilt sie dennoch als eine der repräsentativsten frei zugänglichen Quellen für Softwareschwachstellen.

Use After Free und Out of Bounds Write aus der Einleitung teilen gemeinsame Merkmale mit zahlreichen weiteren Schwachstellen in der CWE Bewertung. Die betrachtete Auswertung bezieht sich auf Known Exploited Vulnerabilities (KEV), also nachweislich ausgenutzte Schwachstellen. Dafür werden Schwachstellen in Kategorien eingeteilt. @fig:kev-categories zeigt die Verteilung der zehn am häufigsten ausgenutzten KEV Schwachstellen nach Kategorie. Speichersicherheit (Memory Safety) nimmt mit 31 Prozent den zweitgrößten Anteil ein, direkt hinter Injection mit 33 Prozent. Weitere Kategorien wie Access Control, Resource Control und File Handling liegen deutlich zurück.

#figure(
  image("assets/top10_kev_cwe_by_category.png", width: 75%),
  caption: [Verteilung der CWE Top 10 KEV Schwachstellen nach Kategorie @noauthor_cwe_nodate-4],
) <fig:kev-categories>

Zur Gewichtung einzelner Schwachstellen dient der sogenannte Danger Score @noauthor_cwe_nodate-3. Er kombiniert die Häufigkeit einer Schwachstelle im Datensatz mit der durchschnittlichen Schwere bei Ausnutzung. Die Häufigkeit entspricht der Anzahl der CVE Einträge, denen die Schwachstelle als Ursache zugeordnet ist. Die Schwere wird über den Common Vulnerability Scoring System (CVSS) Basiswert abgebildet. Beide Größen werden auf einen Wertebereich zwischen 0 und 1 normiert. Der Danger Score ergibt sich daraus wie folgt:

#align(center)[
  #block(
    width: 60%,
    inset: 16pt,
    fill: luma(248),
    stroke: 1pt + luma(180),
    radius: 6pt,
  )[
    #align(center)[
      #set text(size: 18pt)
      $ "Danger Score" = F_r dot S_v dot 100 $
    ]
  ]
]

#v(0.75em)

$ F_r = ( "Anzahl"("CWE") - "Anzahl"_min ) / ( "Anzahl"_max - "Anzahl"_min ) $
$ S_v = ( overline("CVSS")("CWE") - "CVSS"_min ) / ( "CVSS"_max - "CVSS"_min ) $

Dabei bezeichnet $F_r$ die normalisierte Häufigkeit einer Schwachstelle und $S_v$ die normalisierte durchschnittliche CVSS Schwere @noauthor_cwe_nodate-3. $"Anzahl"("CWE")$ ist die Anzahl der CVE Zuordnungen, $overline("CVSS")("CWE")$ der durchschnittliche CVSS Basiswert. Die Indizes $min$ und $max$ bezeichnen jeweils den kleinsten und größten Wert im Datensatz. $F_r$ und $S_v$ liegen damit jeweils zwischen 0 und 1. Schwachstellen, die selten auftreten oder bei Ausnutzung geringe Auswirkungen haben, erhalten einen niedrigen Score. Häufige Schwachstellen mit schwerwiegenden Folgen werden entsprechend höher bewertet.

== Begriff der Speichersicherheit

Ausgehend von der CWE Bewertung stellt Speichersicherheit ein zentrales Sicherheitsproblem dar. Damit ist jedoch noch nicht geklärt, was unter Speichersicherheit, im Englischen Memory Safety, konkret zu verstehen ist. Der Begriff wird häufig verwendet, eine einheitliche Definition ist aber weniger selbstverständlich, als es zunächst wirkt.

Grundsätzlich lässt sich zwischen der Speichersicherheit einer Programmausführung, eines Programms und einer Programmiersprache unterscheiden @hicks_what_2014. Eine Programmausführung gilt als speichersicher, wenn während ihres Ablaufs kein Speicherzugriffsfehler auftritt. Ein Programm gilt als speichersicher, wenn alle möglichen Ausführungen speichersicher sind. Entsprechend gilt eine Programmiersprache als speichersicher, wenn jedes in ihr erzeugbare Programm speichersicher ist.

Eine verbreitete Definition orientiert sich an einer Liste typischer Speicherzugriffsfehler @szekeres_sok_2013 @hicks_what_2014. Solche Fehler zählen zu den ältesten und persistierendsten Sicherheitsproblemen in Software, die in Sprachen wie C oder C++ geschrieben ist. Fehlt Speichersicherheit, können Angreifer das Verhalten von Programmen verändern oder die Kontrolle über den Programmablauf übernehmen. Trotz zahlreicher Schutzmechanismen bleiben Speicherfehler bis heute eine ernsthafte Bedrohung. @tab:memory-errors fasst fünf zentrale Speicherzugriffsfehler zusammen. Tritt mindestens einer dieser Fehler in einer möglichen Ausführung auf, ist das Programm nicht speichersicher.

#figure(
  kind: table,
  supplement: [Tabelle],
  caption: [Fünf zentrale Speicherzugriffsfehler @szekeres_sok_2013],
)[
  #set text(size: 10.5pt)
  #show table.cell: it => {
    set par(justify: false, leading: 0.65em, spacing: 0.65em)
    set align(left)
    it
  }
  #table(
    columns: (4.6cm, 3.4cm, 1fr),
    align: (left + horizon, left + horizon, left + top),
    inset: (x: 8pt, y: 6pt),
    stroke: (_, y) => (
      top: if y == 0 { 1pt + black },
      bottom: if y == 0 { 0.75pt + black } else if y == 5 { 1pt + black } else { none },
      left: none,
      right: none,
    ),
    table.header(
      table.cell(fill: luma(245))[*Speicherzugriffsfehler*],
      table.cell(fill: luma(245))[*Zugriffsart*],
      table.cell(fill: luma(245))[*Beschreibung*],
    ),
    [Out of Bounds Write], [Schreiben], [Schreibzugriff außerhalb eines gültigen Puffers oder Arrays],
    [Out of Bounds Read], [Lesen], [Lesezugriff außerhalb eines gültigen Puffers oder Arrays],
    [Use After Free], [Lesen oder Schreiben], [Zugriff auf Speicher, der bereits freigegeben wurde],
    [Use of Uninitialized Memory], [Lesen oder Schreiben], [Zugriff auf reservierten, aber noch nicht initialisierten Speicher],
    [Double Free], [Freigabe], [Erneute Freigabe eines bereits freigegebenen Speicherbereichs],
  )
] <tab:memory-errors>

Kurz gefasst lässt sich Speichersicherheit auch so erklären: Ein Programm ist speichersicher, solange es keinen undefinierten Speicher verwendet @hicks_what_2014. Undefinierter Speicher ist Speicher, der nie alloziert wurde oder dessen Lebensdauer bereits beendet ist. Explizit alloziert wird Speicher auf dem Heap, auf dem Stack oder im statischen Datenbereich. Die genannten Speicherzugriffsfehler lassen sich als unzulässige Zugriffe auf undefinierten Speicher interpretieren.

== Use After Free

Use After Free bezeichnet einen Speicherzugriffsfehler, bei dem auf Speicher zugegriffen wird, der bereits freigegeben wurde. Der Fehler tritt ausschließlich im Zusammenhang mit dynamischer Speicherverwaltung auf. Betroffen ist damit Speicher, der zur Laufzeit auf dem Heap alloziert wurde.

Im Gegensatz zum Stack, auf dem lokale Variablen und Funktionsparameter automatisch verwaltet werden, dient der Heap für Speicher, dessen Lebensdauer über den aktuellen Funktionsaufruf hinausgehen soll. Allokation und Freigabe erfolgen in C explizit über Funktionen wie #raw("malloc()") und #raw("free()"). Der Heap ist ein großer Speicherbereich, aus dem der Laufzeitallocator bei Bedarf einzelne Blöcke bereitstellt. Freigegebene Blöcke können bei späteren Allokationen erneut vergeben werden. Diese Flexibilität ermöglicht effiziente Speichernutzung, birgt aber das Risiko, dass Zeiger auf bereits freigegebenen Speicher weiterhin existieren. Das folgende C Beispiel veranschaulicht den Fehler, da C zusammen mit C++ zu den verbreitetsten Sprachen mit manueller Speicherverwaltung zählt.

#figure(
  image("assets/use_after_free_heap_c.drawio.svg", width: 100%),
  caption: [Vierphasiger Ablauf eines Use After Free Fehlers auf dem Heap @noauthor_cwe_nodate-5],
) <fig:uaf-stages>

Nach der CWE Definition greift ein Use After Free vor, wenn ein Programm Speicher erneut verwendet oder referenziert, nachdem dieser freigegeben wurde @noauthor_cwe_nodate-5. Zu einem späteren Zeitpunkt kann derselbe Speicherbereich erneut alloziert. Der ursprüngliche Zeiger verweist dabei weiterhin auf eine Adresse innerhalb der neuen Allokation. Zugriffe über den ursprünglichen Zeiger sind ungültig, da der Speicherbereich faktisch dem Code gehört, der über den neuen Zeiger arbeitet. Ein Zeiger, der nach einer Freigabe nicht mehr auf gültigen Speicher verweist, wird als Dangling Pointer bezeichnet. Typischerweise durchläuft ein Use After Free vier Phasen, die in @fig:uaf-stages zusammengefasst sind:

+ *Allocate:* Speicher wird auf dem Heap alloziert.
+ *Free:* Der Speicher wird freigegeben. Bestehende Zeiger verweisen danach auf ungültigen Speicher und werden zu Dangling Pointern.
+ *Allocate:* Derselbe Speicherbereich kann erneut alloziert werden.
+ *Use:* Ein Zugriff über den Dangling Pointer liest oder schreibt fälschlich den neu zugewiesenen Inhalt.

@lst:uaf zeigt ein minimales Beispiel. In Zeile 5 wird über #raw("malloc()") Speicher für einen Integer alloziert und #raw("buffer_ptr1") gesetzt. Zeile 6 schreibt den Wert 21 in diesen Block. Zeile 8 erzeugt mit #raw("buffer_ptr2") einen zweiten Zeiger auf dieselbe Adresse, ohne neuen Speicher zu reservieren. Mit #raw("free(buffer_ptr1)") in Zeile 10 wird der Block freigegeben. Damit endet die Gültigkeit der Allokation. Beide Zeiger enthalten weiterhin die bisherige Adresse und sind ab diesem Punkt Dangling Pointer. Entspricht dies der Free Phase aus @fig:uaf-stages.

#let uaf-code = read("listings/use_after_free/main.c")

#figure(
  supplement: [Quelltext],
  caption: [Minimales Use After Free Beispiel in C],
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
      raw(block: true, lang: "c", uaf-code)
    },
  )
] <lst:uaf>

Zeile 12 alloziert erneut Speicher für einen Integer, was der zweiten Allocate Phase entspricht. Je nach Allocator und Heap Zustand kann #raw("buffer_ptr3") dieselbe Adresse erhalten wie zuvor #raw("buffer_ptr1"). Zeile 13 überschreibt den Inhalt mit 42.

Zeile 15 dereferenziert #raw("buffer_ptr2") und gibt den Wert aus. Der Zugriff erfolgt über einen Dangling Pointer und entspricht der Use Phase. Statt des ursprünglichen Werts 21 wird der Wert 42 ausgegeben, der über #raw("buffer_ptr3") geschrieben wurde. Der Fehler entsteht, weil zwei Zeiger auf denselben Speicher verwiesen, die Freigabe aber nur über einen von ihnen durchgeführt wurde.

Dieses Verhalten ist sicherheitskritisch, wenn über den neuen Zeiger vertrauliche Daten abgelegt werden und der Dangling Pointer unberechtigten Lesezugriff ermöglicht. Derartige Fehler entstehen besonders leicht, wenn mehrere Zeiger auf denselben Heap Block verweisen und die Freigabe nicht für alle Zeiger nachvollziehbar ist.

== Out of Bounds Write

Neben Use After Free zählt Out of Bounds Write zu den häufigsten Speicherzugriffsfehlern aus der Einleitung. Anders als Use After Free betrifft dieser Fehler nicht nur den Heap, sondern tritt besonders häufig auf dem Stack auf. Der Stack dient der Verwaltung von Funktionsaufrufen in Programmen. Bei jedem Aufruf werden lokale Variablen, Funktionsparameter und Rücksprunginformationen in einem last in, first out Verfahren abgelegt. Beim Verlassen einer Funktion wird der zugehörige Stackbereich wieder freigegeben. Im Gegensatz zum Heap erfolgt diese Verwaltung automatisch durch den Compiler und die Laufzeitumgebung. Typischerweise wächst der Stack dabei in Richtung abnehmender Speicheradressen. Welche Variablen an welcher Adresse liegen, hängt vom Compiler und der Zielplattform ab. Gerade diese feste Nachbarschaft von Daten auf dem Stack macht Out of Bounds Write besonders gefährlich.

#figure(
  image("assets/out_of_bounds_write_stack_c.drawio.svg", width: 55%),
  caption: [Out of Bounds Write auf dem Stack @noauthor_cwe_nodate-6],
) <fig:oob-stack>

Nach der CWE Definition liegt ein Out of Bounds Write vor, wenn Daten hinter das Ende oder vor den Anfang eines vorgesehenen Puffers geschrieben werden @noauthor_cwe_nodate-6. Schreibt ein Programm außerhalb der gültigen Grenzen eines Arrays oder Puffers, kann benachbarter Speicher überschrieben werden. In der CWE Terminologie wird der daraus resultierende Schaden häufig als Memory Corruption bezeichnet, also die Beschädigung von Speicher durch ungültige Schreibzugriffe @noauthor_cwe_nodate-6. @fig:oob-stack veranschaulicht den Fehler am Beispiel eines Stacklayouts. Dort liegen eine lokale Variable und ein Array unmittelbar hintereinander. Gültige Indizes des Arrays reichen von 0 bis 1. Wird dennoch über Index 2 geschrieben, trifft der Schreibzugriff nicht mehr den Arraybereich, sondern die benachbarte Variable. Der ursprüngliche Wert der Variable wird so stillschweigend überschrieben.

#let oob-code = read("listings/out_of_bounds_write/main.c")

#figure(
  supplement: [Quelltext],
  caption: [Minimales Out of Bounds Write Beispiel in C],
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
      raw(block: true, lang: "c", oob-code)
    },
  )
] <lst:oob>

@lst:oob zeigt ein minimales C Beispiel. In Zeile 8 wird die Variable #raw("var") mit dem Wert 5 initialisiert. Zeile 9 legt ein Array mit zwei Elementen an. Zeile 11 ruft #raw("write_arr_at_index(array, 2)") auf und übergibt den Index 2. Für ein Array der Länge 2 sind jedoch nur die Indizes 0 und 1 gültig. Die Funktion in Zeile 3 und 4 führt den Schreibzugriff ohne Prüfung des Index aus. Entsprechend der in @fig:oob-stack dargestellten Anordnung kann der Zugriff auf #raw("arr[2]") den Speicher der Variable #raw("var") treffen. Beim GNU C Compiler (GCC) liegen lokale Variablen und Arrays auf dem Stack typischerweise in unmittelbarer Nachbarschaft mit absteigenden Adressen. Zeile 13 gibt daher nicht den erwarteten Wert 5 aus, sondern 99.

Auch wenn die Veränderung einer einzelnen Variable harmlos erscheint, sind die Folgen bei sicherheitskritischem Code gravierend. Liegt an der betroffenen Stackposition statt einer einfachen Variable beispielsweise eine Rücksprungadresse oder ein Funktionszeiger, kann ein gezielter Out of Bounds Write die Programmausführung umleiten und die Ausführung von Angreifercode ermöglichen @szekeres_sok_2013.

== Sicherheitsrelevante Konsequenzen

Die beiden beschriebenen Fehler wirken sich auf mehrere zentrale Sicherheitsziele aus. Neben Integrität und Verfügbarkeit sind vor allem Vertraulichkeit und die Kontrolle über die Programmausführung betroffen @baker_memory_2023 @szekeres_sok_2013.

Vertraulichkeit stellt sicher, dass Informationen nur für berechtigte Empfänger zugänglich sind. Use After Free kann dieses Ziel verletzen, wenn über Dangling Pointer in bereits freigegebenen Speicher gelesen wird. Der Speicherbereich kann inzwischen anderen Teilen des Programms zugeordnet sein, etwa einem neuen Heap Block mit vertraulichen Inhalten. In @lst:uaf liest #raw("buffer_ptr2") einen Wert aus, der eigentlich über #raw("buffer_ptr3") geschrieben wurde. Übertragen auf realen Code entspricht das dem unbefugten Auslesen fremder Daten aus dem Prozessspeicher.

Integrität bedeutet, dass Daten nicht unbefugt verändert werden. Use After Free gefährdet dieses Ziel auf dem Heap, wenn über Dangling Pointer in bereits freigegebenen Speicher geschrieben wird. Out of Bounds Write bedroht die Integrität vor allem auf dem Stack. Wie in @lst:oob gezeigt, überschreibt ein ungültiger Index den Wert einer benachbarten Variable. Allgemeiner lassen sich damit benachbarte Speicherbereiche manipulieren, etwa Metadaten, Zeiger oder Kontrollstrukturen.

Neben der Integrität einzelner Datenwerte kann Speicherkorruption die Kontrolle über den Programmablauf selbst gefährden. Out of Bounds Write erlaubt es, Funktionszeiger oder Rücksprungadressen auf dem Stack zu überschreiben. Use After Free kann zusammen mit weiteren Techniken dazu genutzt werden, unerwartete Ausführungspfade zu erzeugen @szekeres_sok_2013. Die CWE ordnet Out of Bounds Write ausdrücklich der Folge Execute Unauthorized Code or Commands zu @noauthor_cwe_nodate-6. Damit lassen sich Speicherfehler von reinen Datenfehlern zu Angriffen eskalieren, die die ursprüngliche Logik des Programms vollständig unterlaufen.

Verfügbarkeit beschreibt, ob ein System oder Dienst für berechtigte Nutzer erreichbar bleibt. Speicherfehler können diese Verfügbarkeit durch Abstürze oder instabiles Verhalten einschränken @baker_memory_2023. Bei Use After Free spielt die interne Verwaltung des Heaps eine Rolle. Speicherallocator wie die Implementierung von #raw("malloc") in der GNU C Library führen nach einer Freigabe häufig eine Chunk Konsolidierung durch, bei der benachbarte freie Blöcke zusammengeführt werden. Greift ein Programm danach über einen Dangling Pointer erneut auf den freigegebenen Bereich zu, können die internen Verwaltungsinformationen des Heaps nicht mehr gültig sein. Der Prozess bricht in solchen Fällen oft ab. Out of Bounds Write kann die Verfügbarkeit ebenfalls beeinträchtigen. Wird etwa eine Rücksprungadresse auf dem Stack überschrieben, kehrt die Ausführung nicht mehr kontrolliert in den aufrufenden Code zurück. Auch ungültige Zugriffe auf nicht vorgesehene Speicherbereiche können den Prozess beenden. Für netzwerk- oder serverbasierte Anwendungen bedeutet ein solcher Absturz unmittelbar den Ausfall des betroffenen Dienstes.

== Lösungsansätze

Die gezeigten Beispiele verdeutlichen, warum Speicherfehler in C und C++ ein dauerhaftes Sicherheitsproblem darstellen. Gegen Speicherfehler haben sich in der Praxis im Wesentlichen drei Ansätze etabliert. Sie unterscheiden sich darin, ob Speicher zur Laufzeit automatisch verwaltet, zur Laufzeit überwacht oder bereits zur Compilezeit geprüft.

Der verbreitetste Ansatz ist der Einsatz speichersicherer Programmiersprachen mit automatischer Speicherverwaltung. Dabei übernimmt eine Laufzeitumgebung die Verwaltung des Heaps. Ein Garbage Collector ermittelt zur Laufzeit, welche Speicherobjekte noch erreichbar sind, und gibt nicht mehr benötigten Speicher automatisch frei. Entwickler müssen in solchen Sprachen typischerweise weder #raw("malloc()") noch #raw("free()") aufrufen und können damit Use After Free oder Double Free in der vorliegenden Form vermeiden. Sprachen wie Java, Python oder JavaScript setzen diesen Ansatz unterschiedlich um, gelten aber gemeinsam als speichersicherer als C oder C++. Häufig werden zusätzlich Laufzeitprüfungen für Arraygrenzen eingesetzt, um Out of Bounds Zugriffe abzufangen. Der Preis dafür ist ein zusätzlicher Laufzeitaufwand, der vor allem durch den Garbage Collector entsteht. In performancekritischen Systemen kann dieser Overhead spürbar sein. Für bestehende C Codebasen ist ein vollständiger Wechsel auf eine andere Sprache zudem oft mit erheblichem Migrationsaufwand verbunden @team_eliminating_nodate.

Ein zweiter Ansatz zielt auf bestehenden C oder C++ Code. Dabei wird das Programm beim Kompilieren oder zur Laufzeit so erweitert, dass ungültige Speicherzugriffe erkannt werden, bevor sie unkontrolliert eskalieren. AddressSanitizer (ASan) ist ein verbreitetes Beispiel für diese Kategorie. ASan fügt zusätzliche Prüfungen ein und nutzt sogenanntes Shadow Memory, um nachzuvollziehen, welche Speicheradressen gültig sind. Das Werkzeug findet unter anderem Out of Bounds Zugriffe und Use After Free während der Programmausführung. Laut den Autoren entsteht dabei im Mittel eine Verlangsamung von etwa 73 Prozent @serebryany_addresssanitizer_2012. Valgrind verfolgt einen ähnlichen Zweck, arbeitet aber durch dynamische Instrumentierung zur Laufzeit und ist deutlich langsamer. Es eignet sich vor allem für Tests und Fehlersuche in der Entwicklung, nicht für den dauerhaften Produktionseinsatz. Entscheidend ist, dass diese Werkzeuge Fehler erst zur Laufzeit sichtbar machen. Sie verhindern Speicherfehler nicht vollständig und decken nicht alle Fehlerklassen zuverlässig ab @szekeres_sok_2013. Auch Rust führt bei einigen Prüfungen, etwa Grenzchecks bei Arrayzugriffen, zur Laufzeit einen kontrollierten Abbruch aus, statt undefiniertes Verhalten zu erzeugen. Die zentrale Speichersicherheit wird in Rust jedoch nicht über Instrumentierung, sondern über Compilezeitprüfungen erreicht.

Der dritte Ansatz verschiebt die Erkennung von Speicherfehlern in den Compiler. Potenziell unsichere Programme werden gar nicht erst gebaut, wenn sie gegen die Regeln der Sprache verstoßen. Damit lassen sich Use After Free, Dangling Pointer und viele Out of Bounds Zugriffe bereits vor der Ausführung ausschließen. Im Idealfall entsteht dafür kein dauerhafter Garbage Collection Overhead, weil die Speicherverwaltung statisch geprüft wird statt vollständig zur Laufzeit nachverfolgt zu werden. Dieser Ansatz erfordert jedoch strengere Sprachregeln und ein Umdenken bei der Programmierung. Rust verfolgt genau diese Strategie mit Konzepten wie Ownership und Borrowing. Im folgenden Kapitel wird dargestellt, wie Rust Speicherfehler zur Compilezeit verhindert und damit einen alternativen Weg zu Garbage Collection und nachträglicher Instrumentierung eröffnet.
