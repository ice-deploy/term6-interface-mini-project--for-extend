import Vue from "vue";
import App from "./App.vue";
import router from "./router";
import store from "./store";

import axios from "axios";
import VueAxios from "vue-axios";

import "@/assets/css/tailwind.css";

Vue.config.productionTip = false;

Vue.use(VueAxios, axios);

// import VueCookies from 'vue-cookies'
// Vue.use(VueCookies)
Vue.use(require("vue-cookies"));

// set default config
// อายุ cookies
Vue.$cookies.config("10y");

new Vue({
  router,
  store,
  render: (h) => h(App),
}).$mount("#app");
