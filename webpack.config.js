htmlPlugin = require("html-webpack-plugin")
poststylus = require("poststylus")

htmlPluginConfig = {
  template: "index.pug"
}

module.exports = {
  context: __dirname + "/src",
  entry: "./index.js",
  output: {
    path: __dirname + "/dist",
    filename: "bundle.[hash].js"
  },
  module: {
    loaders: [
      { test: /\.pug$/, loader: "pug" },
      { test: /\.styl$/, loader: "style!css!stylus" }
    ]
  },
  plugins: [
    new htmlPlugin(htmlPluginConfig),
  ],
  stylus: {
    use: [
      poststylus()
    ]
  }
}
