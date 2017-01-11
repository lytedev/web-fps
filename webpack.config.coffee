htmlPlugin = require "html-webpack-plugin"
poststylus = require "poststylus"

htmlPluginConfig =
  template: "index.pug"

module.exports =
  context: __dirname + "/src"
  entry: "./index.coffee"
  output:
    path: __dirname + "/dist"
    filename: "bundle.[hash].js"
  module:
    loaders: [
      { test: /\.pug$/, loader: "pug" }
      { test: /\.styl$/, loader: "style!css!stylus" }
      { test: /\.coffee$/, loader: "coffee" }
    ]
  plugins: [ new htmlPlugin(htmlPluginConfig) ]
  stylus:
    use: [
      poststylus()
    ]
