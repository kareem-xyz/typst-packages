// Problem environment helper
#let problem(n, body) = {
  block(
    width: 100%,
    stroke: (left: 2pt + luma(80)),
    inset: (left: 10pt, y: 6pt),
    radius: 0pt,
    [
      #text(weight: "bold", size: 1.05em)[Problem #n] \
      #v(2pt)
      #body
    ]
  )
}

// Main template show rule
#let coursework(
  title: "Homework",
  course: "",
  author: "Kareem",
  due: none,
  body,
) = {
  // Document metadata
  set document(title: title, author: author)

  // Typography and spacing
  set text(font: "Libertinus Serif", size: 10.5pt)
  set par(justify: true, leading: 0.65em)

  // Math defaults
  set math.mat(delim: "[")
  set math.vec(delim: "[")

  // Page layout
  set page(
    paper: "us-letter",
    margin: (x: 1in, top: 1.1in, bottom: 1in),
    header: context {
      if counter(page).get().first() > 1 [
        #grid(
          columns: (1fr, 1fr),
          align(left)[#text(size: 8.5pt, fill: luma(100))[#course: #title]],
          align(right)[#text(size: 8.5pt, fill: luma(100))[#author]],
        )
        #v(-4pt)
        #line(length: 100%, stroke: 0.4pt + luma(180))
      ]
    },
    footer: context {
      let current = counter(page).get().first()
      let total = counter(page).final().first()
      align(center)[
        #text(size: 8.5pt, fill: luma(120))[Page #current of #total]
      ]
    },
  )

  // Title / Metadata Banner (Page 1)
  grid(
    columns: (1fr, auto),
    gutter: 1em,
    [
      #if course != "" [
        #text(size: 1.1em, weight: "medium", fill: luma(80))[#course] \
      ]
      #text(size: 1.6em, weight: "bold")[#title]
    ],
    align(right)[
      #text(weight: "medium")[#author] \
      #if due != none [
        #text(fill: luma(90))[Due: #due]
      ] else [
        #text(fill: luma(90))[#datetime.today().display("[month repr:long] [day], [year]")]
      ]
    ]
  )

  v(6pt)
  line(length: 100%, stroke: 1.2pt + black)
  v(12pt)

  body
}
