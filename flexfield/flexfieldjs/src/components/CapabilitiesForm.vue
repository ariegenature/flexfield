<template>
  <form id="capabilities-form" method="POST" accept-charset="UTF-8" v-on:submit.prevent>
    <form-wizard ref="capabilities-wizard" title="" subtitle="" step-size="xs"
                 next-button-text="Suivant" back-button-text="Retour"
                 finish-button-text="Passer au formulaire">
      <tab-content title="Étude">
        <div class="content"><p>Protocole</p></div>
      </tab-content>
      <tab-content title="Protocole">
        <div class="content"><p>Protocole</p></div>
      </tab-content>
      <tab-content title="Formulaire">
        <div class="content"><p>Formulaire</p></div>
      </tab-content>
    </form-wizard>
  </form>
</template>

<script>
export default {
  name: 'CapabilitiesForm'
}
</script>

<style>
@media screen and (max-width: 767px) {
  #capabilities-form .vue-form-wizard .wizard-nav > li,
  .wizard-progress-with-circle {
    display: none
  }
  #capabilities-form .vue-form-wizard .wizard-nav > li.active {
    display: block
  }
}
</style>
