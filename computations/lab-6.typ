#let results;
#{
  import "@preview/spreet:0.2.0"
  import "utils.typ" as utils
  let sio2-data = spreet.decode(read("/data/sio2-data.xlsx", encoding: none))
  let temp = sio2-data
    .keys()
    .map(sheet-name => {
      let sheet = sio2-data.at(sheet-name)
      let keys = sheet.at(0)
      let rows = sheet.slice(1)

      keys
        .enumerate()
        .map(pair => {
          let (i, key) = pair
          if i == 0 { key = "v-base" }
          (key, rows.map(row => row.at(i)))
        })
        .to-dict()
    })
  sio2-data = sio2-data.keys().zip(temp).to-dict()

  // leakage correction technique
  let temp = sio2-data
    .at("20A_SiO2")
    .pairs()
    .map(pair => {
      let (key, value) = pair
      if not (key == "1MHz" or key == "100kHz") {
        return pair
      }
      value = value
        .enumerate()
        .map(it => {
          let (idx, value) = it
          value - sio2-data.at("20A_SiO2").at("1kHz").at(idx)
        })

      (key, value)
    })
    .to-dict()

  let _ = temp.remove("1kHz")
  let _ = temp.remove("10kHz")

  sio2-data.insert("20A_SiO2", temp)

  let get_nit(sheet-name, data) = data
    .keys()
    .filter(key => not key == "v-base")
    .map(frequency => {
      let unit-location = frequency.match("Hz").start - 1
      let suffix = frequency.at(unit-location)
      let si-conversions = (
        "M": 1e6,
        "k": 1e3,
      )

      let f = (
        float(frequency.slice(0, unit-location)) * si-conversions.at(suffix)
      )

      let device_area = 1e-7 // width * length, from video

      (
        "nit-" + frequency,
        sio2-data
          .at(sheet-name)
          .at(frequency)
          .map(it => it / (device_area * f * utils.q)),
      )
    })
    .to-dict()

  for (sheet-name, data) in sio2-data.pairs() {
    let nit = get_nit(sheet-name, data)
    for (key, value) in nit.pairs() {
      sio2-data.at(sheet-name).insert(key, value)
    }
  }

  let hik-raw = spreet.decode(read("/data/hik-data.xlsx", encoding: none))
  hik-raw = hik-raw
    .pairs()
    .map(pair => {
      let (name, data) = pair
      let headers = data.at(0).map(header => header.trim())
      let frequencies-str = headers
        .filter(header => header.contains("Hz"))
        .map(it => it.slice(0, it.match("Hz").end))

      data = data.slice(1)
      (
        name,
        headers
          .enumerate()
          .map(pair => {
            let (index, header) = pair
            if header == "VPEAK" {
              header = "v-amp_"
            }
            (header.trim(), data.map(it => it.at(index)))
          })
          .to-dict(),
      )
    })
    .to-dict()

  results = (sio2-data: sio2-data, hik-data: hik-raw)
}
