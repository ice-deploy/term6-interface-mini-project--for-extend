<template>
  <div class="m-auto">
    <div class="debug">
      <h1>State: {{ debugMessage }}</h1>
    </div>
    <button
      class="bg-blue-400 hover:bg-blue-600 text-white font-bold py-2 px-4 rounded-full block"
      :class="{ 'animate-bounce':isToggleUP, 'opacity-50 cursor-not-allowed':!isStateConnecting }"
      @click="clickToggle('up')"
      :disabled="!isStateConnecting"
    >Toggle {{ getSideText }}-UP</button>
    <button
      class="bg-red-400 hover:bg-red-600 text-white font-bold py-2 px-4 rounded-full block"
      @click="clickToggle('stop')"
      :class="{ 'opacity-50 cursor-not-allowed':!isStateConnecting}"
      :disabled="!isStateConnecting"
    >{{ getSideText }}-STOP</button>

    <button
      class="bg-blue-400 hover:bg-blue-600 text-white font-bold py-2 px-4 rounded-full block"
      :class="{ 'animate-bounce':isToggleDOWN, 'opacity-50 cursor-not-allowed':!isStateConnecting }"
      @click="clickToggle('down')"
      :disabled="!isStateConnecting"
    >Toggle {{ getSideText }}-DOWN</button>
  </div>
</template>

<script>
// https://stackoverflow.com/questions/57538539/how-to-use-enums-or-const-in-vuejs
const ENUM_STATE_TOGGLE = Object.freeze({
  up: "up",
  down: "down",
  stop: "stop"
});

export default {
  name: "JoyComp",
  props: {
    // [l/r]
    ENUM_MOTOR_SIDE: String
  },
  data() {
    return {
      debugMessage: null,
      stateToggle: ENUM_STATE_TOGGLE.stop //[up,down,stop]
    };
  },
  computed: {
    getSideText() {
      if (this.ENUM_MOTOR_SIDE == "l") {
        return "LEFT";
      } else if (this.ENUM_MOTOR_SIDE == "r") {
        return "RIGHT";
      } else {
        return "Err: props -> ENUM_MOTOR_SIDE";
      }
    },
    getCommandUP() {
      return this.ENUM_MOTOR_SIDE + "u";
    },
    getCommandDOWN() {
      return this.ENUM_MOTOR_SIDE + "d";
    },
    getCommandZERO() {
      return this.ENUM_MOTOR_SIDE + "0";
    },
    isStateConnecting() {
      const _isStateConnecting = this.$store.getters.getConnecting;
      return _isStateConnecting;
    },
    isToggleUP() {
      if (!this.$store.getters.getConnecting) {
        return false;
      }
      return this.stateToggle == ENUM_STATE_TOGGLE.up;
    },
    isToggleDOWN() {
      if (!this.$store.getters.getConnecting) {
        return false;
      }
      return this.stateToggle == ENUM_STATE_TOGGLE.down;
    }
  },
  // https://vuejs.org/v2/guide/computed.html#Watchers
  watch: {
    isStateConnecting: function(newVal) {
      if (!newVal) {
        console.log("JoyComp (" + this.ENUM_MOTOR_SIDE + ") -> resetState.");
        this.stateToggle = ENUM_STATE_TOGGLE.stop;
      }
    }
  },
  methods: {
    // vuex-FN
    // ...

    // local(private)-FN
    _callUP() {
      // DEBUG-only
      this.debugMessage = "_callUP()";

      this.stateToggle = ENUM_STATE_TOGGLE.up;

      // call -> [l/r]u
      let commandAPI = this.getCommandUP;

      this.$store.dispatch({
        type: "callApiOne",
        command: commandAPI
      });

      console.log("_callUP: ", commandAPI);
    },
    _callDOWN() {
      // DEBUG-only
      this.debugMessage = "_callDOWN()";

      this.stateToggle = ENUM_STATE_TOGGLE.down;

      // call -> [l/r]d
      let commandAPI = this.getCommandDOWN;

      this.$store.dispatch({
        type: "callApiOne",
        command: commandAPI
      });

      console.log("_callDOWN: ", commandAPI);
    },
    _callSTOP() {
      // DEBUG-only
      this.debugMessage = "_callSTOP()";

      // call -> [l/r]0
      let commandAPI = this.getCommandZERO;

      this.$store.dispatch({
        type: "callApiOne",
        command: commandAPI
      });

      this.stateToggle = ENUM_STATE_TOGGLE.stop;

      console.log("_callSTOP: ", commandAPI);
    },
    onStop(ENUM_UP_DOWN) {
      // call -> [l/r]0
      this._callSTOP();
      console.log("onStop: ", ENUM_UP_DOWN);
    },
    clickToggle(ENUM_UP_DOWN_STOP) {
      switch (ENUM_UP_DOWN_STOP) {
        case "up":
          this._callUP();
          break;
        case "down":
          this._callDOWN();
          break;
        case "stop":
          // call -> [l/r]0
          this._callSTOP();
          break;

        default:
          // call -> [l/r]0
          this._callSTOP();
          console.log("Err-clickToggle(...): NOT match.");
          break;
      }
    }
  }
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.anime-up {
  animation: ping 1s cubic-bezier(0, 0, 0.2, 1) infinite;

  @keyframes ping {
    0% {
      transform: scale(1);
      opacity: 1;
    }
    75%,
    100% {
      transform: scale(2);
      opacity: 0;
    }
  }
}
</style>
