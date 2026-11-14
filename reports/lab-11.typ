#import "@preview/unify:0.8.1": num, qty, unit
#import "lab-11-plot.typ": energy-diagram, power-diagram, lpm0-stats, lpm3-stats
#import "common.typ"

#import "@preview/zebraw:0.6.3": zebraw
#show: zebraw


#common.title[Lab 11---Low Power Mode, WDT, and EnergyTrace+]
= Introduction

= Procedure

#figure(power-diagram)
#figure(energy-diagram)

#figure(
  table(
    columns: 3,
    table.header([*Mode*], [*Power #unit("mW")*], [*Current (#unit("uA"))*]),
    [AM LED ON (`lpm0`)], str(lpm0-stats.led-on), [#{1000 * lpm0-stats.led-on / 3.3}],
    [AM LED ON (`lpm3`)], str(lpm3-stats.led-on), [#{1000 * lpm3-stats.led-on / 3.3}],
    [AM LED OFF (`lpm0`)], str(lpm0-stats.led-off),  [#{1000 * lpm0-stats.led-off / 3.3}],
    [AM LED OFF (`lpm3`)], str(lpm3-stats.led-off), [#{ 1000 * lpm3-stats.led-off / 3.3}],
    [Sleep (`lpm0`)], str(lpm0-stats.sleep), [#{1000 * lpm0-stats.sleep / 3.3}],
    [Sleep (`lpm3`)], str(lpm3-stats.sleep), [#{1000 * lpm3-stats.sleep / 3.3}],
  )
)

= Discussion

== Conclusion

#pagebreak()
= Appendix I---Use of Large Language Models
#table(
  stroke: none,
  inset: (left: 0pt, right: 1em),
  columns: 3,
  [Was an LLM used for this project?],
  [#sym.square.stroked.big Yes],
  [#sym.ballot.check No],
)

#pagebreak()
= Appendix II---UART Source Code

#figure(
  common.code("../labs/msp432/low-power-mode.c", title-full: false, lang: "c"),
  caption: [Firmware for the low power mode],
)<listing:common>

#pagebreak()
#figure(
  common.code("lab-11-plot.typ", title-full: false, lang: "typst"),
  caption: [Typst code to plot Energy and Power plots],
)
