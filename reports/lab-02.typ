#import "common.typ"

#import "@preview/cheq:0.4.0": checklist
#show: checklist

#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.10": *

#show: codly-init
#codly(languages: codly-languages, lang-format: none)


= Introduction
The objective of this lab was to make us familiar with the three-axis analog
accelerometer on the BoosterPack stream motion data from the LaunchPad to our
laptop. We used 12-bit resolution ADC, firstly reading the raw data then
calibrating the acceleration in units of g and then finally detecting fall. What
we basically had to verify was a calibrated acceleration vector magnitude that
remained closer to 1g while the straight laying board was titled in any
direction. We could identify a fall only when there was a high magnitude impact
that happened at a low magnitude free-fall interval within a 500ms window. The
main aim was to get an idea on how to set sampling and serial settings to
display the three-axis measurements and to determine the calibration constraint
for each axis. We were also made to visualize the acceleration vector in three
dimensions and then figure out a practical threshold by doing drop test and
false -alarm test.

= Procedure
== Part 1 Raw Accelerator Data
In the first part we configured the converter to 12-bit resolution and sampled
all three axis X, Y and Z at 2Hz. Each value for all the axis was visible like a
comma separated value on the serial monitor at 15200 baud and the same thing was
displayed on the LCD after closing the serial monitor, which is shown in
@table:rates. Then we plotted the vector for the uncalibrated values using
@listing:plot-raw and took screenshots of that as well as a picture of the LCD.

== Part 2 Calibration
In the second part we held each axis first as +1g orientation and then -1g
orientation. We observed and recorded these six readings and then used these
values to find out the zero-g offset and counts per $g$ scale for each of the
channels, which is shown in @table:calibration-readings. We plotted the vector
with these calibrated values in @listing:plot-calibrated. We took a screenshot
of this to show rescaled acceleration in g. We also took a picture of the LCD.

#pagebreak()
== Part 3 Fall Detection
In the third part we increased the sampling rate to $50"Hz"$ so that the detector could record the free fall whenever the vector magnitude would fall below $0.40"g"$ and declared it as a fall only when the magnitude subsequently exceeded the selected impact threshold within the $500"ms"$. We performed the five drop test sand shook the micro-controller in our hands to evaluate false detections. We performed this fall detection tests using threshold values `3`, `2.5` and `1.5`.

#figure(
  image("../assets/lab02/raw-readings.png", width: 60%),
  caption: [LCD displaying the three raw accelerometer readings.],
)<figure:raw-readings>

#figure(
  image("../assets/lab02/raw-plot.png", width: 80%),
  caption: [Three-dimensional plot of the uncalibrated raw vector.],
)<figure:raw-plots>

#figure(
  image("../assets/lab02/raw-capture.png", width: 80%),
  caption: [LCD display along with the 3D vector together],
)<figure:raw-capture>

#figure(
  image("../assets/lab02/calibrated-results.png"),
  caption: [LCD displaying the calibrated acceleration components in $g$.],
)

#figure(
  image("../assets/lab02/calibrated-plot.png", width: 66%),
  caption: [Three-dimensional plot of the calibrated acceleration vector.],
)

#figure(
  image("../assets/lab02/fall-reading.png", width: 35%),
  caption: [LCD displaying the fall-detected alert],
)

#figure(
  image("../assets/lab02/fall-plot-1.png", width: 65%),
  caption: [Three-dimensional plot displaying the fall-detected alert with
    threshold 1.],
)

#figure(
  image("../assets/lab02/fall-plot-25.png", width: 70%),
  caption: [Three-dimensional plot displaying the fall-detected alert with
    threshold 2.5.],
)

#figure(
  caption: [Sample, delay, and baud rates],
  table(
    columns: 3,
    common.table-header([], [Value], [Calculation]), [*Sample Rate*], $2 "Hz"$,
    [], [*Delay*], $500 "ms"$,
    $(1000 frac("ms", "sec", style: "skewed")) / (2"Hz")$,
    [*Baud Rate*],
    $115200$,

    [Good starting value],
  ),
)<table:rates>

