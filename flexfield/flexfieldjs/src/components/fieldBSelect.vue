<template>
  <b-field :label="schema.fieldLabel" :type="schema.fieldClass" :message="schema.fieldHelp"
           :expanded="Boolean(schema.expanded)">
    <b-select :id="schema.id"
             :name="schema.id"
             v-model="value"
             :icon="schema.icon"
             :required="schema.required"
             :placeholder="schema.placeholder">
      <option v-for="option in schema.values" :value="option.id" :key="option.id">
      {{ option.title }}
      </option>
    </b-select>
  </b-field>
</template>

<script>
import { abstractField } from 'vue-form-generator'

export default {
  name: 'field-b-select',
  mixins: [abstractField]
}
</script>
