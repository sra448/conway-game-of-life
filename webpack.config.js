module.exports = {
  entry: {
    // "src/conway": "./src/srcipt.ls",
    "spec/conway_spec": "./spec/conway-spec.ls"
  },
  output: {
    path: __dirname,
    filename: "[name].js"
  },
  module: {
    loaders: [
      { test: /\.ls$/, loader: "livescript" }
    ]
  }
}