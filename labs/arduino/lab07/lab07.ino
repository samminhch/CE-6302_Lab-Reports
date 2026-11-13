/*
 * =====================================================================
 *  MSP432 Timer_A0 PWM project
 * =====================================================================
 *  PWM output : P2.5 (TA0.2)
 *  PWM input  : P2.3   -> connect a jumper wire from P2.5 to P2.3
 *  Button     : P1.4 on the LaunchPad -> press to plot and measure
 *
 *  HOW TO WORK:
 *   1. Choose the step with  #define STEP  below and upload.
 *   2. STEP 0 is a finished sample: 5 Hz, 50 %, UP mode, OUTMOD 7.
 *      Read it carefully - every line is explained.
 *   3. STEPS 1-6: target is 10 Hz with approximately 50 % duty.
 *      Each step changes ONE thing compared with the step before:
 *
 *        Step 1 : UP,     OUTMOD 7  (new frequency: 5 Hz -> 10 Hz)
 *        Step 2 : UP,     OUTMOD 4  (change output mode 7 -> 4)
 *        Step 3 : UP,     OUTMOD 2  (change output mode 4 -> 2)
 *        Step 4 : UPDOWN, OUTMOD 2  (change counting mode UP -> UPDOWN)
 *        Step 5 : UPDOWN, OUTMOD 4  (change output mode 2 -> 4)
 *        Step 6 : UPDOWN, OUTMOD 7  (change output mode 4 -> 7)
 *
 *      YOU write the code of every step. The HINT comments tell you
 *      what to write on each line (Step 0 shows how it looks).
 *      For each step:
 *        (a) define Sx_COUNT and Sx_COUNT2 yourself, starting with
 *            the PREVIOUS step's values,
 *        (b) write the code with the NEW mode of this step, upload,
 *            press P1.4 and write down the measured f and D,
 *        (c) answer the QUESTIONS for that step,
 *        (d) if the new mode changes the waveform, recalculate your
 *            Sx_COUNT / Sx_COUNT2 values and measure again.
 *
 *   4. The LCD plots the waveform and displays the measured frequency
 *      and duty cycle.
 *
 *  TIP: draw the timer count and the output on paper before coding!
 * =====================================================================
 */

#define STEP 4  // <-- choose 0 (sample) or 1..6

#include <Screen_HX8353E.h>
Screen_HX8353E myScreen;
#define MSP432P401R
#include <msp.h>
#include <stdio.h>

// ---- Timer_A CTL bits you will need ---------------------------------
//  Counting mode (MC, bits 5-4)
#define HALT 0x0000    // timer stopped
#define UP 0x0010      // 0 -> CCR0, then back to 0
#define CONT 0x0020    // 0 -> 0xFFFF (not used here)
#define UPDOWN 0x0030  // 0 -> CCR0 -> 0
//  Clock source (TASSEL, bits 9-8)
#define ACLK 0x0100  // 32768 Hz
//  Clear (TACLR, bit 2): resets the count to 0
//      TIMER_A_CTL_CLR
//
// ---- Output modes for TIMER_A0->CCTL[2] -------------------------------
//      TIMER_A_CCTLN_OUTMOD_2   toggle/reset
//      TIMER_A_CCTLN_OUTMOD_4   toggle
//      TIMER_A_CCTLN_OUTMOD_7   reset/set
//
// ---- Port 2 registers for P2.5 (use BIT5) -----------------------------
//      P2->DIR   1 = output
//      P2->SEL0, P2->SEL1   SEL0=1, SEL1=0 -> pin is used by Timer_A0 (TA0.2)
//      Configure only BIT5; do not disturb the other Port 2 pins.


/* =====================================================================
 *  STEP 0  -  SAMPLE  (finished)  5 Hz, 50 %, UP mode, OUTMOD 7
 *  Read every line. Steps 1-6 use exactly the same 6 parts.
 * =====================================================================
 *  UP mode: the timer counts 0 -> CCR0 and starts again, so
 *      period = CCR0 / 32768 s   ->  CCR0 = 32768 / f
 *  OUTMOD 7 (reset/set): output goes LOW when the count reaches CCR2
 *  and HIGH when it reaches CCR0, so it is high from 0 to CCR2:
 *      duty = CCR2 / CCR0        ->  CCR2 = CCR0 / 2 for 50 %
 */

