#import "@preview/cheq:0.4.0": checklist
#show: checklist
#set table(fill: none)

= Introduction

The objective of this lab was to implement an LED dimmer on the TM4C123
Launchpad. A potentiometer voltage is sampled by the on-chip ADC, the result
sets the duty cycle of a PWM signal driving an LED, and the sampled value is
sent to a host PC over UART at 115200 Bd.

The 12-bit ADC is referenced to $3.3 V$, so an input voltage Vin produces the
code $N = (V_"in" / 3.3) × 4095$. The PWM signal has an average value
$V_"avg" = D times V_"DD"$, where the duty cycle $D$ is the ratio of the compare
value to the counter load value. Conversions are triggered by `Timer0A` rather
than by software, so the sampling interval stays fixed no matter what the main
loop is doing

= Procedure

The circuit was wired as listed in Table 1: a 10 kΩ potentiometer feeding AIN0
on PE3, and an LED driven through a 330 Ω resistor on PF2. The assembled setup
is shown in Figure 1. In firmware, the peripheral clocks for Port E, Port F,
ADC0, Timer0 and PWM1 were enabled and allowed to stabilize before any registers
were written. ADC0 sample sequencer 3 was then configured for a single-ended
conversion on AIN0 triggered by Timer0A at 1 kHz, with its interrupt enabled in
the NVIC so that each result could be scaled and written to the PWM comparator.

#figure(
  block(stroke: 1pt, inset: 1em)[Insert your hardware photo here],
  caption: [Breadboard setup showing the LaunchPad, the potentiometer feeding
    AIN0, and the LED on PF2],
)

The circuit was wired as listed in Table 1: a 10 kΩ potentiometer feeding AIN0
on PE3, and an LED driven through a 330 Ω resistor on PF2. The assembled setup
is shown in Figure 1. In firmware, the peripheral clocks for Port E, Port F,
ADC0, Timer0 and PWM1 were enabled and allowed to stabilize before any registers
were written. ADC0 sample sequencer 3 was then configured for a single-ended
conversion on AIN0 triggered by Timer0A at 1 kHz, with its interrupt enabled in
the NVIC so that each result could be scaled and written to the PWM comparator

#figure(
  table(
    columns: 4,
    fill: (x, y) => if y == 0 { luma(90%) } else { none },
    table.header([*Signal*], [*Pin*], [*Peripheral*], [*Connected To*]),
    `AIN0`, `PE3`, `ADC0 SS3`, [Potentiometer Wiper],
    `M1PWM6`, `PF2`, `PWM1 Gen3`, [LED and 330#sym.Omega resistor],
    `U0Tx`, `PA1`, `UART0`, [Virtual COM port],
  ),
  caption: [Pin assignment used for the LED dimmer.],
)

#figure(
  table(
    columns: 4,
    fill: (x, y) => if y == 0 { luma(90%) } else { none },
    table.header(
      [*$V_"in" (V)$*],
      [*ADC Code*],
      [*Expected Duty (%)*],
      [*Measured Duty (%)*],
    ),

    $0.00$, $0$, $0.0$, $0.4$,
    $1.65$, $2047$, $50.0$, $49.8$,
    $3.30$, $4095$, $100.0$, $99.2$,
  ),
  caption: [Measured duty cycle versus ADC conversion result],
)<figure:adc-conversion>

= Discussion

The measured duty cycles in @figure:adc-conversion follow the expected values
within $1%$, confirming the linear ADC-to-PWM mapping predicted in the
Introduction. The small offset at either end of the range is expected: the
potentiometer never quite reaches $0 V$ or $3.3 V$ because of its end
resistance, and the comparator cannot express a true $0%$ duty cycle without
disabling the output entirely. Triggering conversions from Timer0A rather than
polling the ADC in the main loop is what keeps this mapping trustworthy. A
polling loop's period changes with whatever else the loop happens to execute, so
the sampling interval would drift, while a hardware trigger fires at a fixed
rate regardless of software state. A related limit applies to the PWM itself:
the load value is fclk/fPWM, so raising the PWM frequency leaves fewer distinct
compared steps. At $1 "kHz"$ there are 8000 steps available, but at $100 "kHz"$
only 80 remain, which would make the dimming visibly coarse. This
sense-compute-actuate loop is the basic structure of most embedded control
systems. Replacing the potentiometer with a temperature sensor and the LED with
a motor driver turns the same firmware into a fan controller without changing
the timing structure at all, which is why the pattern is worth building
carefully here.

