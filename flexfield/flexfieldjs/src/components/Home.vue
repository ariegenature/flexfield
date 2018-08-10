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
            <main-map @new-geometry="showCreateForm"
                      @geometry-updated="saveGeometries"></main-map>
          </div>
        </div>
        <div class="column is-paddingless">
          <observation-table @edit-click="showUpdateForm"></observation-table>
        </div>
      </div>
    </div>
  </div>
  <b-modal id="modal" :active.sync="isModalActive" :canCancel="['escape', 'x']">
    <component :is="currentModalComponent" @form-complete="saveFormData"
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
    async saveFormData () {
      this.hideModal()
      if (this.currentMode === 'creating') {
        this.addCurrentFeatureForCreation()
      } else if (this.currentMode === 'updating') {
        this.addCurrentFeatureForUpdate()
      }
      await this.saveFeatures()
      await this.fetchObservations()
      this.setCurrentMode('normal')
    },
    async saveGeometries (features) {
      this.setCurrentMode('updating')
      features.forEach((feature) => {
        this.addFeatureForUpdate(feature)
      })
      await this.saveFeatures()
      await this.fetchObservations()
      this.setCurrentMode('normal')
    },
    afterCapabilitiesSelected () {
      if (this.currentMode === 'normal') {
        this.hideModal()
      } else {
        this.loadObservationForm()
      }
    },
    hideModal () {
      this.isModalActive = false
    },
    showCreateForm (feature) {
      this.setCurrentMode('creating')
      this.setCurrentFeature(feature)
      if (this.currentForm) {
        this.loadObservationForm()
      } else {
        this.loadCapabilitiesForm()
      }
      this.showModal()
    },
    showUpdateForm (feature) {
      this.setCurrentMode('updating')
      this.setCurrentFeature(feature)
      this.loadObservationForm()
      this.showModal()
    },
    showModal () {
      this.isModalActive = true
    },
    ...mapActions([
      'addCurrentFeatureForCreation',
      'addCurrentFeatureForUpdate',
      'addFeatureForUpdate',
      'fetchObservations',
      'loadCapabilitiesForm',
      'loadObservationForm',
      'saveAndClearCurrentFeature',
      'saveFeatures',
      'setCurrentFeature',
      'setCurrentFeatureProperties',
      'setCurrentMode'
    ])
  },
  watch: {
    notification: {
      handler (val, oldVal) {
        if (val) {
          this.$toast.open(val)
        }
      }
    }
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
