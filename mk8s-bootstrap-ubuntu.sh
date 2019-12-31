#!/bin/bash
# This Installation will work for both Ubuntu v16.04, v18.04 and Centosv7
# Author: Alexander Hill
# Company: Exxact COrp
# Revision v1

#set -e  # exit immediately on error
set -u  # fail on undeclared variables

## Make sure to have root privilege
if [ "$(whoami)" != 'root' ]; then
  echo -e "\e[31m\xe2\x9d\x8c Please retry with root privilege.\e[m"
  exit 1
fi

# Set OS distribution variable
. /etc/os-release


printf "\e[93m%s\e[0m\n" "Distribution OS is $ID, starting installation"
echo " "


# Checking for WellKnown Packages if not installed them Install
printf "\e[93m%s\e[0m\n" "Installing Essential Packages"
echo " "

LIST="net-tools
sshpass
hwinfo
smartmontools
build-essential
ethtool
software-properties-common
curl
git
wget
"

for i in $LIST; do
if [ $(dpkg-query -W -f='${Status}' $i 2>/dev/null | grep -c "install ok installed") -eq 0 ];
then
  apt-get install -y $i;
echo "Packake is not installed"
else
echo "Package is installed"
fi
 done

echo " "

# Update Version of all installed packages
printf "\e[93m%s\e[0m\n" "Updating Version of all installed packages"
echo " "
apt-get upgrade -y

echo " "

# Update Package Dependencies
printf "\e[93m%s\e[0m\n" "Updating all package dependencies"
apt-get dist-upgrade -y
echo " "

# Install GCC 6
printf "\e[93m%s\e[0m\n" "Installing GCC Package"
add-apt-repository ppa:ubuntu-toolchain-r/test -y
apt-get update && apt-get install gcc-6 g++-6 -y && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 60 --slave /usr/bin/g++ g++ /usr/bin/g++-6
echo " "

# Install Ansible
printf "\e[93m%s\e[0m\n" "Installing Ansible Package"
sudo apt-add-repository ppa:ansible/ansible
apt update -y
apt install ansible -y
echo " "

# Checking if python3 is installed
if [ $(dpkg-query -W -f='${Status}' python3  2>/dev/null | grep -c "install ok installed") -eq 0 ];
then
  apt-get install -y python3;
printf "\e[93m%s\e[0m\n" "Installing Python3 Package"
else
echo "Package is installed"
fi
echo " "

# Install Python3 Dependencies
printf "\e[93m%s\e[0m\n" "Installing Python3 Dependencies"
apt install -y libssl-dev libffi-dev python-dev python3-venv
echo " "



# Instal Pip3
printf "\e[93m%s\e[0m\n" "Installing Pip3 Package"
apt update -y
apt install python-pip -y
apt install python3-pip -y
echo " "

# Install Node.js
printf "\e[93m%s\e[0m\n" "Installing Nopde.js Package"
apt install nodejs -y
apt install npm -y
echo " "

# Setup up Docker Repo and update
printf "\e[93m%s\e[0m\n" "Setup up Docker Repo and update"
echo " "
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"


# Set Nvidia repo and update
printf "\e[93m%s\e[0m\n" "Set Nvidia repo and update"
echo " "
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$ID$VERSION_ID/nvidia-docker.list | tee /etc/apt/sources.list.d/nvidia-docker.list
apt-get update -y


# install the nvidia-docker from the repo and reload the daemon
printf "\e[93m%s\e[0m\n" "install the nvidia-docker from the repo and reload the daemon"
echo " "
apt-get install nvidia-docker2 -y
pkill -SIGHUP dockerd

# Add Standard Users
printf "\e[93m%s\e[0m\n" "Add Standard Users"
echo " "
useradd -c "Exx User" -d /home/exx -s /bin/bash -m exx
echo -e "exx\nexx" | passwd exx

useradd -c "Docker User" -d /home/dockeruser -s /bin/bash -m dockeruser
echo -e "dockeruser\ndockeruser" | passwd dockeruser


# Add Standard users to docker group
printf "\e[93m%s\e[0m\n" "Add Standard users to docker group"
echo " "
usermod -aG docker dockeruser
usermod -aG docker exx


