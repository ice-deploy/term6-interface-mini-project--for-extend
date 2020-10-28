import Vue from "vue";
import Vuex from "vuex";

import {
  UPDATE_PING,
  UPDATE_Connecting,
  UPDATE_IP,
  INIT_IP,
} from "./mutation-types";

/**
 * NOTE-vuex:
 *  setting-IP
 *  disable Button when not-Connect.
 *  call-API: [ping,command,stop]
 *    ping -> [connect,disconnect]
 *    ping,checkAllState
 */

Vue.use(Vuex);

export default new Vuex.Store({
  // // DEBUG-only
  // strict: true,

  state: {
    ping: 0,
    isConnecting: false,
    currentIP: null,
    defaultIP: "127.0.0.1:5000",
  },
  mutations: {
    [UPDATE_PING](state, { pingTimeCount }) {
      state.ping = pingTimeCount;
    },
    [UPDATE_Connecting](state, { isConnected }) {
      state.isConnecting = isConnected;
      console.log("mutations() -> isConnected: ", isConnected);
    },
    [UPDATE_IP](state, { newIP }) {
      state.currentIP = newIP;
      Vue.$cookies.set("lastIP", newIP);
      console.log("mutations() -> UPDATE_IP(...) newIP: ", newIP);
    },
    [INIT_IP](state) {
      if (Vue.$cookies.isKey("lastIP")) {
        state.currentIP = Vue.$cookies.get("lastIP");
        console.log("mutations() -> INIT_IP(): ");
      }
    },
  },
  actions: {
    async pingCheck({ getters, commit }) {
      try {
        let timeStart = new Date().getTime();
        let pingRes = await Vue.axios.get(getters.path_api + "/ping");
        if (pingRes.data.dataStatus != "success") {
          console.log("Err-ping: ", pingRes.data);
        }
        let timeEnd = new Date().getTime();
        let pingTimeCount = timeEnd - timeStart;
        commit(UPDATE_PING, { pingTimeCount });
      } catch (error) {
        commit(UPDATE_Connecting, { isConnected: false });
        console.log("Err-ping: Connecting Fail!!");
      }
    },
    async callApiOne({ commit, getters }, { command }) {
      const res = await Vue.axios.get(getters.path_api + "/api/" + command);
      if (res.data.dataStatus != "success") {
        console.log("Err-callApiOne(): ", res.data);
        commit(UPDATE_Connecting, { isConnected: false });
      }
      return res.data;
    },
  },

  getters: {
    getConnecting: (state) => state.isConnecting,
    getPing: (state) => state.ping,
    getSettingIP: (state) => state.currentIP ?? state.defaultIP,
    path_api: function (_, getters) {
      if (getters.getSettingIP) {
        if (getters.getSettingIP.startsWith("https://")) {
          return "https://" + getters.getSettingIP;
        }
      }
      return "http://" + getters.getSettingIP;
    },
  },
  modules: {},
});
