---
title: roadhog 1.3.X 打包慢的解决办法
date: 2019-06-11 19:01:51
categories: 前端
toc: true
---

背景：公司的后台管理系统项目基于 Antd Pro 早期版本，使用的脚手架是 [roadhog](https://github.com/sorrycc/roadhog)，虽然接入了 dva 等框架，方便了我们把工作重心集中在业务上，但是随着项目的庞大，问题随之而来，首当其冲的就是线上部署的时候打包慢的问题。因为 road 的扩展不太灵活，其本身的初衷就是尽可能减少webpack的配置，所以如何降低打包的速度就成了亟需解决的问题。

项目依赖58个，打包之后140个文件。

网上搜了一圈，发现没有令人满意的解决方案，只好自己来解决。仔细缕了一遍思路后发现，还是有解决办法的。

以下改动仅适用于公司的后台管理系统项目。

>1. 删除项目中没有用到或废弃的代码
>2. 利用好 roadhog 支持的 webpack 配置项
>3. 自己改 roadhog 的源码，然后发布为 npm 包，替换掉 roadhog

第一项不用说。

第二项是设置 webpack 的 externals，由于项目中用到了 g2、d3、echarts、@antv/data-set、moment、g-cloud、g2-plugin-slider、cal-heatmap 等 js 库，所以把它们都配置到 externals 下：
```json
{
  "entry": "src/index.js",
  "extraBabelPlugins": [
    "transform-runtime",
    "transform-decorators-legacy",
    "transform-class-properties",
    ["import", { "libraryName": "antd", "libraryDirectory": "es", "style": true }]
  ],
  "env": {
    "development": {
      "extraBabelPlugins": [
        "dva-hmr"
      ]
    }
  },
  "externals": {
    "g2": "G2",
    "echarts": "echarts",
    "@antv/data-set": "DataSet",
    "moment": "moment",
    "g-cloud": "Cloud",
    "g2-plugin-slider": "G2.Plugin.slider"
  },
  "ignoreMomentLocale": true,
  "theme": "./src/theme.js",
  "hash": true,
  "multipage": true
}
```
在 .eslint.js 将其配置为全局变量：
```json
"globals": {
  "CalHeatMap": true,
  "DataSet": true,
  "moment": true,
  "echarts": true,
  "G2": true
}
```
以上注意：

1. 配置 `"multipage": true` 后，roadhog 才会把超过2次引用的依赖打为 common 包
2. "dva-hmr" 设置在 development 才会避免生产环境下将其打包，因为生产环境下不会用到
3. 将这些 js 库文件（不用包涵g-cloud、g2-plugin-slider）下载下来，放到项目根目录下 public/js 下，roadhog 作者约定 public 目录下的文件会在 server 和 build 时被自动 copy 到输出目录（默认是 ./dist）下。所以可以在这里存放 favicon, iconfont, html, html 里引用的图片等。
4. 手动在 index.ejs 里面将其引入

第三项

主要改动的地方：

1. common.js 下 HtmlWebpackPlugin 插件配置的地方，给它配置 public 下的所有 js 文件和 css 文件的路径和环境变量：
```js
if (existsSync(join(paths.appSrc, 'index.ejs'))) {
    const scripts = glob.sync(path.resolve(paths.appPublic) + '/js/*.js').map(filePath => path.basename(filePath));
    const stylesheets = glob.sync(path.resolve(paths.appPublic) + '/stylesheets/*.css').map(filePath => path.basename(filePath));
    ret.push(new HtmlWebpackPlugin({
        template: 'src/index.ejs',
        inject: true,
        scripts,
        stylesheets,
        env: JSON.stringify(NODE_ENV)
    }));
}
```
然后在你的项目的 index.ejs 中引入：
```html
<head>
  <% var stylesheets = htmlWebpackPlugin.options.stylesheets || [] %>
  <% for(var i = 0; i < stylesheets.length; i++) { %>
  <link rel="stylesheet" href="<%= 'stylesheets/' + stylesheets[i] %>">
  <% } %>
</head>

<body>
  <% var scripts = htmlWebpackPlugin.options.scripts || [] %>
  <% for(var i = 0; i < scripts.length; i++) { %>
  <script type="text/javascript" src="<%= 'js/' + scripts[i] %>"></script>
  <% } %>
</body>
```
2. 修改 webpack.config.prod.js

替换 webpack.optimize.UglifyJsPlugin 为：
```js
...(debug ? [] : [new UglifyJsPlugin({
    uglifyOptions: {
        compress: {
        warnings: false,
        },
    },
    cache: true,
    sourceMap: false,
    parallel: true,
})]),
```
UglifyJsPlugin 的好处不必多说，大家自己 google。

删掉 webpack.optimize.CommonsChunkPlugin 配置，参考 vue-cli2 的配置项：
```js
if (config.multipage) {
    // Support hash
    const name = config.hash ? 'common.[hash]' : 'common';
    // ret.push(new webpack.optimize.CommonsChunkPlugin({
    //   name: 'common',
    //   filename: `${name}.js`,
    // }));
    ret = ret.concat([
      // split vendor js into its own file
      // 将所有从node_modules中引入的js提取到vendor.js，即抽取库文件
      new webpack.optimize.CommonsChunkPlugin({
        name: 'vendor',
        minChunks(module) {
          return (module.resource && /\.js$/.test(module.resource) && module.resource.indexOf(paths.appNodeModules) === 0);
        },
      }),
      // extract webpack runtime and module manifest to its own file in order to
      // prevent vendor hash from being updated whenever app bundle is updated
      // 从vendor中提取出manifest，原因如上
      new webpack.optimize.CommonsChunkPlugin({
        name: 'manifest',
        minChunks: Infinity,
      }),
      // This instance extracts shared chunks from code splitted chunks and bundles them
      // in a separate chunk, similar to the vendor chunk
      // see: https://webpack.js.org/plugins/commons-chunk-plugin/#extra-async-commons-chunk
      new webpack.optimize.CommonsChunkPlugin({
        name,
        async: 'vendor-async',
        children: true,
        minChunks: 3,
      }),
    ]);
}
```
然后，运行 `npm run test`，`npm run build`，编译好之后，发布到 npm 仓库如 [liangxinwei_roadhog](https://www.npmjs.com/package/liangxinwei_roadhog)。

最后，删掉项目下的 package.json 里面 roadhog 相关的依赖，替换为  `"liangxinwei_roadhog": "^1.0.0"`：
```json
"devDependencies": {
  - "roadhog": "^1.3.1",
  - "roadhog-api-doc": "^0.1.0",
  + "liangxinwei_roadhog": "^1.0.0",
},
```
修改启动和打包命令：
```bash
"start": "node --max_old_space_size=4096 node_modules/liangxinwei_roadhog/lib/server.js",
"build": "node --max_old_space_size=4096 node_modules/liangxinwei_roadhog/lib/build.js"
```
经过我前后的数据比对，修改第二项之后，打包时间由原来的 20-30min 缩减到 5-6min，修改第三项之后，初次打包时间为 3-4min，再次打包时间缩减到 1min 之内。大功告成！

前端开发长路漫漫，大家且行且珍惜。
