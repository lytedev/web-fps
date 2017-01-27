THREE = require 'three'
ThreeWindowResize = require 'three-window-resize'

Stats = require 'stats.js'

DEFAULT_FOV=70

# NOTE: Maybe move to game?
rendererOptions =
  antialias: true

class GameRenderer
  constructor: (@game, options) ->
    # TODO: merge options
    @stats = new Stats()

    @camera = new THREE.PerspectiveCamera(DEFAULT_FOV, window.innerWidth / window.innerHeight, 0.1, 100000)

    @scenes = {}

    @renderer = new THREE.WebGLRenderer rendererOptions
    @renderer.shadowMap.type = THREE.PCFSoftShadowMap
    @renderer.shadowMap.enabled = true

    @renderer.setSize window.innerWidth, window.innerHeight
    @autoWindowResizer = new ThreeWindowResize @renderer, @camera

    @addDomElements()

    @camera.position.y = 2
    @camera.position.z = 3
    @camera.position.x = 5
    @camera.up = new THREE.Vector3 0, 0, 1
    @camera.rotation.order = 'ZYX'
    @camera.lookAt new THREE.Vector3 0, -1.5, 2.1

  start: (sceneName = 'default') ->
    @currentScene = sceneName
    @loadScene @currentScene

  loadScene: (sceneName, sceneFile) ->
    if not sceneFile? then sceneFile = sceneName
    scene = require("../scenes/" + sceneFile + ".coffee")(@game)
    scene.init()
    @scenes[sceneName] = scene

  addDomElements: ->
    @stats.dom.id = "stats"

    app = document.getElementById 'app'

    app.appendChild @renderer.domElement
    app.appendChild @stats.dom

    contextmenu = (ev) -> ev.preventDefault()

    @renderer.domElement.addEventListener 'contextmenu', contextmenu, false

  getCurrentScene: ->
    @scenes[@currentScene]

  renderCurrentScene: ->
    # render our scene
    @renderer.render @scenes[@currentScene], @camera

  update: (dt) ->
    # start stats
    @stats.begin()

    # TODO: draw an indicator of mouse captured or not

    for name, scene of @scenes
      scene.update dt

    @renderCurrentScene()

    # end stats
    @stats.end()

module.exports = GameRenderer
