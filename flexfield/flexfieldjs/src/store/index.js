import Vue from 'vue'
import Vuex from 'vuex'
import { $get } from '../plugins/api'

Vue.use(Vuex)

export default new Vuex.Store({
  state () {
    return {
      currentStudy: null,
      newFeature: null,
      user: null,
      userCapabilities: null
    }
  },
  getters: {
    currentStudy: (state) => state.currentStudy,
    newFeature: (state) => state.newFeature,
    user: (state) => state.user,
    userCapabilities: (state) => state.userCapabilities
  },
  mutations: {
    currentStudy: (state, obj) => {
      state.currentStudy = obj
    },
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
    setCurrentStudy ({ commit, state }, code) {
      const study = state.userCapabilities.available_studies.find(study => study.code === code)
      commit('currentStudy', study)
    },
    setNewFeature ({ commit }, feature) {
      commit('newFeature', feature)
    }
  }
})
