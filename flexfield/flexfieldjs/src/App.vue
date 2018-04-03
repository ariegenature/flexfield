<template>
  <div id="app">
    <router-view/>
    <site-footer></site-footer>
  </div>
</template>

<script>
import SiteFooter from './components/SiteFooter'

export default {
  name: 'App',
  components: {
    SiteFooter
  }
}
</script>
