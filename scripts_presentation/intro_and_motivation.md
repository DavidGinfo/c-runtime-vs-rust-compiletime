# Intro and Motivation

## Title Slide

- Begrüßung nochmal von meiner Seite aus
- wie Sie hier schon auf meiner Titlefolie sehen wird sich mein Vortrag mit Rust beschäftigen
- aber ich möchte mal garnicht zu viel vorwegnehmen und sofort mit einer Frage an Sie einsteigen:

## Slide 2 - Question to Audience

- was denken Sie sind mit die häufigsten Bugs in moderner Software?
- also welche Programmier-Fehler machen Systeme, die wir entwickeln, besonders angreibar?
- hat jemand eine Idee, um was für Bugs es sich da handelt
- ... Antworten abwarten
- zu Beginn dieser Recherche hätte ich nicht gedacht, dass die Ergebnisse so ausfallen

## Slide 3 - Most common Vulnarabilites

- wenn man herausfinden möchte, was denn die größten Probleme sind, die Sicherheitslücken verursachen, dann landet man releativ schnell bei der "Common Weakness Enumeration" kurz CWE
- diese CWE ist eine Liste in der verschiedene Schwachstellen aufgelistet und definiert werden, die bestimmte Angriffsmöglichkeiten von Software beschreiben
- dafür werden abstrakte Fehler festgelegt und auf "echte" wirkliche passiert Fehler gemapped
- diese echten Fehler sogenannte "Common Vulnarabilites and Exposures" (CVEs) stammen aus einer Datenbank der US Regierung, in der Software Fehler eingetragen werden
- Fehler kann dort quasi jeder eintragen
- man muss eine Schwachstelle nur beschreiben und einem CVE zuordnen können und dann über einen sogenannten CNA (CVE Numbering Authority) einreichen
- CNA's sind große Tech Konzerne wie Microsoft und Google
- die Daten sind sicherlich nicht vollständig, da natürlich nicht jeder Fehler frei rausgegeben wird, aber durch die Masse an Beteiligungen vermutlich das repräsentativste, was man frei zugänglich so findet
- so viel ganz kurz dazu, wie man generell herausfinden kann, welche Bugs Entwickler heutzutage so produzieren

- die größte Schwachstelle laut der aktuellsten Statistik der CWE is tatsächlich eine Injection Schwachstelle
- genauer gesagt OS Command Injection, also eine Schwachstelle, die dadurch entsteht, dass der Entwickler eine Anwendung nicht gut genug gegen bösartige Argumente abgesichert hat
- aber um diese Schwachstelle soll es hier nicht gehen
- Platz 2 und 3 im Ranking beschreiben Bugs mit denen ich diese Seminararbeit gerne motivieren würde
  1. Ein Use-After-Free Bug landet auf Platz 2 des Rankings
  2. Und ein Out-Of-Bounds Write tatsächlich auf Platz 3, während dieser Fehler in der Statistik aus dem Jahr 2024 sogar Platz 1 belegte
- wahrscheinlich können die meisten von Ihnen grob etwas mit den kurzen Beschreibungen anfangen
- damit aber genau klar wird, woher diese Fehler kommen schauen wie uns die Details gleich noch genau an

## Slide 4 - Memory Safety vulnarability category

- davor lohnt es sich aber noch einmal anzuschauen, was diese beiden Bugs und viele andere Schwachstellen mit einschlägigen Bewertung so gemeinsam haben
- die Bugs werden von der CWE immer noch in Kategorien eingeteilt
- Memory Safety ist hier immer als top Kategorie vertreten gemessen, wenn man alle Einzel Scores der Schwachstellen aufsummiert
- dafür sollte man wissen, dass jede Schwachstelle von der CWE eine Bewertung quasi einen Danger Score bekommt
- dieser Danger Score berechnet sich aus Häufigkeit des Auftretens und daraus wie groß die Auswirkungen auf die Sicherheit sind, wenn dieser Fehler auftritt
- ausgehend von dieser Bewertung scheint Memory Safety ein ziemlich großes Problem darzustellen
- daher wollen wir uns in diesem Vortrag einmal anschauen, warum Memory Safety zu so vielen Exploits führt
- und welche ganze eigene Lösung Rust für diese Probleme anbietet 

# Sources

https://cwe.mitre.org/top25/archive/2025/2025_methodology.html

- [Towards a Common Enumeration of Vulnerabilities](https://www.cve.org/Resources/General/Towards-a-Common-Enumeration-of-Vulnerabilities.pdf)
  - Das ist ein White paper von der Erfindern/Gründern der MITRE Unternehmens in dem erklärt wird wie es dazu kam eine Fehler Datenbank zu Erstellen und was der Nutzen davon ist. Alter Paper aber gut.
- [2025 CWE Top 25 Methodology](https://cwe.mitre.org/top25/archive/2025/2025_methodology.html)
  - kurze aber präzise Beschreibung von CWE Bezeichnungen
- [2025 CWE Top 10 KEV Weaknesses List Insights](https://cwe.mitre.org/top25/archive/2025/2025_kev_insights.html)
  - Auf dieser Seite befinden sich Auswertungen, welche zeigen in was für Kategorien die Schwachstellen unterteilt werden können.
- [2025 CWE Top 25 Most Dangerous Software Weaknesses](https://cwe.mitre.org/top25/archive/2025/2025_kev_list.html)
  - Platzierung der größten Schwächen nach CWE sortiert