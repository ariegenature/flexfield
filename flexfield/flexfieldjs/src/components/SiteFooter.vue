<template>
  <footer class="footer is-size-7 has-text-centered has-text-weight-light has-text-grey-darker">
    <div class="container is-fluid">
      <div class="columns">
        <div class="column is-one-third vcenter">
          <div class="content">
            <div>
              <div class="image" style="display: inline-block;">
                <a href="http://flask.pocoo.org/" target="_blank">
                  <img src="static/logo-flask.png"
                       border="0" alt="Logo Flask" title="Propulsé par Flask"
                       style="height: 16px; width: auto;">
                </a>
              </div>&nbsp;
              <div class="image is-16x16" style="display: inline-block;">
                <a href="https://vuejs.org" target="_blank">
                  <img src="static/logo-vuejs.png"
                       boroder="0" alt="Logo Vue.js" title="Propulsé par Vue.js">
                </a>
              </div>
            </div>
            <p>Réalisé avec
            <a href="http://flask.pocoo.org" target="_blank" title="Flask">Flask</a>
            et
            <a href="https://vuejs.org" target="_blank" title="Vue.js">Vue.js</a>.</p>
            <p>Copyright © ANA 2018.</p>
          </div>
        </div>
        <div class="column is-one-third vcenter">
          <div class="content">
            Outil de saisie des relevés de terrain de l'ANA.
          </div>
        </div>
        <div class="column is-one-third vcenter">
          <div class="block">
            <a href="https://www.facebook.com/ariegenature/" target="_blank" title="Facebook ANA">
              <b-icon icon="facebook" type="is-dark"></b-icon>
            </a>
            &emsp;
            <a href="https://www.youtube.com/channel/UCjIAs3vAZxZT33x3eBI5t4w" target="_blank" title="Chaîne Youtube ANA">
              <b-icon icon="youtube-play" type="is-dark"></b-icon>
            </a>
            &emsp;
            <a href="https://ariegenature.fr" target="_blank" title="Site web ANA">
              <b-icon icon="web" type="is-dark"></b-icon>
            </a>
          </div>
        </div>
      </div>
    </div>
  </footer>
</template>

<script>
export default {
  name: 'SiteFooter'
}
</script>

<style>
.vcenter {
  margin-top: auto;
  margin-bottom: auto;
}
</style>
