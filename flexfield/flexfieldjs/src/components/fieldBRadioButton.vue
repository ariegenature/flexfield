<template>
  <b-field :type="schema.fieldClass" :message="schema.fieldHelp" :expanded="schema.expanded">
    <b-radio-button href="#" v-for="option in schema.values"
                    :key="option.id"
                    :name="option.id"
                    v-model="value"
                    :size="schema.size"
                    :type="schema.fieldType"
                    :native-value="option.id">
      <div v-html="option.text"></div>
    </b-radio-button>
  </b-field>
</template>

<script>
import { abstractField } from 'vue-form-generator'

export default {
  name: 'field-b-radio-button',
  mixins: [abstractField]
}
</script>
