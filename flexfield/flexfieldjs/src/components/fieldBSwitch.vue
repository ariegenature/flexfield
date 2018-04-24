<template>
  <b-field :label="schema.fieldLabel" :type="schema.fieldClass" :message="schema.fieldHelp">
    <b-switch :id="schema.id"
              :name="schema.id"
              v-model="value"
              :size="schema.size"
              :true-value="schema.valueOn"
              :false-value="schema.valueOff">
      {{ value ? schema.textOn : schema.textOff }}
    </b-switch>
  </b-field>
</template>

<script>
import { abstractField } from 'vue-form-generator'

export default {
  name: 'field-b-switch',
  mixins: [abstractField]
}
</script>
