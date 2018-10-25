<template>
<div class="main">
  <Header/>
  <div id="canvasBox" class="container d-flex align-items-stretch">
    <canvas id="myCanvas" style="background: #ccc" @mousedown="canvasClick" @mousemove="drag" @mouseup="stopDrag"></canvas>
  </div>
  <div class="position-absolute p-3 text-white" style="width:250px;height:500px;top:60px;left:0;background:rgba(0,0,0,0.5)">
    <p>工具：</p>
    <el-radio-group v-model="drawType">
      <el-radio label="rect">矩形</el-radio>
      <el-radio label="point">标点</el-radio>
    </el-radio-group>
    <p>工具属性：</p>
    <span>颜色：</span>
    <el-color-picker v-model="toolsNature.color"></el-color-picker>
    <p>线条粗细或点的大小:</p>
    <el-slider v-model="toolsNature.size" :min="1" :max="8"></el-slider>
    <p>操作：</p>
    <button type="button" class="btn btn-primary" @click="clearCanvas">清除画布</button>
    <button type="button" class="btn btn-primary" @click="revoke">撤销</button>
    <p class="pt-3">位置：<span class="pr-2">x:{{moveClickX}}</span>,<span class="pl-2">y:{{moveClickY}}</span></p>
    <!-- <button type="button" class="btn btn-primary">Primary</button> -->
  </div>
  <Footer/>
</div>
</template>

<script>
import Header from 'components/header'
import Footer from 'components/footer'
import $ from 'jquery'

var ctx
var clickX = 0
var clickY = 0
// 画布宽高
let boxWidth = 0
let boxHeight = 0

// 构造函数
function Rect (x, y, width, height, color, size) {
  this.x = x
  this.y = y
  this.width = width
  this.height = height
  this.color = color
  this.size = size
}
Rect.prototype.type = 'Rect'

function Point (x, y, r, color) {
  this.x = x
  this.y = y
  this.r = r
  this.color = color
}
Point.prototype.type = 'Point'
// 拖拽距离
var distanceX
var distanceY
export default {
  name: 'app',
  components: {
    Header,
    Footer
  },
  data () {
    return {
      moveClickX: 0,
      moveClickY: 0,
      // 拖拽事件
      drageEvent: {
        status: false
      },
      toolsNature: {
        color: '#000',
        size: 1
      },
      drawType: 'rect',
      // 保存图形
      saveDraw: []
    }
  },
  mounted: function () {
    var canvas1 = document.getElementById('myCanvas')
    ctx = canvas1.getContext('2d')
    // canvas1的宽高等于外盒子的宽高
    const box = $('#canvasBox')
    boxWidth = box[0].clientWidth
    boxHeight = box[0].clientHeight
    canvas1.width = boxWidth
    canvas1.height = boxHeight
  },
  methods: {
    // 清除画布
    clearCanvas () {
      ctx.clearRect(0, 0, boxWidth, boxHeight)
      this.saveDraw = []
    },
    // 撤销
    revoke () {
      if (this.saveDraw.length > 0) {
        this.saveDraw.pop()
        this.drawAgain()
      }
    },
    // 重绘
    drawAgain () {
      let vm = this
      ctx.clearRect(0, 0, boxWidth, boxHeight)
      vm.saveDraw.forEach((el, index) => {
        if (el.type === 'Rect') {
          ctx.setLineDash([el.size, 0])
          vm.strokeRect(el.x, el.y, el.width, el.height, el.color, el.size)
        }
        if (el.type === 'Point') {
          vm.drawPoint(el.x, el.y, el.r, el.color)
        }
      })
    },
    // 画矩形
    strokeRect (x, y, width, height, color, size) {
      ctx.beginPath()
      ctx.strokeStyle = color || this.toolsNature.color
      ctx.lineWidth = size || this.toolsNature.size
      ctx.rect(x, y, width, height)
      ctx.stroke()
      ctx.closePath()
    },
    // 画点
    drawPoint (x, y, r, color) {
      ctx.beginPath()
      ctx.strokeStyle = color || this.toolsNature.color
      ctx.fillStyle = color || this.toolsNature.color
      ctx.arc(x, y, r, 0, 2 * Math.PI)
      ctx.stroke()
      ctx.fill()
      ctx.closePath()
    },
    // 画布点击事件
    canvasClick (e) {
      let vm = this
      var canvas1 = $('#myCanvas')
      console.log(canvas1)
      clickX = event.clientX - canvas1[0].offsetLeft
      clickY = event.clientY - canvas1[0].offsetTop
      this.drageEvent.status = true
      console.log(`clickX${clickX},clickY:${clickY}`)
      if (vm.drawType === 'point') {
        vm.drawPoint(clickX, clickY, this.toolsNature.size)
        vm.saveDraw.push(new Point(clickX, clickY, this.toolsNature.size, this.toolsNature.color))
      }
    },
    // 画布中鼠标移动
    drag (e) {
      let vm = this
      var canvas1 = $('#myCanvas')
      vm.moveClickX = event.clientX - canvas1[0].offsetLeft
      vm.moveClickY = event.clientY - canvas1[0].offsetTop
      if (vm.drageEvent.status === true) {
        console.log('拖拽中')
        distanceX = vm.moveClickX - clickX
        distanceY = vm.moveClickY - clickY
        var x = distanceX > 0 ? clickX : vm.moveClickX
        var y = distanceY > 0 ? clickY : vm.moveClickY
        var width = Math.abs(distanceX)
        var height = Math.abs(distanceY)
        // ctx.clearRect(0, 0, boxWidth, boxHeight)
        if (vm.drawType === 'rect' && distanceX !== 0 && distanceY !== 0) {
          vm.drawAgain()
          ctx.setLineDash([4, 4])
          vm.strokeRect(x, y, width, height)
        }
        // ctx.setLineDash([4, 4])
      }
    },
    // 画布停止拖拽
    stopDrag () {
      let vm = this
      var x = distanceX > 0 ? clickX : vm.moveClickX
      var y = distanceY > 0 ? clickY : vm.moveClickY
      var width = Math.abs(distanceX)
      var height = Math.abs(distanceY)
      console.log(x)
      if (vm.drawType === 'rect' && distanceX !== 0 && distanceY !== 0) {
        ctx.setLineDash([this.toolsNature.size, 0])
        vm.strokeRect(x, y, width, height)
        vm.saveDraw.push(new Rect(x, y, width, height, this.toolsNature.color, this.toolsNature.size))
        console.log(vm.saveDraw)
      }
      vm.drageEvent.status = false
    }
  }
}
</script>

<style>
</style>
