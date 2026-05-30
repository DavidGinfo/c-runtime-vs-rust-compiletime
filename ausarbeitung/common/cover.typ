#import "../meta.typ": *

#set page(
  margin: 30pt,
)

#rect(
  width: 100%,
  height: 95%,
  radius: (
    top-right: 15pt,
    bottom-left: 15pt,
  ), 
  stroke: rgb("#8a8a8a") + 1pt,
  inset: 1cm, [
    #grid(
      columns: (1fr, 1fr),
      align: (left + horizon, right + horizon),
      [#image("../assets/hka_logo_iwi_text.svg", width: 150pt)],
      [#image("../assets/hka_logo_icon.svg", height: 60pt)],
    )

    #pad(top: 75pt)[
      #align(center)[
        #block(width: 75%)[
          #text(font: "Liberation Sans", weight: "bold", size: 24pt)[#title]
        ]
      ]
    ]

    #pad(top: 45pt)[
      #align(center)[
        #block(width: 50%)[
            #text(size: 12pt)[#thesisType #linebreak() von]
          ]
      ]
    ]

    #pad(top: 30pt)[
      #align(center)[
        #text(font: "Liberation Sans", weight: "bold", size: 18pt)[#author]
      ]
    ]

    #pad(top: 30pt)[
      #align(center)[
        #text(size: 12pt)[
          #department
        ]
      ]
    ]

    #pad(top: 50pt)[
      #align(center,
        [#grid(
          columns: (auto, auto),
          rows: (auto),
          align: (right, left),
          column-gutter: 1em,
          row-gutter: 1em,
          [#text(size: 12pt)[Betreuer:]],
          [#text(size: 12pt)[#reviewerOne]],
          [#text(size: 12pt)[Bearbeitungszeitraum:]],
          [#text(size: 12pt)[#completionPeriod]],
        )]
      )
    ]

  ]
)
