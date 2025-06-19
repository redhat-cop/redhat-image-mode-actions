MAINTAINER chadmf

FROM registry.redhat.io/rhel9/rhel-bootc:9.6

#install software
RUN dnf -y install tmux mkpasswd wget

#configure ansible user
RUN pass=$(mkpasswd --method=SHA-512 --rounds=4096 redhat) && useradd -m -G wheel ansible -p $pass

#setup sudo to not require password
RUN echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/wheel-sudo

#configure dnf and install packages
RUN dnf config-manager --add-repo rhel-9-for-x86_64-appstream-rpms 
RUN dnf install -y ansible-core wget git rsync

#RUN hostnamectl set-hostname aap-aio.local
RUN echo "127.0.0.1 aap-aio.local" >> /etc/hosts

# Create working directory for AAP installation with proper ownership
RUN mkdir -p /opt/aap-installer && chown -R ansible:ansible /opt/aap-installer
WORKDIR /opt/aap-installer

# Copy inventory file first and set ownership
COPY inventory.txt .
RUN chown ansible:ansible inventory.txt

# Copy and extract the AAP installer bundle from build context
COPY ansible-automation-platform-containerized-setup-2.5-15.tar.gz ./
RUN chown ansible:ansible ansible-automation-platform-containerized-setup-2.5-15.tar.gz

# Switch to non-root user for AAP installation
USER ansible

# Extract and install AAP as non-root user
RUN tar -xzf ansible-automation-platform-containerized-setup-2.5-15.tar.gz --strip-components=1

# Install AAP as non-root (this is the recommended approach)
RUN ansible-playbook -i inventory.txt ansible.containerized_installer.install -v

# Switch back to root for cleanup and final steps
USER root

#clean up caches in the image and lint the container
RUN rm /var/{cache,lib}/dnf /var/lib/rhsm /var/cache/ldconfig -rf
RUN rm /opt/aap-installer/ansible-automation-platform-containerized-setup-bundle-*.tar.gz
RUN bootc container lint

# Set final user for runtime
USER ansible

EXPOSE 443
