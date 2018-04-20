<template>
  <form id="capabilities-form" method="POST" accept-charset="UTF-8" v-on:submit.prevent>
    <form-wizard ref="capabilitiesWizard" title="" subtitle="" step-size="xs"
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
                <img :alt="protocol.title || no_protocol_title"
                     :title="protocol.title || no_protocol_title"
                     :src="protocol.pictogram">
              </figure>
              <p class="is-size-7">{{ protocol.short_title || no_protocol_short_title }}</p>
            </b-radio>
          </div>
        </div>
      </tab-content>
      <tab-content title="Formulaire">
        <div class="columns is-multiline is-centered" v-if="currentProtocol !== null">
          <div class="column is-one-third has-text-centered"
               v-for="form in currentProtocol.forms"
               :item="form" :key="form.code">
            <b-radio href="#" size="is-small" v-model="currentFormCode"
                     :native-value="form.code">
              <figure class="image is-64x64 block-center">
                <img :alt="form.title" :title="form.title" :src="form.pictogram">
              </figure>
              <p class="is-size-7">{{ form.short_title }}</p>
            </b-radio>
          </div>
        </div>
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
      currentFormCode: null,
      currentProtocolCode: null,
      currentStudyCode: null,
      no_protocol_title: 'Pas de protocole particulier',
      no_protocol_short_title: 'Pas de protocole'
    }
  },
  computed: mapGetters([
    'currentProtocol',
    'currentStudy',
    'userCapabilities'
  ]),
  methods: {
    nextTab () {
      this.$refs.capabilitiesWizard.nextTab()
    },
    ...mapActions([
      'setCurrentForm',
      'setCurrentProtocol',
      'setCurrentStudy'
    ])
  },
  watch: {
    currentFormCode: {
      handler (val, oldVal) {
        this.setCurrentForm(val)
      }
    },
    currentProtocolCode: {
      handler (val, oldVal) {
        this.setCurrentProtocol(val)
        this.nextTab()
      }
    },
    currentStudyCode: {
      handler (val, oldVal) {
        this.setCurrentStudy(val)
        this.nextTab()
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
