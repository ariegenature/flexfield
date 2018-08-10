<template>
  <b-table id="observations" :data="tableData" :bordered="false" :striped="false" :narrowed="true"
           :hoverable="true" :mobile-cards="true" detailed detail-key="id" focusable class="is-size-7"
           :selected.sync="selectedFeature" paginated :per-page="10" :current-page.sync="currentPage"
           pagination-size="is-small">
    <template slot-scope="props">
      <b-table-column label="id" :visible="false">
        {{ props.row.id }}
      </b-table-column>
      <b-table-column label="Date" numeric>
        {{ props.row.dc_date.toLocaleDateString() }}
      </b-table-column>
      <b-table-column label="Sujet">
        {{ props.row.dc_subject }}
      </b-table-column>
      <b-table-column label="Observateur(s)">
        {{ props.row.observers.join(', ') }}
      </b-table-column>
      <b-table-column>
        <a v-if="props.row.can_edit" @click="emitEdit(props.row.id)">
          <b-icon icon="pencil" type="is-info" size="is-small"></b-icon>
        </a>
        <a v-if="props.row.can_edit" @click="emitDelete(props.row.id)">
          <b-icon icon="delete" type="is-danger" size="is-small"></b-icon>
        </a>
      </b-table-column>
    </template>
    <template slot="detail" slot-scope="props">
      <div class="columns is-multiline is-centered">
        <div class="column is-half is-paddingless has-text-centered" v-for="(v, k) in props.row" :key="k"
             v-if="k.startsWith('ui_') && v">
          <div class="content is-size-7">
            <p><strong>{{ k | trimFirstThree }}&nbsp;:</strong> <span>{{ v }}</span></p>
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
      currentPage: 1,
      tableData: [],
      selectedFeature: null
    }
  },
  computed: mapGetters([
    'observations',
    'selectedFeatureId'
  ]),
  filters: {
    trimFirstThree (s) {
      if (s.length < 4) return ''
      s = s.toString()
      return s.substring(3)
    }
  },
  methods: {
    emitEdit (featureId) {
      var feature = this.observations.features.find((feature) => feature.id === featureId)
      this.$emit('edit-click', feature)
    },
    emitDelete (featureId) {
      this.$emit('delete-click')
    },
    ...mapActions([
      'updateSelectedFeatureId'
    ])
  },
  watch: {
    observations: {
      handler (val, oldVal) {
        this.tableData = []
        if (val && val.features) {
          val.features.forEach((feature) => {
            this.tableData.push(Object.assign({}, { id: feature.id }, feature.properties))
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
          const selectedFeature = this.tableData.find((feature) => feature.id === this.selectedFeatureId)
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
