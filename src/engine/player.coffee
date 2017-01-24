class Player
  constructor: ->
    @speed = 20

  update: (dt) ->
    if @hasControlFocus
      effectiveSpeed = @speed

      forwardOrBackward = (@inputs.forward or @inputs.backward)
      leftOrRight = (@inputs.strafeRight or @inputs.strafeLeft)
      if forwardOrBackward and leftOrRight
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

