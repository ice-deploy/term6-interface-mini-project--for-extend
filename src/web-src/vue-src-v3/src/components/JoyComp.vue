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
      return this.$store.getters.getConnecting;
    },
    isStateMotor() {
      // รับ stateMotor จาก Vuex มา render(update-stateLocal)

      if (this.ENUM_MOTOR_SIDE == "l") {
        return this.$store.getters.getStateMotor.left;
      } else if (this.ENUM_MOTOR_SIDE == "r") {
        return this.$store.getters.getStateMotor.right;
      } else {
        console.log("Err ENUM_STATE_TOGGLE-not-[r/l] in JoyComp.vue");
        return ENUM_STATE_TOGGLE.stop;
      }
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
      //(newVal, oldVal)
      if (!newVal) {
        console.log("JoyComp (" + this.ENUM_MOTOR_SIDE + ") -> resetState.");
        this.stateToggle = ENUM_STATE_TOGGLE.stop;
      }
    },
    isStateMotor: function(newVal) {
      // deep-watch
      // https://stackoverflow.com/questions/42133894/vue-js-how-to-properly-watch-for-nested-data
      this.stateToggle = newVal;
      console.log("update stateToggle to:", newVal);
    }
  },
  methods: {
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

    // this-FN
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
      console.log("Event-> clickToggle: ", ENUM_UP_DOWN_STOP);
    }
  }
};
</script>
