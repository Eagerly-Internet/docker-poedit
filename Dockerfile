FROM ich777/novnc-baseimage

LABEL maintainer="admin@minenet.at"


RUN wget --quiet "https://release.gitkraken.com/linux/gitkraken-amd64.deb" -O /tmp/gitkraken-amd64.deb && \
 	export TZ=Europe/Amsterdam && \
	apt-get update && \
	apt-get -y install --no-install-recommends chromium fonts-takao fonts-arphic-uming gconf2 gconf-service libgtk2.0-0 libnotify4 libnss3 gvfs-bin xdg-utils libxss1 libasound2 procps && \
	dpkg -i /tmp/gitkraken-amd64.deb && \
	apt-get -f install && \
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
	echo $TZ > /etc/timezone && \
	echo "ko_KR.UTF-8 UTF-8" >> /etc/locale.gen && \
	echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen && \
	locale-gen && \
	rm -rf /var/lib/apt/lists/* && \
	sed -i '/    document.title =/c\    document.title = "GitKraken - noVNC";' /usr/share/novnc/app/ui.js && \
	rm /usr/share/novnc/app/images/icons/* && \
	rm /tmp/gitkraken-amd64.deb

ENV DATA_DIR=/chrome
ENV CUSTOM_RES_W=1024
ENV CUSTOM_RES_H=768
ENV CUSTOM_DEPTH=16
ENV NOVNC_PORT=8080
ENV RFB_PORT=5900
ENV TURBOVNC_PARAMS="-securitytypes none"
ENV UMASK=000
ENV UID=99
ENV GID=100
ENV DATA_PERM=770
ENV USER="chrome"

RUN mkdir $DATA_DIR && \
	useradd -d $DATA_DIR -s /bin/bash $USER && \
	chown -R $USER $DATA_DIR && \
	ulimit -n 2048

ADD /scripts/ /opt/scripts/
COPY /icons/* /usr/share/novnc/app/images/icons/
COPY /conf/ /etc/.fluxbox/
RUN chmod -R 770 /opt/scripts/

EXPOSE 8080

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]