// 6553 ticks = 200 ms -> 5 Hz
#define S0_COUNT ((1 << 15) / 5)  
// half of the period -> 50 %
#define S0_COUNT2 (S0_COUNT / 2)

void step0(void) {
  // 1) stop the timer and clear it while we change the settings
  TIMER_A0->CTL = HALT | ACLK | TIMER_A_CTL_CLR;

  // 2) period: 32768 / 5 = 6553 ticks = 200 ms -> 5 Hz
  TIMER_A0->CCR[0] = S0_COUNT;

  // 3) duty: half of the period -> 50 %
  TIMER_A0->CCR[2] = S0_COUNT2;

  // 4) output mode of CCR2 -> drives TA0.2
  TIMER_A0->CCTL[2] = TIMER_A_CCTLN_OUTMOD_7;

  // 5) P2.5: output, and give the pin to Timer_A0 (TA0.2)
  P2->DIR |= BIT5;
  P2->SEL0 |= BIT5;
  P2->SEL1 &= ~BIT5;

  // 6) start: ACLK, UP mode, clear the count
  TIMER_A0->CTL = UP | ACLK | TIMER_A_CTL_CLR;
}


/* =====================================================================
 *  STEP 1  -  goal 10 Hz, 50 %   |  UP mode, OUTMOD 7
 *  Start with: Step 0 counts (5 Hz). The mode is the same as Step 0.
 *
 *  QUESTIONS
 *   Q1. First use the Step 0 counts. What f and D do you measure? Why?
 *   Q2. Write the formula for f using COUNT and 32768 in UP mode.
 *       Which value must change to get 10 Hz?
 *   Q3. You changed COUNT, but kept COUNT2 = COUNT/2. Why did the
 *       duty cycle stay at 50 %? Write the formula for D in OUTMOD 7.
 *   Q4. What D would you get with COUNT2 = COUNT/4? Predict, then try.
 * ===================================================================== */
// ---------------------------------------------------------------------
// HINT: Step 1 changes only the frequency, the mode stays as in Step 0.
// Write two #defines here:
//   S1_COUNT   -> first: S0_COUNT    later (c): your corrected calculation
//   S1_COUNT2  -> first: S0_COUNT2   later (c): your corrected calculation
// ---------------------------------------------------------------------
// STUDENT: define both values below.
// First use the previous step values (S0_COUNT and S0_COUNT2).
// After observing the new output mode/counting mode, change them only if needed.

// 3276 ticks = 100 ms -> 10 Hz
#define S1_COUNT S0_COUNT / 2
#define S1_COUNT2 S0_COUNT2 / 2

#if STEP == 1
void step1(void) {
  // 1) stop and clear Timer_A0 while you configure it:
  TIMER_A0->CTL = HALT | ACLK | TIMER_A_CTL_CLR;

  // 2) period: write S1_COUNT into TIMER_A0->CCR[0]
  TIMER_A0->CCR[0] = S1_COUNT;

  // 3) duty: write S1_COUNT2 into TIMER_A0->CCR[2]
  TIMER_A0->CCR[2] = S1_COUNT2;

  // 4) output mode: TIMER_A0->CCTL[2] = TIMER_A_CCTLN_OUTMOD_?  -> OUTMOD 7 (reset/set) - same as Step 0
  TIMER_A0->CCTL[2] = TIMER_A_CCTLN_OUTMOD_7;

  // 5) P2.5 pin: make it an output (P2->DIR) and give it to the timer
  //    (P2->SEL0 = 1, P2->SEL1 = 0 for BIT5).
  P2->DIR |= BIT5;
  P2->SEL0 |= BIT5;
  P2->SEL1 &= ~BIT5;

  // 6) start Timer_A0: TIMER_A0->CTL = (counting mode) | ACLK | TIMER_A_CTL_CLR
  //    -> UP mode - same as Step 0
  TIMER_A0->CTL = UP | ACLK | TIMER_A_CTL_CLR;
}
#endif


