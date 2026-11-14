#import "@preview/unify:0.8.1": qty, num
#import "@preview/zebraw:0.6.3": zebraw
#show: zebraw

#import "common.typ"

// Shorthands
#let i2c = [I#super[2]C]

#common.title[Lab 10---#i2c Communication between the TI MSP432 and Adafruit PCF8523]
= Introduction
The main objective of this lab was to configure an `MSP432` LaunchPad as an #i2c master and then establish a connection between it and the Adafruit `PCF8523` realtime clock. Two programs were written to explore reading and writing data with the #i2c protocol. The firmware was verified by looking at the #i2c packets using the AD2 (Analog Discovery 2) WaveForms software.

#i2c uses a serial data line (`SDA`) and serial clock line (`SCL`). The `SDA` carries the actual data between the master and slave and the `SCL` carries the clock signal that synchronizes the data transfer. The master initiats the transfer with `START` then transmits a slave address then a read/write bit. Pull-up resistors keep `SDA` and `SCL` lines `HIGH` when no device pulls them `LOW` and the `MSP432` uses address `0x68` to communicate with the RTC and the register address `0x03` to access its seconds value. The calculation for `SCL` is calculated below:

$ f_mono("SCL") = f_mono("SMCLK")/mono("BRW") = qty(6, "MHz")/60 = qty(100, "kHz") $

= Procedure

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
= Appendix II---#i2c Source Code

#figure(
  common.code("../labs/msp432/i2c_common.h", title-full: false, lang: "c"),
  caption: [#i2c shared header among the reader and writer],
)<listing:common>
#figure(
  common.code("../labs/msp432/i2c_reader.c", title-full: false, lang: "c"),
  caption: [#i2c reader firmware],
)<listing:writer>
#figure(
  common.code("../labs/msp432/i2c_writer.c", title-full: false, lang: "c"),
  caption: [#i2c writer firmware],
)<listing:reader>
