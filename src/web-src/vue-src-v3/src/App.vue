<template>
  <div id="app" class="h-full w-full flex">
    <div class="flex flex-col w-full h-screen">
      <div class="rounded bg-blue-500 items-center">
        <div class="flex px-6 py-2">
          <div class="mt-4 w-5/6 text-left">
            <p class="text-xl text-white leading-tight">โปรแกรมพลิกเตียงผู้ป่วยติกเตียง</p>
          </div>
          <div class="mt-4 w-1/6"></div>
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
