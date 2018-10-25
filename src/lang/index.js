import VueI18n from 'vue-i18n'
import Cookies from 'js-cookie'
import enLocale from './en'
import zhLocale from './zh'

const messages = {
  en: {
    ...enLocale
  },
  zh: {
    ...zhLocale
  }
}

const navigatorLanguage = (navigator.language || navigator.userLanguage).substr(0, 2)
const cookieLanguage = Cookies.get('lang')

export const lang = cookieLanguage || navigatorLanguage || 'en'

const i18n = new VueI18n({
  locale: lang, // set locale
  messages // set locale messages
})

export function language (key) {
  var keys = (lang + '.' + key).split('.')
  var tmp = messages
  for (const e of keys) {
    if (!tmp[e]) {
      return key
    }
    tmp = tmp[e]
  }
  return tmp
}

// 根据语言改变窗口的title
if (lang === 'en') {
  document.title = 'miaomiao study'
} else {
  document.title = 'miaomiao联系'
}

export default i18n
