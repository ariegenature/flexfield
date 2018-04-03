<template>
  <main class="hero is-fullheight">
  <div class="hero-head">
    <navbar></navbar>
  </div>
  </main>
</template>

<script>
import Navbar from './Navbar'

export default {
  name: 'Home',
  components: {
    Navbar
  }
}
</script>
