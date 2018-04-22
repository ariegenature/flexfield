<template>
  <form id="field-form" method="POST" accept-charset="UTF-8" v-on:submit.prevent>
    <form-wizard ref="fieldWizard" title="" subtitle="" step-size="xs"
                 next-button-text="Suivant" back-button-text="Retour"
                 finish-button-text="Terminer" @on-complete="submitForm">
      <tab-content :title="tab.title" v-for="tab in currentForm.yaml_description.tabs"
                   :item="tab" :key="tab.id">
        <vue-form-generator :model="currentForm.model" :schema="tab.schema"
                            :options="formOptions"></vue-form-generator>
      </tab-content>
    </form-wizard>
  </form>
</template>

<script>
import { mapActions, mapGetters } from 'vuex'

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
    'currentForm',
    'currentProtocol',
    'currentStudy',
    'newFeature'
  ]),
  methods: {
    async submitForm () {
      this.updateNewFeatureProperties(this.currentForm.model)
      const additionalProperties = {
        study: this.currentStudy.code,
        protocol: this.currentProtocol.code
      }
      Object.assign(this.newFeature.properties, additionalProperties)
      const payload = {
        form: this.currentForm.code,
        feature: this.newFeature
      }
      try {
        await this.$post('backend/observation', payload, {
          headers: {
            'X-CSRFToken': '«« csrf_token() »»'
          }
        })
        this.$toast.open({
          duration: 5000,
          message: 'Votre observation a bien été enregistrée. Merci !',
          type: 'is-success'
        })
      } catch (e) {
        console.warn(e)
        this.$toast.open({
          duration: 5000,
          message: "Une erreur s'est produite. Veuillez contacter un administrateur.",
          type: 'is-danger'
        })
      }
    },
    ...mapActions([
      'updateNewFeatureProperties'
    ])
  }
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
