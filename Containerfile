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

# Install additional dependencies for AAP containerized installation
RUN dnf install -y python3-pip systemd python3-devel gcc systemd-devel
RUN pip3 install docker-compose requests pyyaml psycopg2-binary

# Install required Ansible collections
RUN ansible-galaxy collection install ansible.posix community.general containers.podman

#Get AAP bundle installer WIP
RUN hostnamectl set-hostname aap-aio.local
RUN echo "127.0.0.1 aap-aio.local" >> /etc/hosts

# Create working directory for AAP installation
WORKDIR /opt/aap-installer

# Copy inventory and installation playbook
COPY inventory.txt .
COPY install-aap-bootc.yml .

# Copy and extract the AAP installer bundle from build context
COPY ansible-automation-platform-containerized-setup-bundle.tar.gz ./
RUN tar -xzf ansible-automation-platform-containerized-setup-bundle.tar.gz --strip-components=1

#Install AAP using the bootc-specific installation playbook
RUN ansible-playbook install-aap-bootc.yml

#clean up caches in the image and lint the container
RUN rm /var/{cache,lib}/dnf /var/lib/rhsm /var/cache/ldconfig -rf
RUN bootc container lint

EXPOSE 8443
