/*
 * [INFO] If you want to edit the lab report data:
 * + Go to `reports/lab-#.typ`
 * + Use the file explorer to view the files
 */

// Change this number to switch between homework assignments
// ...or use `typst compile --inputs lab-number=X main.typ` for parameterized compile
#import "lab-info.typ";

#let lab-number = sys.inputs.at("lab-number", default: 1)
#if type(lab-number) == str {
  lab-number = int(lab-number)
}

#let authors = lab-info.authors
#let course = lab-info.course
#let labs = lab-info.lab
#let current-lab = labs.at(lab-number)

#set document(
  title: "[" + course.number + "." + course.section + "] " + current-lab.title,
  author: authors.map(author => author.name),
)

#import "lib/template.typ": *
#import "@local/templates:0.2.3": undergrad-lab-report
#show: undergrad-lab-report.with(
  title: current-lab.title,
  subtitle: [Lab \##lab-number],
  authors: authors,
  instructor: course.instructor,
  teaching-assistants: course.teaching-assistants,
  course: course,
  styles: (
    title: (fonts: "Calistoga"),
    heading: (fonts: "Calistoga"),
    body: (fonts: ("Comic Neue")),
    mono: (fonts: "Maple Mono"),
    math: (fonts: ("Fira Math", "New Computer Modern Math")),
  ),
  date: current-lab.date.display(),
)
#include "reports/lab-" + str(lab-number) + ".typ"
