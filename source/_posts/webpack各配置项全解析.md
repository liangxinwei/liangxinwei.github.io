---
title: webpack各配置项全解析
date: 2019-01-30 18:59:45
categories: 前端
---

以下内容摘自**【深入浅出webpack】**，包含每一项的具体配置。

## entry
表示入口, Webpack 执行构建的第一步将从 Entry 开始,可抽象成输入，类型可以是 string、 object、 array
```
// 只有 1 个入口,入口只有 1 个文件
entry: ' ./app/entry',
// 只有1个入口,入口有两个文件
entry: [
    './app/entry1',
    './app/entry2'
],
// 有两个入口
entry: {
    a: './app/entry-a',
    b: ['./app/entry-bl', './app/entry-b2']
},
```

## output
如何输出结果 : 在 Webpack 经过一系列处理后,如何输出最终想要的代码
```
{
    // 输出文件存放的目录,必须是 string 类型的绝对路径
    path: path.resolve(dirname, ' dist '),
    // 输出文件的名称
    // 完整的名称
    filename: ' bundle.js',
    // 在配置了多个 entry 时,通过名称模板为不同的 entry 生成不同的文件名称
    filename: ' [name].js',
    // 根据文件内容的 Hash 值生成文件的名称, 用于 浏览器长时间缓存文件
    filename: ' [chunkhash].js',
    // 放到指定目录下
    // 发布到线上的所有资源的 URL 前缀,为 string 类型
    publicPath: '/assets/',
    // 放到根目录下
    publicPath: '',
    // 放到 CDN 上 // 导出库的名称 , 为 string 类型, 不填它时,默认的输出格式是匿名的立即执行函数
    publicPath: 'https://cdn.example.com/',
    library: ' MyLibrary ',
    // 导出库的类型,为枚举类型,默认是 var
    // 可以是umd、 umd2、 commonjs2、 commonjs、 amd、 this、 var、 assign、 window、global、jsonp
    libraryTarget: 'umd',
    // 是否包含有用的文件路径信息到生成的代码里 ,为 boolean 类型
    pathinfo: true,
    // 附加 Chunk 的文件名称
    chunkFilename: '[id].js',
    chunkFilename: '[chunkhash].js',
    // JSONP 异步加载资源时的回调函数名称,需要和服务端搭配使用
    jsonpFunction: 'myWebpackJsonp',
    // 生成的 Source Map 文件的名称
    // 浏览器开发者工具里显示的源码模块名称
    sourceMapFilename: '[file].map',
    // 异步加载跨域的资源时使用的方式
    devtoolModuleFilenameTemplate: 'webpack:lll[resource-path]',
    crossOriginLoading: 'use-credentials',
    crossOriginLoading: 'anonymous',
    crossOriginLoading: false
},
```

