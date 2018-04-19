import Vue from 'vue'
import Vuex from 'vuex'
import { $get } from '../plugins/api'

Vue.use(Vuex)

export default new Vuex.Store({
  state () {
    return {
      user: null
    }
  },
  getters: {
    user: (state) => state.user
  },
  mutations: {
    user: (state, obj) => {
      state.user = obj
    }
  },
  actions: {
    async init ({ dispatch }) {
      await dispatch('updateUser')
    },
    async updateUser ({ commit }) {
      try {
        const user = await $get('/backend/user')
        commit('user', user.data)
      } catch (e) {
        console.warn(e)
        commit('user', null)
      }
    }
  }
})
