<template>
  <div class="bg-orange-300 p-2 flex setting">
    <div class="w-4/5">
      <input
        class="w-4/5"
        type="text"
        ref="formIP"
        @keypress.13.prevent="onEnter"
        @keydown.esc="cancelIP"
        :value="getSettingIP"
        :disabled="!isEditing"
      />
    </div>
    <div class="w-1/5">
      <h1
        class="bg-yellow-200 hover:bg-yellow-700 border border-green-900 text-center py-1 font-bold"
        v-show="!isEditing"
        @click="editIP"
      >Edit</h1>
      <h1 class="bg-green-600 font-semibold" v-show="isEditing" @click="updateIP">Save</h1>
      <h1 class="bg-gray-300 font-semibold" v-show="isEditing" @click="cancelIP">Cancel</h1>
    </div>
  </div>
</template>

<script>
/**
 * NOTE:
 *  set-IP(edit,save)
 */

import { mapGetters } from "vuex";
import { UPDATE_IP } from "@/store/mutation-types";

export default {
  name: "HelloWorld",
  data() {
    return {
      isEditing: false
    };
  },
  computed: {
    ...mapGetters({
      getSettingIP: "getSettingIP"
    })
  },
  methods: {
    onEnter(event) {
      event.preventDefault();
      this.updateIP();
    },
    editIP() {
      this.isEditing = true;
      this.$nextTick(() => this.$refs.formIP.focus());

      console.log("editIP().");
    },
    updateIP() {
      this.isEditing = false;
      let newIP = this.$refs.formIP.value;

      this.$store.commit({
        type: UPDATE_IP,
        newIP: newIP
      });
      this.$cookies.set("lastIP", newIP);

      console.log("updateIP().");
    },
    cancelIP() {
      this.isEditing = false;
      this.$refs.formIP.value = this.getSettingIP;
      console.log("cancelIP().");
    }
  }
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>
