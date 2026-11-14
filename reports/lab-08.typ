#import "common.typ"
#import "@preview/unify:0.8.1": qty, num

#import "@preview/zebraw:0.6.3": zebraw
#show: zebraw

#let pct(n) = qty(n, "%")

#common.title[Lab 08---UART Communication between two MSP432 boards]

= Introduction
The main objective of this lab was to help us how to configure a UART communication between two `MSP432P401R` LaunchPads so that the keyboard commands that we give from the computer can control the RGB LED on the receiving board. The first board acts as a transmitter and is connected to the computer terminal through `EUSCI_A0`. Then the second board is connected using `EUSCI_A2`. The main purpose was to press `r`, `g`, or `b` on the keyboard and the LEDs red, green and blue to light up on the receiver LaunchPad. If any other character on keyboard is pressed, then the LED blinks twice.

We observed that UART transmitted serial data without a shared clock line, so both the devices basically had to use same baud rate of 9600 and same frame formats. We arrived at this number as the code we used had `SMCLK`, $#raw("BRW") = 19$, $#raw("BRF") = 9$, and 16#sym.times oversampling. So keeping in mind `SMCLK` to be #qty(3, "MHz"), $N = num("3E6") / num("9.6E3") = 312.5$ and $#raw("BRW") = floor(N / 16) = 19$. We were given the first-stage modulation and $#raw("BRS") = 0$, so the baud rate becomes $num("3e6") / (16 × 19 + 9) = 9,584.7 "baud"$, about #pct(0.16) below #num("9.6E3"). The nominal bit period was #qty(104.17, "us"). We saw that the UART configuration selected eight data bits with no parity and a one stop bit having the least significant bit which was being transmitted first.

= Procedure
We first downloaded the correct version of code composer and then opened two separate CCS projects one for transmitter and one for receiver. We connected the transmitter to the laptop using USB cable and the receiver was first flashed and then it was powered from the wall outlet. We also made inter-board connections cross TX to RX and connected their ground as well. So basically we connected pin `P3.3` of the transmitter to `P3.2` of the receiver and connected the ground of TX with ground of RX.

#block(breakable: false, figure(
  table(
    columns: 3,
    table.header([*Signal*], [*Pin*], [*Purpose*]),
    [Forward UART], [Transmitter `P3.3` #sym.arrow\ Receiver `P3.2`], [Command transmission],
    [Ground], [Transmitter `GND` #sym.arrow\ Receiver `GND`], [Common reference voltage],
    [Receiver RGB LED], [`P2.0`, `P2.1`, `P2.2`], [RGB],
    [Receiver Error LED], [`P1.0`], [Two blinks for an invalid command],
  ),
  caption: [Signal connections]
))

We basically assigned `EUSCI_A0` for the transmitter to computer terminal link and `EUSCI_A2` for the board to board link. In the transmitter code it stopped the watchdog timer to prevent it from watchdog reset during execution. We held each UART in software reset while the clock and baud settings were configured and then they were released from reset. The transmitter enabled `EUSCI_A0` to receive the interrupt in `NVIC` and then enable global interrupts. After that we initialized the ```c sendString()``` and displayed the terminal prompt. So when the character arrived from the keyboard ```c EUSCIA0_IRQHandler()``` read `RXBUF` and then forwarded that through `EUSCI_A2` using ```c send_char()```. Then it echoes it back to the computer using carriage return and newline using ```c send_string()```. Both the functions then poll `TXIFG` before they write `TXBUF` to avoid overwriting a busy transmission buffer.

The receiver then configures P1.0 which is the receiver error LED and `P2.0`#sym.arrow`P2.2` which are GPIO outputs for the red, green and blue LEDs. Initially it switches all the LEDs off then we enabled `EUSCI_A2` that is receiver interrupt and the NVIC interrupt. The ```c EUSCIA2_IRQHandler()``` then checked RXIFG and read RXBUF which cleared the receive flag. This means that the RGB outputs were cleared first after that we used a switch statement to form the logic for the requested color. We also made sure that any invalid character executed four toggles of `P1.0` separated by software delays to show the LED blinking twice.

