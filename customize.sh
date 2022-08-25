SKIPUNZIP=1
chooseportold() {
  # Keycheck binary by someone755 @Github, idea for code below by Zappo @xda-developers
  # Calling it first time detects previous input. Calling it second time will do what we want
  while true; do
    $MODPATH/tools/$ARCH32/keycheck
    $MODPATH/tools/$ARCH32/keycheck
    local SEL=$?
    if [ "$1" == "UP" ]; then
      UP=$SEL
      break
    elif [ "$1" == "DOWN" ]; then
      DOWN=$SEL
      break
    elif [ $SEL -eq $UP ]; then
      return 0
    elif [ $SEL -eq $DOWN ]; then
      return 1
    fi
  done
}

chooseport_legacy() {
  # Keycheck binary by someone755 @Github, idea for code below by Zappo @xda-developers
  # Calling it first time detects previous input. Calling it second time will do what we want
  [ "$1" ] && local delay=$1 || local delay=3
  local error=false
  while true; do
    timeout 0 $MODPATH/tools/$ARCH32/keycheck
    timeout $delay $MODPATH/tools/$ARCH32/keycheck
    local sel=$?
    if [ $sel -eq 42 ]; then
      return 0
    elif [ $sel -eq 41 ]; then
      return 1
    elif $error; then
      ui_print "未检测到音量键!尝试使用旧的keycheck方案"
      export chooseport=chooseportold
      ui_print " "
      ui_print "- 音量键录入 -"
      ui_print "  请按音量+键:"
      chooseport "UP"
      ui_print "  请按音量–键"
      chooseport "DOWN"
    else
      error=true
      ui_print "- 未检测到音量键。再试一次。"
    fi
  done
  
}

chooseport() {
  # Original idea by chainfire and ianmacd @xda-developers
  [ "$1" ] && local delay=$1 || local delay=3
  local error=false 
  while true; do
    local count=0
    while true; do
      timeout $delay /system/bin/getevent -lqc 1 2>&1 > $TMPDIR/events &
      sleep 0.5; count=$((count + 1))
      if (`grep -q 'KEY_VOLUMEUP *DOWN' $TMPDIR/events`); then
        return 0
      elif (`grep -q 'KEY_VOLUMEDOWN *DOWN' $TMPDIR/events`); then
        return 1
      fi
      [ $count -gt 15 ] && break
    done
    if $error; then
      # abort "未检测到音量键!"
      ui_print "未检测到音量键。 尝试keycheck模式"
      export chooseport=chooseport_legacy VKSEL=chooseport_legacy
      chooseport_legacy $delay
      return $?
    else
      error=true
      ui_print "- 未检测到音量键。再试一次。"
    fi
  done
}
function download() {
if $(curl -V > /dev/null 2>&1) ; then
    for i in $(seq 1 3); do
    if curl "$1" -# -kL -o "$2" >&2; then
    break;
    fi
    sleep 2
    if [[ $i == 3 ]]; then
    ui_print "curl连接失败"
    exit 1
    fi
    done
elif $(wget --help > /dev/null 2>&1) ; then
      for i in $(seq 1 3); do
      if wget --no-check-certificate $1 -O $2; then
      break;
      fi
      if [[ $i == 3 ]]; then
      ui_print "wget连接失败"
      exit 1
      fi
      done
else
      ui_print "错误: 您缺失必备命令(curl或者wget)，请安装Busybox for Android NDK模块"
      exit 1
fi
}
ui_print "选择下载源"
ui_print "  音量+ = GitHub链接(国外推荐)"
ui_print "  音量– = ghproxy反向代理链接(国内推荐)"
if chooseport; then
    ui_print "已选择GitHub链接"
    cn=""
else
      ui_print "已选择ghproxy反向代理链接"
      cn="https://ghproxy.com/"
fi
status=""
architecture=""
system_gid="1000"
system_uid="1000"
clash_data_dir="/data/clash"
modules_dir="/data/adb/modules"
ca_path="/system/etc/security/cacerts"
CPFM_mode_dir="${modules_dir}/clash_premium"
mod_config="${clash_data_dir}/clash.config"
geoip_file_path="${clash_data_dir}/Country.mmdb"
GeoIP_dat_url=${cn}"https://github.com/Loyalsoldier/geoip/releases/latest/download/cn.dat"
Country_mmdb_url=${cn}"https://github.com/Loyalsoldier/geoip/releases/latest/download/Country-only-cn-private.mmdb"
GeoSite_url=${cn}"https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"