## module
配置模块相关
```
{
    // 不用解析和处理的模块，Webpack忽略对部分没采用模块化的文件的递归解析处理，这样做的好处是能提高构建性能
    // 注意，被忽略掉的文件里不应该包含 import、 require、 define 等模块化语句，
    // 不然会导致在构建出的代码中包含无法在浏览器环境下执行的模块化语句。
    // 单独、完整的 、react.min.js、文件没有采用模块化，忽略对 、react.min.js、文件 的递归解析处理
    noParse: [/react\.min\.js$/],
    // 配置 Loader
    rules: [
      {
        // 正则匹配命中要使用 Loader 的文件
        test: /\.jsx$/,
        // 只会命中这里面的文件
        include: [
          path.resolve(__dirname, 'src')
        ],
        // 忽略这里面的文件
        exclude: [
          path.resolve(__dirname, 'node_modules')
        ],
        // 使用哪些 Loader,有先后次序,从后向前执行
        use: [
          // style-loader会将 css代码转换成字符串后，注入 JavaScript代码中，通过 JavaScript 向 DOM 增加样式。 如果我们想将 css 代码提取到一个单独的文件中，而不是和 JavaScript 混在 一 起，则可以使用 ExtractTextPlugin
          'style-loader',
          // css-loader 会找出 css 代码中 eimport 和 url ()这样的导入语句，告诉 Webpack 依赖这些资源 。 同时支持 CSS Modules、压缩 css 等功能 。处理完后再将结果交给 style-loader处理。
          'css-loader',
          // 通过 sass-loader将 scss 源码转换为 css 代码，再将 css 代码交给 css-loader处理。
          'sass-loader',
          // 直接使用 Loader 的名称
          {
            loader: 'css-loader',
            // 向 html-loader 传一些参数
            options: {}
          },
        ],
        // 不用解析和处理的模块，Webpack忽略对部分没采用模块化的文件的递归解析处理，这样做的好处是能提高构建性能
        noParse: [
          // 用正则匹配
          /special-library\.js$/
        ]
      }
    ],
    /**
     * 配置插件
     */
    plugins: [],
    /**
     * 配置寻找模块的规则
     */
    resolve: {
        // 寻找模块的根目录,为 array 类型,默认以 node_modules 为根目录
        // 可以指明存放第三方模块的绝对路径，以减少寻找， dirname 表示当前工作目录
        modules: [path.resolve(__dirname, 'node_modules')],
        modules: [
            'node modules ',
             path.resolve(__dirname, 'app')
        ],
        // 模块的后缀名，后缀尝试列表要尽可能小，频率出现最高的文件后缀要优先放在最前面
        extensions: ['.js', 'json', 'jsx', '.css'],
        // 模块别名配置,用于映射模块，从而跳过耗时的递归解析操作。
        alias: {
          // 将 'module'映射成'new-module' ,同样, 'module/path/file'也会被映射 成'new-module/path/file'
          'module': 'new-module',
          // 使用结尾符号$后 ,将 'only-module' 映射成 'new-module', // 但是不像上面的 ,' module/path/file '不会被映射成' new-module/path/file
          'only-module$': 'new-modules',
        },
        // alias 还支持使用数组来更详细地进行配置
        alias: [
            {
              // 老模块
              name: 'module',
              // 新模块
              alias: 'new-module ',
              // 是否只映射模块,如果是 true, 则只有' module '会被映射:如果是 false,则'module/inner/path '也会被映射
              onlyModule: true,
            }
        ],
        // 是否跟随文件的软链接去搜寻模块的路径
        symlinks: true,
        // 模块的描述文件
        descriptionFiles: [' package.json '],
        // 模块的描述文件里描述入口的文件的字段名
        mainFields: [' main '],
        // 是否强制导入语句写明文件后缀
        enforceExtension: false
    },
    /**
     * 输出文件的性能检查配置
     */
    performance: {
        // 有性能问题时输出警告
        hints: 'warning ',
        // 有性能问题时输出错误
        hints: 'error ',
        // 关闭性能检查
        hints: false,
        // 最大文件的大小(单位为 bytes)
        maxAssetSize: 200000,
        // 最大入口文件的大小 (单位为 bytes)
        maxEntrypointSize: 400000,
        // 过滤要检查的文件
        assetFilter: function (assetFilename) {
            return assetFilename.endsWith(' .css ') || assetFilename.endsWith('.js');
        }
    },
    // 配置 source-map 类型
    devtool: ' source-map ',
    // Webpack 使用的根目录, string 类型必须是绝对路径 //  配置输出代码的运行环境
    context: __dirname,
    // 浏览器,默认
    target: 'web',
    // WebWorker
    target: 'webworker',
    // Node.js,使用 、require、语句加载 Chunk代码 target:'async-node', II Node.js,异步加载 Chunk代码
    target: 'node',
    // nw.js
    target: 'node-webkit',
    // electron,主线程
    target: 'electron-main',
    // electron,渲染线程
    target: 'electron-renderer',
    // 使用来自 JavaScript 运行环境提供的全局变量
    externals: {
        jquery: 'jQuery'
    },
    /**
     * 控制台输出日志控制
     */
    stats: {
      assets: true,
      colors: true,
      errors: true,
      errorDetails: true,
      hash: true
    },
    /**
     * DevServer 相关的配置
     */
    devServer: {
        // 代理到后端服务接口
        proxy: {
            '/api': 'http:// localhost:3000'
        },
        // 配置 DevServer HTTP 服务器的文 件根目录
        contentBase: path.join(__dirname, 'public'),
        // 是否开启 Gzip 压缩
        compress: true,
        // 是否开发 HTMLS History API 网页
        historyApiFallback: true,
        // 是否开启模块热替换功能
        hot: true,
        // 是否开启 HTTPS 模式
        https: false,
        // 是否捕捉 Webpack构建的性能信息,用于分析是什么原因导致构建性能不佳
        profile: true,
        // 是否启用缓存来提升构建速度
        cache: false,
        // 是否开始
        watch: true,
        // 监听模式选项
        // 不监听的文件或文件夹,支持正则匹配。默认为空
        watchOptions: {
            ignored: /node modules/,
            // 监听到变化发生后,等 300ms 再执行动作,截流,防止文件更新太快导致重新编 译频率太快。默认为 300ms
            aggregateTimeout: 300,
            // 不停地询问系统指定的文件有没有发生变化,默认每秒询问 1000 次
            poll: 1000
        }
    }
},
```
