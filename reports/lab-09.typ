#import "common.typ"
#import "@preview/unify:0.8.1": num, qty

#let pct(n) = qty(n, "%")

#import "@preview/zebraw:0.6.3": zebraw
#show: zebraw

#common.title[Lab 09---SPI Communication between two MSP432 boards]

= Introduction
The main objective of this lab was to implement a Serial Peripheral Interface SPI communication between two `MSP432P401R` LaunchPads. We set one board to operate as a master transmitter and the other one as slave receiver. Every time we pressed the `P1.4` switch of the master board it sent one byte from a four-byte array. The slave board then received the byte and displayed its value in the console and then changed the LED lights on the board to show that the bytes had been received properly.

SPI is basically a synchronous serial communication protocol in which the master creates a shared clock to synchronize data transfer to the slave. How it works is that `SCLK` carries the clock, MOSI carries data from master to slave, and MISO carries data from slave to master. In this experiment we used a three-pin SPI configuration without a separate chip- select signal. The clocks on both the LaunchPads had matching polarity, clock phase, byte length and bit order. In the conventional SPI Mode 0, the clock was idle low, and the data was sampled on the rising edge and we saw data changed on the falling edge. We determined the master’s SPI clock frequency by the source-clock and baud rate divider with the below equation: $ f_"SPI"=f_"SMCLK"/"BRW" $ Given $f_"SMCLK"=qty(6, "MHz")$ and our target of $f_"SPI"=qty(3, "MHz")$, we needed $"BRW"=2$.

= Procedure
The connections of the two Lauchpads are specified in @table:connections.

The SPI firmware contains a shared header (@listing:common) that both the SPI transmitter (@listing:transmitter) and receiver (@listing:receiver) would use. This shared header contains the SPI pins that each board would connect to, their shared SPI configuration, as well as the packet data and length that would be sent and received between the two boards.

After uploading the firmware, the SPI transmitter's button `P1.4` is to be pressed at least 5 times to verify that the entire sequence was sucessfully transmitted and repeated.

#block(width: 100%, breakable: false)[
  #figure(
    table(
      columns: 3,
      table.header([*Signal*], [*Master Board*], [*Slave Board*]),
      `SCLK`, `P1.5`, `P1.5`,
      `MOSI`, `P1.6`, `P1.6`,
      `GND`, `GND`, `GND`,
    ),
    caption: [SPI wiring and control pins.],
  )<table:connections>
]

#figure(
  table(
    columns: 3,
    [*Button Press*], [*Expected Byte*], [*Received Byte*],
    `1`, `0x7D`, `0x7D`,
    `2`, `0xAA`, `0xAA`,
    `3`, `0x33`, `0x33`,
    `4`, `0x77`, `0x77`,
    `5`, `0x7D`, `0x7D`,
  ),
  caption: [Expected and observed data sequence from the SPI receiver.]
)

#figure(
  image("../assets/lab09/spi-output.png", width: 80%),
  caption: [SPI receiver output]
)

= Discussion
We saw that the values that we observed were the same as we expected as per our table. This showed that the master transmitted the intended bytes correctly and the slave received them correctly. On the fifth press we got `0x7D` again which verified that the array index wrapped around after four transmissions.

We were able to see that the interrupts allowed the master to respond to the switch presses and the slave responded to the received data without having to continuously check for these events in the main loop. TXIFG was able to demonstrate that the transmit buffer was able to accept another byte but it does not by itself tell us whether the transmission was completed over the wire. So then for confirmation we used `RXIFG` which showed that the received data was available for reading.

We observed that reliable communication depended on correct wiring and carefully setting the SPI settings. If even the slightest clock-phase or bit order mismatch was there then it would show incorrect received values. We had to tackle mechanical switch bounce during testing too as it sometimes caused multiple interrupts from one press which showed repeated or skipped values. We were able to troubleshoot and fix all that in the end. We also understood the importance of taking #qty(6, "MHz") as `SMCLK` in the final implementation for a divider of 2 to give us a #qty(3,"MHz") SPI clock.

While we were testing, we observed the sequence `0x7d`, `0xAA`, `0x33`, `0x77` on the terminal after flashing both master and slave code on both the MSP432 LaunchPads. We pressed the button of the master LaunchPad 5 times and on the fifth button press `0x7D` appears again. The bred LED lights up in master MSP432 which shows that the data has been successfully transmitted and the slave MSP green LED is toggled each time it receives a byte from the master.

== Conclusion
In conclusion the SPI communication between the two MSP432 boards was successfully demonstrated. We were able to observe and record that the slave received the 5 bytes sequence and the sequence then repeated after the fourth byte. Therefore, we successfully met all the criteria for completing this lab successfully. We were able to show successful communication between two MSP432 boards. The master board was able to send the correct sequence to the slave which was `0x7D`, `0xAA`, `0x33`, `0x77` and the sequence started repeating itself after the fifth button press (i.e. it showed `0x7D` again).

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
= Appendix II---SPI Source Code

#figure(
  common.code("../labs/msp432/spi_common.h", title-full: false, lang: "c"),
  caption: [SPI shared header among the transmitter and receiver],
)<listing:common>
#figure(
  common.code("../labs/msp432/spi_transmitter.c", title-full: false, lang: "c"),
  caption: [SPI transmitter source code],
)<listing:transmitter>
#pagebreak()
#figure(
  common.code("../labs/msp432/spi_receiver.c", title-full: false, lang: "c"),
  caption: [SPI receiver source code],
)<listing:receiver>
