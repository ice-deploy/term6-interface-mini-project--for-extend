import Vue from "vue";
import App from "./App.vue";
import router from "./router";
import store from "./store";

import "@/assets/css/tailwind.css";

Vue.config.productionTip = false;

// set default config
Vue.use(require("vue-cookies"));
Vue.$cookies.config("10y");

new Vue({
  router,
  store,
  render: (h) => h(App),
}).$mount("#app");
