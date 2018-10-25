<template>
<div id="header">
  <nav class="navbar navbar-light navbar-expand-md fixed-top">
    <a class="navbar-brand p-2" href="/">
      <img src="~assets/img/miao.png" class="rounded" height="40px" />
      <span>{{$t("navbar.title")}}</span>
    </a>
  </nav>
</div>
</template>

<script>

export default {
  name: 'app',
  props: ['location'],
  data () {
    return {
    }
  },
  mounted: function () {
    this.$nextTick(function () {
      // Code that will run only after the
      // entire view has been rendered
    })
  },
  methods: {
  }
}
</script>
<style scoped>
#header .navbar {
  background-color:#FFFFFF;
  box-shadow: 0 1px 2px 0 rgba(31,45,61,.1);
  padding-top: 0rem;
  padding-bottom: 0rem;
}
#header .navbar-brand {
  padding-top: 0rem;
  padding-bottom: 0rem;
}
</style>
