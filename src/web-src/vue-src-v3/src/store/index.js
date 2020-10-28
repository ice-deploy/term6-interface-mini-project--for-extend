import Vue from "vue";
import Vuex from "vuex";

import { UPDATE_Connecting, UPDATE_IP, INIT_IP } from "./mutation-types";

Vue.use(Vuex);

export default new Vuex.Store({
  // // DEBUG-only
  // strict: true,

  state: {
    ping: 0,
    isConnecting: false,
    stateMotor: {
      left: "stop",
      right: "stop",
    },
    websocket: null,
    currentIP: null,
    // defaultIP: "wss://echo.websocket.org",
    // defaultIP: "127.0.0.1:6789",
    defaultIP: location.hostname + ":6789",
  },
  mutations: {
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
    /**
     * NOTE: ws-step
     * 
     - connecting...
     - รับ stateServer มา render(update-stateLocal)
     - send-command
     -    (stand-by),update-stateLocal
     - disconnect, clear-stateLocal
     
     */

    // onConnect
    async onConnectServer({ state, getters, commit, dispatch }) {
      //ป้องกัน JS-Err
      try {
        state.websocket = new WebSocket(getters.path_api);
        //stop-connecting เมื่อ Err
        state.websocket.onerror = function (evt) {
          if (state.websocket.readyState == 1) {
            console.log("ws normal error (still connecting): " + evt.type);
            dispatch("callDisConnect");
          } else {
            console.log("ws-Err-cannot-connect...: ", evt);
          }
        };
        state.websocket.onclose = function (event) {
          commit(UPDATE_Connecting, { isConnected: false });
          console.log("ws-closed by: ", event);
        }; // disable onclose handler first
        state.websocket.onmessage = function (event) {
          const data = JSON.parse(event.data);
          switch (data.type) {
            case "users":
              // แสดงจำนวน users ที่เชื่อมต่อ
              console.log("users ->data.count: " + data.count.toString());
              break;
            case "connection-id":
              console.log("connection-id ->data.id: " + data.id.toString());
              break;
            case "state":
              // update status เมื่อมี command จาก device อื่น
              console.log("data.state: ", data);
              state.stateMotor.left = data.left;
              state.stateMotor.right = data.right;
              break;
            case "err":
              // TODO: show flash-message when res-Err.
              console.log("data.res: ", data.message);
              break;
            default:
              console.error("unsupported event.data.type", data);
              // https://stackoverflow.com/questions/4812686/closing-websocket-correctly-html5-javascript
              dispatch("callDisConnect");
            // throw "data.type not match!!";
          }
        };
      } catch (error) {
        dispatch("callDisConnect");
        console.log("Err-onConnectServer: Connecting Fail!!");
      }
    },

    // onDisConnect (update state from local-component)
    // async callDisConnect({ commit, state }) {
    async callDisConnect({ state }) {
      console.log("call disconnect.");
      try {
        state.websocket.close(1000);
      } catch (error) {
        console.log("Err-callDisConnect(): ", error);
      }
      // isConnected: false ใน .onclose
    },

    // onCommandEvent to-//callApiOne
    async callApiOne({ state, dispatch }, { command }) {
      try {
        state.websocket.send(
          JSON.stringify({ action: "motor-control", command: command })
        );
      } catch (error) {
        console.log("Err-callApiOne(): ", error);
        dispatch("callDisConnect");
      }
    },
  },
  getters: {
    getConnecting: (state) => state.isConnecting,
    getStateMotor: (state) => state.stateMotor,
    getPing: (state) => state.ping,
    getSettingIP: (state) => state.currentIP ?? state.defaultIP,
    path_api: function (_, getters) {
      // wss-support
      // https://websockets.readthedocs.io/en/stable/intro.html#secure-example
      if (getters.getSettingIP) {
        console.log("start-with protocal-prefix[wss/ws]?");
        if (
          getters.getSettingIP.startsWith("wss://") ||
          getters.getSettingIP.startsWith("ws://")
        ) {
          console.log("path_api: ", getters.getSettingIP);
          return getters.getSettingIP;
        }
      }
      return "ws://" + getters.getSettingIP;
    },
  },
  modules: {},
});
