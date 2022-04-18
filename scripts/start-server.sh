#!/bin/bash
export DISPLAY=:99
export XAUTHORITY=${DATA_DIR}/.Xauthority

echo "---Resolution check---"
if [ -z "${CUSTOM_RES_W}" ]; then
	CUSTOM_RES_W=1024
fi
if [ -z "${CUSTOM_RES_H}" ]; then
	CUSTOM_RES_H=820
fi

if [ "${CUSTOM_RES_W}" -le 1023 ]; then
	echo "---Width to low must be a minimal of 1024 pixels, correcting to 1024...---"
    CUSTOM_RES_W=1024
fi
if [ "${CUSTOM_RES_H}" -le 819 ]; then
	echo "---Height to low must be a minimal of 820 pixels, correcting to 820...---"
    CUSTOM_RES_H=820
fi

rm -rf ${DATA_DIR}/gitkraken-amd64.tar.gz 2>/dev/null

echo "---Checking if GitKraken is installed...---"
if [ ! -f ${DATA_DIR}/bin/gitkraken ]; then
  echo "---GitKraken not installed, installing!---"
  cd ${DATA_DIR}
  if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/gitkraken-amd64.tar.gz "https://release.gitkraken.com/linux/gitkraken-amd64.tar.gz" ; then
    echo "---Sucessfully downloaded GitKraken!---"
  else
    echo "---Something went wrong, can't download GitKraken, putting container in sleep mode!---"
    rm -rf ${DATA_DIR}/gitkraken-amd64.tar.gz 2>/dev/null
    sleep infinity
  fi
  mkdir -p ${DATA_DIR}/bin
  tar -C ${DATA_DIR}/bin --strip-components=1 -xf ${DATA_DIR}/gitkraken-amd64.tar.gz
  rm -rf ${DATA_DIR}/gitkraken-amd64.tar.gz 2>/dev/null
else
  echo "---GitKraken found!---"
fi

echo "---Checking for old logfiles---"
find $DATA_DIR -name "XvfbLog.*" -exec rm -f {} \;
find $DATA_DIR -name "x11vncLog.*" -exec rm -f {} \;
echo "---Checking for old display lock files---"
rm -rf /tmp/.X99*
rm -rf /tmp/.X11*
rm -rf ${DATA_DIR}/.vnc/*.log ${DATA_DIR}/.vnc/*.pid
chmod -R ${DATA_PERM} ${DATA_DIR}
if [ -f ${DATA_DIR}/.vnc/passwd ]; then
	chmod 600 ${DATA_DIR}/.vnc/passwd
fi
screen -wipe 2&>/dev/null

echo "---Starting TurboVNC server---"
vncserver -geometry ${CUSTOM_RES_W}x${CUSTOM_RES_H} -depth ${CUSTOM_DEPTH} :99 -rfbport ${RFB_PORT} -noxstartup ${TURBOVNC_PARAMS} 2>/dev/null
sleep 2
echo "---Starting Fluxbox---"
screen -d -m env HOME=/etc /usr/bin/fluxbox
sleep 2
echo "---Starting noVNC server---"
websockify -D --web=/usr/share/novnc/ --cert=/etc/ssl/novnc.pem ${NOVNC_PORT} localhost:${RFB_PORT}
sleep 2
cp usr/share/novnc/vnc.html usr/share/novnc/index.html

echo "---Starting GitKraken---"
cd ${DATA_DIR}
${DATA_DIR}/bin/gitkraken --user-data-dir=${DATA_DIR}/user --disable-accelerated-video --no-sandbox --disable-gpu 2>/dev/null
