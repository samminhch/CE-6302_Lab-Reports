#import "@preview/codly:1.3.0": *
#show: codly-init

#import "@preview/codly-languages:0.1.10": *
#codly(languages: codly-languages)

= Introduction
The purpose of this laboratory is to serve as an introduction to microcontroller programming on the Texas Instruments (TI) LaunchPad.

= Procedure

== Pre-Requisite

+ Attach the TI BoostPack MKII onto the LaunchPad.
+ Connect the TI LaunchPad to the device that will be used to upload the firmware
+ Install the necessary software required to program and upload the Arduino code firmware onto the TI LaunchPad:
  + Install either the *Arduino IDE* or *Arduino CLI*
  + If you're on Windows, install the *emupack* driver from Texas Instruments (#link("https://software-dl.ti.com/ccs/esd/documents/xdsdebugprobes/emu_xds_software_package_download.html"))
  + If you're on MacOS, you don't have to do anything
  + If you're on Linux, add the udev rules from #link("https://github.com/Andy4495/TI_Platform_Cores_For_Arduino/raw/refs/heads/main/extras/71-ti-permissions.rules")
  + Add the Arduino board manager URL from #link("https://github.com/Andy4495/TI_Platform_Cores_For_Arduino/raw/refs/heads/main/json/package_energia_optimized_index.json")
  + Install this package from the boards manager: `energia:msp432 (5.30.0)`, and set this as the board: `energia:msp432:MSP-EXP432P401R`

== Writing the Firmware

The following steps will be builing off of @listing:starting-template

#figure(
  ```cpp
  #include "Screen_HX8353E.h"

  Screen_HX8353E myScreen;

  const int xpin = 2;   // joystick X
  const int ypin = 26;  // joystick Y

  // ---- STEP 3: add the joystick range constants here ----
  // ---- STEP 2: add the pad() helper function here ----

  void setup() {
    // ---- STEP 2: start Serial and set the converter resolution here ----
    // ---- STEP 1: write the title here ----
    // ---- STEP 2: write the X and Y labels here ----
    // ---- STEP 3: write the column headings here ----
  }

  void loop() {
    // ---- STEP 2: read the joystick, show and print the raw values ----
    // ---- STEP 3: convert the readings to 0-9 and show them ----
    // ---- STEP 4: apply constrain() to these two lines ----

    delay(200);
  }
  ```,
  caption: [Initial Arduino sketch template for this laboratory]
)<listing:starting-template>

= Discussion

= Conclusion
