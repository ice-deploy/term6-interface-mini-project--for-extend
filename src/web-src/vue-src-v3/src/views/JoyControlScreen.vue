<template>
  <div class="home flex h-full bg-orange-500">
    <div class="w-1/5 bg-green-200 flex h-full">
      <JoyComp ENUM_MOTOR_SIDE="l" />
    </div>
    <div class="w-3/5 bg-teal-100">
      <div class="flex h-full">
        <div class="m-auto">
          <div class="flex text-left m-5 bg-white rounded-lg p-2">
            <SettingComp />
          </div>
          <div class="text-center bg-transparent">
            <div
              @click.prevent="startPing"
              v-show="!isStateConnecting"
              class="rounded-full bg-teal-700 text-white"
            >
              <p class="p-6">Connect</p>
            </div>
            <div
              @click="stopPing"
              v-show="isStateConnecting"
              class="rounded-full bg-yellow-600 text-white"
            >
              <p class="p-6">DisConnect</p>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="w-1/5 bg-green-200 flex h-full">
      <JoyComp ENUM_MOTOR_SIDE="r" />
    </div>
  </div>
</template>

<script>
// Event-touch for mobile
// https://stackoverflow.com/questions/57723142/handling-touchstart-touchmove-touchend-the-same-way-as-mousedown-mousemove-mouse
// -// https://stackoverflow.com/questions/51333798/how-can-i-make-mousedown-mouseup-trigger-on-mobile-devices
// -// https://developer.mozilla.org/en-US/docs/Web/Events/touchstart

/**
 * TODO:
 *  ping-animation on isConnecting...
 */

// @ is an alias to /src
import SettingComp from "@/components/SettingComp.vue";
import JoyComp from "@/components/JoyComp.vue";

import { UPDATE_Connecting } from "../store/mutation-types";

export default {
  name: "Home",
  components: {
    SettingComp,
    JoyComp
  },
  data() {
    return {
      // some-data
    };
  },
  computed: {
    isStateConnecting() {
      return this.$store.getters.getConnecting;
    }
  },
  methods: {
    // bind(this)
    // https://stackoverflow.com/questions/61481722/vue-data-updates-in-method-with-setinterval-but-the-dom-view-doesnt-update

    // stopPing = disConnectServer
    stopPing() {
      this.$store.dispatch("callDisConnect");
    },
    // startPing = connectServer
    startPing() {
      this.$store.commit({
        type: UPDATE_Connecting,
        isConnected: true
      });

      this.$store.dispatch("onConnectServer");
    }
  }
};
</script>

<style >
* {
  -webkit-touch-callout: none;

  /* iOS Safari */
  -webkit-user-select: none;

  /* Safari */
  -khtml-user-select: none;

  /* Konqueror HTML */
  -moz-user-select: none;

  /* Firefox */
  -ms-user-select: none;

  /* Internet Explorer/Edge */
  user-select: none;

  /* Non-prefixed version, currently supported by Chrome and Opera */
}
</style>