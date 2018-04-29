<template>
  <b-table id="observations" :data="observations" :bordered="false" :striped="false" :narrowed="true"
           :hoverable="true" :mobile-cards="true" detailed detail-key="id" focusable class="is-size-7">
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
        <div class="column is-narrow" v-for="(v, k) in props.row" :key="k"
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
export default {
  name: 'ObservationTable',
  data () {
    return {
      observations: [
        {
          id: 1,
          'observation_date': new Date(),
          subject: 'minus minus',
          observers: 'Yann Voté, Thomas Cuypers, Cécile Brousseau',
          'Type de contact': 'Vu et entendu',
          'Effectif': '~ 5-6',
          'Remarques': 'qezrfgq qsdf qfsz qSEDF QSDGF QfsESDFGH DSGFQSGQZDV QSDFQSDFQEZVRG qergqerfgqergqerg'
        }
      ]
    }
  }
}
</script>

<style>
#observations {
  height: 75vh;
}
</style>
