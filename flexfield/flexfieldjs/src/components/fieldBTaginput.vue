<template>
  <b-field :label="schema.fieldLabel" :type="schema.fieldClass" :message="schema.fieldHelp"
           :expanded="schema.expanded">
    <b-taginput :id="schema.id"
                :name="schema.id"
                v-model="value"
                :icon="schema.icon"
                :placeholder="schema.placeholder"
                :size="schema.size"
                :type="schema.tagType"
                :maxlength="schema.tagMaxLength"
                :maxtags="schema.maxTags"
                :autofocus="schema.autofocus"
                :autocomplete="schema.autocomplete"></b-taginput>
  </b-field>
</template>

<script>
import { abstractField } from 'vue-form-generator'

export default {
  name: 'field-b-taginput',
  mixins: [abstractField]
}
</script>
