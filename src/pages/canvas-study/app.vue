<template>
<div class="main">
  <Header/>
  <div id="canvasBox" class="container d-flex align-items-stretch">
    <canvas id="myCanvas" style="background: #ccc" @mousedown="canvasClick" @mousemove="drag" @mouseup="stopDrag"></canvas>
  </div>
  <div class="position-absolute p-3 text-white" style="width:250px;height:500px;top:60px;left:0;background:rgba(0,0,0,0.5)">
    <p>工具：</p>
    <el-radio-group v-model="drawType" size="small">
      <el-radio-button label="rect">矩形</el-radio-button>
      <el-radio-button label="point">标点</el-radio-button>
      <el-radio-button label="arc">正圆</el-radio-button>
      <el-radio-button label="ellipse">椭圆</el-radio-button>
      <el-radio-button label="eraser">橡皮擦</el-radio-button>
      <el-radio-button label="pencil">画笔工具</el-radio-button>
    </el-radio-group>
    <button type="button" class="btn btn-primary" @click="crossLine ? crossLine = false : crossLine = true">标尺</button>
    {{crossLine}}
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

let ctx
let clickX = 0
let clickY = 0
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

function Arc (x, y, r, color, size) {
  this.x = x
  this.y = y
  this.r = r
  this.color = color
  this.size = size
}
Arc.prototype.type = 'Arc'

function Ellipse (x, y, r1, r2, color, size) {
  this.x = x
  this.y = y
  this.r1 = r1
  this.r2 = r2
  this.color = color
  this.size = size
}
Ellipse.prototype.type = 'Ellipse'
// 拖拽距离
let distanceX
let distanceY

