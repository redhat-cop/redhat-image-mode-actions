MAINTAINER chadmf

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
dnf config-manager --add-repo rhel-9-for-x86_64-appstream-rpms 
dnf install -y ansible-core wget git rsync
hostnamectl set-hostname aap-aio.local

#Get AAP bundle installer WIP
#wget bundle
#tar -xzvf bundlename
COPY inventory.txt ~/inventory.txt

#Install AAP
ansible-playbook -i inventory.txt ansible.containerized_installer.install

#clean up caches in the image and lint the container
RUN rm /var/{cache,lib}/* -rf
RUN bootc container lint

EXPOSE 80
