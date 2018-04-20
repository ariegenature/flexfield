import Vue from 'vue'
import Vuex from 'vuex'
import { $get } from '../plugins/api'

Vue.use(Vuex)

export default new Vuex.Store({
  state () {
    return {
      newFeature: null,
      user: null,
      userCapabilities: null
    }
  },
  getters: {
    newFeature: (state) => state.newFeature,
    user: (state) => state.user,
    userCapabilities: (state) => state.userCapabilities
  },
  mutations: {
    newFeature: (state, obj) => {
      state.newFeature = obj
    },
    user: (state, obj) => {
      state.user = obj
    },
    userCapabilities: (state, obj) => {
      state.userCapabilities = obj
    }
  },
  actions: {
    async init ({ dispatch }) {
      await dispatch('updateUser')
      await dispatch('updateUserCapabilities')
    },
    async updateUser ({ commit }) {
      try {
        const user = await $get('/backend/user')
        commit('user', user.data)
      } catch (e) {
        console.warn(e)
        commit('user', null)
      }
    },
    async updateUserCapabilities ({ commit, state }) {
      try {
        const caps = await $get(`/backend/user-capabilities/${state.user.username}`)
        commit('userCapabilities', caps.data)
      } catch (e) {
        console.warn(e)
        commit('userCapabilities', null)
      }
    },
    clearNewFeature: ({ commit }) => {
      commit('newFeature', null)
    },
    setNewFeature ({ commit }, feature) {
      commit('newFeature', feature)
    }
  }
})