/* =====================================================================
 *  STEP 2  -  goal 10 Hz, 50 %   |  UP mode, OUTMOD 4 (toggle)
 *  Start with: Step 1 counts + the NEW mode of this step.
 *
 *  QUESTIONS
 *   Q1. With the old counts and the new mode, what f do you measure now?
 *       Why is it exactly HALF of Step 1? (Hint: how many toggles
 *       does the output need for one complete period?)
 *   Q2. Correct COUNT to get 10 Hz. Write your calculation.
 *   Q3. Try COUNT2 = COUNT/4 and COUNT2 = COUNT/8. Does D change?
 *       Explain why the duty cycle is always 50 % in this mode.
 *   Q4. What happens if COUNT2 > COUNT? Try it and explain.
 * ===================================================================== */
// ---------------------------------------------------------------------
// HINT: Only the output mode changes compared with Step 1.
// Write two #defines here:
//   S2_COUNT   -> first: S1_COUNT    later (c): your corrected calculation
//   S2_COUNT2  -> first: S1_COUNT2   later (c): your corrected calculation
// ---------------------------------------------------------------------
// STUDENT: define both values below.
// First use the previous step values (S1_COUNT and S1_COUNT2).
// After observing the new output mode/counting mode, change them only if needed.

// 1368 ticks = 50 ms -> 20 Hz
#define S2_COUNT S1_COUNT / 2
#define S2_COUNT2 S1_COUNT2 / 2

#if STEP == 2
void step2(void) {
  // 1) Stop timer during configuration
  TIMER_A0->CTL = HALT | ACLK | TIMER_A_CTL_CLR;

  // 2) period: write S1_COUNT into TIMER_A0->CCR[0]
  TIMER_A0->CCR[0] = S2_COUNT;

  // 3) duty: write S1_COUNT2 into TIMER_A0->CCR[2]
  TIMER_A0->CCR[2] = S2_COUNT2;

  // 4) output mode: TIMER_A0->CCTL[2] = TIMER_A_CCTLN_OUTMOD_?
  TIMER_A0->CCTL[2] = TIMER_A_CCTLN_OUTMOD_4;

  // 5) P2.5 pin: make it an output (P2->DIR) and give it to the timer
  //    (P2->SEL0 = 1, P2->SEL1 = 0 for BIT5).
  P2->DIR |= BIT5;
  P2->SEL0 |= BIT5;
  P2->SEL1 &= ~BIT5;

  // 6) start Timer_A0: TIMER_A0->CTL = (counting mode) | ACLK | TIMER_A_CTL_CLR
  TIMER_A0->CTL = UP | ACLK | TIMER_A_CTL_CLR;
}
#endif


/* =====================================================================
 *  STEP 3  -  goal 10 Hz, 50 %   |  UP mode, OUTMOD 2 (toggle/reset)
 *  Start with: Step 2 counts + the NEW mode of this step.
 *
 *  QUESTIONS
 *   Q1. With the old counts and the new mode, what f do you measure now?
 *       Why did it DOUBLE compared with Step 2?
 *   Q2. If your D is not 50 %, explain why COUNT2 matters again in
 *       this mode. Write the formula for D in OUTMOD 2 (UP mode).
 *   Q3. Correct COUNT and COUNT2 for 10 Hz, 50 %.
 *   Q4. Compare the plot with Step 1 (same f and D): in which part
 *       of the period is the output HIGH in mode 7 and in mode 2?
 * ===================================================================== */
// ---------------------------------------------------------------------
// HINT: Only the output mode changes compared with Step 2.
// Write two #defines here:
//   S3_COUNT   -> first: S2_COUNT    later (c): your corrected calculation
//   S3_COUNT2  -> first: S2_COUNT2   later (c): your corrected calculation
// ---------------------------------------------------------------------
// STUDENT: define both values below.
// First use the previous step values (S2_COUNT and S2_COUNT2).
// After observing the new output mode/counting mode, change them only if needed.
#define S3_COUNT S2_COUNT * 2
#define S3_COUNT2 S2_COUNT2 * 2

