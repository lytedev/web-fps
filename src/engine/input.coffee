InputNames =
  FORWARD: "forward"
  BACKWARD: "backward"
  STRAFE_LEFT: "strafeLeft"
  STRAFE_RIGHT: "strafeRight"

class InputManager
  constructor: ->
    # map keys to input names
    @keyMap =
      w: InputNames.FORWARD
      s: InputNames.BACKWARD
      a: InputNames.STRAFE_LEFT
      d: InputNames.STRAFE_RIGHT

    @keyInputs = {}
    for it of InputNames
      @keyInputs[it] = false

    @otherInputs =
      mouseLook:
        zrot: 0
        xrot: 0

    @mouseSensitivity = 0.0020
    @hasControlFocus = false

  mouseLockHandler: (ev) ->
    body = document.body
    if document.pointerLockElement == body or document.mozPointerLockElement == body or document.webkitPointerLockElement == body
      @hasControlFocus = true
    else
      @hasControlFocus = false

  mouseLockError: (ev) ->
    null

  requestMouseLock: (ev) ->
    body = document.body
    if not @hasControlFocus
      body.requestPointerLock = body.requestPointerLock || body.mozRequestPointerLock || body.webkitRequestPointerLock
      body.requestPointerLock()

  setup: ->
    # setup mouse capture
    browserHasPointerLock = 'pointerLockElement' of document or 'mozPointerLockElement' of document or 'webkitPointerLockElement' of document

    if browserHasPointerLock
      # handle gain or loss of mouse capture
      document.addEventListener 'pointerlockchange', @mouseLockError, false
      document.addEventListener 'mozpointerlockchange', @mouseLockError, false
      document.addEventListener 'webkitpointerlockchange', @mouseLockError, false

      # handle mouse capture errors
      document.addEventListener 'pointerlockerror', @mouseLockHandler, false
      document.addEventListener 'mozpointerlockerror', @mouseLockHandler, false
      document.addEventListener 'webkitpointerlockerror', @mouseLockHandler, false

      # try to capture mouse when the user clicks
      document.addEventListener 'mousedown', @requestMouseLock, false

    # handle mouse move events and translate to mouselook
    document.addEventListener 'mousemove', @mouseLook, false

    # handle keyboard events
    document.addEventListener 'keydown', @keyDown, false
    document.addEventListener 'keyup', @keyUp, false

  mouseLook: (ev) ->
    if @hasControlFocus
      xmov = (ev.movementX || ev.mozMovementX || ev.webkitMovementX || 0)
      ymov = (ev.movementY || ev.mozMovementY || ev.webkitMovementY || 0)
      @otherInputs.mouseLook.zrot = -xmov * @mouseSensitivity
      @otherInputs.mouseLook.xrot = -ymov * @mouseSensitivity

  keyDown: (ev) ->
    if ev.key of @keyMap then @keyInputs[@keyMap[ev.key]] = true

  keyUp: (ev) ->
    if ev.key of @keyMap then @keyInputs[@keyMap[ev.key]] = false

  getInputState: (inputName) ->
    if not inputName? then return { keys: @keyInputs, other: @otherInputs } # return all inputs
    if @keyInputs[inputName] then return @keyInputs[inputName]
    if @otherInputs[inputName] then return @otherInputs[inputName]
    return undefined

module.exports
