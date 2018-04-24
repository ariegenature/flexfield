<template>
  <div class="columns is-multiline is-centered">
    <div class="column is-one-third has-text-centered" v-for="option in schema.values"
         :item="option" :key="option.id">
      <b-radio href="#"
               :name="option.id"
               v-model="value"
               :size="schema.size"
               :native-value="option.id">
        <div v-html="option.text"></div>
      </b-radio>
    </div>
  </div>
</template>

<script>
import { abstractField } from 'vue-form-generator'

export default {
  name: 'field-b-radio',
  mixins: [abstractField]
}
</script>
