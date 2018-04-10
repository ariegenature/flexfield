<template>
 <div class="hero is-fullheight" id="sign-hero">
   <div class="hero-body">
     <div class="container">
       <div class="columns is-centered">
         <div class="column is-one-third">
           <div class="card">
             <div class="card-header">
               <div class="media-content">
                 <h1 class="card-header-title">Connectez-vous</h1>
               </div>
               <div class="card-header-icon">
                 <b-icon icon="login"></b-icon>
               </div>
             </div>
             <div class="card-content">
               <login-form></login-form>
             </div>
           </div>
         </div>
       </div>
     </div>
   </div>
 </div>
</template>

<script>
import LoginForm from './LoginForm'

export default {
  name: 'login-page',
  components: {
    LoginForm
  }
}
</script>

<style>
#app .card {
  border-radius: 10px;
  background-color: #ffffffee;
}
#main-column {
  border-right: thin solid #ddd;
}
#switch-column {
  margin-top: auto;
  margin-bottom: auto;
}
</style>
