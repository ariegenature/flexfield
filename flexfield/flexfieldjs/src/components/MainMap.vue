<template>
  <l-map ref="map" :zoom="zoom" :center="center" @l-draw-created="emitNewGeometry">
    <l-tile-layer :url="tileURL" :attribution="tileAttrib"></l-tile-layer>
    <l-geojson ref="observations" :geojson="observations" v-if="observations !== null"
               :options="observationLayerOptions"></l-geojson>
    <l-geojson ref="new-feature" :geojson="newFeature"
               v-if="newFeature !== null"></l-geojson>
    <leaflet-draw></leaflet-draw>
  </l-map>
</template>

<script>
import { mapGetters } from 'vuex'
import L from 'leaflet'
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
      tileAttrib: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors',
      observationLayerOptions: {
        pointToLayer: function (feature, latlng) {
          return L.circleMarker(latlng, {
            radius: 4,
            weight: 1,
            color: '#7A3432',
            opacity: 1,
            fillColor: feature.properties.color,
            fillOpacity: 1,
            className: 'contribution'
          })
        },
        onEachFeature: function (feature, layer) {
          layer.bindPopup(`<div class="media">
            <div class="media-content">
            <div class="content">
            <p style="margin-top: 0; margin-bottom: 0">
            <strong>${feature.properties.subject}</strong>
            <br>
            <span class="has-text-grey">${feature.properties.observation_date.toLocaleDateString()}</span>
            <br>
            <small>
            <span>Observateur(s)&nbsp;:&nbsp;</span> <span class="has-text-info">${feature.properties.observers}</span>
            </small>
            </p>
            </div>
            </div>
            </div>`)
        }
      }
    }
  },
  computed: mapGetters([
    'newFeature',
    'observations'
  ]),
  methods: {
    emitNewGeometry (ev) {
      this.$emit('new-geometry', ev.layer.toGeoJSON())
    }
  }
}
</script>
