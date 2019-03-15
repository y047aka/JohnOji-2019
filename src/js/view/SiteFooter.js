import { span, footer, p, a } from '@hyperapp/html'

export default () =>
  footer({ class: 'site-footer' }, [
    p({ class: 'copyright' }, [
      span({ class: 'copyright', innerHTML: ['&copy; 2019 '] }),
      a({ href: 'https://y047aka.me', target: '_blank' }, 'y047aka')
    ])
  ])
