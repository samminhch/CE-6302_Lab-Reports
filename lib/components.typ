#import "@preview/valkyrie:0.2.2"

#let problem(
  title,
  subtitle: none,
  padding: 0.25em,
  radius: 4pt,
  stroke: 1pt,
  body,
) = {
  title = str(title)
  subtitle = if subtitle != none { str(subtitle) } else { none }

  let problem-box = context {
    // Measure bare text height to size vertical line
    let title = strong("Step " + title)
    let title-box-height = measure(box(height: 1em + padding)).height

    let title-content = {
      title
      if subtitle != none {
        h(padding)
        box(
          baseline: measure(title).height / 2,
          line(
            length: 100%,
            angle: 90deg,
          ),
        )
        h(padding)
        subtitle
      }
    }

    let height-single-line = (
      measure(body).height < title-box-height
        and measure(box(width: 100% - measure(body).width)).width > 0pt
    )

    // Title box with baseline aligned to inner text
    let title-block-radius = if height-single-line {
      radius
    } else {
      (top-left: radius, bottom-right: radius)
    }
    let title-block = rect(
      height: title-box-height,
      radius: title-block-radius,
      stroke: stroke,
      inset: (left: padding, right: padding, top: if subtitle == none {padding} else {0pt}, bottom: 0pt),
      outset: 0pt,
      title-content,
    )

    box(
      height: if height-single-line {
        title-box-height
      } else { auto },
      width: 100%,
      radius: radius,
      stroke: stroke,
      inset: padding,
      {
        set par(justify: true)
        // Render inline with body. Both share baseline.
        place(dy: -padding, dx: -padding, title-block)
        h(measure(title-block).width)
        body
      },
    )
  }

  [
    #figure(
      kind: "Step",
      supplement: [Step],
      [
        #set align(left)
        #set enum(numbering: "(A.1)")
        #show heading: it => {
          set text(size: 0.75em)
          it.body
        }
        #problem-box
      ],
    )
    #label("step:" + title)
  ]
}