// 点
let oldX
let oldY
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
      crossLine: false,
      drawType: 'rect',
      // 保存图形
      saveDraw: []
    }
  },
  mounted: function () {
    const canvas1 = document.getElementById('myCanvas')
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
    // 橡皮工具
    eraser (x, y, size) {
      ctx.save()
      ctx.beginPath()
      ctx.arc(x, y, size, 0, Math.PI * 2, false)
      ctx.clip()
      ctx.clearRect(0, 0, boxWidth, boxHeight)
      ctx.restore()
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
          vm.drawFont(index, el.x, el.y)
        }
        if (el.type === 'Point') {
          vm.drawPoint(el.x, el.y, el.r, el.color)
          vm.drawFont(index, el.x + 10, el.y - 10)
        }
        if (el.type === 'Arc') {
          ctx.setLineDash([el.size, 0])
          vm.drawArc(el.x, el.y, el.r, el.color, el.size)
          vm.drawFont(index, el.x - el.r - 30, el.y)
        }
        if (el.type === 'Ellipse') {
          ctx.setLineDash([el.size, 0])
          vm.drawEllipse(el.x, el.y, el.r1, el.r2, el.color, el.size)
          vm.drawFont(index, el.x - el.r1 + 10, el.y - el.r2 + 10)
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
    // 画圆
    drawArc (x, y, r, color, size) {
      ctx.beginPath()
      ctx.lineWidth = size || this.toolsNature.size
      ctx.strokeStyle = color || this.toolsNature.color
      ctx.arc(x, y, r, 0, 2 * Math.PI)
      ctx.stroke()
      ctx.closePath()
    },
    // 画椭圆
    drawEllipse (x, y, r1, r2, color, size) {
      ctx.beginPath()
      ctx.lineWidth = size || this.toolsNature.size
      ctx.strokeStyle = color || this.toolsNature.color
      ctx.ellipse(x, y, r1, r2, 0, 0, 2 * Math.PI)
      ctx.stroke()
      ctx.closePath()
    },
    // 画十字
    drawCrossline () {
      let vm = this
      ctx.beginPath()
      ctx.moveTo(0, vm.moveClickY)
      ctx.lineTo(boxWidth, vm.moveClickY)
      ctx.stroke()
      ctx.closePath()
      ctx.beginPath()
      ctx.moveTo(vm.moveClickX, 0)
      ctx.lineTo(vm.moveClickX, boxHeight)
      ctx.stroke()
      ctx.closePath()
    },
    pencil (x, y, x1, y1) {
      ctx.beginPath()
      ctx.moveTo(x, y)
      ctx.lineTo(x1, y1)
      ctx.stroke()
      ctx.closePath()
    },
    // 文字
    drawFont (text, x, y) {
      ctx.font = '30px Georgia'
      ctx.fillText(text, x, y)
    },
    // 画布点击事件
    canvasClick (e) {
      let vm = this
      const canvas1 = $('#myCanvas')
      console.log(canvas1)
      clickX = event.clientX - canvas1[0].offsetLeft
      clickY = event.clientY - canvas1[0].offsetTop
      this.drageEvent.status = true
      console.log(`clickX${clickX},clickY:${clickY}`)
      if (vm.drawType === 'point') {
        vm.drawFont(vm.saveDraw.length, clickX + 10, clickY - 10)
        vm.drawPoint(clickX, clickY, this.toolsNature.size)
        vm.saveDraw.push(new Point(clickX, clickY, this.toolsNature.size, this.toolsNature.color))
      }
    },
    // 画布中鼠标移动
    drag (e) {
      let vm = this
      const canvas1 = $('#myCanvas')
      vm.moveClickX = event.clientX - canvas1[0].offsetLeft
      vm.moveClickY = event.clientY - canvas1[0].offsetTop
      if (vm.crossLine) {
        vm.drawAgain()
        ctx.setLineDash([4, 4])
        vm.drawCrossline()
      }
      if (vm.drageEvent.status === true) {
        console.log('拖拽中')
        distanceX = vm.moveClickX - clickX
        distanceY = vm.moveClickY - clickY
        let x = distanceX > 0 ? clickX : vm.moveClickX
        let y = distanceY > 0 ? clickY : vm.moveClickY
        let width = Math.abs(distanceX)
        let height = Math.abs(distanceY)
        if (vm.drawType === 'eraser') {
          vm.eraser(vm.moveClickX, vm.moveClickY, this.toolsNature.size * 2)
        }
        if (vm.drawType === 'pencil') {
          oldX = oldX || clickX
          oldY = oldY || clickY
          vm.pencil(oldX, oldY, vm.moveClickX, vm.moveClickY)
          oldX = vm.moveClickX
          oldY = vm.moveClickY
          console.log('pencil')
        }
        if (vm.drawType === 'rect' && distanceX !== 0 && distanceY !== 0) {
          vm.drawAgain()
          ctx.setLineDash([4, 4])
          vm.strokeRect(x, y, width, height)
        }
        if (vm.drawType === 'arc' && distanceX !== 0 && distanceY !== 0) {
          vm.drawAgain()
          ctx.setLineDash([4, 4])
          let arcR = Math.sqrt(distanceX * distanceX + distanceY * distanceY) / 2
          let x1 = distanceX > 0 ? clickX + distanceX / 2 : vm.moveClickX - distanceX / 2
          let y1 = distanceY > 0 ? clickY + distanceY / 2 : vm.moveClickY - distanceY / 2
          vm.drawArc(x1, y1, arcR)
        }
        if (vm.drawType === 'ellipse' && distanceX !== 0 && distanceY !== 0) {
          vm.drawAgain()
          ctx.setLineDash([4, 4])
          let r1 = width / 2
          let r2 = height / 2
          let x2 = distanceX > 0 ? clickX + distanceX / 2 : vm.moveClickX - distanceX / 2
          let y2 = distanceY > 0 ? clickY + distanceY / 2 : vm.moveClickY - distanceY / 2
          vm.drawEllipse(x2, y2, r1, r2)
        }
      }
    },
    // 画布停止拖拽
    stopDrag () {
      let vm = this
      let x = distanceX > 0 ? clickX : vm.moveClickX
      let y = distanceY > 0 ? clickY : vm.moveClickY
      let width = Math.abs(distanceX)
      let height = Math.abs(distanceY)
      console.log(x)
      if (vm.drawType === 'rect' && distanceX !== 0 && distanceY !== 0) {
        ctx.setLineDash([this.toolsNature.size, 0])
        vm.strokeRect(x, y, width, height)
        vm.drawFont(vm.saveDraw.length, x, y)
        vm.saveDraw.push(new Rect(x, y, width, height, this.toolsNature.color, this.toolsNature.size))
        console.log(vm.saveDraw)
      }
      if (vm.drawType === 'arc' && distanceX !== 0 && distanceY !== 0) {
        ctx.setLineDash([this.toolsNature.size, 0])
        let arcR = Math.sqrt(distanceX * distanceX + distanceY * distanceY) / 2
        let x1 = distanceX > 0 ? clickX + distanceX / 2 : vm.moveClickX - distanceX / 2
        let y1 = distanceY > 0 ? clickY + distanceY / 2 : vm.moveClickY - distanceY / 2
        vm.drawArc(x1, y1, arcR)
        vm.drawFont(vm.saveDraw.length, x1 - arcR - 30, y1)
        vm.saveDraw.push(new Arc(x1, y1, arcR, this.toolsNature.color, this.toolsNature.size))
      }
      if (vm.drawType === 'ellipse' && distanceX !== 0 && distanceY !== 0) {
        ctx.setLineDash([this.toolsNature.size, 0])
        let r1 = width / 2
        let r2 = height / 2
        let x2 = distanceX > 0 ? clickX + distanceX / 2 : vm.moveClickX - distanceX / 2
        let y2 = distanceY > 0 ? clickY + distanceY / 2 : vm.moveClickY - distanceY / 2
        vm.drawEllipse(x2, y2, r1, r2)
        vm.drawFont(vm.saveDraw.length, x + 10, y + 10)
        vm.saveDraw.push(new Ellipse(x2, y2, r1, r2, this.toolsNature.color, this.toolsNature.size))
      }
      vm.drageEvent.status = false
      distanceX = 0
      distanceY = 0
      oldX = 0
      oldY = 0
    }
  }
}
</script>

<style>
</style>
