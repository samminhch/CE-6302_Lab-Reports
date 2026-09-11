#import "@preview/cheq:0.4.0": checklist
#show: checklist

#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.10": *

#show: codly-init
#codly(languages: codly-languages)

#import "common.typ"

= Introduction
The objective of this lab was to make us familiar with the MSP432 board and
BoosterPack. The main goal was to read the analog axes x and y of the
BoosterPack joystick with the MSP432P401R ADC which is analog to digital
converter. We then had to display live readings on the LCD and convert those
readings to a smaller 0-9 range and contain those values within the given
ranges. The lab also emphasized how changing the ADC resolution from 10-bit to
12-bit and further to 14-bit affected the numerical readings. It was to be
observed how each of the joystick axis was acting like a potentiometer which
produced a voltage between 0V-3.3V. The intention was to see that with the
12-bit resolution the ADC divided the range using the formula $2^n$ that is
mathematically $2^12 = 4096$ levels and the analog would give range from 0
to 4095. The use of the ```cpp map()``` function was established that how
function linearly rescaled the selected raw range to a fine tune range of 0
to 9. The use of ```cpp constrain()``` function was established that how it
eliminated any mapped result that was outside of this range which would be below
0 or above 9. The target was to see howe increasing or decreasing the resolution
changed the available levels so 10-bit gives us 1024 levels, 12-bit gives us
4096 levels, and 14-bit gives us 16384 levels.

= Procedure
The setup and installation steps are to be completed as-mentioned in the manual.
Once that was finished, the TI LaunchPad's basic functionality was checked using
the Blink example sketch, and the TI Boosterpack was mounted on top for the
Joystick code.

First, code was uploaded to display the title (i.e. "Joystick") on the LCD. Once
that was shown to be working, the sketch was then modified to read the raw input
values from the joystick with ```cpp analogRead()```, whose resolution was set
via. ```cpp analogReadResolution()```. Once the raw values were successfully
displayed on the Boosterpack's LCD, the sketch was modified to also display the
raw values in a 0-9 range suing the ```cpp map()``` function and setting
`RAW_MIN` and `RAW_MAX`. The result that followed showed the values 0-9 on the
LCD, but when the raw values read were outside of the range of `RAW_MIN` and
`RAW_MAX`, the output would also fall outside the range of 0-9. Finally, the
code was modified to use the ```cpp constrain()``` function as well as the
```cpp map()``` function to ensure that the values will stay from 0-9.

The sketch was ran on 10-bit resolution, 14-bit resolution, and 10-bit
resolution to observe and compare readings. The nominal (centered) values of the
12 and 14 bit resolutions can be seen on @figure:nominal-12bit and
@figure:nominal-14bit.

#figure(
  rotate(-90deg, image("../assets/lab01/output.jpg", width: 2.5in), reflow: true),
  caption: [LCD output: title displays "Joystick", contains raw analog data and
    scaled values from 0-9],
)<figure:lcd-output>

#figure(
  image("../assets/lab01/nominal-12bit.png", height: 30%),
  caption: [Nominal values of the joystick for 12-bit resolution],
)<figure:nominal-12bit>

#figure(
  image("../assets/lab01/nominal-14bit.png", width: 60%),
  caption: [Nominal values of the joystick for 14-bit resolution],
)<figure:nominal-14bit>

#pagebreak()
= Discussion

It was observed that the joystick readings changed without interruption as we
kept on moving the stick. This basically demonstrated how the physical position
was being converted into an ADC code. We could see that at 12-bit resolution the
expected numerical range was from 0-4095 and our observed values at the center
were 2009 on the x-axis and 2058 on the y-axis and when we moved the joystick to
the right the y-axis value was 4096 and x -axis 0 and moving the joystick to the
left gave us y-axis value of 0 and x-axis 4069. These values were observed both
on the LCD and the serial monitor. We could see small fluctuations while the
joystick remained untouched and that was accounted for as normal ADC noise. We
understood how the ```cpp map()``` function was used to convert the raw working
range of 1000-3000 to 0-9 range. This much more simple range can help pinpoint
the exact joystick position instead of a very lengthy ADC code. We also observed
that before we added the ```cpp constrain() ``` function the `RAW_MIN` or
`RAW_MAX` was making the mapped result to be negative or greater than 9 and this
was because the ```cpp map() ``` function was performing a liner rescaling and
did not check whether the input was inside the specified input range. This meant
that we definitely had to add the ```cpp constrain() ``` function to make sure
that the converted values remained between 0-9 even if the raw joystick reading
was going beyond this range. This made the output much more reliable and can be
applicable for control logic. The 10-bit resolution gave us a center value of
512 at x-axis and 508 on y-axis, at 12-bit we got x-axis value 2009 and y-axis
value 2058 and similarly at 14-bit we got 8304 on x-axis and 8038 on y-axis.
These values are different based on the different resolutions because an n-bit
ADC gives us $2^n$ codes over the same voltage range. This means that the same
joystick voltage gives a larger numerical code with higher resolution and vice
versa and this exactly what we observed and verified in the lab. In conclusion
we can say that this lab basically helped us understand a common embedded
systems signal path where a physical analog input can be sampled by an ADC for
numerically processing and giving the user simpler ranges to read. The LCD on
the BoosterPack gave instant visual confirmation for the raw measurements that
the serial monitor was already showing and recording. We were able to
successfully display and read the live joystick values and as a result map them
to a 0-9 scale using the ```cpp constrain() ``` function. Therefore, the effects
of the ADC resolution were achieved and observed thoroughly.

== Conclusion

The lab helped us successfully understand how joystick movement can be observed
and read using the ADC and then further displayed on the LCD. We also
accomplished an understanding of how the map () and constrain () functions were
used to convert the raw readings to a much more simpler and controlled range of
0-9.

#set heading(numbering: none)

#pagebreak()
= Appendix I --- Use of Large Language Models
#table(
  stroke: none,
  columns: 3,
  [*Was an LLM used for this project?*], [- [ ] Yes], [- [x] No],
)

#pagebreak()
= Appendix II --- Source Code
#figure(
  common.code("../labs/lab01/lab01.ino", title-full: false, lang: "cpp"),
  caption: [Source code for this laboratory---12-bit resolution],
)<listing:12-bit>

#figure(
  common.code("../labs/lab01/lab01-14bit.ino", title-full: false, lang: "cpp"),
  caption: [Source code for this laboratory---14-bit resolution],
)<listing:14-bit>
#figure(
  common.code("../labs/lab01/lab01-10bit.ino", title-full: false, lang: "cpp"),
  caption: [Source code for this laboratory---10-bit resolution],
)<listing:10-bit>