#figure(
  caption: [Calibration readings, and $k$ derived from them],
  table(
    align: (x, y) => if x == 0 or y <= 1 { center } else { left } + horizon,
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

#pagebreak()
= Discussion
== What was wrong with the uncalibrated plot?
The raw values that we got from the uncalibrated data did not give us the physical acceleration so all the three raw ADC values had a large value for positive electrical offset which was near the middle of the converter range. This meant that the vector remained in one corner of the plot rather than being near the origin. When we changed the position of the micro-controller and tilted it by a few hundred counts then we were able to compare with the several thousand count offset and the vector length did not change much physically. This helped us understand that the vector length basically had no physical unit or useful interpretation.

== What does $abs(a)$ stay near $1"g"$ at any tilt, and why is that a stronger check on your calibration than the flat reading alone?
We observed that when the board was placed stationary on the table then the gravity is redistributed among the X,Y and Z components as we move it meaning when we tilt it. But the big observation was that the magnitude of the gravity vector did not change though. So we came to the conclusion that\ $abs(a)=sqrt(x^2+y^2+z^2)$ should remain near $1g$ at every orientation. This was a stronger calibration check than using one flat reading because we noticed that tilting used up all three offsets and scaling factors and that any error that we saw on any axis made the magnitude change with orientation. So we saw that the measured magnitudes were `0.08` flat value of $g$ and `1.08` tilted value of $g$.

== Why was $2 "Hz"$ too slow for fall detection? Support the answer with the free-fall time.
We were able to grasp the idea of why we needed a higher sampling rate for the fall detection test. Basically it was based on the logic that when we dropped the micro-controller from 15cm then the free fall time t is\ $t=sqrt((2h)/g)=sqrt((2*0.15)/9.81)approx 0.175"s"$. So at $2"Hz"$ the expected number of samples would be $N = t$, $"sampling rate" = 0.1752 times 2 = 0.35$. So, the entire free fall interval is able to happen between the consecutive readings. This means that using $50"Hz"$ would give us $N = 0.17550 = 8.75$ which approximately about 9 samples. This made the low-magnitude phase observable, and it increased the chance of capturing the short impact peak.

== Justify your final threshold, and state which error it favors: a missed fall or a false alarm.
We observed that the final threshold was $2.5g$. At this setting we were able to get 3 out of 5 drops and 1 false alarms in a span of 10 seconds. We also observed that if we reduced the threshold even further to $1.5g$ we got 4/5 drops being detected and normal handling gave 4 false detection sin 10 seconds, and we did a threshold 3g as well and recorded those values as well which were 0 falls detections and 0 false alarms. We made a decision that the $2.5g$ threshold was much more favorable in terms of practical fall detections as well as false alarms. Therefore the $2.5g$ threshold was our final selection because it acted as a middle ground for both fall detections and false alarms as compared to the lower $1.5g$ threshold. That is because it favors reducing false alarms at the cost of potentially missing some of the falls.

== Conclusion
In conclusion this experiment emphasized on how the complete measurement happened from analog acceleration to a live 3D visualization and how to detect an event. We observed uncalibrated and calibrated data which showed that calibration removed the channel offsets and converted the ADC counts into physical units that basically allowed the stationary vector magnitude to remain close to 1g while making it remain stationary or flat and tilting it to see the g value across various orientations. We were also able to see that how changing the sampling rate from 2Hz to 50Hz gave us enough temporal resolution to help us observe the approximately $0.175"s"$ free fall interval. We were able to see that how a low magnitude condition followed by an impact reduced the false alarms and compared this by repeating the event. Finally, we were able to detect 3 out 5 falls and 1 false detection in 10 seconds while ordinary handling and all this occurred at an impact threshold of $2.5g$.

#pagebreak()
= Appendix I --- Source Code
#figure(
  common.code("../labs/lab02/lab02.ino", title-full: false, lang: "cpp"),
  caption: [Arduino sketch that reads and calculates acceleration],
)<listing:sketch>

#figure(
  common.code("../labs/lab02/plot_raw.py", title-full: false),
  caption: [Code to plot the raw accelerometer data],
)<listing:plot-raw>

#figure(
  common.code("../labs/lab02/plot_calibrated.py", title-full: false),
  caption: [Code to plot the calibrated accelerometer data with fall detection],
)<listing:plot-calibrated>
