#import "common.typ"
#import "../lib/components.typ"
#import "@preview/unify:0.8.1": qty
#import "@preview/subpar:0.2.2"
#import "@preview/zebraw:0.6.3": zebraw

#show: zebraw
#set math.frac(style: "skewed")

#common.title[Lab 07---Timer Practice for MSP-EXP432P401R Launchpad]

= Introduction
The main objective of this lab was to help us understand how to configure `Timer_A0` on the MSP-EXP432P401R LaunchPad. We did that in order to generate a #qty(10, "Hz") pulse width modulation (PWM) square wave with a duty cycle of #qty(50, "%"). We had to examine three output modes which were mode 2 (`toggle/reset`), mode 4 (`toggle`), and mode 7 (`reset/set`). We had to do that under both `up` and `up/down` counting and record all six of the configurations.

We were made to familiarize ourselves with Timer and how it uses a clock source of `ACLK` (#qty(32768, "Hz")). We also saw how `TACCR0` was responsible for controlling the counting limit and how `TACCR2` was used to compare the events that shaped the output. The target period was $T = 1/f = 1/10 = qty(100, "ms")$ and from #qty(50, "%") duty cycle we got #qty(50, "ms") high and low. We saw that in the up mode the count per period was given by $32768/10 = 3276.8$ ticks. Similarly, in the `up/down` mode the count traversed the selected limit by twice. So whichever mode we selected the output waveform was made accordingly and specifically for toggle we saw that it required two count cycles for the full output period.

= Procedure
Firstly, we made jumper wire connections (@figure:hardware-connection) between the MSP432 LaunchPad BoosterPack and `P2.5` which was the `Timer_A0` output and `P2.3` which was the digital input. We used the `S2` button at `P1.4` to get an LCD waveform update. We modified the given msp432 timer PWM starter code to select `ACLK`, configure the output modes for `Timer_A0` counting and set the `TACCR0` and `TACCR2` for each of those cases.

We programmed each of the six combinations and checked them using the waveform that was shown on the LaunchPad LCD. We compared each of the modes duty cycle and expected period with the waveform that was actually being displayed on the LCD. Our goal was to get #qty(50, "%") duty cycle and #qty(10, "Hz") frequency. The code we started with had the Timer starting to count till 6553 and halfway through the output changed from `HIGH` to `LOW` and then it was repeated. So, we set the initial `CCR0` value to $32768/5 = 6553$ and `CCR2` value to $6553/2 = 3276$ which gave us #qty(5, "Hz") with #qty(50, "%") duty cycle on the LCD. Then for step 1 we had to do `UP-MODE=7` (`RESET/SET`) for which we set the `CCR0` to 3277 and `CCR2` to $3277/2=1638$. This meant that the timer finished each cycle in half the time. Then we did `UP-MODE=4`(`TOGGLE`) for step 2 which was first ON then OFF if the button was pressed and in this step we completed two timer rounds for 1 output cycle and set `CCR0` to 1638 and `CCR2` to 819. Then for step 3 we did `UP-MODE=2` (`TOGGLE/RESET`) for which the output we got completed a full cycle in one timer round again so we increased `CCR0` to 3277 and `CCR2` to 1638 back up for #qty(10, "Hz") frequency. We saw that the signal stayed `LOW` during half the period and HIGH during the second half. We followed the same logic for `UP/DOWN` mode and recorded our values. We carefully took screenshots of everything and recorded our video accordingly.

The outputs for each step is seen at @figure:output-results.

#figure(
  image("../assets/lab07/hardware-connection.jpg", width: 50%),
  caption: [Hardware connection],
)<figure:hardware-connection>

#figure(
  image("../assets/lab07/step1-out.jpg", width: 50%),
  caption: [Step 0 (example) output],
),

