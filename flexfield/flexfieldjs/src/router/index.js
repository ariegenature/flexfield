import Vue from 'vue'
import Router from 'vue-router'
import Home from '@/components/Home'
import LoginPage from '@/components/LoginPage'
import store from '@/store'

Vue.use(Router)

const router = new Router({
  mode: 'history',
  routes: [
    {
      path: '/webcli',
      name: 'home',
      component: Home,
      meta: {
        private: true
      }
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

router.beforeEach((to, from, next) => {
  const user = store.getters.user
  if (to.meta.private && !user) {
    next({
      name: 'login',
      params: {
        wantedRoute: to.fullPath
      }
    })
    return
  }
  next()
})

export default router