We then ran both the programs and opened the transmitter terminal at 9600 baud with 8 data bits with no parity, one stop bit and no flow control. We then sent `r` , `g`, `b` and one invalid character at a time to compare the receiver response. We then made the table below to confirm our observations. We also took screenshots and recorded our video.

#figure(
  table(
    columns: 3, align: (x, y) => if x == 0 or y == 0 {center} else {left} + horizon,
    table.header([*Input*], [*Expected Response*], [*Observed Response*]),
    `r`, [Red on; green and blue off], [Red on; green and blue off],
    `g`, [Green on; red and blue off], [Green on; red and blue off],
    `b`, [Blue on; red and green off], [Blue on; red and green off],
    `n`, [RGB off; error LED blinks twice], [RGB off; error LED blinks twice]
  ),

  caption: [Expected and observed command responses of the UART receiver.]
)

#figure(
  image("../assets/lab08/uwart-connection.png", width: 60%),
  caption: [Two LaunchPads showing crossed UART connections and common ground.]
)<figure:uart-connection>

#figure(
 image("../assets/lab08/red-led.png", width: 60%),
 caption: [Terminal command `r` and the corresponding receiver response.]
)

#figure(
 image("../assets/lab08/green-led.png", width: 60%),
 caption: [Terminal command `g` and the corresponding receiver response.]
)

#figure(
 image("../assets/lab08/blue-led.png", width: 60%),
 caption: [Terminal command `b` and the corresponding receiver response.]
)

#figure(
 image("../assets/lab08/error-led.png", width: 60%),
 caption: [Terminal command `n` and the corresponding receiver response.]
)

= Discussion
We observed that the code implemented a one way command path from the computer to the receiver. We were able to confirm that the character was received locally from keyboard and then it was forwarded by software and we saw this in the transmitter’s echo terminal. We also made a very important observation that although the transmitter and receiver boards were both connected using jumper wires, the receiver was not sending back a response it was just acknowledging and accepting responses from the transmitter. We saw that reading `RXBUF` in each handler service received the data, while polling `TXIFG` ensured that each outgoing byte was written only when its transmitter buffer was ready.

The code implementation was very simple it selected a color rather than toggling that color on successive valid commands. We saw that each received character cleared the RGB outputs before and then the selected output was set. Only lower-case `r`, `g` and `b` were acceptable; we tested this using upper case `R`, `G`, and `B`, which gave us two LED blinks which was indication of invalid characters. We did not implement yellow and the delay loop depended on the software so its duration was not aa measured or precise timing interval.

We understood how we need to consider several details before interpreting a program. We configured the receiver program using `UART2` and `P3.2`/`P3.3`. This means that the transmitter enabled UART2 to receive interrupts locally but it did not enable its `NVIC` interrupt or give an `A2` receiver handler. This means that the return path was unused and we only used the forward path. The statements clearing the `IFG` used the `RXIFG` flag symbol and for clock we set it at #qty(3, "MHz") via `SMCLK`, and neither of the main functions explicitly initializes it. Lastly we observed that long software delays inside the receiver interrupt were also preventing timely handling of the subsequent characters sometimes during testing. So we started sending commands individually with patience and then we were able to successfully implement this TX/RX UART communication between two Launchpads.

#pagebreak()
== Conclusion
In conclusion the given programs implemented the UART-based RGB LED control system using two MSP432 boards. We also used receiver interrupts and transmitter buffer polling to help us make a successful communication system. The code set red, green and blue as valid commands and two error LED blinks for any other input which we characterized as invalid input. We filled out our observation table by confirming that if we pressed r, g and b on our laptop we could see red, green and blue corresponding LED light up on the receiver LaunchPad. And if anything other than these commands was pressed then two error blinks were observed on the receiver LaunchPad. Hence our UART-based communication implementation was successful.

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
  common.code("../labs/msp432/uart-transmitter.c", title-full: false, lang: "c"),
  caption: [UART transmitter source code],
)<listing:uart-transmitter>
#figure(
  common.code("../labs/msp432/uart-receiver.c", title-full: false, lang: "c"),
  caption: [UART receiver source code],
)<listing:uart-receiver>
