<template>
  <b-field :label="schema.fieldLabel" :type="schema.fieldClass" :message="schema.fieldHelp"
           :expanded="Boolean(schema.expanded)">
    <b-input :id="schema.id"
             :type="schema.inputType ? schema.inputType.toLowerCase() : 'text'"
             :name="schema.id"
             v-model="value"
             :icon="schema.icon"
             :placeholder="schema.placeholder"
             :required="schema.required"
             :autofocus="schema.autofocus"
             :autocomplete="schema.autocomplete"></b-input>
  </b-field>
</template>

<script>
import { abstractField } from 'vue-form-generator'

export default {
  name: 'field-b-input',
  mixins: [abstractField]
}
</script>
