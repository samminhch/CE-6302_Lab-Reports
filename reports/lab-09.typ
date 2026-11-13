#import "common.typ"
#import "@preview/unify:0.8.1": qty, num

#let pct(n) = qty(n, "%")

#common.title[Lab 09---SPI Communication between two MSP432 boards]

= Introduction
The main objective of this lab was to implement a Serial Peripheral Interface SPI communication between two `MSP432P401R` LaunchPads. We set one board to operate as a master transmitter and the other one as slave receiver. Every time we pressed the `P1.4` switch of the master board it sent one byte from a four-byte array. The slave board then received the byte and displayed its value in the console and then changed the LED lights on the board to show that the bytes had been received properly.

SPI is basically a synchronous serial communication protocol in which the master creates a shared clock to synchronize data transfer to the slave. How it works is that `SCLK` carries the clock, MOSI carries data from master to slave, and MISO carries data from slave to master. In this experiment we used a three-pin SPI configuration without a separate chip- select signal. The clocks on both the LaunchPads had matching polarity, clock phase, byte length and bit order. In the conventional SPI Mode 0, the clock was idle low, and the data was sampled on the rising edge and we saw data changed on the falling edge. We determined the master’s SPI clock frequency by the source-clock and baud rate divider with the below equation: $ f_"SPI"=f_"SMCLK"/"BRW" $ Given $f_"SMCLK"=qty(6, "MHz")$ and our target of $f_"SPI"=qty(3, "MHz")$, we needed $"BRW"=2$.

== Procedure
We first defined a shared header (@listing:common) that both the SPI transmitter (@listing:transmitter) and receiver (@listing:receiver) would use. This shared header contains the SPI pins that each board would connect to, their shared SPI configuration, as well as the packet data and length that would be sent and received between the two boards. 

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
  // common.code("../labs/msp432/spi-receiver.c", title-full: false, lang: "c"),
  ```c
  ```,
  caption: [SPI shared header among the transmitter and receiver],
)<listing:common>
#figure(
  // common.code("../labs/msp432/spi-transmitter.c", title-full: false, lang: "c"),
  ```c
  ```,
  caption: [SPI transmitter source code],
)<listing:transmitter>
#figure(
  // common.code("../labs/msp432/spi-receiver.c", title-full: false, lang: "c"),
  ```c
  ```,
  caption: [SPI receiver source code],
)<listing:receiver>