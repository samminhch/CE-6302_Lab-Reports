#import "common.typ"

#import "@preview/cheq:0.4.0": checklist
#show: checklist

#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.10": *

#show: codly-init
#codly(languages: codly-languages)


= Introduction

= Procedure

#figure(
  caption: [Sample, delay, and baud rates],
  table(
    columns: 3,
    common.table-header([], [Value], [Calculation]),
    [*Sample Rate*], $2 "Hz"$, [],
    [*Delay*], $500 "ms"$, $(1000 frac("ms", "sec", style: "skewed")) / (2"Hz")$,
    [*Baud Rate*], $115200$, [Good starting value],
  )
)<table:rates>

#figure(
  caption: [Calibration readings, and $k$ derived from them],
  table(
  align: (x, y) => if x == 0 or y <= 1 {center} else {left} + horizon,
    columns: 5,
    common.table-header(
      table.cell(rowspan: 2)[Axis],
      table.cell(colspan: 2)[measured],
      table.cell(colspan: 2)[computed],
      $N_"up"$,
      $N_"dn"$,
      $N_0$,
      $k$,
    ),

    $X$, `2921`, `1286`, `2103.5`, `817.5`,
    $Y$, `2846`, `1242`, `2,044`, `802`,
    $Z$, `2878`, `1240`, `2059`, `819`,
  ),
)<table:calibration-readings>

#figure(
  caption: [Accelerometer: raw vs. calibrated measurements],
  table(
    columns: 3,
    common.table-header([Measurement], [Raw (counts)], [Calibrated ($g$)]),

    [$X$, board flat], `2098`, `0.03`,
    [$Y$, board flat], `2180`, `0.067`,
    [$Z$, board flat], `2882`, `0.043`,
    [Length of the vector, board flat], `4175`, `0.08`,
    [Length of the vector, tilted], `3817`, `1.08`,
  ),
)<table:raw-vs-calibrated>

#figure(
caption: [Threshold test values and measurements],
  table(
    columns: 3,
    common.table-header(
      [Threshold used ($g$)],
      [Falls detected (of $5$)],
      [False alarms observed],
    ),

    $3.00$, $0$, $0$,
    $2.50$, $3$, $3$,
    $1.50$, $4$, $4$,
  ),
)<table:fall-measurements>

= Discussion

*What was wrong with the uncalibrated plot?*

*What does $abs(a)$ stay near $1"g"$ at any tilt, and why is that a stronger check on your calibration than the flat reading alone?*

*Why was $2 "Hz"$ too slow for fall detection? Support the answer with the free-fall time.*

*Justify your final threshold, and state which error it favours: a missed fall or a false alarm.*

== Conclusion

#pagebreak()
= Appendix I
#table(
  stroke: none,
  columns: 3,
  [*Was an LLM used for this project?*], [- [ ] Yes], [- [x] No],
)

#pagebreak()
= Appendix II --- Source Code
#figure(
  common.code("../labs/lab02/lab02.ino", title-full: false, lang: "cpp"),
  caption: [Arduino sketch that reads and calculates acceleration],
)<listing:sketch>

#figure(
  common.code("../labs/lab02/plot_raw.py", title-full: false),
  caption: [Code to plot the raw accelerometer data],
)<listing:plot>

#figure(
  common.code("../labs/lab02/plot_calibrated.py", title-full: false),
  caption: [Code to plot the calibrated accelerometer data with fall detection],
)<listing:plot>
