class Game
  constructor: ->
    @speed = 20

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

module.exports = new Game()
