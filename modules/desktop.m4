#Install software
RUN add-apt-repository -y ppa:webupd8team/sublime-text-3
RUN apt-get update
RUN apt-get install -y sudo net-tools lxde gtk2-engines-murrine \ 
	ttf-ubuntu-font-family libreoffice firefox fonts-wqy-microhei \ 
	python-pip python-dev python-numpy build-essential lxterminal \ 
	x11vnc Xvfb chromium-browser sublime-text retext evince supervisor \ 
	pwgen vim 

#Install NoVNC
RUN cd /root && git clone https://github.com/kanaka/noVNC.git && \
    cd noVNC/utils && git clone https://github.com/kanaka/websockify websockify
RUN ln -s /root/noVNC/vnc_auto.html /root/noVNC/index.html

#Create ubuntu user
RUN useradd --create-home --shell /bin/bash --user-group --groups adm,sudo ubuntu

#Add supervisor config
ADD files/supervisor-desktop /etc/supervisor/conf.d

#Edit firstboot script
ADD files/desktop-pw-reset /bin
RUN chmod 755 /bin/pw-reset
RUN echo "/bin/pw-reset" >> /bin/firstboot
