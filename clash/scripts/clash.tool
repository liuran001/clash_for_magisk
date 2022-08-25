#!/system/bin/sh

scripts=$(realpath $0)
scripts_dir=$(dirname ${scripts})
. /data/clash/clash.config

monitor_local_ipv4() {

    change=false

    wifistatus=$(dumpsys connectivity | grep "WIFI" | grep "state:" | awk -F ", " '{print $2}' | awk -F "=" '{print $2}' 2>&1)

    if [ ! -z "${wifistatus}" ]; then
        if test ! "${wifistatus}" = "$(cat ${Clash_run_path}/lastwifi)"; then
            change=true
            echo "${wifistatus}" >${Clash_run_path}/lastwifi
        elif [ "$(ip route get 1.2.3.4 | awk '{print $5}' 2>&1)" != "wlan0" ]; then
            change=true
            echo "${wifistatus}" >${Clash_run_path}/lastwifi
        fi
    else
        echo "" >${Clash_run_path}/lastwifi
    fi

    if [ "$(settings get global mobile_data 2>&1)" -eq 1 ] || [ "$(settings get global mobile_data1 2>&1)" -eq 1 ]; then
        if [ ! "${mobilestatus}" = "$(cat ${Clash_run_path}/lastmobile)" ]; then
            change=true
            echo "${mobilestatus}" >${Clash_run_path}/lastmobile
        fi
    fi

    if [ ${change} == true ]; then

        local_ipv4=$(ip a | awk '$1~/inet$/{print $2}')
        local_ipv6=$(ip -6 a | awk '$1~/inet6$/{print $2}')
        rules_ipv4=$(${iptables_wait} -t mangle -nvL FILTER_LOCAL_IP | grep "ACCEPT" | awk '{print $9}' 2>&1)
        rules_ipv6=$(${ip6tables_wait} -t mangle -nvL FILTER_LOCAL_IP | grep "ACCEPT" | awk '{print $8}' 2>&1)

        for rules_subnet in ${rules_ipv4[*]}; do
            ${iptables_wait} -t mangle -D FILTER_LOCAL_IP -d ${rules_subnet} -j ACCEPT
        done

        for subnet in ${local_ipv4[*]}; do
            if ! (${iptables_wait} -t mangle -C FILTER_LOCAL_IP -d ${subnet} -j ACCEPT >/dev/null 2>&1); then
                ${iptables_wait} -t mangle -I FILTER_LOCAL_IP -d ${subnet} -j ACCEPT
            fi
        done

        for rules_subnet6 in ${rules_ipv6[*]}; do
            ${ip6tables_wait} -t mangle -D FILTER_LOCAL_IP -d ${rules_subnet6} -j ACCEPT
        done

        for subnet6 in ${local_ipv6[*]}; do
            if ! (${ip6tables_wait} -t mangle -C FILTER_LOCAL_IP -d ${subnet6} -j ACCEPT >/dev/null 2>&1); then
                ${ip6tables_wait} -t mangle -I FILTER_LOCAL_IP -d ${subnet6} -j ACCEPT
            fi
        done
    fi

    unset local_ipv4
    unset rules_ipv4
    unset local_ipv6
    unset rules_ipv6
    unset wifistatus
    unset mobilestatus
    unset change
}

restart_clash() {
     ${scripts_dir}/clash.service -k && ${scripts_dir}/clash.iptables -k
    ${scripts_dir}/clash.service -s && ${scripts_dir}/clash.iptables -s
    if [ "$?" == "0" ]; then
        log "info: 内核成功重启."
    else
        log "err: 内核重启失败."
        exit 1
    fi
}

keep_dns() {
    local_dns=$(getprop net.dns1)

    if [ "${local_dns}" != "${static_dns}" ]; then
        for count in $(seq 1 $(getprop | grep dns | wc -l)); do
            setprop net.dns${count} ${static_dns}
        done
    fi

    if [ $(sysctl net.ipv4.ip_forward) != "1" ]; then
        sysctl -w net.ipv4.ip_forward=1
    fi

    unset local_dns
}

updateFile() {
    file="$1"
    file_bk="${file}.bk"
    update_url="$2"

    mv -f ${file} ${file_bk}
    echo "curl -L -A 'clash' ${update_url} -o ${file} "
    curl -L -A 'clash' ${update_url} -o ${file} 2>&1 # >> /dev/null 2>&1

    sleep 1

    if [ -f "${file}" ]; then
        rm -rf ${file_bk}

        log "info: ${file}更新成功."
    else
        mv ${file_bk} ${file}
        log "war: ${file}更新失败,文件已恢复.."
        return 1
    fi
}

