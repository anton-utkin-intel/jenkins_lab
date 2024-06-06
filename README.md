#Run services:
docker-compose build
docker-compose up -d

Jenkins will be available on the port 8088.

#Manual step required on the node.
Connect to node container: docker exec -it <ubuntu_id> /bin/bash

##Create user in Ubuntu
groupadd -g 2000 test_group
useradd -l -m -u 2000 -g test_group -s /bin/bash -d /users/test_user test_user
useradd -l -m -u 2000 -g test_group -s /bin/bash test_user
passwd test_user

##SSH on the Ubuntu 24.04
apt-get install -y openssh-server
mkdir /var/run/sshd
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
echo "export VISIBLE=now" >> /etc/profile

nano /etc/ssh/sshd_config  -- > open port 22
service ssh start