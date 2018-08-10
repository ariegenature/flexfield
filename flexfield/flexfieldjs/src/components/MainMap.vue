<template>
  <l-map ref="map" :zoom="zoom" :center="center" @l-draw-created="emitNewGeometry"
         @l-draw-edited="emitGeometryUpdated"
         @popupopen="selectFeature" @popupclose="unselectFeature">
    <l-tile-layer :url="tileURL" :attribution="tileAttrib"></l-tile-layer>
    <l-geojson ref="observations" :geojson="leafletObservations"
               :options="observationLayerOptions"></l-geojson>
    <l-geojson ref="features-to-update" :geojson="featuresToUpdate"
               :options="updatedFeaturesLayerOptions" v-if="hasFeaturesToUpdate"></l-geojson>
    <l-geojson ref="features-to-create" :geojson="featuresToCreate"
               :options="newFeaturesLayerOptions" v-if="hasFeaturesToCreate"></l-geojson>
    <l-geojson ref="current-feature" :geojson="currentFeature"
               v-if="currentFeature"></l-geojson>
    <leaflet-draw :marker="true" :polyline="false" :polygon="false" :rectangle="false"
                  :circle="false" :circle-marker="false" :edit="true" :remove="true"
                  :editableLayer="observationLayer" v-if="observationLayer"></leaflet-draw>
  </l-map>
</template>

<script>
import { mapActions, mapGetters } from 'vuex'
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
      observationLayer: null,
      defaultLayerStyle: {
        radius: 4,
        weight: 1,
        color: '#7A3432',
        opacity: 1,
        fillOpacity: 1
      }
    }
  },
  computed: {
    hasFeaturesToCreate () {
      return this.featuresToCreate.features.length > 0
    },
    hasFeaturesToUpdate () {
      return this.featuresToUpdate.features.length > 0
    },
    leafletObservations () {
      if (this.observations.features.length === 0) {
        return null
      } else {
        return this.observations
      }
    },
    observationLayerOptions () {
      return this.layerOptions(this.defaultLayerStyle, this.defaultPopupContent)
    },
    newFeaturesLayerOptions () {
      var newFeatureStyle = {}
      Object.assign(newFeatureStyle, this.defaultLayerStyle)
      newFeatureStyle.color = '#0000ff'
      return this.layerOptions(newFeatureStyle, this.defaultPopupContent)
    },
    updatedFeaturesLayerOptions () {
      var updatedFeatureStyle = {}
      Object.assign(updatedFeatureStyle, this.defaultLayerStyle)
      updatedFeatureStyle.color = '#ffff00'
      return this.layerOptions(updatedFeatureStyle, this.defaultPopupContent)
    },
    ...mapGetters([
      'currentFeature',
      'featuresToCreate',
      'featuresToUpdate',
      'observations',
      'selectedFeatureId'
    ])
  },
  methods: {
    emitGeometryUpdated (ev) {
      var updatedFeatures = []
      ev.layers.eachLayer((layer) => {
        updatedFeatures.push(layer.toGeoJSON())
      })
      this.$emit('geometry-updated', updatedFeatures)
    },
    emitNewGeometry (ev) {
      this.$emit('new-geometry', ev.layer.toGeoJSON())
    },
    layerOptions (style) {
      return {
        onEachFeature: function (feature, layer) {
          layer.bindPopup(`<div class="media">
      <div class="media-content">
      <div class="content">
      <pstyle="margin-top: 0; margin-bottom: 0">
      <strong>${feature.properties.dc_subject}</strong>
      <br>
      <span class="has-text-grey">${feature.properties.dc_date.toLocaleDateString()}</span>
      <br>
      <small>
      <span>Observateur(s)&nbsp;:&nbsp;</span> <span class="has-text-info">${feature.properties.observers}</span>
      </small>
      </p>
      </div>
      </div>
      </div>`)
        },
        pointToLayer: function (feature, latlng) {
          return L.circleMarker(latlng, style)
        },
        style
      }
    },
    selectFeature (ev) {
      this.$refs.observations.mapObject.eachLayer((layer) => {
        if (layer.isPopupOpen()) {
          this.updateSelectedFeatureId(layer.feature.id)
        }
      })
    },
    unselectFeature (ev) {
      this.updateSelectedFeatureId(null)
    },
    ...mapActions([
      'updateSelectedFeatureId'
    ])
  },
  watch: {
    selectedFeatureId: {
      handler (val, oldVal) {
        this.$refs.observations.mapObject.eachLayer((layer) => {
          if (layer.feature.id === this.selectedFeatureId) {
            layer.openPopup()
          }
        })
      }
    }
  },
  mounted () {
    this.$nextTick(function () {
      this.observationLayer = this.$refs.observations.mapObject
    })
  }
}
</script>
