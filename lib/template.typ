#let undergrad-lab-report(
  title: "",
  subtitle: "",
  students: (),
  group: "",
  professor: "",
  teaching-assistant: "",
  date: datetime.today(),
  body,
) = {
  set document(
    date: date,
    author: students,
    title: title,
    description: subtitle,
  )
  set page(paper: "us-letter")
  set text(size: 14pt)

  // Title Page
  align(center + horizon, {
    text(size: 32pt, weight: "bold", title)
    linebreak()
    v(0em)
    text(size: 16pt, subtitle)
    divider()
    v(2em)
    table(
      columns: 2,
      stroke: none,
      align: (x, _) => { if x == 0 { right } else { left } },
      ..students
        .enumerate()
        .map(it => {
          ([*Student #{ it.at(0) + 1 }:*], it.at(1))
        })
        .flatten(),

      [*Group Number:*], [#group],
      [*Professor:*], [#professor],
      [*TA:*], [#teaching-assistant],
      [*Date:*], [#date.display("[month]/[day]/[year]")],
    )
  })
  pagebreak()

  counter(page).update(1)
  set page(numbering: "1", header: {
    set text(size: 10pt)
    grid(
      columns: (100% - 8em, 8em),
      align: (x, y) => if x == 0 { left } else { right },
      title, group,
    )
    v(-1.75em)
    divider()
  })

  align(center, text(size: 19pt, weight: "bold", title))

  set par(justify: true)
  set heading(numbering: "1")
  show heading: it => {
    set text(size: if it.level == 1 { 18pt } else { 14pt })
    if (
      it.level == 2
        or it
          .body
          .fields()
          .values()
          .flatten()
          .any(it => if type(it) == str {
            it.contains("Appendix")
          } else if type(it) == content {
            it.text.contains("Appendix")
          })
    ) {
      it.body
      linebreak()
    } else {
      it
    }
  }

  show figure: set block(breakable: true)
  show figure.caption: it => context {
    set text(size: 12pt)
    box(width: 75%, {
      strong(it.supplement)
      if it.counter != none [ *#it.counter.display()*]
      if measure(it.body) != 0pt [*:* #it.body]
    })
  }

  show raw: set text(font: "Maple Mono", size: 10pt)

  show link: it => {
    set text(fill: blue)
    underline[#it]
  }
  show ref: it => strong(it)
  show table.header: it => {
    set table.cell(fill: luma(80%))
    it
  }
  set table(align: (x, y) => if y == 0 { center } else { left } + horizon)
  body
}
