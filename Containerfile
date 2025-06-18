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

#RUN hostnamectl set-hostname aap-aio.local
RUN echo "127.0.0.1 aap-aio.local" >> /etc/hosts

# Create working directory for AAP installation
WORKDIR /opt/aap-installer

# Copy inventory file first
COPY inventory.txt .

# Copy and extract the AAP installer bundle from build context
COPY ansible-automation-platform-containerized-setup-bundle-2.5-10.1-x86_64.tar.gz ./
RUN tar -xzf ansible-automation-platform-containerized-setup-bundle-2.5-10.1-x86_64.tar.gz --strip-components=1

#Install AAP
RUN ansible-playbook -i inventory.txt ansible.containerized_installer.install

#clean up caches in the image and lint the container
RUN rm /var/{cache,lib}/dnf /var/lib/rhsm /var/cache/ldconfig -rf
RUN rm /opt/aap-installer/ansible-automation-platform-containerized-setup-bundle-*.tar.gz
RUN bootc container lint

EXPOSE 8443