#if STEP == 3
void step3(void) {
  // 1) Stop timer during configuration
  TIMER_A0->CTL = HALT | ACLK | TIMER_A_CTL_CLR;

  // 2) period: write S1_COUNT into TIMER_A0->CCR[0]
  TIMER_A0->CCR[0] = S3_COUNT;

  // 3) duty: write S1_COUNT2 into TIMER_A0->CCR[2]
  TIMER_A0->CCR[2] = S3_COUNT2;

  // 4) output mode: TIMER_A0->CCTL[2] = TIMER_A_CCTLN_OUTMOD_?
  TIMER_A0->CCTL[2] = TIMER_A_CCTLN_OUTMOD_2;

  // 5) P2.5 pin: make it an output (P2->DIR) and give it to the timer
  //    (P2->SEL0 = 1, P2->SEL1 = 0 for BIT5).
  P2->DIR |= BIT5;
  P2->SEL0 |= BIT5;
  P2->SEL1 &= ~BIT5;

  // 6) start Timer_A0: TIMER_A0->CTL = (counting mode) | ACLK | TIMER_A_CTL_CLR
  TIMER_A0->CTL = UP | ACLK | TIMER_A_CTL_CLR;
}
#endif


/* =====================================================================
 *  STEP 4  -  goal 10 Hz, 50 %   |  UPDOWN mode, OUTMOD 2
 *  Start with: Step 3 counts + the NEW mode of this step.
 *
 *  QUESTIONS
 *   Q1. With the old counts and the new mode, what f do you measure? Why?
 *   Q2. Write the formula for the timer period in UPDOWN mode.
 *   Q3. How many times per period does the count pass CCR2? What
 *       does OUTMOD 2 do at each of these points?
 *   Q4. Correct COUNT and COUNT2 for 10 Hz, 50 %. Write the formula
 *       for D in OUTMOD 2 (UPDOWN mode).
 * ===================================================================== */
// ---------------------------------------------------------------------
// HINT: Only the counting mode changes compared with Step 3.
// Write two #defines here:
//   S4_COUNT   -> first: S3_COUNT    later (c): your corrected calculation
//   S4_COUNT2  -> first: S3_COUNT2   later (c): your corrected calculation
// ---------------------------------------------------------------------
// STUDENT: define both values below.
// First use the previous step values (S3_COUNT and S3_COUNT2).
// After observing the new output mode/counting mode, change them only if needed.
#define S4_COUNT S3_COUNT / 2
#define S4_COUNT2 S3_COUNT2 / 2

#if STEP == 4
void step4(void) {
  // 1) Stop timer during configuration
  TIMER_A0->CTL = HALT | ACLK | TIMER_A_CTL_CLR;

  // 2) period: write S1_COUNT into TIMER_A0->CCR[0]
  TIMER_A0->CCR[0] = S4_COUNT;

  // 3) duty: write S1_COUNT2 into TIMER_A0->CCR[2]
  TIMER_A0->CCR[2] = S4_COUNT2;

  // 4) output mode: TIMER_A0->CCTL[2] = TIMER_A_CCTLN_OUTMOD_?
  TIMER_A0->CCTL[2] = TIMER_A_CCTLN_OUTMOD_2;

  // 5) P2.5 pin: make it an output (P2->DIR) and give it to the timer
  //    (P2->SEL0 = 1, P2->SEL1 = 0 for BIT5).
  P2->DIR |= BIT5;
  P2->SEL0 |= BIT5;
  P2->SEL1 &= ~BIT5;

  // 6) start Timer_A0: TIMER_A0->CTL = (counting mode) | ACLK | TIMER_A_CTL_CLR
  TIMER_A0->CTL = UPDOWN | ACLK | TIMER_A_CTL_CLR;
}
#endif


/* =====================================================================
 *  STEP 5  -  goal 10 Hz, 50 %   |  UPDOWN mode, OUTMOD 4 (toggle)
 *  Start with: Step 4 counts + the NEW mode of this step.
 *
 *  QUESTIONS
 *   Q1. With the old counts and the new mode, what f and D do you measure? Why?
 *   Q2. In Step 2 (UP mode) toggle mode HALVED the frequency. Why
 *       does it not halve it here? (Count the toggles per period.)
 *   Q3. Try COUNT2 = COUNT/4. Does D change now? Compare with
 *       Step 2 Q3 and explain the difference.
 *   Q4. Which COUNT2 gives exactly 50 %? Why?
 * ===================================================================== */
