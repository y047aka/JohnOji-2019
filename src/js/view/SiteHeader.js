import { div, header, h1, p, img } from '@hyperapp/html'

export default () =>
  header({ class: 'site-header' }, [
    h1('Leaderboard')
  ])
