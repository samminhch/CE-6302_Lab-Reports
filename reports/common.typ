#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.10": *

#let code(file, title: auto, title-full: true, lang: auto) = {
  let title = if title == auto {
    if title-full { file } else { file.split("/").last() }
  } else { title }
  if lang == auto {
    lang = file.split(".").last()
  }
  codly(header: [#title], header-cell-args: (align: center))
  raw(read(file), lang: lang, block: true)
}
