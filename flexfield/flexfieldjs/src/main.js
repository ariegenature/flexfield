// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import 'babel-polyfill'
import Vue from 'vue'
import App from './App'
import Buefy from 'buefy'
import Vue2Leaflet from 'vue2-leaflet'
import VueFormGenerator from 'vue-form-generator'
import VueFormWizard from 'vue-form-wizard'
import VueApi from './plugins/api'
import fieldBInput from './components/fieldBInput'
import fieldBAutocomplete from './components/fieldBAutocomplete'
import fieldBDatepicker from './components/fieldBDatepicker'
import fieldBSelect from './components/fieldBSelect'
import router from './router'
import store from './store'
import 'buefy/lib/buefy.css'
import 'vue-form-wizard/dist/vue-form-wizard.min.css'

Vue.config.productionTip = false

Vue.use(Buefy)
Vue.use(VueApi)
Vue.use(VueFormGenerator)
Vue.use(VueFormWizard)

Vue.component('fieldBInput', fieldBInput)
Vue.component('fieldBAutocomplete', fieldBAutocomplete)
Vue.component('fieldBDatepicker', fieldBDatepicker)
Vue.component('fieldBSelect', fieldBSelect)
Vue.component('l-map', Vue2Leaflet.LMap)
Vue.component('l-tile-layer', Vue2Leaflet.LTileLayer)
Vue.component('l-geojson', Vue2Leaflet.LGeoJson)

async function main () {
  await store.dispatch('init')
  /* eslint-disable no-new */
  new Vue({
    el: '#app',
    router,
    components: { App },
    store,
    template: '<App/>'
  })
}

main()
