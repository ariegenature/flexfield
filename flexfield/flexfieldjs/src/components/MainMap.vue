<template>
  <l-map ref="map" :zoom="zoom" :center="center" @l-draw-created="emitNewGeometry">
    <l-tile-layer :url="tileURL" :attribution="tileAttrib"></l-tile-layer>
    <l-geojson ref="new-feature" :geojson="newFeature"
               v-if="newFeature !== null"></l-geojson>
    <leaflet-draw></leaflet-draw>
  </l-map>
</template>

<script>
import { mapGetters } from 'vuex'
import LeafletDraw from './LeafletDraw'

export default {
  name: 'MainMap',
  components: {
    LeafletDraw
  },
  data () {
    return {
      center: [42.857846, 0.626220],
      zoom: 8,
      tileURL: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      tileAttrib: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
    }
  },
  computed: mapGetters([
    'newFeature'
  ]),
  methods: {
    emitNewGeometry (ev) {
      this.$emit('new-geometry', ev.layer.toGeoJSON())
    }
  }
}
</script>
