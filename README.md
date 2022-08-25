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

模板:
```bash
socks-port: 7891 #socks代理端口
redir-port: 7892 #redir端口
tproxy-port: 7893 #tprox代理端口
allow-lan: true #允许来自局域网链接
geodata-mode: true
unified-delay: true
mode: rule
log-level: info
ipv6: true
tcp-concurrent: false
sniffer:
  enable: false
profile:
store-fake-ip: true
external-controller: 127.0.0.1:9090
external-ui: yacd
tun:
  enable: false
  device: Meta
  stack: system #system or gvisor
  dns-hijack:
    - 127.0.0.1:53
  auto-route: true
  auto-detect-interface: true
  
#hosts: #本地dns解析 需要就把26-27行开头的#删掉
#'域名': ip
   
dns:
  enable: true
  listen: 0.0.0.0:1053
  ipv6: true
  default-nameserver:
    - 8.8.8.8
    - 114.114.114.114
  enhanced-mode: redir-host #redir-host or fake-ip
  fake-ip-range: 198.18.0.1/16
  fake-ip-filter:
    - localhost.ptlogin2.qq.com
  fallback-filter:
    geoip: true
    geoip-code: CN
  nameserver:
    - https://h.iqiq.io:777/dns-query
    - https://dns.alidns.com/dns-query
    - https://doh.pub/dns-query
  fallback:
    - https://h.iqiq.io:777/dns-query
    - https://doh.opendns.com/dns-query
    - https://dns.adguard.com/dns-query
    - https://dns.google/dns-query

```

* `config.yaml` - clash订阅节点配置文件,注意: 实际使用时,`从第一行到proxies:的前一行`使用的是clash.yaml`文件的内容,`rule-providers:后面的内容`使用的是rule.yaml`文件的内容.

模板:
```bash
proxies:
p: &p
  type: http
  interval: 1800
  health-check:
    enable: true
    url: http://www.gstatic.com/generate_204
    interval: 300
 
proxy-providers:
  机场1:
    <<: *p
    url: "订阅链接"
    path: ./proxy_providers/qcjs.yaml
 
 
proxy-groups:
  - name: 代理设置
    type: select
    proxies:
      - 机场1
      - 关闭代理

  - name: 机场1
    type: select
    use:
      - 机场1

  - name: 关闭代理
    type: select
    proxies:
      - DIRECT
```

* `rule.yaml` - clash规则配置文件

模板:
```bash
rule-providers:
  ad:
    type: http
    behavior: domain
    url: "https://raw.githubusercontent.com/heinu112/fuck-you-ads/main/antiad.yaml"
    path: ./rule_providers/antiad.yaml
    interval: 21600
rules:
  - PROCESS-NAME,clashMeta,REJECT # 解决回环 注意:需要填写clash内核的进程名
  - RULE-SET,ad,REJECT # 去广告
  - MATCH,代理设置
```
clash去广告配置链接：https://github.com/heinu112/fuck-you-ads

* `Country.mmdb` - geoip文件,clash需要.

* `packages.list` - 黑白名单过滤列表,填包名.

* `clash.config` - 模块配置文件.

