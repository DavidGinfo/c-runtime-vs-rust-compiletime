= Fazit

Diese Arbeit hat Use After Free und Out of Bounds Write als zentrale Speicherzugriffsfehler betrachtet und Rusts Ansatz zur Compilezeitprüfung dagegen untersucht. Kapitel 2 zeigte, wie derartige Fehler in C entstehen, welche Sicherheitsfolgen drohen und welche alternativen Lösungsansätze sich etabliert haben. Kapitel 3 stellte dar, wie Ownership, Borrowing, Lifetimes und der Borrow Checker Dangling References verhindern, wie Use After Free bereits beim Kompilieren scheitert und wie Out of Bounds Zugriffe zur Compilezeit oder zur Laufzeit abgefangen werden.

*Vorteile* gegenüber manueller Speicherverwaltung in C liegen vor allem in der frühen Fehlererkennung. Viele Speicherfehler führen nicht zu lauffähigen Programmen, sondern zu Kompilierfehlern. Damit entsteht kein undefiniertes Verhalten zur Laufzeit. Rust verbindet diese Prüfungen mit direktem Speicherzugriff ohne Garbage Collector für den sicheren Kern der Sprache. Grenzverletzungen mit dynamischem Index werden zwar erst zur Laufzeit erkannt, aber kontrolliert über Panic abgebrochen, statt stillschweigend benachbarten Speicher zu überschreiben wie in @lst:oob.

*Nachteile* und Grenzen sind ebenfalls zu berücksichtigen. Ownership, Borrowing und Lifetimes erfordern ein Umdenken und verlangsamen die Einarbeitung. Der Compiler lehnt Code ab, der in C noch kompiliert, was anfangs zusätzlichen Aufwand bedeutet. Rust ist nicht pauschal speichersicher, solange #raw("unsafe") Code oder unsichere Schnittstellen zu C genutzt werden. Laufzeitprüfungen bei Arrayzugriffen erzeugen zudem einen geringen, aber messbaren Overhead. Für große bestehende C Codebasen bleibt ein vollständiger Sprachwechsel mit erheblichem Migrationsaufwand verbunden.

In der Praxis zeigt sich der Nutzen des Ansatzes. Google berichtet für Android, dass der Anteil speicherbezogener Schwachstellen an allen Sicherheitslücken von 76 Prozent im Jahr 2019 auf 24 Prozent bis Ende 2024 gesunken ist @team_eliminating_nodate-1. Hintergrund ist die Safe Coding Strategie, bei der neuer Code bevorzugt in speichersicheren Sprachen wie Rust entwickelt wird, ohne den gesamten bestehenden C und C++ Code ersetzen zu müssen. @fig:android-memory-vulns zeigt den absoluten Rückgang speicherbezogener Schwachstellen pro Jahr im selben Zeitraum.

Die Abbildung bestätigt den Trend der sinkenden absoluten Fallzahlen. Von etwa 223 speicherbezogenen Schwachstellen im Jahr 2019 geht der Wert bis 2024 auf etwa 36 zurück. Damit unterstreicht das Beispiel, dass Compilezeitprüfungen und speichersichere Sprachentwicklung nicht nur theoretisch wirksam sind, sondern in großen Produktionscodebasen messbare Sicherheitsgewinne erzielen können.

#figure(
  image("assets/google_safety_vuls_stat.png", width: 75%),
  caption: [Anzahl speicherbezogener Schwachstellen in Android pro Jahr @team_eliminating_nodate-1],
) <fig:android-memory-vulns>

Rust verhindert die in dieser Arbeit betrachteten Speicherfehler nicht in jedem Fall automatisch. Für den sicheren Teil der Sprache bietet es jedoch ein durchdachtes Regelwerk, das Fehler früh erkennt und damit genau jene Schwachstellen adressiert, die in der CWE Statistik zu den häufigsten und schwerwiegendsten zählen. Die Kombination aus Compilezeitprüfung und kontrollierter Laufzeitabsicherung macht Rust zu einer ernsthaften Alternative im Vergleich zu manueller Speicherverwaltung in C und zu nachträglicher Fehlersuche mit Laufzeitwerkzeugen allein.
