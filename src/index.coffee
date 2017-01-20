require "./styles/main.styl"

Three = require 'three'
Stats = require 'stats.js'
ThreeWindowResize = require 'three-window-resize'

PI = Math.PI
TAU = PI * 2
PI2 = PI / 2
PI4 = PI / 4

DEFAULT_FOV=60

rendererOptions =
  antialias: true

class Game
  constructor: ->
    @lastElapsed = 0
    @stats = new Stats()
    @renderer = new Three.WebGLRenderer rendererOptions
    @renderer.shadowMap.type = Three.PCFSoftShadowMap
    @renderer.shadowMap.enabled = true
    @speed = 20

    @camera = new Three.PerspectiveCamera DEFAULT_FOV, window.innerWidth / window.innerHeight, 0.1, 100000

    @inputMap = {
      "w": "forward"
      "s": "backward"
      "a": "strafeLeft"
      "d": "strafeRight"
    }

    @inputs = {
      "forward": false
      "backward": false
      "strafeLeft": false
      "strafeRight": false
    }

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

      @mouseSensitivity = 0.0020

      document.addEventListener 'mousemove', (ev) =>
        if @hasControlFocus
          cameraAxes = @getCurrentScene().getObjectByName "mouse_help_axes"

          xmov = (ev.movementX || ev.mozMovementX || ev.webkitMovementX || 0)
          ymov = (ev.movementY || ev.mozMovementY || ev.webkitMovementY || 0)

          @camera.rotation.z -= xmov * @mouseSensitivity
          @camera.rotation.x -= ymov * @mouseSensitivity

          # cameraAxes.rotation = @camera.rotation

      , false

      document.addEventListener 'keydown', (ev) =>
        # console.log "KeyDown: ", ev
        if ev.key of @inputMap then @inputs[@inputMap[ev.key]] = true
      , false

      document.addEventListener 'keyup', (ev) =>
        # console.log "KeyUp: ", ev
        if ev.key of @inputMap then @inputs[@inputMap[ev.key]] = false
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
    axes.name = "world_center_axes"
    scene.add axes

    mouseAxes = new Three.AxisHelper 0.5
    mouseAxes.position.x += 2
    mouseAxes.position.y += 2
    mouseAxes.name = "mouse_help_axes"
    mouseAxes.rotation.order = 'ZYX'
    #scene.add mouseAxes

    geometry = new Three.SphereGeometry 0.5, 32, 32
    material = new Three.MeshNormalMaterial()
    ball = new Three.Mesh geometry, material
    ball.position.set 10, -10, 10
    scene.add ball

    spotLight = new Three.SpotLight 0xffffff, 1, 10000, undefined, 0.5
    spotLight.position.set 0, 0, -1
    spotLight.name = "default_scene_point_light"
    spotLight.castShadow = true

    spotLight.shadow.mapSize.width = 2048
    spotLight.shadow.mapSize.height = 2048

    # spotLight.shadow.camera.near = 500
    # spotLight.shadow.camera.far = 4000
    # spotLight.shadow.camera.fov = 30

    ball.add spotLight

    directionalLight = new Three.DirectionalLight 0xffffffff, 0.2
    directionalLight.name = "default_scene_directional_light"
    directionalLight.position.set 10, 10, 20
    directionalLight.caseShadow = true
    scene.add directionalLight

    directionalLight.shadow.camera.right = 5
    directionalLight.shadow.camera.left = -5
    directionalLight.shadow.camera.top = 5
    directionalLight.shadow.camera.bottom = -5

    geometry = new Three.BoxGeometry 1, 1, 1
    material = new Three.MeshLambertMaterial()
    cube = new Three.Mesh geometry, material
    cube.castShadow = true
    cube.name = "spinning_cube"
    scene.add cube

    # baby skybox

    geometry = new Three.SphereGeometry 0.5, 32, 32
    material = new Three.MeshLambertMaterial()
    ball = new Three.Mesh geometry, material
    ball.castShadow = true
    ball.position.set -1.5, 0, 0
    ball.name = "spinning_ball"
    scene.add ball


    urls = []
    for piece in [ "front", "back", "left", "right", "top", "bottom" ]
      urls.push require "./../static/img/skybox_space_#{piece}.png"

    skyboxCubeTextureLoader = new Three.CubeTextureLoader()
    textureCube = skyboxCubeTextureLoader.load urls, (texture) ->
      shader = Three.ShaderLib["cube"]
      uniforms = Three.UniformsUtils.clone
      uniforms['tCube'].texture = texture

      skyboxMaterial = new Three.ShaderMaterial
        fragmentShader: shader.fragmentShader
        vertexShader: shader.vertexShader
        uniforms: uniforms


      # geometry = new Three.BoxGeometry 40, 40, 40
      geometry = new Three.BoxGeometry 1, 1, 1
      cube = new Three.Mesh geometry, skyboxMaterial
      cube.position.set 0, -3, 0
      cube.castShadow = true
      cube.name = "tiny_skybox"
      scene.add cube

      geometry = new Three.BoxGeometry 5000, 5000, 5000
      urls = []
      for piece in [ "front", "back", "left", "right", "top", "bottom" ]
        urls.push "./static/img/skybox_space_#{piece}.png"
      # textureCube = Three.ImageUtils.loadTextureCube urls
      skybox = new Three.Mesh geometry, skyboxMaterial
      skybox.name = "skybox"
      skybox.scale.set -1, 1, 1
      # scene.add skybox

    geometry = new Three.BoxGeometry 100, 100, 0.1
    material = new Three.MeshPhongMaterial()
    plane = new Three.Mesh geometry, material
    plane.position.z = -1
    plane.receiveShadow = true
    scene.add plane

    #@camera.position.z = 5
    @camera.position.y = 2
    @camera.position.z = 3
    @camera.position.x = 5
    @camera.up = new Three.Vector3 0, 0, 1
    @camera.rotation.order = 'ZYX'
    @camera.lookAt new Three.Vector3 0, 0, 0
    # mouseAxes.rotation = @camera.rotation

    window.camera = @camera

  update: (dt) ->
    # update objects
    cube = @getCurrentScene().getObjectByName "spinning_cube"
    cube.rotation.x += 1 * dt
    cube.rotation.y += 1 * dt

    ball = @getCurrentScene().getObjectByName "spinning_ball"
    ball.rotation.x += 1 * dt
    ball.rotation.y += 1 * dt

    @updatePlayer(dt)

  updatePlayer: (dt) ->
    # mld = document.getElementById 'mouselook-data'
    # mld.innerText = "@lat: #{@latitude}, @lon: #{@longitude}"

    if @hasControlFocus
      effectiveSpeed = @speed

      # TODO: jumping

      if (@inputs.forward or @inputs.backward) and (@inputs.strafeRight or @inputs.strafeLeft)
        effectiveSpeed *= 0.707106781

      if @inputs.forward
        x = @camera.rotation.x
        @camera.rotation.x = PI2
        @camera.translateZ -effectiveSpeed * dt
        @camera.rotation.x = x

      if @inputs.backward
        x = @camera.rotation.x
        @camera.rotation.x = PI2
        @camera.translateZ effectiveSpeed * dt
        @camera.rotation.x = x

      if @inputs.strafeLeft
        @camera.translateX -effectiveSpeed * dt

      if @inputs.strafeRight
        @camera.translateX effectiveSpeed * dt
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
