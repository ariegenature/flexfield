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
            <main-map @new-geometry="setNewFeature"></main-map>
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
  </main>
</template>

<script>
import { mapActions } from 'vuex'
import MainMap from './MainMap'
import Navbar from './Navbar'

export default {
  name: 'Home',
  components: {
    MainMap,
    Navbar
  },
  methods: mapActions([
    'setNewFeature'
  ])
}
</script>

<style>
#hero, #main-container {
  height: 100%;
}
#map {
  height: 80vh;
}
</style>