// ---------------------------------------------------------------------
// HINT: Only the output mode changes compared with Step 4.
// Write two #defines here:
//   S5_COUNT   -> first: S4_COUNT    later (c): your corrected calculation
//   S5_COUNT2  -> first: S4_COUNT2   later (c): your corrected calculation
// ---------------------------------------------------------------------
// STUDENT: define both values below.
// First use the previous step values (S4_COUNT and S4_COUNT2).
// After observing the new output mode/counting mode, change them only if needed.
#define S5_COUNT   S4_COUNT
#define S5_COUNT2  S4_COUNT2

#if STEP == 5
void step5(void) {
    // 1) Stop timer during configuration
  TIMER_A0->CTL = HALT | ACLK | TIMER_A_CTL_CLR;

  // 2) period: write S1_COUNT into TIMER_A0->CCR[0]
  TIMER_A0->CCR[0] = S5_COUNT;

  // 3) duty: write S1_COUNT2 into TIMER_A0->CCR[2]
  TIMER_A0->CCR[2] = S5_COUNT2;

  // 4) output mode: TIMER_A0->CCTL[2] = TIMER_A_CCTLN_OUTMOD_?
  TIMER_A0->CCTL[2] = TIMER_A_CCTLN_OUTMOD_4;

  // 5) P2.5 pin: make it an output (P2->DIR) and give it to the timer
  //    (P2->SEL0 = 1, P2->SEL1 = 0 for BIT5).
  P2->DIR |= BIT5;
  P2->SEL0 |= BIT5;
  P2->SEL1 &= ~BIT5;

  // 6) start Timer_A0: TIMER_A0->CTL = (counting mode) | ACLK | TIMER_A_CTL_CLR
  TIMER_A0->CTL = UPDOWN | ACLK | TIMER_A_CTL_CLR;
}
#endif


/* =====================================================================
 *  STEP 6  -  goal 10 Hz, 50 %   |  UPDOWN mode, OUTMOD 7  (CHALLENGE)
 *  Start with: Step 5 counts + the NEW mode of this step.
 *
 *  QUESTIONS
 *   Q1. With the old counts and the new mode, what D do you measure?
 *   Q2. Using the Timer_A output-mode timing diagram (Figure 6 in the
 *       lab manual), draw TAR counting 0 -> CCR0 -> 0 and TA0.2. Mark
 *       the CCR2 compare events and the CCR0 event on your drawing.
 *   Q3. From your timing diagram, identify where the output is set and
 *       reset. Then derive the formula for D using COUNT and COUNT2,
 *       and check it against your measurement from Q1.
 *   Q4. Which COUNT2 gives approximately 50 % duty? Based on your
 *       timing diagram, can this mode produce more than 50 % duty in
 *       UPDOWN mode? Explain.
 * ===================================================================== */
// ---------------------------------------------------------------------
// HINT: Only the output mode changes compared with Step 5.
// Write two #defines here:
//   S6_COUNT   -> first: S5_COUNT    later (c): your corrected calculation
//   S6_COUNT2  -> first: S5_COUNT2   later (c): your corrected calculation
// ---------------------------------------------------------------------
// STUDENT: define both values below.
// First use the previous step values (S5_COUNT and S5_COUNT2).
// After observing the new output mode/counting mode, change them only if needed.
#define S6_COUNT   S5_COUNT
#define S6_COUNT2  0

#if STEP == 6
void step6(void) {
  // 1) Stop timer during configuration
  TIMER_A0->CTL = HALT | ACLK | TIMER_A_CTL_CLR;

  // 2) period: write S1_COUNT into TIMER_A0->CCR[0]
  TIMER_A0->CCR[0] = S6_COUNT;

  // 3) duty: write S1_COUNT2 into TIMER_A0->CCR[2]
  TIMER_A0->CCR[2] = S6_COUNT2;

  // 4) output mode: TIMER_A0->CCTL[2] = TIMER_A_CCTLN_OUTMOD_?
  TIMER_A0->CCTL[2] = TIMER_A_CCTLN_OUTMOD_7;

  // 5) P2.5 pin: make it an output (P2->DIR) and give it to the timer
  //    (P2->SEL0 = 1, P2->SEL1 = 0 for BIT5).
  P2->DIR |= BIT5;
  P2->SEL0 |= BIT5;
  P2->SEL1 &= ~BIT5;

  // 6) start Timer_A0: TIMER_A0->CTL = (counting mode) | ACLK | TIMER_A_CTL_CLR
  TIMER_A0->CTL = UPDOWN | ACLK | TIMER_A_CTL_CLR;
}
#endif


