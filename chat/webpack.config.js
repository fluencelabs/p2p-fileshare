const path = require('path');
const webpack = require('webpack');
const CopyWebpackPlugin = require('copy-webpack-plugin')

module.exports = {
    entry: {
        app: ['./src/index.ts']
    },
    resolve: {
        extensions: ['.js', '.ts']
    },
    devServer: {
        contentBase: './bundle',
        hot: false,
        inline: false,
    },
    devtool: "eval-source-map",
    module: {
        rules: [
            {
                test: /\.tsx?$/,
                loader: 'ts-loader',
                exclude: /node_modules/
            }
        ]
    },
    mode: "development",
    output: {
        filename: 'bundle.js',
        path: path.resolve(__dirname, 'bundle')
    },
    plugins: [
        new CopyWebpackPlugin([{
            from: './*.html'
        }]),
        new webpack.HotModuleReplacementPlugin()
    ]
};

