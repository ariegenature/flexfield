<template>
  <form id="field-form" method="POST" accept-charset="UTF-8" v-on:submit.prevent>
    <form-wizard ref="fieldWizard" title="" subtitle="" step-size="xs"
                 next-button-text="Suivant" back-button-text="Retour"
                 finish-button-text="Terminer">
      <tab-content title="Onglet 1">
        <div class="content"><p>Onglet 1</p></div>
      </tab-content>
      <tab-content title="Onglet 2">
        <div class="content"><p>Onglet 2</p></div>
      </tab-content>
      <tab-content title="Onglet 3">
        <div class="content"><p>Onglet 3</p></div>
      </tab-content>
    </form-wizard>
  </form>
</template>

<script>
export default {
  name: 'FieldForm'
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
