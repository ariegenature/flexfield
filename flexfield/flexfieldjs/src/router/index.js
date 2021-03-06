import Vue from 'vue'
import Router from 'vue-router'
import Home from '@/components/Home'
import LoginPage from '@/components/LoginPage'

Vue.use(Router)

export default new Router({
  mode: 'history',
  routes: [
    {
      path: '/webcli',
      name: 'home',
      component: Home
    },
    {
      path: '/login',
      name: 'login',
      component: LoginPage
    },
    {
      path: '/',
      redirect: '/webcli'
    }
  ]
})
