THREE = require 'three'
GameScene = require './base-scene.coffee'

module.exports = (@game) ->
  scene = new GameScene @game

  scene.update = (dt) ->
    # update scene objects
    cube = @getObjectByName "spinning_cube"
    cube.rotation.x += 1 * dt
    cube.rotation.y += 1 * dt

    ball = @getObjectByName "spinning_ball"
    ball.rotation.x += 1 * dt
    ball.rotation.y += 1 * dt

    game.player.handleInput dt

  scene.init = ->
    @add game.player

    ambientLight = new THREE.AmbientLight 0xffffff, 0.025
    @add ambientLight

    axes = new THREE.AxisHelper 2
    @add axes

    mouseAxes = new THREE.AxisHelper 0.5
    mouseAxes.position.x -= 2
    mouseAxes.position.y -= 2
    mouseAxes.name = "mouse_help_axes"
    mouseAxes.rotation.order = 'ZYX'
    @add mouseAxes

    do => # lamp
      geometry = new THREE.SphereGeometry 0.5, 32, 32
      material = new THREE.MeshNormalMaterial()
      ball = new THREE.Mesh geometry, material
      ball.position.set 10, -10, 10
      @add ball

      spotLight = new THREE.SpotLight 0xffffff, 1, 10000, undefined, 0.5
      spotLight.position.set 0, 0, -1
      spotLight.name = "default_scene_point_light"
      spotLight.castShadow = true

      spotLight.shadow.mapSize.width = 2048
      spotLight.shadow.mapSize.height = 2048

      # spotLight.shadow.camera.near = 500
      # spotLight.shadow.camera.far = 4000
      # spotLight.shadow.camera.fov = 30

      ball.add spotLight

      directionalLight = new THREE.DirectionalLight 0xffffffff, 0.2
      directionalLight.name = "default_scene_directional_light"
      directionalLight.position.set 10, 10, 20
      directionalLight.caseShadow = true
      @add directionalLight

      directionalLight.shadow.camera.right = 5
      directionalLight.shadow.camera.left = -5
      directionalLight.shadow.camera.top = 5
      directionalLight.shadow.camera.bottom = -5

    geometry = new THREE.BoxGeometry 1, 1, 1
    material = new THREE.MeshLambertMaterial()
    cube = new THREE.Mesh geometry, material
    cube.castShadow = true
    cube.name = "spinning_cube"
    @add cube

    geometry = new THREE.SphereGeometry 0.5, 32, 32
    material = new THREE.MeshLambertMaterial()
    ball = new THREE.Mesh geometry, material
    ball.castShadow = true
    ball.position.set -1.5, 0, 0
    ball.name = "spinning_ball"
    @add ball

    geometry = new THREE.BoxGeometry 100, 100, 0.1
    material = new THREE.MeshPhongMaterial()
    plane = new THREE.Mesh geometry, material
    plane.position.z = -1
    plane.receiveShadow = true
    @add plane

    do => # skyboxes
      # load texture map
      textureLoader = new THREE.TextureLoader()
      pieces = [ "front", "back", "left", "right", "top", "bottom" ]
      urls = {}
      textures = {}
      materials = []
      for piece in pieces
        urls[piece] = require "static/img/skybox_space_#{piece}.png"
        textures[piece] = textureLoader.load urls[piece]
        materials.push new THREE.MeshBasicMaterial
          map: textures[piece]
      skyboxFaceMaterial = new THREE.MultiMaterial materials

      # baby skybox
      geometry = new THREE.BoxGeometry 1, 1, 1
      cube = new THREE.Mesh geometry, skyboxFaceMaterial
      cube.position.set 0, -3, 0
      cube.castShadow = true
      cube.name = "tiny_skybox"
      @add cube

      # main skybox
      geometry = new THREE.BoxGeometry 5000, 5000, 5000
      skybox = new THREE.Mesh geometry, skyboxFaceMaterial
      skybox.name = "skybox"
      skybox.scale.set -1, 1, 1
      @add skybox

    # TODO: allow access to camera
    #@camera.position.z = 5
    # @camera.position.y = 2
    # @camera.position.z = 3
    # @camera.position.x = 5
    # @camera.up = new THREE.Vector3 0, 0, 1
    # @camera.rotation.order = 'ZYX'
    # @camera.lookAt new THREE.Vector3 0, -1.5, 2.1

  return scene
