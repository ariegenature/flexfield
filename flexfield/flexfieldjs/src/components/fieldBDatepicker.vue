<template>
  <b-field :label="schema.fieldLabel" :type="schema.styleClasses" :message="schema.fieldHelp"
           :expanded="schema.expanded">
    <b-datepicker :id="schema.id"
                  :name="schema.id"
                  v-model="value"
                  :icon="schema.icon"
                  :placeholder="schema.placeholder"
                  :required="schema.required"
                  :inline="schema.inline"
                  :min-date="schema.minDate"
                  :max-date="schema.maxDate"
                  :month-names="monthNames"
                  :day-names="dayNames"
                  :first-day-of-week="firstDayOfWeek"></b-datepicker>
  </b-field>
</template>

<script>
import { abstractField } from 'vue-form-generator'

const DAY_NAMES = ['dim.', 'lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.']
const FIRST_DAY_OF_WEEK = 1
const MONTH_NAMES = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août',
  'Septembre', 'Octobre', 'Novembre', 'Décembre']

export default {
  name: 'field-b-datepicker',
  mixins: [abstractField],
  data () {
    return {
      dayNames: DAY_NAMES,
      firstDayOfWeek: FIRST_DAY_OF_WEEK,
      monthNames: MONTH_NAMES
    }
  }
}
</script>
