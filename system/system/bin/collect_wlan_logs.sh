#!/system/bin/sh

TAG="cnss_collect_wlan_logs"
BASE_DIR="/data/vivo-common/circulatedlog/"

function dump_sys_service {
    log -t ${TAG} "dumpsys start ${1}"
    dumpsys wifi > "${1}/wifi.dump"
    chmod 774 ${1}/wifi.dump
    dumpsys connectivity > "${1}/connectivity.dump"
    chmod 774 ${1}/connectivity.dump
    #dumpsys netd > "${1}/netd.dump"
    dumpsys wificond > "${1}/wificond.dump"
    chmod 774 ${1}/wificond.dump
    dumpsys network_management > "${1}/network_management.dump"
    chmod 774 ${1}/network_management.dump
    logcat -d > "${1}/logcat.log"
    chmod 774 ${1}/logcat.log
    dmesg > "${1}/dmesg.log"
    chmod 774 ${1}/dmesg.log
}

log -t ${TAG} "started"
if [ "$1" == "onoff" ]; then
    status=`getprop persist.sys.circulated_wlan_logs`
    log -t $TAG "Circulated wlan logs enabled state: $status"
    if [ "$status" == "1" ]; then
        echo "v_ds,1" > data/connsyslog/connsyslog_serv_fifo
    else
        echo "v_dp,1" > data/connsyslog/connsyslog_serv_fifo
    fi
    return
fi

# Starts here
log -t ${TAG} "Trigger log dump..."
rm -rf /data/vivo-common/circulatedlog/*
dump_sys_service $BASE_DIR
# cp FW logs
cp -rf /data/debuglogger/connsyslog/fw/CsLog*/*.clog /data/vivo-common/circulatedlog/
cp -rf /data/debuglogger/connsyslog/fw/CsLog*/*.clog.curf /data/vivo-common/circulatedlog/
chmod 0777 /data/vivo-common/circulatedlog/*.clog
chmod 0777 /data/vivo-common/circulatedlog/*.clog.curf
