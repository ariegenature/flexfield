<template>
  <nav id="navigation" class="navbar has-shadow" role="navigation" aria-label="main navigation">
    <navbar-brand :menu-active="menuActive" @burger-click="toggleBurger"></navbar-brand>
    <navbar-menu :menu-active="menuActive" @menu-click="closeMenu"></navbar-menu>
  </nav>
</template>

<script>
import NavbarBrand from './NavbarBrand'
import NavbarMenu from './NavbarMenu'

export default {
  name: 'Navbar',
  components: {
    NavbarBrand,
    NavbarMenu
  },
  data () {
    return {
      menuActive: false
    }
  },
  methods: {
    toggleBurger () {
      this.menuActive = !this.menuActive
    },
    closeMenu () {
      this.menuActive = false
    }
  }
}
</script>

<style>
#navigation {
  background-color: #e9e5ff;
}
</style>
