// use the new NPM package name, `shakapacker`.
// merge is webpack-merge from https://github.com/survivejs/webpack-merge
const { webpackConfig: baseWebpackConfig, merge } = require('shakapacker')

const options = {
  resolve: {
    extensions: ['.scss', '.css', '.png', '.svg', '.gif', '.jpeg', '.jpg', 'ico', 'woff', 'woff2']
  }
}

module.exports = merge({}, baseWebpackConfig, options)
