<template>
  <b-field :label="schema.fieldLabel" :type="schema.fieldClass" :message="schema.fieldHelp"
           :expanded="schema.expanded">
    <b-input :id="schema.id"
             :type="schema.inputType ? schema.inputType.toLowerCase() : 'text'"
             :name="schema.id"
             :value="value"
             @input="evaluateValue"
             :icon="schema.icon"
             :placeholder="schema.placeholder"
             :required="schema.required"
             :size="schema.size"
             :autofocus="schema.autofocus"
             :autocomplete="schema.autocomplete"></b-input>
  </b-field>
</template>

<script>
import { abstractField } from 'vue-form-generator'

export default {
  name: 'field-b-input',
  mixins: [abstractField],
  methods: {
    evaluateValue (value) {
      switch (this.schema.inputType.toLowerCase()) {
        case 'number':
        case 'range':
          value = Number(value)
          break
      }
      this.value = value
    }
  }
}
</script>