#subpar.grid(
  columns: 2,
  figure(
    image("../assets/lab07/step1-out.jpg"),
    caption: [Step 1 output],
  ),
  figure(
    image("../assets/lab07/step2-out.jpg"),
    caption: [Step 2 output],
  ),

  figure(
    image("../assets/lab07/step3-out.jpg"),
    caption: [Step 3 output],
  ),
  figure(
    image("../assets/lab07/step4-out.jpg"),
    caption: [Step 4 output],
  ),

  figure(
    image("../assets/lab07/step5-out.jpg"),
    caption: [Step 5 output],
  ),
  figure(
    image("../assets/lab07/step6-out.jpg"),
    caption: [Step 6 output],
  ),

  caption: [Output results for steps 1-6],
  label: <figure:output-results>,
)


#block(breakable: false)[#figure(
  table(
    columns: 6,
    table.header(
      [*Mode*],
      [*Output Mode*],
      [*`TACCR0`*],
      [*`TACCR2`*],
      [*$f$*],
      [*Duty\ Cycle*],
    ),

    `UP`, [Set/Reset (7)], $3276$, $1638$, qty(10, "Hz"), qty(50, "%"),
    `UP`,
    [Toggle (4)],
    $3276/2=1368$,
    $1638/2=819$,
    qty(10, "Hz"),
    qty(50, "%"),

    `UP`,
    [Toggle/Reset (2)],
    $1638*2=3276$,
    $819*2=1638$,
    qty(10, "Hz"),
    qty(50, "%"),

    `UP/DOWN`,
    [Toggle/Reset (2)],
    $3276/2=1368$,
    $1638/2=819$,
    qty(10, "Hz"),
    qty(50, "%"),

    `UP/DOWN`, [Toggle (4)], $1368$, $819$, qty(10, "Hz"), qty(50, "%"),
    `UP/DOWN`, [Set/Reset (7)], $1368$, $0$, qty(10, "Hz"), qty(50, "%"),
  ),
  caption: [Configuration and verification log],
)<table:results>]

= Discussion
We observed that the timer period depends on the `ACLK` frequency, the counting direction and whatever the output behaved like according to the transitions that we made to it. We saw that for a up mode `reset/set` or `toggle/reset` waveforms had a frequency of #qty(10, "Hz"), and the period needed about 3277 timer ticks and the midpoint was observed around 1638 ticks. And for `Up/Down` counting, the timer counted from 0 to `CCR0` and then back to 0 which was approximately 3277 total timer ticks that were needed for a #qty(10, "Hz") waveform. This gave `CCR0` #sym.approx 1638.

We saw that mode 4 toggled at `TACCR2` and some counting and mode combinations gave #qty(50, "%") duty cycle at #qty(10, "Hz") frequency without any additional delays. We verified the final register values with the actual output and the source code.

We calculated our PWM values using the given information that was `ACLK` frequency #qty(32768, "Hz"), the required PWM frequency was #qty(10, "Hz"), the duty cycle was #qty(50, "%"), the period was #qty(100, "ms") this means that the High duration was #qty(50, "ms") and the low duration was #qty(50, "ms"). So, according to the information, for `Up` mode the timer counts from 0#sym.arrow.r`CCR0` and then it restarts. Therefore, for a timer event that repeats once per counting cycle it becomes $#raw("CCR0") + 1 = 32768/10 = 3276.8$. This means `CCR0` = 3276 and for #qty(50, "%") of the counting interval $#raw("CCR2") = 3277/2 = 1638$. So `CCR2` #sym.approx 1638 approximately. These values are basically the starting values for output modes where one timer cycle can correspond to one PWM period.

