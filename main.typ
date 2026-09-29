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
)

#let lab-number = sys.inputs.at("lab-number", default: 4)
#let current-lab = labs.at(
  if type(lab-number) == str {
    int(lab-number)
  } else { lab-number },
)
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
