<template>
<div class="main">
  <!-- <Header/> -->
  <div class="w-100 d-flex align-items-center text-white" style="height: 10%; background:#2f2f2c">
    <div class="h3 ml-3" id="demo">study</div>
    <span class="ml-3">颜色：</span>
    <el-color-picker v-model="toolsNature.color"></el-color-picker>
    <span class="ml-3">线条粗细或点的大小:</span>
    <el-slider class="d-inline-block pl-3" v-model="toolsNature.size" :min="1" :max="8" style="width:200px"></el-slider>
    <span class="ml-3">标尺：</span>
    <button type="button" class="btn btn-primary btn-sm" @click="crossLine ? crossLine = false : crossLine = true">启用</button>{{crossLine}}
    <span class="ml-3">正圆：</span>
    <button type="button" class="btn btn-primary btn-sm" @click="selectTools('arc')">正圆</button>
  </div>
  <div class="w-100 d-flex" style="height: 85%">
    <div class="p-3 text-white" style="display: flex;background:#2f2f2c;flex-direction: column;">
      <button type="button" class="btn btn-link btn-sm mb-2" @click="selectTools('select')" :style="drawType === 'select' ? 'color: #0cf' : 'color: #ccc'">
        <i class="fa fa-mouse-pointer" style="font-size: 25px"></i>
      </button>
      <button type="button" class="btn btn-link btn-sm mb-2" @click="selectTools('rect')" :style="drawType === 'rect' ? 'color: #0cf' : 'color: #ccc'">
        <i class="fa fa-object-ungroup" style="font-size: 25px"></i>
      </button>
      <button type="button" class="btn btn-link btn-sm mb-2" @click="selectTools('point')" :style="drawType === 'point' ? 'color: #0cf' : 'color: #ccc'">
        <i class="fa fa-crosshairs" style="font-size: 32px"></i>
      </button>
      <button type="button" class="btn btn-link btn-sm mb-2" @click="selectTools('ellipse')" :style="drawType === 'ellipse' ? 'color: #0cf' : 'color: #ccc'">
        <i class="fa fa-circle" style="font-size: 28px"></i>
      </button>
      <button type="button" class="btn btn-link btn-sm mb-2" @click="selectTools('eraser')" :style="drawType === 'eraser' ? 'color: #0cf' : 'color: #ccc'">
        <i class="fa fa-eraser" style="font-size: 28px"></i>
      </button>
      <button type="button" class="btn btn-link btn-sm mb-2" @click="selectTools('pencil')" :style="drawType === 'pencil' ? 'color: #0cf' : 'color: #ccc'">
        <i class="fa fa-paint-brush" style="font-size: 28px"></i>
      </button>
      <button type="button" class="btn btn-link btn-sm mb-2" @click="selectTools('bezierlines')" :style="drawType === 'bezierlines' ? 'color: #0cf' : 'color: #ccc'">
        <i class="fa fa-pencil-square-o" style="font-size: 30px"></i>
      </button>
    </div>
    <div id="canvasBox" class="w-100 d-flex align-items-stretch p-0" style="flex: 1;border: 1px solid #666">
      <canvas id="myCanvas" style="background: #3f3f3c" @mousedown="canvasClick" @mousemove="drag" @mouseup="stopDrag"></canvas>
    </div>
    <div class="p-3 text-white" style="width:250px;background:#2f2f2c">
      <p>元素图层：</p>
      <div class="mb-3" style="height: 300px;overflow-y: auto">
        <div class="p-2 mb-1 rounded" :class="select.index===index?'border border-primary':''" style="background:#3f3f3c" v-for="(item, index) in saveDraw" :key="index">
          {{index}}.{{saveDraw[index].type}}
          <button type="button" class="btn btn-link" @click="delItem(index)"><i class="fa fa-trash-o"></i></button>
        </div>
      </div>
      <button type="button" class="btn btn-primary" @click="clearCanvas"><i class="fa fa-reply-all"></i></button>
      <button type="button" class="btn btn-primary" @click="revoke"><i class="fa fa-reply"></i></button>
    </div>
  </div>
  <div class="w-100 text-white" style="height: 5%; background:#2f2f2c">
    <p>位置：<span class="pr-2">x:{{moveClickX}}</span>,<span class="pl-2">y:{{moveClickY}}</span></p>
  </div>
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
  this.select = (x0, y0) => {
    if (x <= x0 && x0 <= x + width && y <= y0 && y0 <= y + height) {
      return true
    } else {
      return false
    }
  }
}
Rect.prototype.type = 'Rect'

