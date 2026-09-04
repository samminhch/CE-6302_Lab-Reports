#let results;
#{
  import "@preview/spreet:0.2.0"
  import "utils.typ" as utils
  let data-raw = spreet.decode(read(
    "/data/LabWork4_BTI_Data.xlsx",
    encoding: none,
  ))

  let dataset-1 = data-raw
    .DataSet1
    .slice(1)
    .map(row => {
      (
        V-g: row.at(0),
        I-d: row.slice(1, 19),
        time: row.at(21),
        Vt-shift: row.at(23),
        gm-shift: row.at(27),
      )
    })

  let dataset-2 = data-raw.DataSet2
  let dataset-3 = data-raw.DataSet3

  let process-dataset(dataset) = {
    let groups = (1, 18, 35).map(row-num => {
      (start: row-num, end: row-num + 14)
    })
    let result = (:)

    for group in groups {
      let stress-voltage = dataset.at(group.start).at(11)
      let data-group = dataset.slice(group.start, group.end)
      result.insert(str(stress-voltage), (
        time: data-group.map(row => row.at(0)),
        V-t: data-group.map(row => row.at(1)),
        gm-max: data-group.map(row => row.at(2)),
        deg-gm-max: data-group.map(row => row.at(6)),
        delta-Vt: data-group.map(row => row.at(8)),
      ))
    }
    result
  }

  results = (
    dataset-1: (
      V-g: dataset-1.map(col => col.V-g),
      I-d: range(0, 18).map(idx => dataset-1.map(row => row.I-d.at(idx))),
      time: dataset-1.map(col => col.time).filter(row => type(row) == float),
      Vt-shift: dataset-1
        .map(col => col.Vt-shift)
        .filter(row => type(row) == float),
      gm-shift: dataset-1
        .map(col => col.gm-shift)
        .filter(row => type(row) == float),
    ),
    dataset-2: process-dataset(dataset-2),
    dataset-3: process-dataset(dataset-3),
  )
}
