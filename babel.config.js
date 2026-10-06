// Babel is only used by Jest to transform ES modules for the test run.
// esbuild compiles the application JavaScript (see package.json "build").
module.exports = {
  presets: [
    ['@babel/preset-env', { targets: { node: 'current' } }]
  ]
}
