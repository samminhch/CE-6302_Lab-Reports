#let undergrad-lab-report(
  title,
  subtitle,
  cover-page-footer,
  course,
  authors,
  instructor,
  teaching-assistants,
  date,
  styles,
  body
) = {
  import "schemas.typ": *

  valkyrie.parse(title, valkyrie.string)
}