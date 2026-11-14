#import "@preview/lilaq:0.6.0" as lq
#import "@preview/unify:0.8.1": qty, unit

#let (power-diagram, energy-diagram, lpm0-stats, lpm3-stats) = {
  let get-stats(data) = {
    let time = data.at("Time:ulong")
    let power = data.at("Power:float")

    (
      sleep: calc.min(..power),
      led-on: calc.max(..power),
      led-off: calc.min(
        ..time.zip(power)
        .filter(((t, _)) => (t >= 0 and t < 6) or (t >= 15 and t <= 20))
        .map(((_, p)) => p)
      )
    )
  }

  let lpm0 = lq.load-txt(
    read("../assets/lab11/lpm0.csv").replace("\"", ""),
    header: true,
    skip-rows: 0,
  )
  let lpm3 = lq.load-txt(
    read("../assets/lab11/lpm3.csv").replace("\"", ""),
    header: true,
    skip-rows: 0,
  )

  /*
  Time:ulong (ns -> s)
  Energy:float (uJ -> mJ)
  Power:float (mW)
  */
  let sample-size = 16 // we do _not_ need to plot all the points
  lpm0.at("Time:ulong") = lpm0
    .at("Time:ulong")
    .chunks(sample-size)
    .map(it => it.first() / calc.pow(10, 9))
  lpm0.at("Energy:float") = lpm0
    .at("Energy:float")
    .chunks(sample-size)
    .map(it => it.first() / calc.pow(10, 3))
  lpm0.at("Power:float") = lpm0
    .at("Power:float")
    .chunks(sample-size)
    .map(it => it.first())

  lpm3.at("Time:ulong") = lpm3
    .at("Time:ulong")
    .chunks(sample-size)
    .map(it => it.first() / calc.pow(10, 9))
  lpm3.at("Energy:float") = lpm3
    .at("Energy:float")
    .chunks(sample-size)
    .map(it => it.first() / calc.pow(10, 3))
  lpm3.at("Power:float") = lpm3
    .at("Power:float")
    .chunks(sample-size)
    .map(it => it.first())

  let diagram-config = (
    width: 4in,
    height: 1.6in,
    xlabel: [Time (#unit("s"))],
    legend: (position: left + top, dx: 100% + 0.5em),
  )

  let power-diagram = lq.diagram(
    ..diagram-config,
    ylabel: [Power (#unit("mW"))],
    lq.plot(
      lpm0.at("Time:ulong"),
      lpm0.at("Power:float"),
      mark: none,
      label: $"lpm"_0$,
    ),
    lq.plot(
      lpm3.at("Time:ulong"),
      lpm3.at("Power:float"),
      mark: none,
      label: $"lpm"_3$,
    ),
  )
  let energy-diagram = lq.diagram(
    ..diagram-config,
    ylabel: [Energy (#unit("mJ"))],
    lq.plot(
      lpm0.at("Time:ulong"),
      lpm0.at("Energy:float"),
      mark: none,
      label: $"lpm"_0$,
    ),
    lq.plot(
      lpm3.at("Time:ulong"),
      lpm3.at("Energy:float"),
      mark: none,
      label: $"lpm"_3$,
    ),
  )

  (power-diagram, energy-diagram, get-stats(lpm0), get-stats(lpm3))
}

#set page(width: auto, height: auto, margin: 0in)

#power-diagram
#pagebreak()
#energy-diagram
