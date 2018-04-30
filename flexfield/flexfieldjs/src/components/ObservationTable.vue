<template>
  <b-table id="observations" :data="properties" :bordered="false" :striped="false" :narrowed="true"
           :hoverable="true" :mobile-cards="true" detailed detail-key="id" focusable class="is-size-7"
           :selected.sync="selectedFeature">
    <template slot-scope="props">
      <b-table-column label="id" :visible="false">
        {{ props.row.id }}
      </b-table-column>
      <b-table-column label="Date" numeric>
        {{ props.row.observation_date.toLocaleDateString() }}
      </b-table-column>
      <b-table-column label="Sujet">
        {{ props.row.subject }}
      </b-table-column>
      <b-table-column label="Observateur(s)">
        {{ props.row.observers }}
      </b-table-column>
    </template>
    <template slot="detail" slot-scope="props">
      <div class="columns is-multiline is-centered">
        <div class="column is-half is-paddingless has-text-centered" v-for="(v, k) in props.row" :key="k"
             v-if="k !== 'id' && k !== 'observation_date' && k !== 'subject' && k != 'observers' && v">
          <div class="content is-size-7">
            <p><strong>{{ k }}&nbsp;:</strong> <span>{{ v }}</span></p>
          </div>
        </div>
      </div>
    </template>
  </b-table>
</template>

<script>
import { mapActions, mapGetters } from 'vuex'

export default {
  name: 'ObservationTable',
  data () {
    return {
      properties: [],
      selectedFeature: null
    }
  },
  computed: mapGetters([
    'observations',
    'selectedFeatureId'
  ]),
  methods: mapActions([
    'updateSelectedFeatureId'
  ]),
  watch: {
    observations: {
      handler (val, oldVal) {
        this.properties = []
        if (val && val.features) {
          val.features.forEach((feature) => {
            this.properties.push(Object.assign({}, { id: feature.id }, feature.properties))
          })
        }
      }
    },
    selectedFeature: {
      handler (val, oldVal) {
        if (val === oldVal) return
        if (this.selectedFeature === null) {
          this.updateSelectedFeatureId(null)
        } else {
          this.updateSelectedFeatureId(this.selectedFeature.id)
        }
      }
    },
    selectedFeatureId: {
      handler (val, oldVal) {
        if (this.selectedFeatureId === null) {
          this.selectedFeature = null
        } else {
          const selectedFeature = this.properties.find((feature) => feature.id === this.selectedFeatureId)
          this.selectedFeature = selectedFeature
        }
      }
    }
  }
}
</script>

<style>
#observations {
  height: 75vh;
}
</style>
