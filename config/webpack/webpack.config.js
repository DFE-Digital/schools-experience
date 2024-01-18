// use the new NPM package name, `shakapacker`.
// merge is webpack-merge from https://github.com/survivejs/webpack-merge
const { generateWebpackConfig, merge } = require('shakapacker')

const options = {
  resolve: {
     extensions: ['.scss', '.css', '.png', '.svg', '.gif', '.jpeg', '.jpg', 'ico', 'woff', 'woff2']
   }
}

const webpackConfig = generateWebpackConfig()

module.exports = merge({}, webpackConfig, options)
