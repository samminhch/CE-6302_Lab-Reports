#let results;
#{
  import "@preview/spreet:0.2.0"
  import "utils.typ" as utils
  let R-L = 100 // Load resistor, in Ohms
  let V-dd = 100e-3
  let measured-pv-data = csv("/data/mosfet-time-measurement.csv")
    .slice(1)
    .map(row => {
      let nums = row.map(num => float(num))
      let vals = (time: nums.at(0), V-g: nums.at(1), V-d: nums.at(2))
      let I-d = V-dd / vals.V-d * (V-dd - vals.V-d) / R-L
      vals.insert("I-d", I-d)
      vals
    })

  let sio2-pv-data = spreet
    .decode(read(
      "/data/Lab7_PIVcomp_SiO2.xlsx",
      encoding: none,
    ))
    .Sheet1
    .filter(utils.filter-only-floats)
    .map(row => {
      (
        pulsed: (V-g: row.at(0), I-d: row.at(1)),
        dc: (V-g: row.at(2), I-d: row.at(3)),
      )
    })

  let hik-pv-data = spreet.decode(read(
    "/data/Lab7_PIVcomp_HK.xlsx",
    encoding: none,
  ))
  hik-pv-data.HighK_DC = hik-pv-data
    .HighK_DC
    .filter(utils.filter-only-floats)
    .map(row => (V-g: row.at(0), I-d: row.at(1)))
  hik-pv-data.HighK_PIV = hik-pv-data
    .HighK_PIV
    .filter(utils.filter-only-floats)
    .map(row => (V-g: row.at(0), I-d: row.at(1)))
  let hik-time-data = spreet
    .decode(read(
      "/data/Lab7_PIV_TimeScale_HK.xlsx",
      encoding: none,
    ))
    .Sheet1
    .filter(utils.filter-only-floats)
    .map(row => (time: row.at(0), I-d: row.at(1)))

  results = (
    measured-pv-data: (
      time: measured-pv-data.map(row => row.time),
      V-g: measured-pv-data.map(row => row.V-g),
      V-d: measured-pv-data.map(row => row.V-d),
      I-d: measured-pv-data.map(row => row.I-d),
    ),
    sio2-pv-data: (
      pulsed: (
        V-g: sio2-pv-data.map(row => row.pulsed.V-g),
        I-d: sio2-pv-data.map(row => row.pulsed.I-d),
      ),
      dc: (
        V-g: sio2-pv-data.map(row => row.dc.V-g),
        I-d: sio2-pv-data.map(row => row.dc.I-d),
      ),
    ),
    hik-data: (
      dc: (
        V-g: hik-pv-data.HighK_DC.map(row => row.V-g),
        I-d: hik-pv-data.HighK_DC.map(row => row.I-d),
      ),
      pulsed: (
        V-g: hik-pv-data.HighK_PIV.map(row => row.V-g),
        I-d: hik-pv-data.HighK_PIV.map(row => row.I-d),
      ),
      timed: (
        time: hik-time-data.map(row => row.time),
        I-d: hik-time-data.map(row => row.I-d),
      ),
    ),
  )
}
