const path = require('path');
const CopyWebpackPlugin = require('copy-webpack-plugin')

module.exports = {
    entry: {
        app: ['./src/index.ts']
    },
    resolve: {
        extensions: ['.js', '.ts', ".elm"]
    },
    devServer: {
        contentBase: './bundle',
        hot: false,
        inline: false,
        historyApiFallback:{
            index: 'bundle/index.html'
        }
    },
    devtool: "eval-source-map",
    module: {
        rules: [
            {
                test: /\.html$/,
                exclude: /node_modules/,
                loader: "file-loader?name=[name].[ext]"
            },
            {
                test: [/\.elm$/],
                exclude: [/elm-stuff/, /node_modules/],
                use: [
                    { loader: "elm-hot-webpack-loader" },
                    {
                        loader: "elm-webpack-loader",
                        options:
                            { debug: true, forceWatch: true }
                    }
                ]
            },
            { test: /\.ts$/, loader: "ts-loader" }
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
        // new webpack.HotModuleReplacementPlugin()
    ],
    serve: {
        inline: true,
        stats: "errors-only"
    }
};