find_packages_uid() {
    rm -f ${appuid_file}.tmp
    hd=""
    if [ "${mode}" == "global" ]; then
        mode=blacklist
        uids=""
    else
        uids=$(cat ${filter_packages_file})
    fi
    for package in $uids; do
        if [ "${Clash_enhanced_mode}" == "fake-ip" ] && [ "${Clash_tun_status}" != "true" ]; then
            log "war: Tproxy_fake-ip下禁用黑白名单."
            return
        fi
        nhd=$(awk -F ">" '/^[0-9]+>$/{print $1}' <<< "${package}")
        if [ "${nhd}" != "" ]; then
            hd=${nhd}
            continue
        fi
        uid=$(awk '$1~/'^"${package}"$'/{print $2}' ${system_packages_file})
        if [ "${uid}" == "" ]; then
            log "warn: ${package}未找到."
            continue
        fi
        echo "${hd}${uid}" >> ${appuid_file}.tmp
        if [ "${mode}" = "blacklist" ]; then
            log "info: ${hd}${package}已过滤."
        elif [ "${mode}" = "whitelist" ]; then
            log "info: ${hd}${package}已代理."
        fi
    done
    rm -f ${appuid_file}
    for uid in $(cat ${appuid_file}.tmp | sort -u); do
        echo ${uid} >> ${appuid_file}
    done
    rm -f ${appuid_file}.tmp
}

port_detection() {
    clash_pid=$(cat ${Clash_pid_file})
    match_count=0

    if ! (ss -h >/dev/null 2>&1); then
        clash_port=$(netstat -anlp | grep -v p6 | grep ${Clash_bin_name} | awk '$6~/'"${clash_pid}"*'/{print $4}' | awk -F ':' '{print $2}' | sort -u)
    else
        clash_port=$(ss -antup | grep ${Clash_bin_name} | awk '$7~/'pid="${clash_pid}"*'/{print $5}' | awk -F ':' '{print $2}' | sort -u)
    fi

    if [[ "$(echo ${clash_port} | grep "${Clash_tproxy_port}")" != "" ]];then
        log "info: tproxy端口启动成功."
    else
        log "err: tproxy端口启动失败."
        exit 1
    fi

    if [[ "$(echo ${clash_port} | grep "${Clash_dns_port}")" != "" ]];then
        log "info: dns端口启动成功."
    else
        log "err: dns端口启动失败."
        exit 1
    fi

    exit 0
}

update_pre() {
    flag=false

    if [ ${auto_updateGeoIP} == "true" ]; then
        updateFile ${Clash_GeoIP_file} ${GeoIP_url}
        if [ "$?" = "0" ]; then
            flag=true
        fi
    fi

    if [ ${auto_updateGeoSite} == "true" ]; then
        updateFile ${Clash_GeoSite_file} ${GeoSite_url}
        if [ "$?" = "0" ]; then
            flag=true
        fi
    fi

    if [ -f "${Clash_pid_file}" ] && [ ${flag} == true ]; then
        restart_clash
    fi
}

limit_clash() {
    if [ "${Cgroup_memory_limit}" == "" ]; then
        return
    fi

    if [ "${Cgroup_memory_path}" == "" ]; then
        Cgroup_memory_path=$(mount | grep cgroup | awk '/memory/{print $3}' | head -1)
        if [ "${Cgroup_memory_path}" == "" ]; then
            log "err: 自动获取Cgroup_memory_path失败."
            return
        fi
    fi

    mkdir "${Cgroup_memory_path}/clash"
    echo $(cat ${Clash_pid_file}) >"${Cgroup_memory_path}/clash/cgroup.procs"
    echo "${Cgroup_memory_limit}" >"${Cgroup_memory_path}/clash/memory.limit_in_bytes"

    log "info: 限制内存: ${Cgroup_memory_limit}."
}

while getopts ":kfmpusl" signal; do
    case ${signal} in
    u)
        update_pre
        ;;
    s)
        flag=false
        if [ ${auto_updateSubcript} == "true" ]; then
            updateFile ${Clash_config_file} ${Subcript_url}
            if [ "$?" = "0" ] && [ -f "${Clash_pid_file}" ]; then
                restart_clash
            fi
        fi
        ;;
    k)
        if [ "${mode}" = "blacklist" ] || [ "${mode}" = "whitelist" ] || [ "${mode}" = "global" ]; then
            keep_dns
        else
            exit 0
        fi
        ;;
    f)
        find_packages_uid
        ;;
    m)
        if [ "${mode}" = "blacklist" ] && [ -f "${Clash_pid_file}" ]; then
            monitor_local_ipv4
        else
            exit 0
        fi
        if [ "${mode}" = "global" ] && [ -f "${Clash_pid_file}" ]; then
            monitor_local_ipv4
        else
            exit 0
        fi
        ;;
    p)
        port_detection
        ;;
    l)
        limit_clash
        ;;
    ?)
        echo ""
        ;;
    esac
done
