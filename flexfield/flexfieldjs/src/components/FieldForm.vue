<template>
  <form id="field-form" method="POST" accept-charset="UTF-8" v-on:submit.prevent>
    <form-wizard ref="fieldWizard" title="" subtitle="" step-size="xs"
                 next-button-text="Suivant" back-button-text="Retour"
                 finish-button-text="Terminer">
      <tab-content :title="tab.title" v-for="tab in currentForm.yaml_description.tabs"
                   :item="tab" :key="tab.id">
        <vue-form-generator :model="currentForm.model" :schema="tab.schema"
                            :options="formOptions"></vue-form-generator>
      </tab-content>
    </form-wizard>
  </form>
</template>

<script>
import { mapGetters } from 'vuex'

export default {
  name: 'FieldForm',
  data () {
    return {
      formOptions: {
        validationErrorClass: 'is-danger',
        validationSuccessClass: 'is-success'
      }
    }
  },
  computed: mapGetters([
    'currentForm'
  ])
}
</script>

<style>
@media screen and (max-width: 767px) {
  #field-form .vue-form-wizard .wizard-nav > li,
  .wizard-progress-with-circle {
    display: none
  }
  #field-form .vue-form-wizard .wizard-nav > li.active {
    display: block
  }
}
</style>
