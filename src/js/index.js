// libraries
import axios from 'axios'

// Hyperapp
import { app } from 'hyperapp'
import { div, main } from '@hyperapp/html'

// views
import SiteHeader from './view/SiteHeader'
import SiteFooter from './view/SiteFooter'
import Leaderboard from './view/Leaderboard'

// hyperapp/time.js
export const delay = (fx => (action, { duration }) => [
  fx,
  { action, duration }
])((props, dispatch) =>
  setTimeout(() => dispatch(props.action), props.duration)
)

const changeName = (state, name) => ({ ...state, name })

const view = state => (
  div({}, [
    SiteHeader(),
    main([
      Leaderboard(state)
    ]),
    SiteFooter()
  ])
)

window.onload = async () => {
  const standings = await axios.get('https://y047aka.github.io/MotorSportsData/races/WEC/Sebring1000miles.json').catch(e => { console.log(e) })

  app({
    init: standings.data,
    view: view,
    container: document.body
  })
}