// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import 'babel-polyfill'
import Vue from 'vue'
import App from './App'
import Buefy from 'buefy'
import VueApi from './plugins/api'
import router from './router'
import 'buefy/lib/buefy.css'

Vue.config.productionTip = false

Vue.use(Buefy)
Vue.use(VueApi)

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  components: { App },
  template: '<App/>'
})
