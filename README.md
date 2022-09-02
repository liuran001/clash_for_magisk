# clash_for_magisk
基于magisk模块的clash

## 安装

通过Magisk Manager安装.

## 卸载

通过Magisk Manager卸载.

## 配置

模块目录: `{magisk 安装目录}/Clash_For_Magisk/`

数据目录: `/data/clash/`

数据目录包含以下文件:

## [clash官方配置教程]

https://github.com/Dreamacro/clash/wiki/configuration

* `clash.yaml` - clash代理配置文件

* `config.yaml` - clash订阅节点配置文件,注意: 实际使用时,`从第一行到proxies:的前一行`使用的是clash.yaml`文件的内容,`rule-providers:后面的内容`使用的是rule.yaml`文件的内容.

* `rule.yaml` - clash规则配置文件(可开关)


## 使用方式

* 通过禁用与开启模块来启停clash,或者使用Dashboard软件.
