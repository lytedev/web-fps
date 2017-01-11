require "./styles/main.styl"

Three = require 'three'
Stats = require 'stats.js'
ThreeWindowResize = require 'three-window-resize'

rendererOptions =
  antialias: true

class Game
  constructor: ->
    @lastElapsed = 0
    @stats = new Stats()
    @camera = new Three.PerspectiveCamera 60, window.innerWidth / window.innerHeight, 0.1, 100000
    @renderer = new Three.WebGLRenderer rendererOptions

    @currentScene = 'default'
    @scenes =
      "#{@currentScene}": new Three.Scene()

    @renderer.setSize window.innerWidth, window.innerHeight
    @autoWindowResizer = new ThreeWindowResize @renderer, @camera

    # forces the render method to use our class instance's scope
    @render = this.render.bind this

    @addDomElements()
    @defaultSceneObjects()

    @firstPersonControls()

    requestAnimationFrame @render

  getCurrentScene: -> @scenes[@currentScene]

  firstPersonControls: ->
    @hasControlFocus = false
    @latitude = 0
    @longitude = 0

    hasPointerLock = 'pointerLockElement' of document or 'mozPointerLockElement' of document or 'webkitPointerLockElement' of document
    console.log hasPointerLock

    if hasPointerLock
      element = document.body

      pointerLockChange = (ev) =>
        if document.pointerLockElement == element or document.mozPointerLockElement == element or document.webkitPointerLockElement == element
          @hasControlFocus = true
          # TODO: hide the other thing
        else
          @hasControlFocus = false
          # TODO: show a thing letting the user know they need to click

      pointerLockError = (ev) -> null

      document.addEventListener 'pointerlockchange', pointerLockChange, false
      document.addEventListener 'mozpointerlockchange', pointerLockChange, false
      document.addEventListener 'webkitpointerlockchange', pointerLockChange, false

      document.addEventListener 'pointerlockerror', pointerLockError, false
      document.addEventListener 'mozpointerlockerror', pointerLockError, false
      document.addEventListener 'webkitpointerlockerror', pointerLockError, false

      document.addEventListener 'mousedown', (ev) ->
        element.requestPointerLock = element.requestPointerLock || element.mozRequestPointerLock || element.webkitRequestPointerLock
        element.requestPointerLock()
      , false

      @mouseSensitivity = 0.20

      document.addEventListener 'mousemove', (ev) =>
        if @hasControlFocus
          xmov = (ev.movementX || ev.mozMovementX || ev.webkitMovementX || 0)
          ymov = (ev.movementY || ev.mozMovementY || ev.webkitMovementY || 0)
      , false

  addDomElements: ->
    @stats.dom.id = "stats"
    document.getElementById('app').appendChild @renderer.domElement
    document.getElementById('app').appendChild @stats.dom

    contextmenu = (ev) -> ev.preventDefault()

    @renderer.domElement.addEventListener 'contextmenu', contextmenu, false

  defaultSceneObjects: ->
    scene = @getCurrentScene()

    ambientLight = new Three.AmbientLight 0xffffff, 0.025
    # ambientLight.position.set 10, 10, 10
    ambientLight.name = "default_scene_ambient_light"
    scene.add ambientLight

    axes = new Three.AxisHelper 2
    scene.add axes

    pointLight = new Three.PointLight 0xffffff, 1, 10000
    pointLight.position.set 10, -10, 10
    pointLight.name = "default_scene_point_light"
    scene.add pointLight

    geometry = new Three.BoxGeometry 1, 1, 1
    material = new Three.MeshLambertMaterial()
    cube = new Three.Mesh geometry, material
    cube.name = "spinning_cube"
    scene.add cube

    geometry = new Three.CubeGeometry 1000, 1000, 1000
    material = new Three.MeshNormalMaterial()
    skybox = new Three.Mesh geometry, material
    skybox.name = "skybox"
    scene.add skybox

    geometry = new Three.PlaneGeometry 10, 10, 1, 1
    material = new Three.MeshPhongMaterial()
    plane = new Three.Mesh geometry, material
    plane.position.z = -1.5
    scene.add plane

    #@camera.position.z = 5
    @camera.position.y = 2
    @camera.position.z = 3
    @camera.position.x = 5
    @camera.up = new Three.Vector3 0, 0, 1
    @camera.lookAt new Three.Vector3 0, 0, 0

  update: (dt) ->
    # update objects
    cube = @getCurrentScene().getObjectByName "spinning_cube"
    cube.rotation.x += 1 * dt
    cube.rotation.y += 1 * dt

    @updatePlayer(dt)

  updatePlayer: (dt) ->
    mld = document.getElementById 'mouselook-data'
    mld.innerText = "@lat: #{@latitude}, @lon: #{@longitude}"

    if @hasControlFocus
      null

  renderCurrentScene: ->
    # render our scene
    this.renderer.render this.scenes[this.currentScene], this.camera

  render: (elapsed) ->
    # start stats
    this.stats.begin()

    # request next frame
    requestAnimationFrame this.render

    # calculate delta time
    dt = (elapsed - this.lastElapsed) * 0.001
    this.lastElapsed = elapsed

    @update dt
    @renderCurrentScene()

    # end stats
    this.stats.end()

game = new Game()
