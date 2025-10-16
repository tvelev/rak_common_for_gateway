#!/bin/bash

# Stop on the first sign of trouble
set -e

SCRIPT_COMMON_FILE=$(pwd)/../rak/rak/shell_script/rak_common.sh


source $SCRIPT_COMMON_FILE

if [ $UID != 0 ]; then
    echo "Operation not permitted. Forgot sudo?"
    exit 1
fi

# --- Add skip if HCIUART is not presented ---
set +e  # temporarily turn off 'exit on error'
if systemctl disable hciuart 2>/dev/null; then
    echo "hciuart service disabled."
else
    echo "hciuart service not found or could not be disabled. Skipping..."
fi
set -e  # turn it back on
# -----------------------------------------------

apt install git ppp dialog jq minicom monit i2c-tools -y

cp gateway-config /usr/bin/
cp gateway-version /usr/bin/
cp rak_test /usr/bin/
cp test_rak /usr/bin/
cp rak /usr/local/ -rf

if [ "$1" = "create_img" ]; then
    sed -i "s/^.*install_img.*$/\"install_img\":\"1\",/" /usr/local/rak/gateway-config-info.json
    pushd /usr/local/rak
    popd
else
    rm -rf /usr/local/rak/first_boot
fi

#JSON_FILE=/usr/local/rak/rak_gw_model.json
#GW_ID=`do_get_gw_id`
#linenum=`sed -n "/gw_id/=" $JSON_FILE`
#sed -i "${linenum}c\\\\t\"gw_id\": \"$GW_ID\"," $JSON_FILE

echo_success "Copy Rak file success!"
