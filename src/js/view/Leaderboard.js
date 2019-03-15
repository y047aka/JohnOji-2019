import { section, h1, table, tr, th, td } from '@hyperapp/html'

const TableHead = state =>
  tr([
		th('Pos'),
		th('#'),
    th('Driver'),
    th(''),
    th('Laps'),
    th('Delta'),
    th('Last Lap'),
    th('kph'),
    th('Pit Stops')
//    th('Last Pit')
  ])

const Vehicle = v =>
  tr([
    td(v.ranking),
    td(v.number),
    td(v.driver),
    td({ Chv: 'Chevrolet', Frd: 'Ford', Tyt: 'Toyota' }[v.vehicle_manufacturer]),
    td(v.lap),
    td(v.gap === "" ? "-" : v.gap),
    td(v.lastlap),
    td(v.speed),
    td(v.pitstop)
//    td(v.pit_stops.reverse()[0].pit_in_lap_count)
  ])

export default state =>
  section([
		h1(state.params.eventName),
    table({ class: 'leaderboard' }, [
			TableHead(),
      state.entries.map(vehicle =>
        Vehicle(vehicle)
      )
    ])
  ])