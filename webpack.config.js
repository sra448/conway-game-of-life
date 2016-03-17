module.exports = {
  entry: {
    "src/conway": "./src/conway.ls",
    "spec/conway-spec": "./spec/conway-spec.ls",
    "spec/perf-spec": "./spec/perf-spec.ls"
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