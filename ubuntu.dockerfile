FROM cache-registry.caas.intel.com/cache/library/ubuntu:latest
ARG PROXY=http://proxy-dmz.intel.com:912
ARG SECURE_PROXY=http://proxy-dmz.intel.com:912
ARG NO_PROXY=localhost,127.0.0.1,intel.com,.intel.com
ENV http_proxy=$PROXY \
    https_proxy=$SECURE_PROXY \
    ftp_proxy=$SECURE_PROXY \
    no_proxy=$NO_PROXY
# Install necessary packages
RUN apt-get update && apt-get install -y mc curl openjdk-11-jdk openssh-server git nano

RUN cd /tmp && wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh && \
    sh Miniforge3-Linux-x86_64.sh -b -p /opt/miniforge3 >/dev/null 2>&1 && \
    ln -s /opt/miniforge3 /opt/miniconda3 && \
    export PATH=/opt/miniforge3/bin/:$PATH

RUN /opt/miniforge3/bin/conda init bash && \
    /opt/miniforge3/bin/conda create -y -n py310 python=3.10 && \
    echo "source activate py310" >> ~/.bashrc

# Add a test group and user
RUN groupadd -g 2000 test_group && \
    useradd -l -m -u 2000 -g test_group -s /bin/bash -d /users/test_user test_user && \
    echo "test_user:password" | chpasswd

# SSH setup
RUN mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "export VISIBLE=now" >> /etc/profile

# Open port 22 for SSH access
EXPOSE 22

# Start SSH service
CMD ["/usr/sbin/sshd", "-D"]