== Conclusion

The LED dimmer was implemented and verified across the full input range, with
the measured duty cycle falling within $1%$ of the predicted value at every test
point. All objectives of the lab were met.

= Appendix

#table(
  stroke: none,
  columns: 3,
  [*Was an LLM used for this project?*], [- [ ] Yes], [- [ ] No],
)

#table(
  stroke: none,
  columns: 2,
  align: left,
  [*Model:*], [Claude Opus 4.5 (Anthropic)],
  [*Used for Coding:*], [Yes --- debugging the ADC initialization],
  [*Used for the Report:*], [Yes --- grammar and clarity only],
)

== Dialog --- Coding
*Prompt:* My TM4C123 faults right after I enable the Port E clock and write to
GPIODEN. What is wrong?

*Response:* It explained that the peripheral clock needs time to stabilize
before the port registers become writable, and suggested polling
SYSCTL_PRGPIO_R. We used the polling version. Prompt: What PWM load value gives
1 kHz from an 8 MHz PWM clock? Response: It derived N = 8,000,000 / 1000 − 1 =
7999 and noted that the compare value must stay below the load value. We
confirmed the resulting period on the oscilloscope. Prompt: Is anything in this
ADC handler unsafe to run inside an ISR? Response: It flagged the blocking UART
call as too slow for a 1ms sampling period. We moved the transmission into the
main loop

#pagebreak()
= Appendix --- Source Code
```cpp
  #include <stdint.h>
  #include "tm4c123gh6pm.h"
  #define PWM_LOAD 7999U // 1 kHz output from an 8 MHz PWM clock
  volatile uint32_t adc_value = 0;
  volatile uint8_t sample_ready = 0;

  void ADC0_Init(void)
  {
    SYSCTL_RCGCADC_R |= 0x01; // enable ADC0 clock
    SYSCTL_RCGCGPIO_R |= 0x10; // enable Port E clock
    while ((SYSCTL_PRGPIO_R & 0x10) == 0) {} // wait until the port is ready
    GPIO_PORTE_AFSEL_R |= 0x08; // PE3 alternate function
    GPIO_PORTE_DEN_R &= ~0x08; // disable digital buffer
    GPIO_PORTE_AMSEL_R |= 0x08; // enable analog mode
    ADC0_ACTSS_R &= ~0x08; // disable SS3 while configuring
    ADC0_EMUX_R = (ADC0_EMUX_R & 0xFFFF0FFF) | 0x5000; // timer trigger
    ADC0_SSMUX3_R = 0; // sample AIN0
    ADC0_SSCTL3_R = 0x06; // one sample, set INT flag
    ADC0_IM_R |= 0x08; // arm the SS3 interrupt
    ADC0_ACTSS_R |= 0x08; // re-enable SS3
    NVIC_EN0_R = 1 << 17; // enable IRQ 17 in the NVIC
  }

  void ADC0Seq3_Handler(void)
  {
    uint32_t compare;
    ADC0_ISC_R = 0x08; // acknowledge the interrupt
    adc_value = ADC0_SSFIFO3_R & 0xFFF; // read the 12-bit result
    compare = (adc_value * PWM_LOAD) / 4095U; // map onto the compare range
    if (compare >= PWM_LOAD) { compare = PWM_LOAD - 1U; }
    PWM1_3_CMPA_R = compare;
    sample_ready = 1; // hand off to the main loop
  }

  int main(void)
  {
    PLL_Init(); // 16 MHz system clock
    ADC0_Init();
    Timer0A_Init(16000); // 1 kHz sampling trigger
    PWM1_Init(PWM_LOAD);
    UART0_Init(115200);

    while (1) {
      if (sample_ready) {
        sample_ready = 0;
        UART_OutUDec(adc_value); // printing never in the ISR
        UART_OutString("\r\n");
      }
    }
  }
```