Similarly, for Up/down mode the timer counts upward to `CCR0` and then downward to 0. So, $f = 32768/(2 times #raw("CCR0"))$. This means that $#raw("CCR0") = 32768/((2)(10)) approx 1638$. Now for an output mode where the two compare the events determining the High and Low portions symmetrically, we see that `CCR2` = 819 or we saw that this value depended on the selected output mode and its comparative event behavior. These were our calculations and then we checked the waveform behavior for each mode separately.

This lab showed how hardware timers are able to produce a repeatable waveform without having to completely rely on the software delay loops. The difference that we observed between the target and observed frequency and duty cycle was because of changing the timer counts and the output modes and we carefully understood that what values effectively gave us the desired frequency and duty cycle.

== Questions

#components.problem(1)[
  The goal is #qty(10, "Hz") at a duty cycle of #qty(50, "%") in `UP` mode, `OUTMOD=7`.
  + First use the Step 0 counts. What $f$ and $D$ do you measure? Why?
  + Write the formula for $f$ using `COUNT` and 32768 in `UP` mode. Which value must change to get #qty(10, "Hz")?
  + You changed `COUNT`, but kept `COUNT2 = COUNT/2`. Why did the duty cycle stay at #qty(50, "%")? Write the formula for D in `OUTMOD 7`
  + What $D$ would you get with `COUNT2 = COUNT/4`? Predict, then try.
]

+ Using the same counts and mode as Step 0 we get #qty(5, "Hz") and #qty(50, "%").
+ The formula is $f = 32768/#raw("COUNT")$ and to get #qty(10, "Hz") we need to set $#raw("COUNT") = 3277$.
+ This is because COUNT/2 gives 50% duty cycle that’s why it stayed the same and the formula for D in `OUTMOD` 7 is $D = (#raw("COUNT")-#raw("COUNT2"))/#raw("COUNT") * #qty(100, "%")$.
+ If we used COUNT2 = COUNT/4 then it would give us 75% duty cycle. We verified it on the LCD.

#pagebreak()
#set enum(numbering: "(A)")
#components.problem(2)[
  The goal is #qty(10, "Hz") at a duty cycle of #qty(50, "%") in `UP` mode, `OUTMOD=4`.
  + With the old counts and the new mode, what $f$ do you measure now? Why is it exactly HALF of @step:1? (Hint: how many toggles does the output need for one complete period?)
  + Correct COUNT to get 10 Hz. Write your calculation.
  + Try `COUNT2 = COUNT/4` and `COUNT2 = COUNT/8`. Does $D$ change? Explain why the duty cycle is always #qty(50, "%") in this mode.
  + What happens if `COUNT2` #sym.gt `COUNT`? Try it and explain.
]

+ The frequency halves as compared to step 1 because two toggles make one cycle.
+ So to fix frequency we use $f = 32768/(2*#raw("COUNT"))$; `COUNT = 1638` and this gives us #qty(10, "Hz").
+ The duty cycle remained the same even if we changed `COUNT2` because each `HIGH` and `LOW` lasted one timer period.
+ Then the timer would never reach `CCR2` so the normal toggling would stop.

#components.problem(3)[
  The goal is #qty(10, "Hz") at a duty cycle of #qty(50, "%") in `UP` mode, `OUTMOD=2`.
  + With the old counts and the new mode, what $f$ do you measure now? Why did it DOUBLE compared with @step:2?
  + If your $D$ is not #qty(50, "%"), explain why `COUNT2` matters again in this mode. Write the formula for $D$ in `OUTMOD=2` (`UP` mode).
  + Correct `COUNT` and `COUNT2` for #qty(10, "Hz"), #qty(50, "%").
  + Compare the plot with @step:1 (same $f$ and $D$): in which part of the period is the output `HIGH` in mode 7 and in mode 2?
]

+ The frequency doubled in comparison to @step:2 because one timer period produced one output cycle.
+ `COUNT2` basically controls the duty cycle in this mode. The formula for $D$ is $D = (#raw("COUNT")-#raw("COUNT2"))/#raw("COUNT") * 100%$.
+ The correct values were, `COUNT` = 3277 and `COUNT2` = 1638 to achieve the desired target.
+ After comparison we saw that Mode 7 was `HIGH` first and then Mode 2 was `HIGH` later.

#components.problem(4)[
  The goal is #qty(10, "Hz") at a duty cycle of #qty(50, "%") in `UP/DOWN` mode, `OUTMOD=2`.
  + With the old counts and the new mode, what $f$ do you measure? Why?
  + Write the formula for the timer period in `UP/DOWN` mode.
  + How many times per period does the count pass `CCR2`? What does `OUTMOD=2` do at each of these points?
  + Correct `COUNT` and `COUNT2` for #qty(10, "Hz"), #qty(50, "%"). Write the formula  for $D$ in `OUTMOD=2` (`UPDOWN` mode).
]

