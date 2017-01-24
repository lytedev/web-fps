webpack = require 'webpack'
htmlPlugin = require 'html-webpack-plugin'
poststylus = require 'poststylus'

htmlPluginConfig =
  template: 'index.pug'

module.exports =
  context: __dirname + '/src'
  entry: './index.coffee'
  output:
    path: __dirname + '/dist'
    filename: 'bundle.[hash].js'

  module:
    loaders: [
      { test: /\.pug$/, loader: 'pug' }
      { test: /\.styl$/, loader: 'style!css!stylus' }
      { test: /\.coffee$/, loader: 'coffee' }
      { test: /\.jpe?g$|\.gif$|\.png$|\.svg$|\.woff$|\.ttf$|\.wav$|\.mp3$/, loader: 'file' }
    ]

  resolve:
    alias:
      static: __dirname + '/static'

  plugins: [
    new htmlPlugin(htmlPluginConfig)
    new webpack.DefinePlugin
      'PI': JSON.stringify Math.PI
      'TAU': JSON.stringify Math.PI * 2
      'PI2': JSON.stringify Math.PI / 2
      'PI4': JSON.stringify Math.PI / 4
  ]

  stylus:
    use: [
      poststylus()
    ]
