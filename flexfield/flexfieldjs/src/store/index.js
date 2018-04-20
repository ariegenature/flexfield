import Vue from 'vue'
import Vuex from 'vuex'
import { $get } from '../plugins/api'

Vue.use(Vuex)

export default new Vuex.Store({
  state () {
    return {
      currentForm: null,
      currentModalComponent: 'capabilities-form',
      currentProtocol: null,
      currentStudy: null,
      newFeature: null,
      user: null,
      userCapabilities: null
    }
  },
  getters: {
    currentForm: (state) => state.currentForm,
    currentModalComponent: (state) => state.currentModalComponent,
    currentProtocol: (state) => state.currentProtocol,
    currentStudy: (state) => state.currentStudy,
    newFeature: (state) => state.newFeature,
    user: (state) => state.user,
    userCapabilities: (state) => state.userCapabilities
  },
  mutations: {
    currentForm: (state, obj) => {
      state.currentForm = obj
    },
    currentModalComponent: (state, s) => {
      state.currentModalComponent = s
    },
    currentProtocol: (state, obj) => {
      state.currentProtocol = obj
    },
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
    loadCapabilitiesForm ({ commit }) {
      commit('currentModalComponent', 'capabilities-form')
    },
    loadFieldForm ({ commit }) {
      commit('currentModalComponent', 'field-form')
    },
    setCurrentForm ({ commit, state }, code) {
      const form = state.currentProtocol.forms.find(form => form.code === code)
      commit('currentForm', form)
    },
    setCurrentProtocol ({ commit, state }, code) {
      const protocol = state.currentStudy.protocols.find(protocol => protocol.code === code)
      commit('currentProtocol', protocol)
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
