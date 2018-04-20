<template>
  <form id="capabilities-form" method="POST" accept-charset="UTF-8" v-on:submit.prevent>
    <form-wizard ref="capabilities-wizard" title="" subtitle="" step-size="xs"
                 next-button-text="Suivant" back-button-text="Retour"
                 finish-button-text="Passer au formulaire">
      <tab-content title="Étude">
        <div class="columns is-multiline is-centered" v-if="userCapabilities !== null">
          <div class="column is-one-third has-text-centered"
               v-for="study in userCapabilities.available_studies"
               :item="study" :key="study.code">
            <b-radio href="#" size="is-small" v-model="currentStudyCode"
                     :native-value="study.code">
              <figure class="image is-64x64 block-center">
                <img :alt="study.title" :title="study.title" :src="study.pictogram">
              </figure>
              <p class="is-size-7">{{ study.short_title }}</p>
            </b-radio>
          </div>
        </div>
      </tab-content>
      <tab-content title="Protocole">
        <div class="columns is-multiline is-centered" v-if="currentStudy !== null">
          <div class="column is-one-third has-text-centered"
               v-for="protocol in currentStudy.protocols"
               :item="protocol" :key="protocol.code">
            <b-radio href="#" size="is-small" v-model="currentProtocolCode"
                     :native-value="protocol.code">
              <figure class="image is-64x64 block-center">
                <img :alt="protocol.title" :title="protocol.title" :src="protocol.pictogram">
              </figure>
              <p class="is-size-7">{{ protocol.short_title }}</p>
            </b-radio>
          </div>
        </div>
      </tab-content>
      <tab-content title="Formulaire">
        <div class="content"><p>Formulaire</p></div>
      </tab-content>
    </form-wizard>
  </form>
</template>

<script>
import { mapActions, mapGetters } from 'vuex'

export default {
  name: 'CapabilitiesForm',
  data () {
    return {
      currentProtocolCode: null,
      currentStudyCode: null
    }
  },
  computed: mapGetters([
    'currentStudy',
    'userCapabilities'
  ]),
  methods: mapActions([
    'setCurrentProtocol',
    'setCurrentStudy'
  ]),
  watch: {
    currentProtocolCode: {
      handler (val, oldVal) {
        this.setCurrentProtocol(val)
      }
    },
    currentStudyCode: {
      handler (val, oldVal) {
        this.setCurrentStudy(val)
      }
    }
  }
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
