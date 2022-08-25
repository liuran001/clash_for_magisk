var T=Object.defineProperty,b=Object.defineProperties;var C=Object.getOwnPropertyDescriptors;var f=Object.getOwnPropertySymbols;var P=Object.prototype.hasOwnProperty,y=Object.prototype.propertyIsEnumerable;var E=(e,t,a)=>t in e?T(e,t,{enumerable:!0,configurable:!0,writable:!0,value:a}):e[t]=a,u=(e,t)=>{for(var a in t||(t={}))P.call(t,a)&&E(e,a,t[a]);if(f)for(var a of f(t))y.call(t,a)&&E(e,a,t[a]);return e},x=(e,t)=>b(e,C(t));import{r as o,R as l,K as L,k as N,P as W,D as I,j,g as k}from"./vendor.bd9188bf.js";import{a as w,F as z}from"./index.esm.2329fc07.js";import{r as F,s as D,f as M}from"./logs.793220f2.js";import{c as v,w as A,x as H,k as $,y as B,C as K,S as V,z as q,A as Y,g as G,D as J}from"./index.5b20f2b7.js";import{d as O}from"./debounce.76599460.js";import{u as Q}from"./useRemainingViewPortHeight.2e67e408.js";import{F as U,p as X}from"./Fab.e496f549.js";const Z="_RuleSearch_1gcst_1",ee="_RuleSearchContainer_1gcst_5",te="_inputWrapper_1gcst_10",ae="_input_1gcst_10",oe="_iconWrapper_1gcst_35";var p={RuleSearch:Z,RuleSearchContainer:ee,inputWrapper:te,input:ae,iconWrapper:oe};function se({dispatch:e,searchText:t,updateSearchText:a}){const[s,r]=o.exports.useState(t),i=o.exports.useCallback(c=>{e(a(c))},[e,a]),d=o.exports.useMemo(()=>O(i,300),[i]),g=c=>{r(c.target.value),d(c.target.value)};return l.createElement("div",{className:p.RuleSearch},l.createElement("div",{className:p.RuleSearchContainer},l.createElement("div",{className:p.inputWrapper},l.createElement("input",{type:"text",value:s,onChange:g,className:p.input})),l.createElement("div",{className:p.iconWrapper},l.createElement(L,{size:20}))))}const re=e=>({searchText:A(e),updateSearchText:H});var ne=v(re)(se);const ce="_logMeta_1dg5t_1",le="_logType_1dg5t_8",ie="_logTime_1dg5t_18",pe="_logText_1dg5t_24",ge="_logsWrapper_1dg5t_37",me="_logPlaceholder_1dg5t_51",ue="_logPlaceholderIcon_1dg5t_64";var n={logMeta:ce,logType:le,logTime:ie,logText:pe,logsWrapper:ge,logPlaceholder:me,logPlaceholderIcon:ue};const{useCallback:S,memo:de,useEffect:xe}=j,h=30,he={debug:"#28792c",info:"var(--bg-log-info-tag)",warning:"#b99105",error:"#c11c1c"};function _e({time:e,even:t,payload:a,type:s}){const r=k({even:t},"log");return o.exports.createElement("div",{className:r},o.exports.createElement("div",{className:n.logMeta},o.exports.createElement("div",{className:n.logTime},e),o.exports.createElement("div",{className:n.logType,style:{backgroundColor:he[s]}},s),o.exports.createElement("div",{className:n.logText},a)))}function fe(e,t){return t[e].id}const Ee=de(({index:e,style:t,data:a})=>{const s=a[e];return o.exports.createElement("div",{style:t},o.exports.createElement(_e,u({},s)))},w);function ve({dispatch:e,logLevel:t,apiConfig:a,logs:s,logStreamingPaused:r}){const i=$(),d=S(()=>{r?F(x(u({},a),{logLevel:t})):D(),i.app.updateAppConfig("logStreamingPaused",!r)},[a,t,r,i.app]),g=S(R=>e(B(R)),[e]);xe(()=>{M(x(u({},a),{logLevel:t}),g)},[a,t,g]);const[c,_]=Q(),{t:m}=N();return o.exports.createElement("div",null,o.exports.createElement(K,{title:m("Logs")}),o.exports.createElement(ne,null),o.exports.createElement("div",{ref:c,style:{paddingBottom:h}},s.length===0?o.exports.createElement("div",{className:n.logPlaceholder,style:{height:_-h}},o.exports.createElement("div",{className:n.logPlaceholderIcon},o.exports.createElement(V,{width:200,height:200})),o.exports.createElement("div",null,m("no_logs"))):o.exports.createElement("div",{className:n.logsWrapper},o.exports.createElement(z,{height:_-h,width:"100%",itemCount:s.length,itemSize:80,itemData:s,itemKey:fe},Ee),o.exports.createElement(U,{icon:r?o.exports.createElement(W,{size:16}):o.exports.createElement(I,{size:16}),mainButtonStyles:r?{background:"#e74c3c"}:{},style:X,text:m(r?"Resume Refresh":"Pause Refresh"),onClick:d}))))}const Se=e=>({logs:q(e),logLevel:Y(e),apiConfig:G(e),logStreamingPaused:J(e)});var We=v(Se)(ve);export{We as default};
