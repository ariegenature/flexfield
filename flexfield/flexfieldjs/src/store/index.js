import Vue from 'vue'
import Vuex from 'vuex'
import { $get, $post, $put } from '../plugins/api'

Vue.use(Vuex)

export default new Vuex.Store({
  state () {
    return {
      currentFeature: null,
      currentForm: null,
      currentModalComponent: 'capabilities-form',
      currentMode: 'normal',
      currentProtocol: null,
      currentStudy: null,
      featuresToCreate: {
        type: 'FeatureCollection',
        features: []
      },
      featuresToUpdate: {
        type: 'FeatureCollection',
        features: []
      },
      notification: null,
      observations: {
        type: 'FeatureCollection',
        features: []
      },
      selectedFeatureId: null,
      user: null,
      userCapabilities: null
    }
  },
  getters: {
    currentFeature: (state) => state.currentFeature,
    currentForm: (state) => state.currentForm,
    currentModalComponent: (state) => state.currentModalComponent,
    currentMode: (state) => state.currentMode,
    currentProtocol: (state) => state.currentProtocol,
    currentStudy: (state) => state.currentStudy,
    featuresToCreate: (state) => state.featuresToCreate,
    featuresToUpdate: (state) => state.featuresToUpdate,
    notification: (state) => state.notification,
    observations: (state) => state.observations,
    selectedFeatureId: (state) => state.selectedFeatureId,
    user: (state) => state.user,
    userCapabilities: (state) => state.userCapabilities
  },
  mutations: {
    currentFeature: (state, obj) => {
      state.currentFeature = obj
    },
    currentFeatureProperties: (state, obj) => {
      state.currentFeature.properties = obj
    },
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
    notification: (state, obj) => {
      state.notification = obj
    },
    observations: (state, obj) => {
      state.observations = obj
    },
    pushFeatureToCreateCollection: (state, obj) => {
      state.featuresToCreate.features.push(obj)
    },
    pushFeatureToUpdateCollection: (state, obj) => {
      state.featuresToUpdate.features.push(obj)
    },
    noFeatureToCreate: (state) => {
      state.featuresToCreate.features.length = 0
    },
    noFeatureToUpdate: (state) => {
      state.featuresToUpdate.features.length = 0
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
    async fetchObservations ({ dispatch, state }) {
      try {
        const response = await $get(`resources/${state.currentForm.slug}`)
        var featureCollection = response.data
        featureCollection.features.forEach((feature) => {
          feature.properties.dc_date = new Date(Date.parse(feature.properties.dc_date))
        })
        dispatch('setObservations', featureCollection)
      } catch (e) {
        if (e.response.status !== 401) console.warn(e)
      }
    },
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
    async saveChangesToBackend ({ dispatch, state }, action) {
      var func
      var collection
      var successMessage
      if (action === 'create') {
        func = $post
        collection = state.featuresToCreate
        successMessage = 'Vos observations ont bien été ajoutées. Merci !'
      } else if (action === 'update') {
        func = $put
        collection = state.featuresToUpdate
        successMessage = 'Les observations ont bien été mises à jour.'
      }
      try {
        await func(`resources/${state.currentForm.slug}`, collection, {
          headers: {
            'X-CSRFToken': '«« csrf_token() »»'
          }
        })
      } catch (e) {
        console.warn(e)
        dispatch('setNotification', {
          duration: 6000,
          message: `Un problème est survenu : ${e.response.data.message}. Veuillez contacter un administrateur.`,
          type: 'is-danger'
        })
      }
      dispatch('setNotification', {
        duration: 3000,
        message: successMessage,
        type: 'is-success'
      })
    },
    async saveFeatures ({ dispatch, state }) {
      if (state.featuresToCreate.features.length > 0) {
        await dispatch('saveChangesToBackend', 'create')
      }
      if (state.featuresToUpdate.features.length > 0) {
        await dispatch('saveChangesToBackend', 'update')
      }
    },
    async setCurrentFormAndObservations ({ commit, dispatch, state }, code) {
      const form = state.currentProtocol.forms.find(form => form.code === code)
      commit('currentForm', form)
      await dispatch('fetchObservations')
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
    addCurrentFeatureForCreation ({ commit, state }) {
      commit('pushFeatureToCreateCollection', state.currentFeature)
    },
    addCurrentFeatureForUpdate ({ commit, state }) {
      commit('pushFeatureToUpdateCollection', state.currentFeature)
    },
    addFeatureForCreation: ({ commit }, feature) => {
      commit('pushFeatureToCreateCollection', feature)
    },
    addFeatureForUpdate: ({ commit }, feature) => {
      commit('pushFeatureToUpdateCollection', feature)
    },
    clearCurrentFeature: ({ commit }) => {
      commit('currentFeature', null)
    },
    loadCapabilitiesForm ({ commit }) {
      commit('currentModalComponent', 'capabilities-form')
    },
    loadObservationForm ({ commit }) {
      commit('currentModalComponent', 'observation-form')
    },
    setCurrentFeature ({ commit }, feature) {
      commit('currentFeature', feature)
    },
    setCurrentFeatureProperties ({ commit }, props) {
      commit('currentFeatureProperties', props)
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
    setNotification ({ commit }, notification) {
      commit('notification', notification)
    },
    setObservations ({ commit }, featureCollection) {
      commit('observations', featureCollection)
    },
    setUser ({ commit }, user) {
      commit('user', user)
    },
    updateSelectedFeatureId ({ commit }, id) {
      commit('selectedFeatureId', id)
    }
  }
})
