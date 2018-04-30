<template>
  <form id="capabilities-form" method="POST" accept-charset="UTF-8" v-on:submit.prevent>
    <form-wizard ref="capabilitiesWizard" title="" subtitle="" step-size="xs"
                 next-button-text="Suivant" back-button-text="Retour"
                 finish-button-text="Passer au formulaire" @on-complete="loadFieldForm">
      <tab-content title="Étude" :before-change="checkStudySelected">
        <div class="columns is-multiline is-centered" v-if="userCapabilities !== null">
          <div class="column is-one-third has-text-centered"
               v-for="study in userCapabilities.available_studies"
               :item="study" :key="study.code">
            <b-radio href="#" size="is-small" v-model="currentStudyCode"
                     :native-value="study.code">
              <figure class="image is-64x64 block-center">
                <img :alt="study.title || no_study_title"
                     :title="study.title || no_study_title"
                     :src="study.pictogram">
              </figure>
              <p class="is-size-7">{{ study.short_title || no_study_short_title }}</p>
            </b-radio>
          </div>
        </div>
      </tab-content>
      <tab-content title="Protocole" :before-change="checkProtocolSelected">
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
      <tab-content title="Formulaire" :before-change="checkFormSelected">
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
      no_study_title: "Pas d'étude particulière",
      no_study_short_title: "Pas d'étude",
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
    checkFormSelected () {
      return this.currentFormCode !== null
    },
    checkProtocolSelected () {
      return this.currentProtocolCode !== null
    },
    checkStudySelected () {
      return this.currentStudyCode !== null
    },
    nextTab () {
      this.$refs.capabilitiesWizard.nextTab()
    },
    ...mapActions([
      'loadFieldForm',
      'setCurrentFormAndObservations',
      'setCurrentProtocol',
      'setCurrentStudy'
    ])
  },
  watch: {
    currentFormCode: {
      async handler (val, oldVal) {
        await this.setCurrentFormAndObservations(val)
        if (oldVal !== val) {
          this.loadFieldForm()
        }
      }
    },
    currentProtocolCode: {
      handler (val, oldVal) {
        this.setCurrentProtocol(val)
        this.nextTab()
        if (oldVal !== val) {
          this.currentFormCode = this.currentProtocol.forms.length === 1 ? this.currentProtocol.forms[0].code : null
        }
      }
    },
    currentStudyCode: {
      handler (val, oldVal) {
        this.setCurrentStudy(val)
        this.nextTab()
        if (oldVal !== val) {
          this.currentProtocolCode = this.currentStudy.protocols.length === 1 ? this.currentStudy.protocols[0].code : null
        }
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
