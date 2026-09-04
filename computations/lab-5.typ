#let results;
#{
  import "utils.typ" as utils
  import "@preview/spreet:0.2.0" as spreet

  let area = calc.pow(30e-6, 2)
  let splitcv-data = spreet
    .decode(read(
      "/data/splitcv-data.xlsx",
      encoding: none,
    ))
    .values()
    .map(sheet => sheet.filter(utils.filter-only-floats))
    .map(sheet => {
      let data = sheet.map(row => (V: row.at(0), C: row.at(1)))
      let C-min = data.map(row => row.C).reduce(calc.min)
      data = data.map(row => row + (C-norm: (row.C - C-min) / area, Q-inv: 0))
      data = data
        .enumerate()
        .map(pair => {
          let (index, value) = pair
          (
            value
              + (
                Q-inv: if index == 0 {
                  value.Q-inv
                } else {
                  let prev-value = data.at(index - 1)
                  (
                    (
                      (value.C-norm + prev-value.C-norm)
                        * (value.V - prev-value.V)
                    )
                      / (2 * utils.q)
                      + prev-value.Q-inv
                  )
                },
              )
          )
        })
      data
    })

  let idvg-data = spreet
    .decode(read("/data/idvg-data.xlsx", encoding: none))
    .values()
    .map(sheet => sheet.slice(1).map(row => (I-d: row.at(6), V-g: row.at(2))))

  results = (splitcv-data: splitcv-data, idvg-data: idvg-data)
}
