<template>
  <nav id="navigation" class="navbar has-shadow" role="navigation" aria-label="main navigation">
    <navbar-brand></navbar-brand>
  </nav>
</template>

<script>
import NavbarBrand from './NavbarBrand'

export default {
  name: 'Navbar',
  components: {
    NavbarBrand
  }
}
</script>

<style>
#navigation {
  background-color: #e9e5ff;
}
</style>
