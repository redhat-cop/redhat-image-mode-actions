MAINTAINER Alessandro Rossi <al.rossi87@gmail.com>

FROM registry.redhat.io/rhel9/rhel-bootc:9.5

RUN <<EORUN
set -xeuo pipefail

#install software
dnf -y install tmux mkpasswd

#configure bootc-user
pass=$(mkpasswd --method=SHA-512 --rounds=4096 redhat) && useradd -m -G wheel bootc-user -p $pass

#setup sudo to not require password
echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/wheel-sudo

#configure web server and relocate the webroot to be read-only and managed by this container image
dnf -y install httpd && dnf clean all
systemctl enable httpd
mv /var/www /usr/share/www
sed -ie 's,/var/www,/usr/share/www,' /etc/httpd/conf/httpd.conf
echo "Welcome to the bootc-http instance!" > /usr/share/www/html/index.html

#clean up caches in the image and lint the container
rm /var/{cache,lib}/* -rf
bootc container lint

EORUN

EXPOSE 80
