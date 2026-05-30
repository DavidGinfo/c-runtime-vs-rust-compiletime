= Fazit

- jetzt haben wir an einigen wenigen Beispielen gesehen wie Rusts Konzepte dafür sorgen können Memory safen coden zu entwickeln
- aber sind diese Konzepte wirklich allgemein gültig und ist jedes Programm, welches mit Rust entwickelt wird zu 100% Memory safe?
- und ja natürlich löst Rust nicht alle Memory Safety Probleme, was vor allem daran liegt, dass es in Rust auch möglich ist explizit unsicheren Code zu schreiben, um Beispiel mit perse unsicherem C Code zu interagieren oder Low-Level-Code für Hardware Interaktion zu entwickeln
- außerdem sind die Programmier Konzepte nicht unbedingt schnell für Entwickler zu erlernen, was die Entwicklungs anfangs verlangsamen kann
- dennoch wurde von Forschern bewiesen, dass das Ownership Modell in Rust erhebliche Memory Safety Probleme durch das Design unterbindet
- und auch in der Praxis wirkt die Verwendung von Rust
- Google berichtete in ihrem security blog 2024, dass nach Einführung von Rust in Android die Anzahl memory-safety Schwachstellen von 76% auf 24% der Sicherheitslücken zurückging
- damit möchte ich den Vortrag beenden und hoffe ich habe Ihnen ein paar Gründe mehr gegeben Rust einmal auszuprobieren
- ich bin jetzt gerne bereit noch alle Ihre Fragen zu beantworten