function Point (x, y, r, color) {
  this.x = x
  this.y = y
  this.r = r
  this.color = color
  this.select = (x0, y0) => {
    let position = Math.pow(x0 - x, 2) + Math.pow(y0 - y, 2)
    if (position <= Math.pow(r, 2)) {
      return true
    } else {
      return false
    }
  }
}
Point.prototype.type = 'Point'

function Arc (x, y, r, color, size) {
  this.x = x
  this.y = y
  this.r = r
  this.color = color
  this.size = size
  this.select = (x0, y0) => {
    let position = Math.pow(x0 - x, 2) + Math.pow(y0 - y, 2)
    if (position <= Math.pow(r, 2)) {
      return true
    } else {
      return false
    }
  }
}
Arc.prototype.type = 'Arc'

function Ellipse (x, y, r1, r2, color, size) {
  this.x = x
  this.y = y
  this.r1 = r1
  this.r2 = r2
  this.color = color
  this.size = size
  this.select = (x0, y0) => {
    let position1 = Math.pow(x0 - x, 2) / Math.pow(r1, 2)
    let position2 = Math.pow(y0 - y, 2) / Math.pow(r2, 2)
    if (position1 + position2 <= 1) {
      return true
    } else {
      return false
    }
  }
}
Ellipse.prototype.type = 'Ellipse'
// 拖拽距离
let distanceX
let distanceY

