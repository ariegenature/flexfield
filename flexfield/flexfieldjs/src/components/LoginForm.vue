<template>
  <form id="login-form" method="POST" accept-charset="UTF-8" @submit.prevent="submitForm">
    <b-field :type="inputState" label="Nom d'utilisateur">
      <b-input id="username" icon="user" v-model="username" autofocus></b-input>
    </b-field>
    <b-field :type="inputState" label="Mot de passe">
      <b-input id="password" type="password" v-model="password" icon="user-secret"></b-input>
    </b-field>
    <b-field grouped position="is-right">
      <div class="control">
      <button class="button is-primary" type="submit">
        C'est parti&nbsp;!
      </button>
      </div>
    </b-field>
  </form>
</template>

<script>
export default {
  name: 'login-form',
  data () {
    return {
      username: '',
      password: ''
    }
  },
  methods: {
    async submitForm (ev) {
      var loginData = new FormData()
      loginData.append('username', this.username)
      loginData.append('password', this.password)
      try {
        await this.$post('', loginData, {
          headers: {
            'X-CSRFToken': '«« csrf_token() »»'
          }
        })
      } catch (e) {
        this.$toast.open({
          message: "Nom d'utilisateur ou mot de passe invalide",
          duration: 3000,
          type: 'is-danger'
        })
      }
    }
  }
}
</script>
