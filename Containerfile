MAINTAINER Alessandro Rossi <al.rossi87@gmail.com>

FROM registry.redhat.io/rhel9/rhel-bootc:9.5

#install software
RUN dnf -y install tmux mkpasswd

#configure bootc-user
RUN pass=$(mkpasswd --method=SHA-512 --rounds=4096 redhat) && useradd -m -G wheel bootc-user -p $pass

#setup sudo to not require password
RUN echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/wheel-sudo

#Using the optional heredoc format to help simplify the number of times we call RUN
RUN <<EORUN
set -xeuo pipefail

#configure web server and relocate the webroot to be read-only and managed by this container image
dnf -y install httpd && dnf clean all
systemctl enable httpd
mv /var/www /usr/share/www
sed -ie 's,/var/www,/usr/share/www,' /etc/httpd/conf/httpd.conf
echo "Welcome to the bootc-http instance!" > /usr/share/www/html/index.html

EORUN

#clean up caches in the image and lint the container
RUN rm /var/{cache,lib}/* -rf
RUN bootc container lint

EXPOSE 80
