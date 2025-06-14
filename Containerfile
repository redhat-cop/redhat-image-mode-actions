MAINTAINER chadmf

FROM registry.redhat.io/rhel9/rhel-bootc:9.6

ENV tarball=${tarball}

#install software
RUN dnf -y install tmux mkpasswd wget

#configure bootc-user
RUN pass=$(mkpasswd --method=SHA-512 --rounds=4096 redhat) && useradd -m -G wheel bootc-user -p $pass

#setup sudo to not require password
RUN echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/wheel-sudo

#Using the optional heredoc format to help simplify the number of times we call RUN


#configure web server and relocate the webroot to be read-only and managed by this container image
RUN dnf config-manager --add-repo rhel-9-for-x86_64-appstream-rpms 
RUN dnf install -y ansible-core wget git rsync

#Get AAP bundle installer WIP
#RUN hostnamectl set-hostname aap-aio.local
RUN echo "127.0.0.1 aap-aio.local" >> /etc/hosts
#COPY ansible-automation-platform-containerized-setup-2.5-15.tar.gz .
#COPY inventory.txt .
#RUN tar -xzvf ansible-automation-platform-containerized-setup-2.5-15.tar.gz

#Install AAP
#RUN ansible-playbook -i inventory.txt ansible.containerized_installer.install

#clean up caches in the image and lint the container
RUN rm /var/{cache,lib}/dnf /var/lib/rhsm /var/cache/ldconfig -rf
RUN bootc container lint

EXPOSE 8443
