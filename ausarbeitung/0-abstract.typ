#[
  #v(2.5cm)
  #set text(
    font: "Arial",
    size: 18pt,
  )
  = Zusammenfassung
  #v(0.75em)
]

Speicherzugriffsfehler wie Use After Free und Out of Bounds Write zählen zu den häufigsten Sicherheitsproblemen in Software und entstehen besonders leicht in C, weil Speicher manuell verwaltet wird. Diese Seminararbeit untersucht, wie Rust derartige Fehler durch Compilezeitprüfungen verhindert.

Zunächst werden beide Fehlertypen anhand minimaler C Beispiele erläutert. Anschließend wird Rusts Konzept aus Ownership, Borrowing, Lifetimes und dem Borrow Checker dargestellt und an denselben Beispielen nachvollzogen. Use After Free scheitert beim Kompilieren, Out of Bounds Zugriffe werden zur Compilezeit abgelehnt oder zur Laufzeit kontrolliert abgebrochen.

Rust macht zentrale Speicherfehler früh sichtbar oder verhindert sie vollständig, ohne Garbage Collection. Grenzen bleiben durch unsicheren Code und Migrationsaufwand in bestehenden C Codebasen. Praxisdaten aus der Android Entwicklung zeigen dennoch einen deutlichen Rückgang speicherbezogener Schwachstellen nach verstärkter Nutzung speichersicherer Sprachen.
