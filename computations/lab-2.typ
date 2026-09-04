#let results;
#{
  let idvg-data = csv("/data/dca-id-vg.csv")
  idvg-data = idvg-data
    .slice(1)
    .map(row => {
      (V-gs: float(row.at(0)), I-d: float(row.at(1)) / 1000)
    })
  results = (
    V-gs: idvg-data.map(row => row.V-gs),
    I-d: idvg-data.map(row => row.I-d),
  )
}