// 点
let oldX
let oldY
let bezier = []
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
        color: '#f00',
        size: 1
      },
      crossLine: false,
      drawType: 'select',
      select: {
        color: '',
        index: ''
      },
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
    // 选择工具
    selectTools (val) {
      this.drawType = val
    },
    // 选中
    selectItem () {
      let vm = this
      for (let i = vm.saveDraw.length - 1; i >= 0; i--) {
        if (vm.saveDraw[i].select && vm.saveDraw[i].select(clickX, clickY)) {
          console.log(vm.saveDraw[i])
          if (vm.select.index === '') {
            vm.select.color = vm.saveDraw[i].color
            vm.saveDraw[i].color = '#000'
            vm.select.index = i
            vm.drawAgain()
          } else {
            vm.saveDraw[vm.select.index].color = vm.select.color
            vm.select.color = vm.saveDraw[i].color
            vm.saveDraw[i].color = '#000'
            vm.select.index = i
            vm.drawAgain()
          }
          return
        } else {
          if (vm.select.index !== '') {
            vm.saveDraw[vm.select.index].color = vm.select.color
            console.log(vm.saveDraw[vm.select.index])
            vm.select.index = ''
            vm.select.color = ''
            vm.drawAgain()
          }
        }
      }
    },
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
    // 删除元素
    delItem (index) {
      this.saveDraw.splice(index, 1)
      this.drawAgain()
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
    // 画笔工具
    pencil (x, y, x1, y1) {
      ctx.beginPath()
      ctx.moveTo(x, y)
      ctx.lineTo(x1, y1)
      ctx.stroke()
      ctx.closePath()
    },
    // 贝塞尔曲线
    drawBezierlines (x0, y0, sx, sy, ex, ey, x1, y1) {
      this.drawPoint(x0, y0, 4)
      ctx.beginPath()
      ctx.moveTo(x0, y0)
      ctx.bezierCurveTo(sx, sy, ex, ey, x1, y1)
      ctx.stroke()
      ctx.closePath()
      this.drawPoint(x1, y1, 4)
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
      if (vm.drawType === 'select') {
        vm.selectItem()
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
          vm.strokeRect(x, y, width, height)
        }
        if (vm.drawType === 'arc' && distanceX !== 0 && distanceY !== 0) {
          vm.drawAgain()
          let arcR = Math.sqrt(distanceX * distanceX + distanceY * distanceY) / 2
          let x1 = distanceX > 0 ? clickX + distanceX / 2 : vm.moveClickX - distanceX / 2
          let y1 = distanceY > 0 ? clickY + distanceY / 2 : vm.moveClickY - distanceY / 2
          vm.drawArc(x1, y1, arcR)
        }
        if (vm.drawType === 'ellipse' && distanceX !== 0 && distanceY !== 0) {
          vm.drawAgain()
          let r1 = width / 2
          let r2 = height / 2
          let x2 = distanceX > 0 ? clickX + distanceX / 2 : vm.moveClickX - distanceX / 2
          let y2 = distanceY > 0 ? clickY + distanceY / 2 : vm.moveClickY - distanceY / 2
          vm.drawEllipse(x2, y2, r1, r2)
        }
        // if (vm.drawType === 'select') {
        //   for (let i = 0; i < vm.saveDraw.length; i++) {
        //     if (vm.saveDraw[i].select(clickX, clickY)) {
        //       let selX = clickX - vm.moveClickX
        //       let selY = clickY - vm.moveClickY
        //       console.log('selX:' + selX, 'selY:' + selY)
        //       vm.saveDraw[i].x = vm.select.item.x - selX
        //       vm.saveDraw[i].y = vm.select.item.y - selY
        //       vm.drawAgain()
        //     }
        //   }
        // }
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
        vm.strokeRect(x, y, width, height)
        vm.drawFont(vm.saveDraw.length, x, y)
        vm.saveDraw.push(new Rect(x, y, width, height, this.toolsNature.color, this.toolsNature.size))
        console.log(vm.saveDraw)
      }
      if (vm.drawType === 'arc' && distanceX !== 0 && distanceY !== 0) {
        let arcR = Math.sqrt(distanceX * distanceX + distanceY * distanceY) / 2
        let x1 = distanceX > 0 ? clickX + distanceX / 2 : vm.moveClickX - distanceX / 2
        let y1 = distanceY > 0 ? clickY + distanceY / 2 : vm.moveClickY - distanceY / 2
        vm.drawArc(x1, y1, arcR)
        vm.drawFont(vm.saveDraw.length, x1 - arcR - 30, y1)
        vm.saveDraw.push(new Arc(x1, y1, arcR, this.toolsNature.color, this.toolsNature.size))
      }
      if (vm.drawType === 'ellipse' && distanceX !== 0 && distanceY !== 0) {
        let r1 = width / 2
        let r2 = height / 2
        let x2 = distanceX > 0 ? clickX + distanceX / 2 : vm.moveClickX - distanceX / 2
        let y2 = distanceY > 0 ? clickY + distanceY / 2 : vm.moveClickY - distanceY / 2
        vm.drawEllipse(x2, y2, r1, r2)
        vm.drawFont(vm.saveDraw.length, x + 10, y + 10)
        vm.saveDraw.push(new Ellipse(x2, y2, r1, r2, this.toolsNature.color, this.toolsNature.size))
      }
      if (vm.drawType === 'bezierlines') {
        console.log('bezier')
        bezier.push({x: clickX, y: clickY})
        if (bezier.length > 1) {
          vm.drawBezierlines(bezier[0].x, bezier[0].y, bezier[0].x, bezier[0].y, bezier[1].x, bezier[1].y, bezier[1].x, bezier[1].y)
          bezier = []
        }
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
html, body, .main {
  height: 100%;
}
</style>
