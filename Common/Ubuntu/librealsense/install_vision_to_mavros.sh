#!/bin/bash

set -e
set -x

tput setaf 3
echo "Installing vision_to_mavros"
tput sgr0

if [ -z "$SETUP_DEPTH_CAMERA" ]; then
    echo 'Set SETUP_DEPTH_CAMERA to 1 in config.env to include depth camera script.'
    export SETUP_DEPTH_CAMERA=0
fi

if [ $SETUP_DEPTH_CAMERA -eq 1 ]; then
    echo 'Setting up both tracking and depth cameras'
else
    echo 'Setting up tracking camera only'
fi

sudo apt -y install python3-lxml
sudo -H pip3 install cython
sudo -H pip3 install numpy --upgrade
sudo -H pip3 install transformations
sudo -H pip3 install apscheduler
sudo -H pip3 install dronekit
sudo -H pip3 install pyserial
if [ $SETUP_DEPTH_CAMERA -eq 1 ]; then
    sudo -H pip3 install numba
    sudo apt -y install python3-opencv
fi

pushd /home/$NORMAL_USER/GitHub
rm -rf vision_to_mavros
git clone https://github.com/thien94/vision_to_mavros.git

rm -rf /home/$NORMAL_USER/start_t265_to_mavlink
mkdir /home/$NORMAL_USER/start_t265_to_mavlink
pushd vision_to_mavros/scripts
cp t265_to_mavlink.py /home/$NORMAL_USER/start_t265_to_mavlink
popd
popd
cp autostart_t265.sh /home/$NORMAL_USER/start_t265_to_mavlink
cp start_t265.sh /home/$NORMAL_USER/start_t265_to_mavlink
cp stop_t265.sh /home/$NORMAL_USER/start_t265_to_mavlink
cp view_log_t265.sh /home/$NORMAL_USER/start_t265_to_mavlink
sudo cp t265.service /etc/systemd/system

# add line to /etc/rc.local to start t265 service
LINE="/bin/bash -c '~$NORMAL_USER/start_t265_to_mavlink/autostart_t265.sh'"
sudo perl -pe "s%^exit 0%$LINE\\n\\nexit 0%" -i /etc/rc.local

if [ $SETUP_DEPTH_CAMERA -eq 1 ]; then
    pushd /home/$NORMAL_USER/GitHub
    rm -rf /home/$NORMAL_USER/start_d4xx_to_mavlink
    mkdir /home/$NORMAL_USER/start_d4xx_to_mavlink
    pushd vision_to_mavros/scripts
    cp d4xx_to_mavlink.py /home/$NORMAL_USER/start_d4xx_to_mavlink
    mkdir /home/$NORMAL_USER/cfg
    cp ../cfg/*.json /home/$NORMAL_USER/cfg
    popd
    popd
    cp autostart_d4xx.sh /home/$NORMAL_USER/start_d4xx_to_mavlink
    cp start_d4xx.sh /home/$NORMAL_USER/start_d4xx_to_mavlink
    cp stop_d4xx.sh /home/$NORMAL_USER/start_d4xx_to_mavlink
    cp view_log_d4xx.sh /home/$NORMAL_USER/start_d4xx_to_mavlink
    sudo cp d4xx.service /etc/systemd/system

    # add line to /etc/rc.local to start d4xx service
    LINE="/bin/bash -c '~$NORMAL_USER/start_d4xx_to_mavlink/autostart_d4xx.sh'"
    sudo perl -pe "s%^exit 0%$LINE\\n\\nexit 0%" -i /etc/rc.local
fi

tput setaf 2
echo "Finished installing vision_to_mavros"
tput sgr0