### `clash.config`配置介绍&模板
```bash
auto_updateSubcript="true" #是否自动更新更新订阅
update_subcriptInterval="0 5 * * *" # 每天的半夜5点更新更新订阅
auto_updateGeoIP="true" #是否开启自动更新GeoIP.dat
auto_updateGeoSite.="true"  #是否开启自动更新GeoIP.dat
Clash_port_skipdetection="true" #是否跳过端口检查
WaitClashStartTime="4" #等待clash启动时间(单位:秒)，过短会导致端口检测误判(跳过端口检查时无效)
update_geoXInterval="0 5 * * 7" # 每周日的半夜5点更新GeoX
GeoIP_dat_url="https://ghproxy.com/https://github.com/Loyalsoldier/geoip/releases/latest/download/cn.dat" #顾名思义
Country_mmdb_url="https://ghproxy.com/https://github.com/Loyalsoldier/geoip/releases/latest/download/Country-only-cn-private.mmdb" #顾名思义
GeoSite_url="https://ghproxy.com/https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat" #顾名思义
# 上面的是给你操作的，下面的不懂就别乱改
# Clash运行时别动下方的配置，如动了出问题重启clash
ipv6="true"
pref_id="5000"
mark_id="2021"
table_id="2021"
#blacklist(指定应用不走代理) whitelist(仅指定应用走代理) global(全局代理)
#要指定的应用在packages.list填写包名一行一个 global模式不生效
mode="global"
static_dns="8.8.8.8"
Clash_bin_name="clashMeta" #内置clashMeta clash两个内核
Clash_old_logs="true" #是否保存每次的运行日志
Clash_data_dir="/data/clash"
Clash_run_path="${Clash_data_dir}/run"
busybox_path="/data/adb/magisk/busybox"
CFM_logs_file="${Clash_run_path}/run.logs"
CFM_OldLogs_file="${Clash_run_path}/run.old.logs"
template_file="${Clash_data_dir}/clash.yaml"
rule_file="${Clash_data_dir}/rule.yaml"
appuid_file="${Clash_run_path}/appuid.list"
Clash_pid_file="${Clash_run_path}/clash.pid"
Clash_bin_path="${Clash_data_dir}/clashkernel/${Clash_bin_name}"
Clash_config_file="${Clash_data_dir}/config.yaml"
system_packages_file="/data/system/packages.list"
temporary_config_file="${Clash_run_path}/config.yaml"
filter_packages_file="${Clash_data_dir}/packages.list"
Clash_GeoSite_file="${Clash_data_dir}/GeoSite.dat"
geodata_mode=$(grep "geodata-mode" ${template_file} | awk -F ': ' '{print $2}')
chmod -R 6755 ${Clash_data_dir}/clashkernel
rm -rf ${Clash_data_dir}/*.bak
if "${geodata_mode}"; then
    Clash_GeoIP_file="${Clash_data_dir}/GeoIP.dat"
    GeoIP_url=${GeoIP_dat_url}
else
    Clash_GeoIP_file="${Clash_data_dir}/Country.mmdb"
    GeoIP_url=${Country_mmdb_url}
fi

# 自动绕过本机ip,filter_local请勿轻易打开,打开后有可能引起设备软重启,如你手机有获取到公网ip.
# 优先重启cfm,即可绕过本机ip,检查是否正常,次要选择尝试打开filter_local,如遇设备软重启,请关闭.
filter_local="false"
#请不要轻易打开. 不要轻易打开,不要轻易打开.

Cgroup_memory_path=""
# 留空则自动获取
Cgroup_memory_limit=""
# 限制内存使用，量力而行，限制太死会造成CPU占用过高，-1则不限制，留空则不操作
# 更新限制请保存后执行 /data/clash/scripts/clash.tool -l
Clash_permissions="6755"
Clash_user_group="root:net_admin"
iptables_wait="iptables -w 100"
ip6tables_wait="ip6tables -w 100"
Clash_user=$(echo ${Clash_user_group} | awk -F ':' '{print $1}')
Clash_group=$(echo ${Clash_user_group} | awk -F ':' '{print $2}')
Clash_dns_port=$(grep "listen" ${template_file} | awk -F ':' '{print $3}')
Clash_enhanced_mode=$(grep "enhanced-mode" ${template_file} | awk -F ': ' '{print $2}')
Clash_tproxy_port=$(grep "tproxy-port" ${template_file} | awk -F ': ' '{print $2}')
Clash_tun_status=$(awk -F ': ' '/^tun: *$/{getline; print $2}' ${template_file})
Clash_auto_route=$(grep "auto-route" ${template_file} | awk -F ': ' '{print $2}')
tun_device=$(awk -F ': ' '/ +device: /{print $2}' ${template_file})
if [ "${Clash_tun_status}" == "" ]; then
    Clash_tun_status="false"
fi
if [ "${Clash_auto_route}" == "" ]; then
    Clash_auto_route="false"
fi
if [ "${tun_device}" == "" ]; then
    tun_device="Meta"
fi
log() {
    if [ ${Clash_old_logs} == "true" ];then
        echo [`TZ=Asia/Shanghai date "+%H:%M:%S"`]$1>>${CFM_logs_file}
        echo [`TZ=Asia/Shanghai date "+%Y-%m-%d %H:%M:%S"`]$1>>${CFM_OldLogs_file}
    else
        echo [`TZ=Asia/Shanghai date "+%H:%M:%S"`]$1>>${CFM_logs_file}
    fi
}
reserved_ip=(0.0.0.0/8 10.0.0.0/8 100.64.0.0/10 127.0.0.0/8 169.254.0.0/16 172.16.0.0/12 192.0.0.0/24 192.0.2.0/24 192.168.0.0/16 198.51.100.0/24 203.0.113.0/24 224.0.0.0/4 255.255.255.255/32 240.0.0.0/4)
reserved_ip6=(::/128 ::1/128 ::ffff:0:0/96 100::/64 64:ff9b::/96 2001::/32 2001:10::/28 2001:20::/28 2001:db8::/32 2002::/16 fc00::/7 fe80::/10 ff00::/8)
```

## 使用方式

* 通过禁用与开启模块来启停clash,或者使用Dashboard软件.
