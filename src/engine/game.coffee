GameRenderer = require './renderer.coffee'
Input = require './input.coffee'

class Game
  constructor: ->
    @lastElapsed = 0

    # initialize game systems
    @player = require('./player.coffee')(this)
    @input = new Input.InputManager this
    @renderer = new GameRenderer this

    # force update to be called in the game's scope
    @update = @update.bind this

  update: (elapsed) ->
    # request next frame
    requestAnimationFrame @update

    # calculate delta time in seconds
    dt = (elapsed - @lastElapsed) * 0.001
    @lastElapsed = elapsed

    # update the renderer
    @renderer.update dt

  start: ->
    # initializations
    @input.setup()
    @renderer.start()

    # request the first frame
    requestAnimationFrame @update

module.exports = new Game()
