require("./styles/main.styl")
Three = require('three')

let scene = new Three.Scene()
let aspect = window.innerWidth / window.innerHeight
let camera = new Three.PerspectiveCamera(120, aspect, 0.1, 1000)
let renderer = new Three.WebGLRenderer()

renderer.setSize(window.innerWidth, window.innerHeight)

document.body.appendChild(renderer.domElement)

let geometry = new Three.BoxGeometry(1, 1, 1)
let material = new Three.MeshNormalMaterial()
let cube = new Three.Mesh(geometry, material)

scene.add(cube)

camera.position.z = 1.5

let lastElapsed = 0
let render = function(elapsed) {
  let dt = (elapsed - lastElapsed) * 0.001
  lastElapsed = elapsed
  requestAnimationFrame(render)

  cube.rotation.x += 5 * dt
  cube.rotation.y += 5 * dt

  renderer.render(scene, camera)
}

render(0)
