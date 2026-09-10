#include "Screen_HX8353E.h"

Screen_HX8353E myScreen;

const int xpin = 2;   // joystick X
const int ypin = 26;  // joystick Y

// ---- STEP 3: add the joystick range constants here ----
const int RAW_MIN = 1000;
const int RAW_MAX = 15000;

// ---- STEP 2: add the pad() helper function here ----
// add spaces so every number takes the same width on screen
String pad(int value, int width) {
  String s = String(value);
  while (s.length() < width) s += " ";
  return s;
}

void setup() {
  // --- STEP 2: start Serial and set the converter resolution here ----
  myScreen.begin();
  myScreen.setOrientation(0);
  myScreen.clear(blackColour);
  myScreen.setFontSize(1);

  // ---- STEP 1: write the title here ----
  myScreen.gText(5, 10, "Joystick", greenColour);

  // ---- STEP 2: write the X and Y labels here ----
  Serial.begin(9600);
  analogReadResolution(14); // Update resolution here

  // ---- STEP 3: write the column headings here ----
  myScreen.gText(5, 25, "raw   0-9", greenColour);
}

void loop() {
  // ---- STEP 2: read the joystick, show and print the raw values ----
  myScreen.gText(5, 40, "X:", whiteColour);
  myScreen.gText(5, 60, "Y:", whiteColour);

  int xraw = analogRead(xpin);
  int yraw = analogRead(ypin);

  myScreen.gText(35, 40, pad(xraw, 5), yellowColour);
  myScreen.gText(35, 60, pad(yraw, 5), yellowColour);

  Serial.print("X: ");
  Serial.print(xraw);
  Serial.print("   Y: ");
  Serial.print(yraw);

  // ---- STEP 3: convert the readings to 0-9 and show them ----
  int xlevel = constrain(map(xraw, RAW_MIN, RAW_MAX, 0, 9), 0, 9);
  int ylevel = constrain(map(yraw, RAW_MIN, RAW_MAX, 0, 9), 0, 9);
  // ---- STEP 4: apply constrain() to these two lines ----

  delay(200);
}