# Copy PDF files to Users Directory
printf "\e[93m%s\e[0m\n" "Copy PDF files to Users Directory"
echo " "
cp *.pdf /home/exx
cp *.pdf /home/dockeruser

# List of Docke Images to pull
LIST="portainer/portainer
nvcr.io/nvidia/tensorflow:19.12-tf1-py3
nvcr.io/nvidia/tensorflow:19.12-tf2-py3
nvcr.io/nvidia/pytorch:19.12-py3
nvcr.io/nvidia/rapidsai/rapidsai:0.10-cuda10.0-runtime-ubuntu18.04
nvcr.io/nvidia/cuda:10.2-devel-ubuntu18.04
nvcr.io/nvidia/cuda:10.2-cudnn7-devel-ubuntu18.04
nvcr.io/nvidia/digits:19.12-tensorflow-py3
"

# Pulling images
printf "\e[93m%s\e[0m\n" "Pulling images"
echo " "
for IMAGE in $LIST; do docker pull $IMAGE; done


# reload daemon to clear cache and restart docker
printf "\e[93m%s\e[0m\n" "reload daemon to clear cache and restart docker"
echo " "
systemctl daemon-reload
systemctl restart docker


# Copy startup scripts to /usr/local/bin
printf "\e[93m%s\e[0m\n" "Copy startup scripts to /usr/local/bin"
echo " "
chmod +x start*
cp start* /usr/local/bin/


# Start Portainer
printf "\e[93m%s\e[0m\n" "Start Portainer"
bash -xv /usr/local/bin/startPortainer.sh


# Install Microk8s
apt install snapd -y
systemctl enable --now snapd.socket
snap install microk8s --classic --channel=latest/stable
usermod -a -G microk8s exxadmin
sudo microk8s.enable dns storage dashboard gpu prometheus
newgrp microk8s



# Start Rapids
echo "################################"
echo "${yellow}Starting Rapids${reset}"
echo "################################"
echo " "
#bash -xv /usr/local/bin/startRapids.sh
#wait

# ========= VALIDATION =========="
HOST=`hostname`
FILE=${HOST}_validation.txt

echo "=== $HOST  ===" >> /tmp/$FILE
echo " " >> /tmp/$FILE
echo "=== OS release ===" >> /tmp/$FILE
cat /etc/os-release >> /tmp/$FILE
echo " " >> /tmp/$FILE
echo "=== Users ===" >> /tmp/$FILE
id exx >> /tmp/$FILE
id dockeruser >> /tmp/$FILE
echo " " >> /tmp/$FILE
echo "=== Docker Version ===" >> /tmp/$FILE
docker version | egrep -A1 Client >> /tmp/$FILE
echo " " >> /tmp/$FILE
echo "=== NDIDIA Docker Version ===" >> /tmp/$FILE
nvidia-docker version | grep NVIDIA >> /tmp/$FILE
echo " " >> /tmp/$FILE
echo "=== Docker Packages ===" >> /tmp/$FILE
docker images | awk '{print $1":"$2}' >> /tmp/$FILE
echo " " >> /tmp/$FILE
echo "=== Running Docker Containers ===" >> /tmp/$FILE
docker ps -a | awk ' FNR == 1 {next} {print $2}'
echo " " >> /tmp/$FILE
echo "=== Grep for Errors ===" >> /tmp/$FILE
dmesg | egrep  'error|XID' >> /tmp/$FILE
echo " " >> /tmp/$FILE
echo "=== Valifate Number of GPUs ===" >> /tmp/$FILE
nvidia-smi -L >> /tmp/$FILE
echo " " >> /tmp/$FILE
echo "=== Valifate Memory ===" >> /tmp/$FILE
free -h >> /tmp/$FILE
echo " " >> /tmp/$FILE
echo "=== Valifate Raid ===" >> /tmp/$FILE
cat /proc/mdstat >> /tmp/$FILE
echo " " >> /tmp/$FILE
echo "=== Valifate Block Devices ===" >> /tmp/$FILE
lsblk -o name,size,mountpoint >> /tmp/$FILE
echo " " >> /tmp/$FILE
