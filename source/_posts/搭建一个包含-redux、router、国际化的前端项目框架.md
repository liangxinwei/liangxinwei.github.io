---
title: 搭建一个包含 redux、router、国际化的前端项目框架
date: 2017-06-08 18:57:41
categories: 前端
---

## 目的
搭建一个交互比较多的 **react 前端项目框架**，数据可预测，可路由跳转，可国际化，数据操作可控制
## 使用的主要类库
- i18next 国际化
- react-i18next
- i18next-browser-languagedetector
- immutability-helper
- immutable 处理数据
- react
- react-dom
- react-redux 管理数据
- react-router 路由
- react-router-redux 路由接入 store
- redux
## 说明
* 因为 router 是异步过程，所以注入到 store 中，通过 action 跳转路由
*  在 react-redux 原生 action、reducer 之上封装了一层，便于分发、匹配 action、reducer
*  执行顺序： action -> 前置拦截器（return true）-> reducer（修改 store）-> componentWillReceiveProps -> shouldComponentUpdate（return true）-> render -> 后置拦截器

**项目地址**：https://github.com/liangxinwei/redux-ele
## 项目布局
```
├── cfg                                 webpack 配置文件
│   ├── base.js                        webpack 配置
│   ├── default.js                     loader，plugin
│   ├── dev.js                         dev 环境 
│   └── dist.js                        dist 环境
├── src                                 源码目录
│   ├── app
│   │   ├── component                  具体业务组件，配合 routes 目录使用
│   │   ├── config                     store 配置
│   │   │   ├── AppActionRouter.js    分发相应 type 的 action
│   │   │   ├── AppReducerCreator.js  匹配相应 type 的 action 的 reducer
│   │   │   ├── ConfigureStore.js       生成 store
│   │   │   └── index.js                统一导出
│   │   ├── i18n                        	国际化配置
│   │   │   ├── locales                	中英文配置文件
│   │   │   │   ├── en                 英文配置
│   │   │   │   └── zh                 中文配置
│   │   │   ├── i18n.js                 i18next 配置
│   │   │   └── index.js                统一导出
│   │   ├── middleware                   中间件
│   │   │   ├── AppMiddleWare.js        前置、后置拦截器业务代码
│   │   │   ├── ComponentMiddleWare.js  操作拦截器中间件
│   │   │   ├── index.js                中间件统一导出
│   │   │   └── LoggerMiddleWare.js     日志中间件
│   │   ├── routes                       路由配置
│   │   │   └── index.jsx
│   │   └── App.jsx                      app 入口
│   ├── index.ejs                         ejs 模板文件
│   └── index.jsx                         挂载 react dom
├── test
├── .babelrc                            babel 配置文件
├── .editorconfig                       跨平台编辑器配置文件
├── .eslintignore                       eslintignore 配置文件
├── .eslintrc                           eslint 配置文件
├── .gitignore
├── package.json   
├── postcss.config.js                   postcss 配置文件 
├── server.js                           本地服务（webpack-dev-server）
├── webpack.config.js                   webpack 配置文件入口
└── README.md    
```
## App.jsx 项目入口
```
import React, {Component} from 'react';
import {Provider} from 'react-redux';
import {I18nextProvider} from 'react-i18next';
import {syncHistoryWithStore} from 'react-router-redux';
import {hashHistory} from 'react-router';

import {reducers} from './components'; //合并之后的 reducer
import {default as Store} from './config/ConfigureStore';
import appMiddleWares from './middleware/AppMiddleWare';

import {i18n, locales} from './i18n'; //见下面 i18n 配置
import routes from './routes';
import './style/index.scss';

/**
 * App View
 */
class App extends Component {
    constructor(props) {
        super(props);
    }

    componentWillMount() {
        // 添加i18n语言包
        for (let ns in locales['zh']) {
            if (locales['zh'].hasOwnProperty(ns)) {
                i18n.addResourceBundle('zh', ns, locales['zh'][ns]);
                i18n.addResourceBundle('en', ns, locales['en'][ns]);
            }
        }
    }

    render() {
        let storeOptions = {};

        const defaultStates = {};
        const allReducers = Object.assign({}, reducers);  //此处可以并入其它模块中的 reducer
        const preMiddleWares = Object.assign({}, appMiddleWares.preMiddleWares);  //此处可以并入其它模块中的 preMiddleWares
        const postMiddleWares = Object.assign({}, appMiddleWares.postMiddleWares);  //此处可以并入其它模块中的 postMiddleWares

        storeOptions.initialStates = defaultStates;
        storeOptions.reducers = allReducers;
        storeOptions.preMiddleWares = preMiddleWares;
        storeOptions.postMiddleWares = postMiddleWares;

        const store = Store.configureStore(storeOptions);
        const history = syncHistoryWithStore(hashHistory, store);

        return (
            <Provider store={store}>
                <I18nextProvider i18n={i18n}>
                    {routes(history)}
                </I18nextProvider>
            </Provider>
        );
    }
}

export default App;
```
## routes 路由配置
```
import React from 'react';
import {Router, Route} from 'react-router';

import {
    HomeView,
    BusinessDetail
} from '../components';

const routes = (history) => {
    return (
        <Router history={history}>
            <Route path="/" component={HomeView}/>
            <Route path="/home" component={HomeView}/>
            <Route path="/business/:id" component={BusinessDetail}/>
        </Router>
    );
};

export default routes;
```
## ConfigureStore.js 构建 Store
```
import {applyMiddleware, compose, createStore, combineReducers} from 'redux';
import thunk from 'redux-thunk';
import {hashHistory} from 'react-router';
import {routerReducer, routerMiddleware} from 'react-router-redux';

import {componentMiddleWare, logger} from '../middleware';
import appReducerCreator from './AppReducerCreator';

/**
 * store 构建器
 */
export function configureStore(config) {
    // 合并之后的 preMiddleWares, postMiddleWares, reducers
    let {initialStates, preMiddleWares, postMiddleWares, reducers} = config;
    let allReducer = Object.assign({}, reducers);
    let appReducer = appReducerCreator(initialStates, allReducer);
    const finalReducer = combineReducers({appReducer, routing: routerReducer});
    const allMiddleWares = [
        thunk,  // 异步 action
        componentMiddleWare(preMiddleWares, postMiddleWares),    // 具体业务拦截器
        routerMiddleware(hashHistory),   // router 注入到 store 中
        logger
    ];

    let enhancer = compose(
        applyMiddleware(...allMiddleWares)
    );
    return createStore(finalReducer, {}, enhancer);
}

const Store = {
    configureStore
};

export default Store;
```
## AppReducerCreator.js
```
/**
 * 全局 Reducer 产生器
 */
function appReducerCreator(wrapInitialState, allReducerMap) {
    function appReducer(state = wrapInitialState, action) {
        if (action && action.type && allReducerMap[action.type]) {
            return allReducerMap[action.type](state, action);
        } else {
            return state;
        }
    }
    return appReducer;
}

export default appReducerCreator;
```
## ComponentMiddleWare.js action 拦截器
```
/**
 * 操作拦截器中间件
 */
export function componentMiddleWare(preMiddleWares, postMiddleWares) {
    return function ({getState}) {
        return next => (action) => {
            // 前置拦截校验函数
            let preInterceptFunc = preMiddleWares ? preMiddleWares[action.type] : null;
            // 进行拦截校验操作
            if (preInterceptFunc && !preInterceptFunc.call(this, action, getState())) {
                console.error('Invalid action for preMiddleWares intercept!!');
                return;
            }

            // 调用 middleware 链中下一个 middleware 的 dispatch。
            const returnValue = next(action);

            // 后置拦截函数
            let postInterceptFunc = postMiddleWares ? postMiddleWares[action.type] : null;
            // 进行拦截校验操作
            postInterceptFunc && postInterceptFunc.call(this, action, getState());
            
            return returnValue;
        };
    };
}
```
## LoggerMiddleWare.js
```
/**
 * 日志 MiddleWare
 */
export function logger({getState}) {
    return next => (action) => {
        console.info('will dispatch', action);
        // 调用 middleware 链中下一个 middleware 的 dispatch。
        const returnValue = next(action);
        console.info('after dispatch', getState());
        return returnValue;
    };
}
```
## AppMiddleWare.js 具体业务中间件，构建 store 时注入
```
/**
 * 前置拦截器
 */
let preMiddleWares = {
    TEST: (action, state) => {
        return true;// false 则本次 action 无效，数据不会被修改
    }
};

/**
 * 后置拦截器
 */
let postMiddleWares = {
    TEST: (action, state) => {
        ··· // 此处修改之后不会立即在 ui 上体现出来，因为它在 render 之后执行。且因为参数 state 为引用，所以是直接修改，可做一些提示性的操作
    }
};

let appMiddleWares = {
    preMiddleWares,
    postMiddleWares
};

export default appMiddleWares;
```
## connectToStore.js 组件接入 store decorator
```
import {bindActionCreators} from 'redux';
import {connect} from 'react-redux';
import appConfig from '../config';
// appConfig.router 即下面的 AppActionRouter.js
const AppActionRouter = appConfig.router;

function mapStateToProps(state) {
    return {
        store: state.appReducer || {},
        routerStore: (state.routing && state.routing.locationBeforeTransitions) || {}
    };
}

function mapDispatchToProps(dispatch) {
    return bindActionCreators(AppActionRouter, dispatch);
}

export default function connectToStore(component) {
    return connect(mapStateToProps, mapDispatchToProps)(component);
}
```
## AppActionRouter.js 分发 action
```
import {actions} from '../components';
// action 为合并之后的所有的 action
/**
 * app action Router
 */
function onClickWithoutCheck(action) {
    return action;
}

/**
 * 如果外部注入 action，那么直接使用 action 的操作即可。
 * 如果外部没有注入 action， 使用 dispatch 操作。
 */

export function onClickAction(action, props) {
    return function (dispatch, getState) {
        if (action.type && actions.hasOwnProperty(action.type)) {
            actions[action.type].call(this, action, dispatch, props);
        } else {
            dispatch(onClickWithoutCheck(action));
        }
    };
}
```
## acion 示例
```
let homeActions = {};

homeActions['TEST'] = function (action, dispatch, state) {
    dispatch(action);
};

export default homeActions;

```
## reducer 示例
```
import Immutable from 'immutable';

let homeReducers = {};

homeReducers['TEST'] = function (state, action) {
    let foo = Immutable.fromJS(state);
    let newArr = foo.mergeDeep(Immutable.fromJS(action.content));
    return newArr.toJS();
};

export default homeReducers;
```
## i18n 配置
```
import i18next from 'i18next';
import LanguageDetector from 'i18next-browser-languagedetector';

const i18n = i18next
    .use(LanguageDetector)
    .init({
        fallbackLng: 'zh',

        // have a common namespace used around the full app
        ns: ['common'],
        defaultNS: 'common',

        debug: false,

        interpolation: {
            escapeValue: false // not needed for react!!
        }
    }, (err) => {
        if (err) {
            console.error('i18next', err);
        }
        // console.log('i18next initialized and ready to go!');
    });

export default i18n;
```
### i18n 英文配置
```
const home = {
    title: 'Home Page'
};
export default {home};
```
### i18n 中文配置
```
const home = {
    title: '首页'
};
export default {home};
```
### i18n 中英文统一导出
```
import zh from './zh';
import en from './en';

const locales = {
    zh: zh,
    en: en
};

export default locales;
```
## 组件实例
```
import React, {Component} from 'react';
import {translate} from 'react-i18next';
import i18n from '../i18n';

@translate(['home'], {wait: true})  // 使用多语言
@connectToStore                     // 组件介入 store
class Test extends Component {
    constructor(props) {
        super(props);
    }

    // 路由跳转
    transformRouter = () => {
        const {onClickAction} = this.props;
        // 见下面路由 acion
        let gotoAction = {
            type: 'GOTO',
            content: '/home'
        };
        onClickAction(gotoAction, this.props);
    }

    // 发送 action
    changeStore = () => {
        const {onClickAction, store} = this.props;
        let action = {
            type: 'TEST',
            content: {data: 'test'}
        };
        onClickAction(action, this.props);
    }

    // 切换语言
    setLanguage = () => {
        i18n.changeLanguage('zh'); // or en
    }

    render() {
        const {t, store} = this.props;
        return (
            <div className='app-home'>
                <div className='app-header'>
                    <span>{t('title')}</span>
                </div>
                <div>
                    content
                </div>
                <Footer/>
            </div>
        );
    }
}

export default Test;
```
## 路由 acion，不需要 路由 recuder
```
import {push} from 'react-router-redux';

let routerActions = {};

routerActions['GOTO'] = function (action, dispatch, state) {
    dispatch(push(action['content']));
};

export default routerActions;
```
