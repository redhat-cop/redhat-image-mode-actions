FROM registry.redhat.io/rhel9/rhel-bootc:9.6

LABEL maintainer="chadmf"
LABEL description="Red Hat Ansible Automation Platform on RHEL bootc"
LABEL version="2.5"

#configure dnf and install packages
RUN dnf config-manager --add-repo rhel-9-for-x86_64-appstream-rpms 
RUN dnf install -y ansible-core wget git rsync tmux mkpasswd wget sudo crun podman slirp4netns fuse-overlayfs polkit

#configure ansible user
RUN pass=$(mkpasswd --method=SHA-512 --rounds=4096 ${ANSIBLE_USER_PASS}) && useradd -m -G wheel ansible -p $pass

#setup sudo to not require password and fix PAM issues for containers
RUN echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/wheel-sudo && \
    echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ansible && \
    chmod 440 /etc/sudoers.d/wheel-sudo /etc/sudoers.d/ansible

#copy quadlet files
COPY quadlet/* /etc/containers/systemd/.
RUN chown ansible:ansible /etc/containers/systemd/*

RUN bootc container lint

#clean up caches and install directory in the image and lint the container
RUN rm /var/{cache,lib}/dnf /var/lib/rhsm /var/cache/ldconfig -rf
RUN bootc container lint

# Set final user for runtime
USER ansible

EXPOSE 80 443 8443 5001 5000 3000 8002 8081 27199 44321
