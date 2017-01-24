THREE = require 'three'
Input = require './input.coffee'

Object3D = THREE.Object3D

class Player extends Object3D
  constructor: (@game) ->
    # pseudo-inherit the THREE.Object3D
    Object3D.apply this

    @speed = 20

  handleInput: (dt) ->
    input = @game.input
    inputs = input.getInputState()
    camera = @game.renderer.camera

    # console.log inputs

    if input.hasControlFocus
      effectiveSpeed = @speed

      # console.log inputs.keys.

      forwardOrBackward = (inputs.keys.forward or inputs.keys.backward)
      leftOrRight = (inputs.keys.strafeRight or inputs.keys.strafeLeft)
      if forwardOrBackward and leftOrRight
        effectiveSpeed *= 0.707106781

      if inputs.keys.forward
        x = camera.rotation.x
        camera.rotation.x = PI2
        camera.translateZ -effectiveSpeed * dt
        camera.rotation.x = x

      if inputs.keys.backward
        x = camera.rotation.x
        camera.rotation.x = PI2
        camera.translateZ effectiveSpeed * dt
        camera.rotation.x = x

      if inputs.keys.strafeLeft
        camera.translateX -effectiveSpeed * dt

      if inputs.keys.strafeRight
        camera.translateX effectiveSpeed * dt
      null

module.exports = (game) ->
  new Player game
