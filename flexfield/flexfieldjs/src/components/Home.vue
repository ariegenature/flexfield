<template>
  <main class="hero is-fullheight">
  <div class="hero-head">
    <navbar></navbar>
  </div>
  <div id="hero" class="hero-body">
    <div id="main-container" class="container is-fluid">
      <div class="columns">
        <div class="column is-three-fifths">
          <div id="map">
            <main-map @new-geometry="createNewFeature"></main-map>
          </div>
        </div>
        <div class="column">
          <div class="content">
            <p class="title is-6">Observations récentes</p>
          </div>
        </div>
      </div>
    </div>
  </div>
  <b-modal id="modal" :active.sync="isModalActive" :canCancel="['escape', 'x']">
    <component :is="currentModalComponent"></component>
  </b-modal>
  </main>
</template>

<script>
import { mapActions } from 'vuex'
import CapabilitiesForm from './CapabilitiesForm'
import MainMap from './MainMap'
import Navbar from './Navbar'

export default {
  name: 'Home',
  components: {
    CapabilitiesForm,
    MainMap,
    Navbar
  },
  data () {
    return {
      currentModalComponent: 'capabilities-form',
      isModalActive: false
    }
  },
  methods: {
    createNewFeature (geojson) {
      this.setNewFeature(geojson)
      this.openCapabilitiesForm()
    },
    openCapabilitiesForm () {
      this.curentModalComponent = 'capabilities-form'
      this.isModalActive = true
    },
    ...mapActions([
      'setNewFeature'
    ])
  }
}
</script>

<style>
#hero, #main-container {
  height: 100%;
}
#map {
  height: 80vh;
}
.modal {
  z-index: 1000 !important;
}
.modal-content {
  background-color: rgba(245, 245, 245, 1);
}
</style>
