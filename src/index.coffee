require "./styles/main.styl"
Three = require 'three'

scene = new Three.Scene()
aspect = window.innerWidth / window.innerHeight
camera = new Three.PerspectiveCamera 120, aspect, 0.1, 1000
renderer = new Three.WebGLRenderer()

renderer.setSize window.innerWidth, window.innerHeight

document.body.appendChild renderer.domElement

geometry = new Three.BoxGeometry 1, 1, 1
material = new Three.MeshNormalMaterial()
cube = new Three.Mesh geometry, material

scene.add cube

camera.position.z = 1.5

lastElapsed = 0
render = (elapsed) ->
  dt = (elapsed - lastElapsed) * 0.001
  lastElapsed = elapsed
  requestAnimationFrame render

  cube.rotation.x += 5 * dt
  cube.rotation.y += 5 * dt

  renderer.render scene, camera

render(0)
