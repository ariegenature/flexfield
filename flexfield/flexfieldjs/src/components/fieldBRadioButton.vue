<template>
  <b-field :label="schema.fieldLabel" :type="schema.fieldClass" :message="schema.fieldHelp"
           :expanded="schema.expanded">
    <b-field>
      <b-radio-button href="#" v-for="option in schema.values"
                      :key="option.id"
                      :name="schema.id"
                      v-model="value"
                      :size="schema.size"
                      :type="schema.fieldType"
                      :native-value="option.id">
        <div v-html="option.text"></div>
      </b-radio-button>
    </b-field>
  </b-field>
</template>

<script>
import { abstractField } from 'vue-form-generator'

export default {
  name: 'field-b-radio-button',
  mixins: [abstractField]
}
</script>
