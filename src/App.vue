<template>
  <div id="app">
    <transition name="fade">
		<router-view/>
	</transition>
  </div>
</template>
<style lang="stylus">
#app {
	display: grid;
	width: 100%;
	height: 100%;
}
</style>
