import Vue from 'vue'
import Vuex from 'vuex'
import { $get } from '../plugins/api'

Vue.use(Vuex)

export default new Vuex.Store({
  state () {
    return {
      currentForm: null,
      currentModalComponent: 'capabilities-form',
      currentMode: 'normal',
      currentProtocol: null,
      currentStudy: null,
      newFeature: null,
      observations: null,
      selectedFeatureId: null,
      user: null,
      userCapabilities: null
    }
  },
  getters: {
    currentForm: (state) => state.currentForm,
    currentModalComponent: (state) => state.currentModalComponent,
    currentMode: (state) => state.currentMode,
    currentProtocol: (state) => state.currentProtocol,
    currentStudy: (state) => state.currentStudy,
    newFeature: (state) => state.newFeature,
    observations: (state) => state.observations,
    selectedFeatureId: (state) => state.selectedFeatureId,
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
    currentMode: (state, s) => {
      state.currentMode = s
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
    newFeatureProperties: (state, obj) => {
      state.newFeature.properties = obj
    },
    observations: (state, obj) => {
      state.observations = obj
    },
    selectedFeatureId: (state, s) => {
      state.selectedFeatureId = s
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
    async logout ({ dispatch }) {
      try {
        await $get('/logout')
        dispatch('setUser', null)
      } catch (e) {
        if (e.response.status !== 401) console.warn(e)
      }
    },
    async setCurrentFormAndObservations ({ commit, dispatch, state }, code) {
      const form = state.currentProtocol.forms.find(form => form.code === code)
      commit('currentForm', form)
      await dispatch('fetchObservations')
    },
    async fetchObservations ({ dispatch, state }) {
      try {
        const response = await $get(`resources/${state.currentForm.slug}`)
        var featureCollection = response.data
        featureCollection.features.forEach((feature) => {
          feature.properties.observation_date = new Date(Date.parse(feature.properties.observation_date))
        })
        dispatch('setObservations', featureCollection)
      } catch (e) {
        if (e.response.status !== 401) console.warn(e)
      }
    },
    async updateUser ({ dispatch }) {
      try {
        const user = await $get('/backend/user')
        dispatch('setUser', user.data)
      } catch (e) {
        if (e.response.status !== 401) console.warn(e)
        dispatch('setUser', null)
      }
    },
    async updateUserCapabilities ({ commit, state }) {
      if (!state.user) return
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
    loadObservationForm ({ commit }) {
      commit('currentModalComponent', 'observation-form')
    },
    setCurrentMode ({ commit, state }, mode) {
      commit('currentMode', mode)
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
    },
    setObservations ({ commit }, featureCollection) {
      commit('observations', featureCollection)
    },
    setUser ({ commit }, user) {
      commit('user', user)
    },
    updateNewFeatureProperties ({ commit }, obj) {
      commit('newFeatureProperties', obj)
    },
    updateSelectedFeatureId ({ commit }, id) {
      commit('selectedFeatureId', id)
    }
  }
})
