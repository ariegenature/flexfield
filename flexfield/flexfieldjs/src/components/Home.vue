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
            <p class="title is-6">Dernières observations</p>
            <observation-table></observation-table>
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
import { mapActions, mapGetters } from 'vuex'
import CapabilitiesForm from './CapabilitiesForm'
import FieldForm from './FieldForm'
import MainMap from './MainMap'
import Navbar from './Navbar'
import ObservationTable from './ObservationTable'

export default {
  name: 'Home',
  components: {
    CapabilitiesForm,
    FieldForm,
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
    'currentModalComponent'
  ]),
  methods: {
    createNewFeature (geojson) {
      this.setNewFeature(geojson)
      this.loadCapabilitiesForm()
      this.showModal()
    },
    showModal () {
      this.isModalActive = true
    },
    ...mapActions([
      'loadCapabilitiesForm',
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
