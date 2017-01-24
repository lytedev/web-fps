THREE = require 'three'

Scene = THREE.Scene

class GameScene extends Scene
  constructor: (@game) ->
    # pseudo-inherit the THREE.Scene
    Scene.apply this

    @update = (dt) ->
      null
    @init = ->
      null

module.exports = GameScene
