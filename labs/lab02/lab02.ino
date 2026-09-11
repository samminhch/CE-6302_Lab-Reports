#include "Screen_HX8353E.h"

Screen_HX8353E myScreen;

const uint16_t sampling_rate = 50;
const uint16_t sampling_period = 1000 / sampling_rate;

const uint8_t xpin = 23;    // accelerometer X
const uint8_t ypin = 24;    // accelerometer Y
const uint8_t zpin = 25;    // accelerometer Z
const uint8_t buzzer = 40;  // BoosterPack buzzer, header J4.40

// ---- STEP 2: add your calibration constants here ----
const float X_ZERO = 2103.5, X_COUNTS_PER_G = 817.5;
const float Y_ZERO = 2044, Y_COUNTS_PER_G = 802;
const float Z_ZERO = 2059, Z_COUNTS_PER_G = 819;

// ---- STEP 4: add your fall thresholds here ----
const float FREEFALL_G = 0.40;
const float IMPACT_G = 2.50;
const uint32_t FALL_WINDOW_MS = 500;

// state used by the fall detector
bool inFreeFall = false;
unsigned long freefallTime = 0;
unsigned long alertTime = 0;
int fallFlag = 0;

// sound the buzzer at the given frequency for the given time
void beep(int freqHz, int durationMs) {
  int halfPeriodUs = 500'000 / freqHz;
  long cycles = ((long)durationMs * 1000L) / (2L * halfPeriodUs);
  for (long i = 0; i < cycles; i++) {
    digitalWrite(buzzer, HIGH);
    delayMicroseconds(halfPeriodUs);
    digitalWrite(buzzer, LOW);
    delayMicroseconds(halfPeriodUs);
  }
}

void setup() {
  // ---- STEP 1: your chosen baud rate ----
  Serial.begin(115200);

  analogReadResolution(12);

  pinMode(buzzer, OUTPUT);


  myScreen.begin();
  myScreen.setOrientation(0);
  myScreen.clear();
  myScreen.setFontSize(1);
  myScreen.gText(5, 10, "Accel", greenColour);
  myScreen.gText(5, 40, "X:");
  myScreen.gText(5, 60, "Y:");
  myScreen.gText(5, 80, "Z:");
  // line y = 105 is left free fo rthe Part 3 alert
}

void loop() {
  // ---- STEP 1: read the three axes, print the raw counts,
  //              and show them on the LCD ----
  int xraw = analogRead(xpin);
  int yraw = analogRead(ypin);
  int zraw = analogRead(zpin);

  // ---- STEP 3: convert to g, compute the magnitude,
  //              send, and update the LCD ----
  float ax = (analogRead(xpin) - X_ZERO) / X_COUNTS_PER_G;
  float ay = (analogRead(xpin) - Y_ZERO) / Y_COUNTS_PER_G;
  float az = (analogRead(xpin) - Z_ZERO) / Z_COUNTS_PER_G;

  float mag = sqrt(ax * ax + ay * ay + az * az);

  Serial.print(ax, 3);
  Serial.print(",");
  Serial.print(ay, 3);
  Serial.print(",");
  Serial.print(az, 3);

  myScreen.gText(40, 40, String(ax, 2) + "    ", yellowColour);
  myScreen.gText(40, 60, String(ay, 2) + "    ", yellowColour);
  myScreen.gText(40, 80, String(az, 2) + "    ", yellowColour);

  // ---- STEP 4: detect free fall followed by impact ----
  if (mag < FREEFALL_G && !inFreeFall) {
    inFreeFall = true;
    freefallTime = millis();
  }

  if (inFreeFall && (millis() - freefallTime) > FALL_WINDOW_MS) {
    inFreeFall = false;
  }

  if (inFreeFall && mag > IMPACT_G) {
    inFreeFall = false;
    fallFlag = 1;  // free fall followed by impact
    alertTime = millis();
    beep(2000, 200);  // 2 khz alert for 200ms
  }

  if (fallFlag == 1 && (millis() - alertTime) > 2000) {
    fallFlag = 0;  // clear the alert after 2 seconds
  }

  Serial.print(",");
  Serial.print(fallFlag);

  myScreen.gText(5, 105, fallFlag ? "** FALL **    " : "              ", redColour);

  Serial.println();
  delay(sampling_period);  // ---- STEP 1: your sample interval, in ms ----
}