if [ -d "${CPFM_mode_dir}" ] ; then
    touch ${CPFM_mode_dir}/remove && ui_print "- CPFM模块在重启后将会被删除."
fi

case "${ARCH}" in
    arm)
        architecture="armv7"
        ui_print "不支持的架构"
        exit 1
        ;;
    arm64)
        architecture="armv8"
        ;;
    x86)
        architecture="386"
        ui_print "不支持的架构"
        exit 1
        ;;
    x64)
        architecture="amd64"
        ui_print "不支持的架构"
        exit 1
        ;;
esac

mv -f ${clash_data_dir} ${clash_data_dir}.old
mkdir -p ${MODPATH}/system/bin
mkdir -p ${clash_data_dir}
mkdir -p ${clash_data_dir}/clashkernel
mkdir -p ${MODPATH}${ca_path}


unzip -o "${ZIPFILE}" -x 'META-INF/*' -d $MODPATH >&2
tar -xjf ${MODPATH}/command/command.tar.bz2 -C ${MODPATH}/system/bin/
ui_print "正在下载GeoIP.dat..."
download ${GeoIP_dat_url} ${clash_data_dir}/asset/GeoIP.dat &
ui_print "正在下载GeoSite.dat..."
download ${GeoSite_url} ${clash_data_dir}/asset/GeoSite.dat &
ui_print "正在下载Country.mmdb..."
download ${Country_mmdb_url} ${clash_data_dir}/asset/Country.mmdb
tar -xjf ${MODPATH}/clashkernel/clash.tar.bz2 -C ${clash_data_dir}/clashkernel/ &
mv ${MODPATH}/cacert.pem ${MODPATH}${ca_path}
if [ -f "${clash_data_dir}/config/config.yaml" ];then
    rm -rf ${MODPATH}/clash/config/config.yaml
fi
if [ -f "${clash_data_dir}/config/clash.yaml" ];then
    rm -rf ${MODPATH}/clash/config/clash.yaml
fi
if [ -f "${clash_data_dir}/config/rule.yaml" ];then
    rm -rf ${MODPATH}/clash/config/crule.yaml
fi
mv -f ${MODPATH}/clash/* ${clash_data_dir}/
rm -rf ${MODPATH}/clash
rm -rf ${MODPATH}/clashkernel

if [ ! -f "${clash_data_dir}/packages.list" ] ; then
    touch ${clash_data_dir}/packages.list
fi

ui_print "- 开始设置环境权限."
set_perm_recursive ${MODPATH} 0 0 0755 0644
set_perm  ${MODPATH}/system/bin/setcap  0  0  0755
set_perm  ${MODPATH}/system/bin/getcap  0  0  0755
set_perm  ${MODPATH}/system/bin/getpcaps  0  0  0755
set_perm  ${MODPATH}${ca_path}/cacert.pem 0 0 0644
set_perm  ${MODPATH}/system/bin/curl 0 0 0755
set_perm_recursive ${clash_data_dir} ${system_uid} ${system_gid} 0755 0644
set_perm_recursive ${clash_data_dir}/scripts ${system_uid} ${system_gid} 0755 0755
set_perm_recursive ${clash_data_dir}/clashkernel ${system_uid} ${system_gid} 6755 6755
set_perm  ${clash_data_dir}/clashkernel/clash  ${system_uid}  ${system_gid}  6755
set_perm  ${clash_data_dir}/clash.config ${system_uid} ${system_gid} 0755
set_perm  ${clash_data_dir}/packages.list ${system_uid} ${system_gid} 0644

if [ "$(pm list packages | grep com.dashboard.kotlin)" ] || [ "$(pm list packages | grep -s com.dashboard.kotlin)" ];then
ui_print "- 无需安装DashBoard."
else
ui_print "- 开始安装DashBoard."
pm install -r --user 0 ${MODPATH}/apk/dashBoard.apk
ui_print "- ↑显示Success即为安装完成."
ui_print "- 如果失败请手动安装 安装包文件在:/data/adb/modules/Clash_For_Magisk/apk/dashBoard.apk"
ui_print "- magisk lite版本在/data/adb/modules_lite/Clash_For_Magisk/apk/dashBoard.apk"
fi
ui_print "- 安装完成"
ui_print "
更新日志:
新增:
-WaitClashStartTime变量(clash.config) 修改等待clash启动时间(单位:秒)，过短会导致端口检测误判(跳过端口检查时无效)
-global(全局代理模式)
telegram频道: @wtdnwbzda
"