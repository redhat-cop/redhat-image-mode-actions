LABEL maintainer="chadmf"
LABEL description="Red Hat Ansible Automation Platform on RHEL bootc"
LABEL version="2.5"

FROM registry.redhat.io/rhel9/rhel-bootc:9.6

#install software
RUN dnf -y install tmux mkpasswd wget

#configure ansible user
RUN pass=$(mkpasswd --method=SHA-512 --rounds=4096 ${ANSIBLE_USER_PASS}) && useradd -m -G wheel ansible -p $pass

#setup sudo to not require password and fix PAM issues for containers
RUN echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/wheel-sudo && \
    echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ansible && \
    chmod 440 /etc/sudoers.d/wheel-sudo /etc/sudoers.d/ansible

# Fix PAM configuration for containers
RUN sed -i 's/^session.*pam_loginuid.so/#&/' /etc/pam.d/sudo && \
    sed -i 's/^session.*pam_keyinit.so/#&/' /etc/pam.d/sudo && \
    echo "session optional pam_keyinit.so revoke" >> /etc/pam.d/sudo

# Alternative: Disable requiretty and set pam session requirements
RUN echo "Defaults:ansible !requiretty" >> /etc/sudoers && \
    echo "Defaults:ansible !pam_session" >> /etc/sudoers

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
RUN ansible-playbook -i inventory.txt ansible.containerized_installer.install 

# Switch back to root for cleanup and final steps
USER root

#clean up caches and install directory in the image and lint the container
RUN rm /var/{cache,lib}/dnf /var/lib/rhsm /var/cache/ldconfig -rf
RUN rm -f /opt/aap-installer
RUN bootc container lint

# Set final user for runtime
USER ansible

EXPOSE 443
