InputNames =
  FORWARD: "forward"
  BACKWARD: "backward"
  STRAFE_LEFT: "strafeLeft"
  STRAFE_RIGHT: "strafeRight"
  MOUSE_LOOK: "mouseLook"

class InputManager
  constructor: (@game) ->
    # map keys to input names
    @keyMap =
      w: InputNames.FORWARD
      s: InputNames.BACKWARD
      a: InputNames.STRAFE_LEFT
      d: InputNames.STRAFE_RIGHT

    @keyInputs = {}
    for it in InputNames
      @keyInputs[it] = false

    @otherInputs =
      "#{InputNames.MOUSE_LOOK}":
        zrot: 0
        xrot: 0

    @mouseSensitivity = 0.0020
    @hasControlFocus = false

  mouseLockHandler: (ev) =>
    body = document.body
    if document.pointerLockElement == body or document.mozPointerLockElement == body or document.webkitPointerLockElement == body
      @hasControlFocus = true
    else
      @hasControlFocus = false

  mouseLockError: (ev) =>
    null

  requestMouseLock: (ev) =>
    body = document.body
    if not @hasControlFocus
      body.requestPointerLock = body.requestPointerLock || body.mozRequestPointerLock || body.webkitRequestPointerLock
      body.requestPointerLock()

  setup: ->
    # setup mouse capture
    browserHasPointerLock = 'pointerLockElement' of document or 'mozPointerLockElement' of document or 'webkitPointerLockElement' of document

    if browserHasPointerLock
      # handle gain or loss of mouse capture
      document.addEventListener 'pointerlockchange', @mouseLockHandler, false
      document.addEventListener 'mozpointerlockchange', @mouseLockHandler, false
      document.addEventListener 'webkitpointerlockchange', @mouseLockHandler, false

      # handle mouse capture errors
      document.addEventListener 'pointerlockerror', @mouseLockError, false
      document.addEventListener 'mozpointerlockerror', @mouseLockError, false
      document.addEventListener 'webkitpointerlockerror', @mouseLockError, false

      # try to capture mouse when the user clicks
      document.addEventListener 'mousedown', @requestMouseLock, false

    # handle mouse move events and translate to mouselook
    document.addEventListener 'mousemove', @mouseLook, false

    # handle keyboard events
    document.addEventListener 'keydown', @keyDown, false
    document.addEventListener 'keyup', @keyUp, false

  mouseLook: (ev) =>
    if @hasControlFocus
      xmov = (ev.movementX || ev.mozMovementX || ev.webkitMovementX || 0)
      ymov = (ev.movementY || ev.mozMovementY || ev.webkitMovementY || 0)
      zrot = -xmov * @mouseSensitivity
      xrot = -ymov * @mouseSensitivity

      @game.renderer.camera.rotation.x += xrot
      @game.renderer.camera.rotation.z += zrot

  keyDown: (ev) =>
    if ev.key of @keyMap then @keyInputs[@keyMap[ev.key]] = true

  keyUp: (ev) =>
    if ev.key of @keyMap then @keyInputs[@keyMap[ev.key]] = false

  getInputState: (inputName) ->
    if not inputName? then return { keys: @keyInputs, other: @otherInputs } # return all inputs
    if @keyInputs[inputName] then return @keyInputs[inputName]
    if @otherInputs[inputName] then return @otherInputs[inputName]
    return undefined

  getInputMap: (returnNames, inputNames) ->
    r = {}
    i = 1
    for j of returnNames
      r[j] = @getInputState inputNames[i - 1]
      i++
    for k in [i..inputNames.length]
      r["input$#{k}"] = @getInputState inputNames[k]
    return r

module.exports =
  InputManager: InputManager
  InputNames: InputNames