+ The frequency measured was 5Hz because the UP/DOWN counting took twice as long as UP counting.

+ The formula is Timer period $T = 2 times #raw("COUNT")/#qty(32768, "s")$.

+ The Timer crossed `CCR2` twice, once going up and once going down. It basically toggled UP and then reset to `DOWN`.

+ The correct values were $#raw("COUNT") = 1638$ and $#raw("COUNT2") = 819$. The formula is #linebreak() $D = (#raw("COUNT") - #raw("COUNT2")) / #raw("COUNT") times #qty(100, "%")$

#components.problem(5)[
  The goal is #qty(10, "Hz") at a duty cycle of #qty(50, "%") in `UP/DOWN` mode, `OUTMOD=4`.
  + With the old counts and the new mode, what $f$ and $D$ do you measure? Why?
  + In @step:2 (`UP` mode) toggle mode HALVED the frequency. Why does it not halve it here? (Count the toggles per period.)
  + Try $#raw("COUNT2") = #raw("COUNT")/4$. Does $D$ change now? Compare with @step:2 Q3 and explain the difference.
  + Which `COUNT2` gives exactly 50 %? Why?
]

+ With the old counts and new mode we get $f = #qty(10, "Hz")$ and $D = #qty(50, "%")$. We get this because in `UPDOWN` mode it toggles twice per timer period.

+ The frequency does not half here because `CCR2` is crossed twice and it produced two toggles per timer period.

+ Doing $#raw("COUNT2") = #raw("COUNT")/4$ gave $D = #qty(25, "%")$ or it could also give #qty(75, "%") if we reversed the polarity. In @step:2 the duty cycle stayed #qty(50, "%") and that was because it depended on `CCR2` and we weren’t changing that.

+ $#raw("COUNT2") = #raw("COUNT")/2$ gave exactly #qty(50, "%") duty cycle.

#components.problem(6)[
  The goal is #qty(10, "Hz") at a duty cycle of #qty(50, "%") in `UP/DOWN` mode, `OUTMOD=7`.
  + With the old counts and the new mode, what $D$ do you measure?
  + Using the `Timer_A` output-mode timing diagram (Figure 6 in the lab manual), draw `TAR` counting $0 -> #raw("CCR0") -> 0$ and `TA0.2`. Mark the `CCR2` compare events and the `CCR0` event on your drawing.
  + From your timing diagram, identify where the output is set and reset. Then derive the formula for $D$ using `COUNT` and `COUNT2`, and check it against your measurement from Q1.
  + Which `COUNT2` gives approximately #qty(50, "%") duty? Based on your timing diagram, can this mode produce more than #qty(50, "%") duty in `UPDOWN` mode? Explain.
]

+ With the old counts and new mode $D = #qty(25, "%")$.

+ For Timer counts $0 -> #raw("CCR0") -> 0$ and this counted `CCR2` twice in each direction.

+ The output resets at `CCR2` going up and sets at `CCR2` going down. The formula is $D = (#raw("COUNT")-#raw("COUNT2"))/(2*#raw("COUNT")) * 100%$.

+ When we put $#raw("COUT2") = 0$ then it gave us #qty(50, "%") duty cycle. This is because normal duty cycle cannot exceed #qty(50, "%") in this mode.

== Conclusion

In conclusion this lab helped us to grasp how `Timer_A0` PWM generation uses six configurations of counting and output modes. The results showed that we were able to get #qty(50, "%") duty cycle at #qty(10, "Hz") frequency for both the `UP` and `UP/DOWN` output modes. We measured and compared the LCD waveform with the register settings. This verified that changing the `TACCR0`, `TACCR2` and the output modes were able to allow us control of the PWM frequency and duty cycle. We were accurately able to get our desired readings for frequency and duty cycle using the hardware timers.

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
= Appendix II---Source Code
