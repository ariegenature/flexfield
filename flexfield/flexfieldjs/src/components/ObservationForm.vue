<template>
  <form id="observation-form" method="POST" accept-charset="UTF-8" v-on:submit.prevent>
    <form-wizard ref="fieldWizard" title="" subtitle="" step-size="xs"
                 next-button-text="Suivant" back-button-text="Retour"
                 finish-button-text="Terminer" @on-complete="submitForm">
      <tab-content :title="tab.title" v-for="tab in currentForm.tabs"
                   :item="tab" :key="tab.id" :before-change="validateTab">
        <vue-form-generator :model="currentFeature.properties" :schema="tab.schema"
                            :options="formOptions" ref="forms"></vue-form-generator>
      </tab-content>
    </form-wizard>
  </form>
</template>

<script>
import { mapActions, mapGetters } from 'vuex'

export default {
  name: 'ObservationForm',
  data () {
    return {
      formOptions: {
        validationErrorClass: 'is-danger',
        validationSuccessClass: 'is-success'
      }
    }
  },
  computed: mapGetters([
    'currentFeature',
    'currentForm',
    'currentProtocol',
    'currentStudy'
  ]),
  methods: {
    async submitForm () {
      this.$emit('form-complete')
    },
    validateTab () {
      const form = this.$refs.forms[this.$refs.fieldWizard.activeTabIndex]
      const validationResults = form.validate()
      // Following code purpose is to use Buefy/Bulma tags to display errors
      // and not vue-form-generator hardcoded tags
      if (!validationResults) {
        form.errors.forEach((error) => {
          Object.assign(error.field, { fieldClass: form.options.validationErrorClass, fieldHelp: error.error })
        })
        form.clearValidationErrors()
      } else {
        form.$children.forEach((child) => {
          Object.assign(child.schema, { fieldClass: form.options.validationSuccessClass, fieldHelp: '' })
        })
      }
      return validationResults
    },
    ...mapActions([
      'setCurrentFeatureProperties'
    ])
  },
  mounted () {
    if (Object.keys(this.currentFeature.properties).length === 0) {
      this.setCurrentFeatureProperties(this.currentForm.model)
    }
  }
}
</script>

<style>
@media screen and (max-width: 767px) {
  #observation-form .vue-form-wizard .wizard-nav > li,
  .wizard-progress-with-circle {
    display: none
  }
  #observation-form .vue-form-wizard .wizard-nav > li.active {
    display: block
  }
}
</style>
