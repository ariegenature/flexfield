<template>
  <main class="hero is-fullheight">
  <div class="hero-head">
    <navbar></navbar>
  </div>
  <div id="hero" class="hero-body">
    <div id="main-container" class="container is-fluid is-marginless">
      <div class="columns">
        <div class="column is-three-fifths is-paddingless">
          <div id="map">
            <main-map @new-geometry="createNewFeature"></main-map>
          </div>
        </div>
        <div class="column is-paddingless">
          <observation-table></observation-table>
        </div>
      </div>
    </div>
  </div>
  <b-modal id="modal" :active.sync="isModalActive" :canCancel="['escape', 'x']">
    <component :is="currentModalComponent" @form-complete="completeForm"
               @capabilities-selected="afterCapabilitiesSelected"></component>
  </b-modal>
  </main>
</template>

<script>
import { mapActions, mapGetters } from 'vuex'
import CapabilitiesForm from './CapabilitiesForm'
import MainMap from './MainMap'
import Navbar from './Navbar'
import ObservationForm from './ObservationForm'
import ObservationTable from './ObservationTable'

export default {
  name: 'Home',
  components: {
    CapabilitiesForm,
    ObservationForm,
    MainMap,
    Navbar,
    ObservationTable
  },
  data () {
    return {
      isModalActive: false
    }
  },
  computed: mapGetters([
    'currentModalComponent',
    'currentMode',
    'currentForm'
  ]),
  methods: {
    async completeForm () {
      this.clearNewFeature()
      this.closeModal()
      await this.fetchObservations()
    },
    afterCapabilitiesSelected () {
      if (this.currentMode === 'normal') {
        this.closeModal()
      } else {
        this.loadObservationForm()
      }
    },
    closeModal () {
      this.isModalActive = false
    },
    createNewFeature (geojson) {
      this.setCurrentMode('creating')
      this.setNewFeature(geojson)
      if (this.currentForm) {
        this.loadObservationForm()
      } else {
        this.loadCapabilitiesForm()
      }
      this.showModal()
    },
    showModal () {
      this.isModalActive = true
    },
    ...mapActions([
      'clearNewFeature',
      'fetchObservations',
      'loadCapabilitiesForm',
      'loadObservationForm',
      'setCurrentMode',
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
fieldset {
  border: none;
}
.form-group:not(:last-child) {
  margin-bottom: .75rem;
}
</style>
