#!/bin/bash

RAK_GW_INFO_JSON_FILE=/usr/local/rak/rak_gw_model.json
GATEWAY_CONFIG_INFO=/usr/local/rak/gateway-config-info.json

function echo_normal()
{
    echo -e $1
}

function echo_success()
{
    echo -e "\033[1;32m$1\033[0m"
}

function echo_error()
{
    echo -e "\033[1;31mERROR: $1\033[0m"
}

function echo_warn()
{
    echo -e "\033[1;33mWARNING: $1\033[0m"
}

do_check_variable_type(){
    local a="$1"
    printf "%d" "$a" &>/dev/null && return 0
    printf "%d" "$(echo $a|sed 's/^[+-]\?0\+//')" &>/dev/null && return 0
    printf "%f" "$a" &>/dev/null && return 1
    [ ${#a} -eq 1 ] && return 2
    return 3
}

do_get_json_value()
{
    # $1 key; $2 file
    Var1=$(jq .$1 $2)
    Var2=${Var1//\"/}
    echo $Var2
}

#do_get_gateway_info()
#{
#    do_get_json_value gw_model $GATEWAY_CONFIG_INFO
#}


do_get_gateway_info()
{

    do_get_json_value $1 $GATEWAY_CONFIG_INFO
}

do_check_ip_is_localhost()
{
    if [ "$1" = "localhost" ] || [ "$1" = "127.0.0.1" ]; then
        return 0
    else
        return 1
    fi
}

write_json_gateway_info()
{
    # $1 key; $2 value
    do_check_variable_type  $1
    RET=$?
    if [ $RET -eq 3 ]; then
        sed -i "s/^.*$1.*$/\"$1\":\"$2\",/" $GATEWAY_CONFIG_INFO
    fi
}

write_json_gateway_info_no_comma()
{
    # $1 key; $2 value
    do_check_variable_type  $1
    RET=$?
    if [ $RET -eq 3 ]; then
        sed -i "s/^.*$1.*$/\"$1\":\"$2\"/" $GATEWAY_CONFIG_INFO
    fi
}

write_json_server_plan()
{
    write_json_gateway_info "server_plan" $1
}

write_json_server_freq()
{
    write_json_gateway_info_no_comma "freq" $1
}

write_json_lora_server_ip()
{
    # . 字母 数字
    write_json_gateway_info "lora_server_ip" $1
}

write_json_wifi_mode()
{
    # 数字 1/2
    write_json_gateway_info "wifi_mode" $1
}

write_json_ap_ssid()
{
    # 数字 字母 - _
    write_json_gateway_info "ap_ssid" $1
}

write_json_ap_pwd()
{
    # 数字 字母 特殊字符
    write_json_gateway_info_no_comma "ap_pwd" $1
}

write_json_lan_ip()
{
    # 数字 . 校验下是否为有效IP
    write_json_gateway_info "lan_ip" $1
}

write_json_lan_gw()
{
    # 数字 . 校验下是否为有效IP
    write_json_gateway_info_no_comma "lan_gw" $1
}

write_json_wlan_ip()
{
    # 数字 . 校验下是否为有效IP
    write_json_gateway_info "wifi_ip" $1
}

write_json_wlan_gw()
{
    # 数字 . 校验下是否为有效IP
    write_json_gateway_info_no_comma "wifi_gw" $1
}

write_json_apn_name()
{
    # 任意
    write_json_gateway_info "apn_name" $1
}

write_json_apn_baud()
{
    # 数字
    write_json_gateway_info_no_comma "apn_baud" $1
}

write_json_lte_mode()
{
    # 数字
    write_json_gateway_info_no_comma "lte_mode" $1
}

write_json_sync_time_mode()
{
    # 数字
    write_json_gateway_info_no_comma "sync_time" $1
}

write_json_active_lora_server()
{
    write_json_gateway_info "active_lora_server" $1
}

write_json_loraserver_adr()
{
    # 数字 1/2
    write_json_gateway_info "loraserver_adr" $1
}

write_json_chirpstack_install()
{
    # 数字 1/2
    write_json_gateway_info "install_chirpstack" $1
}

do_get_lora_spi()
{
    do_get_json_value spi $RAK_GW_INFO_JSON_FILE
}

do_get_gw_model()
{
    do_get_json_value gw_model $RAK_GW_INFO_JSON_FILE
}

do_get_gw_lte()
{
    do_get_json_value lte $RAK_GW_INFO_JSON_FILE
}

do_get_gw_chirpstack()
{
    do_get_json_value chirpstack $RAK_GW_INFO_JSON_FILE
}

do_get_gw_version()
{
   do_get_json_value gw_version $RAK_GW_INFO_JSON_FILE
}

do_get_gw_install_lte()
{
   do_get_json_value install_lte $GATEWAY_CONFIG_INFO
}

do_get_gw_install_chirpstack()
{
   do_get_json_value install_chirpstack $GATEWAY_CONFIG_INFO
}

do_get_gw_id()
{
    GATEWAY_EUI_NIC="eth0"
    if [[ `grep "$GATEWAY_EUI_NIC" /proc/net/dev` == "" ]]; then
        GATEWAY_EUI_NIC="wlan0"
    fi
        if [[ `grep "$GATEWAY_EUI_NIC" /proc/net/dev` == "" ]]; then
        GATEWAY_EUI_NIC="usb0"
    fi

    if [[ `grep "$GATEWAY_EUI_NIC" /proc/net/dev` == "" ]]; then
       echo ""
    fi
    GATEWAY_EUI=$(ip link show $GATEWAY_EUI_NIC | awk '/ether/ {print $2}' | awk -F\: '{print $1$2$3"FFFE"$4$5$6}')
    GATEWAY_EUI=${GATEWAY_EUI^^}
    echo $GATEWAY_EUI
}

do_get_gw_id_from_json()
{
    if [ -f /opt/ttn-gateway/packet_forwarder/lora_pkt_fwd/local_conf.json ];then
        GATEWAY_EUI=`do_get_json_value gateway_conf.gateway_ID /opt/ttn-gateway/packet_forwarder/lora_pkt_fwd/local_conf.json`
    else
        GATEWAY_EUI=`do_get_json_value gateway_conf.gateway_ID /opt/ttn-gateway/packet_forwarder/lora_pkt_fwd/global_conf.json`
    fi
    echo $GATEWAY_EUI
}

do_get_rpi_model()
{
    model=255
    text=`tr -d '\0' </proc/device-tree/model | grep -a 'Pi 3'`
    if [ ! -z "$text" ]; then
        model=3
    fi

    if [ $model -eq 255 ]; then
        text=`tr -d '\0' </proc/device-tree/model | grep -a 'Pi 4'`
        if [ ! -z "$text" ]; then
            model=4
        fi
    fi

    if [ $model -eq 255 ]; then
        text=`tr -d '\0' </proc/device-tree/model | grep -a 'Pi Z'`
        if [ ! -z "$text" ]; then
            model=0
        fi
    fi

    # Added for support of the "Raspberry Pi Compute Module 3"
    if [ $model -eq 255 ]; then
        text=`tr -d '\0' </proc/device-tree/model | grep -a 'Pi Compute Module 3'`
        if [ ! -z "$text" ]; then
            model=3
        fi
    fi

    # Added for support of the "Raspberry Pi Compute Module 4"
    if [ $model -eq 255 ]; then
        text=`tr -d '\0' </proc/device-tree/model | grep -a 'Pi Compute Module 4'`
        if [ ! -z "$text" ]; then
            model=4
        fi
    fi
     # Added for support of the "Raspberry Pi 5"
    if [ $model -eq 255 ]; then
        text=`tr -d '\0' </proc/device-tree/model | grep -a 'Pi 5'`
        if [ ! -z "$text" ]; then
            model=5
        fi
    fi
    echo $model
}


