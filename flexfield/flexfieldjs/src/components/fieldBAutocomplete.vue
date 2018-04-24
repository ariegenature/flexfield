<template>
  <b-field :label="schema.fieldLabel" :type="schema.fieldClass" :message="schema.fieldHelp"
           :expanded="schema.expanded">
    <b-autocomplete :id="schema.id"
                    :name="schema.id"
                    v-model="name"
                    @input="getMatchingData"
                    :icon="schema.icon"
                    :placeholder="schema.placeholder"
                    :required="schema.required"
                    :autofocus="schema.autofocus"
                    :loading="isFetching"
                    @select="selectValue"
                    :data="data"
                    :field="schema.displayField"></b-autocomplete>
  </b-field>
</template>

<script>
import { abstractField } from 'vue-form-generator'
import { debounce } from 'lodash'

export default {
  name: 'field-b-autocomplete',
  mixins: [abstractField],
  data () {
    return {
      data: [],
      name: '',
      isFetching: false
    }
  },
  methods: {
    getMatchingData: debounce(async function (value) {
      this.data = []
      if (value.length < 3) return
      this.isFetching = true
      try {
        const data = await this.$get(`${this.schema.api}?${this.schema.searchParam}=${value}`)
        this.data = data.data[this.schema.resultProperty]
        this.isFetching = false
      } catch (e) {
        this.isFetching = false
        console.warn(e)
      }
    }, 800),
    selectValue (choice) {
      if (choice) {
        this.value = choice[this.schema.selectField]
      }
    }
  }
}
</script>
