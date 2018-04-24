<template>
  <div class="navbar-menu" :class="{ 'is-active': menuActive }">
    <div class="navbar-end">
      <a class="navbar-item" title="Déconnexion" @click="logoutUser"
         @click.native="emitMenuClick">
        <b-icon icon="logout"></b-icon>&nbsp;Déconnexion
      </a>
    </div>
  </div>
</template>

<script>
import { mapActions } from 'vuex'

export default {
  name: 'NavbarMenu',
  props: [
    'menuActive'
  ],
  methods: {
    emitMenuClick (ev) {
      this.$emit('menu-click')
    },
    async logoutUser (ev) {
      await this.logout()
      this.$router.push({ name: 'login' })
    },
    ...mapActions([
      'logout'
    ])
  }
}
</script>
