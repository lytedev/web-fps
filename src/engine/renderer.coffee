THREE = require 'three'
ThreeWindowResize = require 'three-window-resize'

Stats = require 'stats.js'

DEFAULT_FOV=60

PI = Math.PI
TAU = PI * 2
PI2 = PI / 2
PI4 = PI / 4

# NOTE: Maybe move to game?
rendererOptions =
  antialias: true

class GameRenderer
  constructor: ->
    @renderer = new THREE.WebGLRenderer rendererOptions
    @renderer.shadowMap.type = THREE.PCFSoftShadowMap
    @renderer.shadowMap.enabled = true
    @stats = new Stats()

    @camera = new THREE.PerspectiveCamera(
      DEFAULT_FOV,
      window.innerWidth / window.innerHeight,
      0.1, 100000)

    @currentScene = 'default'
    @scenes =
      "#{@currentScene}": new THREE.Scene()

    @renderer.setSize window.innerWidth, window.innerHeight
    @autoWindowResizer = new ThreeWindowResize @renderer, @camera

    @addDomElements()

    # forces the render method to use our class instance's scope
    @render = this.render.bind this

  addDomElements: ->
    @stats.dom.id = "stats"
    document.getElementById('app').appendChild @renderer.domElement
    document.getElementById('app').appendChild @stats.dom

    contextmenu = (ev) -> ev.preventDefault()

    @renderer.domElement.addEventListener 'contextmenu', contextmenu, false

  start: ->
    requestAnimationFrame @render

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

    # TODO: draw an indicator of mouse captured or not

    @update dt
    @renderCurrentScene()

    # end stats
    this.stats.end()

