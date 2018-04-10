<template>
  <div class="navbar-menu" :class="{ 'is-active': menuActive }">
    <div class="navbar-end">
      <a href="/logout" class="navbar-item" title="Déconnexion" @click.native="emitMenuClick">
        <b-icon icon="logout"></b-icon>&nbsp;Déconnexion
      </a>
    </div>
  </div>
</template>

<script>
export default {
  name: 'NavbarMenu',
  props: [
    'menuActive'
  ],
  methods: {
    emitMenuClick (ev) {
      this.$emit('menu-click')
    }
  }
}
</script>
