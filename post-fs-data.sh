#!/system/bin/sh
. /data/clash/clash.config

if [ ${ml} == "true" ];then
    baidumlip=$(ping -c 1 cloudnproxy.baidu.com | sed '1{s/[^(]*(//;s/).*//;q}')
    txmlip=$(ping -c 1 weixin.qq.com | sed '1{s/[^(]*(//;s/).*//;q}')
    echo "baidumlip=${baidumlip}
    txmlip=${txmlip}">${Clash_run_path}/ip.dat
fi

if [ ${proxyGoogle} == "true" ];then
    if [ ! -f ${Clash_run_path}/Google.dat ];then
        for packages in $(pm list packages |awk -F : '{print$NF}')$(pm list packages -s |awk -F : '{print$NF}')
        do
            echo $packages | grep "google">>${Clash_run_path}/Google.dat
            echo $packages | grep "com.android.vending">>${Clash_run_path}/Google.dat
        done
    fi
fi