<template>
  <div id="app" class="h-full w-full flex">
    <div class="flex flex-col w-full h-screen">
      <div class="rounded bg-blue-500 items-center">
        <div class="flex px-6 py-2">
          <div class="mt-4 w-5/6 text-left">
            <p class="text-xl text-white leading-tight">โปรแกรมพลิกเตียงผู้ป่วยติกเตียง</p>
          </div>
          <div class="mt-4 w-1/6">
            <div
              class="m-auto inline-flex px-2"
              :class="{'bg-teal-700':!isStateConnecting, 'bg-teal-300':isStateConnecting,} "
            >
              <p class="text-sm text-yellow-700 pr-2">Ping:</p>
              <p class="text-sm text-yellow-900 bg-white">
                {{ getStatePingTimeout }}
                <span class="pl-1 m-0">ms</span>
              </p>
            </div>
          </div>
        </div>
      </div>
      <router-view />
    </div>
  </div>
</template>

<script>
import { INIT_IP } from "@/store/mutation-types";

export default {
  computed: {
    getStatePingTimeout() {
      if (!this.$store.getters.getConnecting) {
        return "-";
      }
      return this.$store.getters.getPing;
    },
    isStateConnecting() {
      return this.$store.getters.getConnecting;
    }
  },
  mounted() {
    // load lastIP from cookie
    this.$store.commit({
      type: INIT_IP
    });
  }
};
</script>