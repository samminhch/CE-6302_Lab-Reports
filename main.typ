/*
 * [INFO] If you want to edit the lab report data:
 * + Go to `reports/lab-#.typ`
 * + Use the file explorer to view the files
 */
#let labs = (
  (
    title: "Example",
    date: datetime(day: 4, month: 9, year: 2026),
  ),
  (
    title: "Reading the Joystick and Displaying on the LCD",
    date: datetime(day: 4, month: 9, year: 2026),
  ),
  (
    title: "Accelerometer Streaming, 3D Visualization and Fall Detection",
    date: datetime(day: 11, month: 9, year: 2026),
  ),
  (
    title: "Continuous Motion Recognition",
    date: datetime(day: 18, month: 9, year: 2026),
  ),
  (
    title: "Audio Classification",
    date: datetime(day: 25, month: 9, year: 2026),
  ),
  (
    title: "Image Classification",
    date: datetime(day: 2, month: 10, year: 2026),
  ),
  (
    title: "Signal Classification",
    date: datetime(day: 9, month: 10, year: 2026),
  ),
  (
    title: "Timer Practice for MSP-EXP432P401R Launchpad",
    date: datetime(day: 16, month: 10, year: 2026),
  ),
  (
    title: "UART Communication between two MSP432 boards",
    date: datetime(day: 23, month: 10, year: 2026),
  ),
  (
    title: "SPI Communication between two MSP432 boards",
    date: datetime(day: 30, month: 10, year: 2026)
  ),
  (
    title: [I#super[2]C Communication between the TI MSP432 and Adafruit PCF8523],
    date: datetime(day: 6, month: 11, year: 2026)
  ),
  (
    title: "Low Power Mode, WDT, and EnergyTrace+",
    date: datetime(day: 13, month: 11, year: 2026)
  )
)

#let lab-number = int(sys.inputs.at("lab-number", default: 9))
#let current-lab = labs.at(lab-number)
#let lab-number = if lab-number < 10 {
  "0" + str(lab-number)
} else {
  str(lab-number)
}

#import "lib/template.typ": *
#show: undergrad-lab-report.with(
  title: [Lab #lab-number;---#current-lab.title],
  subtitle: [EEGD-CE 6302---Embedded Systems],
  group: "Group 01",
  students: ("Minh Nguyen", "Noya Azeem"),
  professor: "Tooraj Nikoubin",
  teaching-assistant: "Saeed Hashemi",
  date: current-lab.date,
)

#{
  include "reports/lab-" + lab-number + ".typ"
}
