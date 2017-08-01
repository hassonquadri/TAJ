#!/bin/bash

# volume setup
vgchange -ay

DEVICE_FS=`blkid -o value -s TYPE ${DEVICE}`
if [ "`echo -n $DEVICE_FS`" == "" ] ; then 
	pvcreate ${DEVICE}
	vgcreate data ${DEVICE}
	lvcreate --name volume1 -l 100%FREE data
	mkfs.ext4 /dev/data/xvdh
fi

echo -e "\n\n\[Bamboo Agent installation script]: Installing postgresql and creating bamboo database...\n\n"
sudo apt-get intsall -y postgresql
sudo -s -H -u postgres
#Create the Bamboo user
/usr/lib/postgresql/9.5/bin/createuser -S -d -r -P -E bamboo
#Create the Bamboo database
/usr/lib/postgresql/9.5/bin/createdb --owner bamboo --encoding utf8 bamboo

sudo -su bamboo
mkdir -p /opt/atlassian/bamboo
echo '/dev/xvdh /opt/atlassian/bamboo ext4 defaults 0 0' >> /etc/fstab
mount /opt/atlassian/bamboo

# Enable the multiverse repos
sudo sed -i "/^# deb.*multiverse/ s/^# //" /etc/apt/sources.list
sudo apt-get update

echo -e "\n\n[Bamboo Agent installation script]: Installing Java...\n\n"
sudo apt-get install -y openjdk-8-jdk
echo -e "\nexport JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" | sudo tee -a /etc/environment

java -version

echo $JAVA_HOME

echo -e "\n\n\[Bamboo Agent installation script]: Installing other packages...\n\n"
sudo apt-get install -y mc unzip gzip htop

echo -e "\n\n[Bamboo Agent installation script]: Configuring users..\n\n"
#sudo useradd -m bamboo --shell /bin/bash
sudo useradd --create-home -c "Bamboo role account" bamboo
sudo groupadd bamboo
usermod -a -G bamboo bamboo
usermod -a -G bamboo root
sudo chown -R bamboo:bamboo /opt/atlassian/bamboo
ls -ld /opt/atlassian/bamboo

echo -e "\n\n[Bamboo Agent installation script]: Installing Bamboo Agent...\n\n"
sudo -su bamboo
cd /opt/atlassian/bamboo
wget https://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-5.10.3.tar.gz
sudo tar -xvf atlassian-bamboo-5.10.3.tar.gz -C /opt/atlassian/bamboo
mv /opt/atlassian/bamboo/atlassian-bamboo-5.10.3/* /opt/atlassian/bamboo/
sudo chown -R bamboo:bamboo /opt/atlassian/bamboo
sudo chmod u+r+w /opt/atlassian/bamboo
sudo chmod 755 /opt/atlassian/bamboo/*

echo -e "\n\n[Bamboo Agent installation script]: Create and modify the application-data folder location in the Bamboo configuration files ...\n\n"
mkdir -p /var/atlassian/application/bamboo
chown bamboo: /var/atlassian/application/bamboo/
cat /opt/atlassian/bamboo/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties
## You can specify your bamboo.home property here or in your system environment variables.
#bamboo.home=C:/bamboo/bamboo-home
#bamboo.home=/var/atlassian/application/bamboo
echo 'bamboo.home=/var/atlassian/application/bamboo' >>/opt/atlassian/bamboo/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties
cat /opt/atlassian/bamboo/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties

echo -e "\n\n[Bamboo Agent installation script]: Start the Bamboo Server ...\n\n"
sudo chown -R bamboo:bamboo /opt/atlassian/bamboo
pwd
#/opt/atlassian/bamboo/
cd /opt/atlassian/bamboo/bin
./start-bamboo.sh

#tail -f /home/bamboo/logs/catalina.out
ps aux | grep bamboo



echo -e "\n\n[Bamboo Agent installation script]: Configuring Bamboo Agent autostart\n\n"
# Configure automatic startup of the Bamboo agent (add before line 14 of /etc/rc.local
sudo sed -i '14 i . /opt/atlassian/bamboo/etc/rc.local\n' /etc/rc.local
#sudo sed -i 's/exit 0/#exit 0/' /etc/rc.local
#echo -e "\n#Configure automatic startup of the Bamboo agent\n. /opt/bamboo-elastic-agent/etc/rc.local\n" | sudo tee -a /etc/rc.local


echo -e "\n\n[Bamboo Agent installation script]: Installing pip...\n\n"
mkdir -p /opt/tmp
cd /opt/tmp/
wget -q https://bootstrap.pypa.io/get-pip.py
python get-pip.py
python3 get-pip.py
rm -f get-pip.py

echo -e "\n\n[Bamboo Agent installation script]: Installing AWS Tools (awscli)...\n\n"
pip install awscli

echo -e "\n\n[Bamboo Agent installation script]: Installing AWS Tools (ec2-api-tools)...\n\n"
#sudo apt-add-repository ppa:awstools-dev/awstools -y
sudo apt-get install -y ec2-api-tools

echo -e "\n\n[Bamboo Agent installation script]: Installing Terraform...\n\n"
cd /usr/local/bin
wget -q https://releases.hashicorp.com/terraform/0.7.7/terraform_0.7.7_linux_amd64.zip
unzip terraform_0.7.7_linux_amd64.zip


echo -e "\n\n[Bamboo Agent installation script]: Installing packer...\n\n"
wget -q https://releases.hashicorp.com/packer/0.10.2/packer_0.10.2_linux_amd64.zip
unzip packer_0.10.2_linux_amd64.zip


echo -e "\n\n[Bamboo Agent installation script]: Cleaning up...\n\n"
apt-get clean
rm terraform_0.7.7_linux_amd64.zip
rm packer_0.10.2_linux_amd64.zip


##Sources##
#https://askubuntu.com/questions/58364/whats-the-difference-between-multiverse-universe-restricted-and-main
#https://github.com/blinkreaction/elastic-bamboo-agent/blob/master/install-bamboo-agent.sh
#https://confluence.atlassian.com/display/ATLAS/Dragons+Stage+1+-+Install+JIRA
#https://confluence.atlassian.com/display/ATLAS/Dragons+Stage+8+-+Install+Bamboo
#https://confluence.atlassian.com/bamboo/running-bamboo-as-a-linux-service-416056046.html
#https://linoxide.com/linux-how-to/install-bamboo-centos-7/
#https://bitbucket.org/DigitalMfgCommons/dmcdb/src/04e50698c14ca30c1182fc5e63d07f70f535cc01/installMeForBamboo.sh?fileviewer=file-view-default
#https://github.com/gstlt/bamboo-server/blob/master/terraform/bamboo-ec2.tf
#https://confluence.atlassian.com/bamkb/how-to-add-bamboo-startup-scripts-to-systemd-867344988.html