/* #####################################################################
 * ###########   TEST FRAMEWORK  -  DO NOT EDIT BELOW THIS LINE   ######
 * ##################################################################### */

#if (STEP < 0) || (STEP > 6)
#error "STEP must be 0..6"
#endif

#define BUTTON_PIN 74  // P1.4
#define PWM_IN_PIN 34  // P2.3
#define MAXDOTS 100
#define SAMPLE_MS 10  // 100 samples x 10 ms = 1 s on screen
#define X0 10
#define Y_HIGH 40
#define Y_LOW 70

int pwm_data[MAXDOTS];

// Expected setup for each step
const uint16_t expMC[7] = { UP, UP, UP, UP, UPDOWN, UPDOWN, UPDOWN };
const uint8_t expOut[7] = { 7, 7, 4, 2, 2, 4, 7 };
const char *title[7] = { "Step 0 sample 5Hz", "Step 1 UP OUT7",
                         "Step 2 UP OUT4", "Step 3 UP OUT2",
                         "Step 4 UPDN OUT2", "Step 5 UPDN OUT4",
                         "Step 6 UPDN OUT7" };

void LCD_plot(void);
bool checkConnection(void);
void measurePWM(float &freq, float &duty);
const char *checkSetup(void);

void setup() {
  WDT_A->CTL = WDT_A_CTL_PW | WDT_A_CTL_HOLD;  // stop watchdog timer
  myScreen.begin();
  myScreen.setPenSolid(true);
  Serial.begin(9600);
  pinMode(BUTTON_PIN, INPUT_PULLUP);
  pinMode(PWM_IN_PIN, INPUT_PULLUP);

#if STEP == 0
  step0();
#elif STEP == 1
  step1();
#elif STEP == 2
  step2();
#elif STEP == 3
  step3();
#elif STEP == 4
  step4();
#elif STEP == 5
  step5();
#elif STEP == 6
  step6();
#endif

  // Keep the LCD backlight enabled if a student's Port 2 setup changed it.
  if (!(P2->DIR & BIT6)) P2->DIR |= BIT6;

  const char *setupMsg = checkSetup();
  myScreen.gText(5, 2, title[STEP], whiteColour);
  myScreen.gText(5, 12, "Press P1.4", whiteColour);

  // Show a setup message only when something is wrong.
  // Do not display "Setup OK" on the LCD.
  if (strcmp(setupMsg, "Setup OK") != 0) {
    myScreen.gText(5, 21, setupMsg, redColour);
  }

  Serial.println(title[STEP]);
  Serial.print("  CTL=0x");
  Serial.print(TIMER_A0->CTL, HEX);
  Serial.print("  CCTL2=0x");
  Serial.println(TIMER_A0->CCTL[2], HEX);
  if (strcmp(setupMsg, "Setup OK") != 0) {
    Serial.print("  ");
    Serial.println(setupMsg);
  }
}

void loop() {
  LCD_plot();
  delay(1);
}

// Reads back the registers and says what is wrong (first problem only)
const char *checkSetup(void) {
  uint16_t ctl = TIMER_A0->CTL;
  if ((ctl & 0x0300) != ACLK) return "Setup: clock?";
  if ((ctl & 0x0030) != expMC[STEP]) return "Setup: count mode?";
  if (((TIMER_A0->CCTL[2] >> 5) & 7) != expOut[STEP]) return "Setup: OUTMOD?";
  if (!(P2->DIR & BIT5) || !(P2->SEL0 & BIT5) || (P2->SEL1 & BIT5))
    return "Setup: P2.5 pin?";
  return "Setup OK";
}

// Drives P2.5 as GPIO high/low and checks P2.3 follows, then restores P2.5
bool checkConnection(void) {
  uint8_t oldDir = P2->DIR & BIT5;
  uint8_t oldSel0 = P2->SEL0 & BIT5;
  P2->SEL0 &= ~BIT5;
  P2->DIR |= BIT5;
  P2->OUT |= BIT5;
  delay(1);
  bool followsHigh = (digitalRead(PWM_IN_PIN) == 1);
  P2->OUT &= ~BIT5;
  delay(1);
  bool followsLow = (digitalRead(PWM_IN_PIN) == 0);
  P2->DIR = (P2->DIR & ~BIT5) | oldDir;
  P2->SEL0 = (P2->SEL0 & ~BIT5) | oldSel0;
  return followsHigh && followsLow;
}

// Measures ONE complete PWM cycle using real signal transitions:
// rising edge -> falling edge -> next rising edge.
// Duty cycle = HIGH time / complete period * 100.
void measurePWM(float &freq, float &duty) {
  const unsigned long TIMEOUT_US = 1500000UL;  // 1.5 s timeout
  unsigned long start = micros();

  freq = 0.0;
  duty = 0.0;

  // First make sure we are in the LOW part of the waveform.
  while ((P2->IN & BIT3) != 0) {
    if ((unsigned long)(micros() - start) > TIMEOUT_US) {
      duty = 100.0;  // signal stayed HIGH
      return;
    }
  }

  // Wait for the first rising edge: LOW -> HIGH.
  while ((P2->IN & BIT3) == 0) {
    if ((unsigned long)(micros() - start) > TIMEOUT_US) {
      duty = 0.0;  // signal stayed LOW
      return;
    }
  }
  unsigned long rise1 = micros();

  // Wait for the falling edge: HIGH -> LOW.
  while ((P2->IN & BIT3) != 0) {
    if ((unsigned long)(micros() - start) > TIMEOUT_US) return;
  }
  unsigned long fall1 = micros();

  // Wait for the next rising edge: this completes one full PWM cycle.
  while ((P2->IN & BIT3) == 0) {
    if ((unsigned long)(micros() - start) > TIMEOUT_US) return;
  }
  unsigned long rise2 = micros();

  unsigned long periodUs = rise2 - rise1;
  unsigned long highUs = fall1 - rise1;

  if (periodUs > 0) {
    freq = 1000000.0 / (float)periodUs;
    duty = 100.0 * (float)highUs / (float)periodUs;
  }
}

void LCD_plot(void) {
  if (digitalRead(BUTTON_PIN) != 0) return;

  myScreen.dRectangle(5, 30, 115, 51, blackColour);
  myScreen.dRectangle(0, 84, 128, 44, blackColour);

  // 1) wire check
  if (!checkConnection()) {
    myScreen.gText(5, 86, "P2.5-P2.3 MISSED", redColour);
    Serial.println("PWM connection (P2.5 to P2.3) missed");
    while (digitalRead(BUTTON_PIN) == 0) {}
    return;
  }
  myScreen.gText(5, 86, "P2.5-P2.3 connected", greenColour);

  // 2) capture: sync to a falling edge (max 1 s wait), then sample
  unsigned long t0 = millis();
  while (digitalRead(PWM_IN_PIN) == 0 && millis() - t0 < 1000) {}
  while (digitalRead(PWM_IN_PIN) == 1 && millis() - t0 < 1000) {}
  for (int i = 0; i < MAXDOTS; i++) {
    pwm_data[i] = digitalRead(PWM_IN_PIN);
    delay(SAMPLE_MS);
  }

  // 3) draw: high at top, low at bottom, vertical line at each edge
  for (int i = 0; i < MAXDOTS; i++) {
    int y = pwm_data[i] ? Y_HIGH : Y_LOW;
    myScreen.dRectangle(X0 + i, y, 1, 1, greenColour);
    if (i > 0 && pwm_data[i] != pwm_data[i - 1])
      myScreen.dRectangle(X0 + i, Y_HIGH, 1, Y_LOW - Y_HIGH + 1, greenColour);
  }

  // 4) measure and display only frequency and duty cycle
  float f, d;
  measurePWM(f, d);
  char buf[24];
  int f10 = (int)(f * 10 + 0.5);
  int d10 = (int)(d * 10 + 0.5);
  if (f10 == 0) sprintf(buf, "No PWM  D=%d.%d%%", d10 / 10, d10 % 10);
  else sprintf(buf, "f=%d.%dHz D=%d.%d%%", f10 / 10, f10 % 10, d10 / 10, d10 % 10);
  myScreen.gText(5, 98, buf, whiteColour);

  Serial.print(title[STEP]);
  Serial.print(" -> ");
  Serial.println(buf);

  while (digitalRead(BUTTON_PIN) == 0) {}  // one press = one measurement
}
