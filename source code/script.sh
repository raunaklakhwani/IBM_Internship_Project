#!/bin/bash
echo "First section"
export
export HOME=/root
echo "HOME:"
echo $HOME
echo "BASH_VERSION:"
echo $BASH_VERSION
set -v

echo "2nd section"
 yum install git -y
 yum install sqlite-devel -y
 yum install libxml2-devel -y
 yum install libxslt-devel -y
 yum install python-novaclient -y
 yum install mysql-devel -y
 yum install postgresql-devel -y
 yum install unzip -y


echo "3rd section"
 yum install gcc-c++ patch readline readline-devel zlib zlib-devel -y
 yum install libyaml-devel libffi-devel openssl-devel make -y
 yum install bzip2 autoconf automake libtool bison iconv-devel -y
curl -sSL https://get.rvm.io | bash -s stable --ruby
source /usr/local/rvm/scripts/rvm
rvm install 1.9.3 
rvm use 1.9.3 --default




echo "4th section"
ruby -v
gem update --system
echo "Finished gem update --system"
gem list



echo "5th section"
 echo "[osee-havana-noarch]" > /etc/yum.repos.d/osee-havana-noarch.repo
 echo "name=osee-havana-noarch" >> /etc/yum.repos.d/osee-havana-noarch.repo
 echo "baseurl=http://9.47.161.115:8080/rhel_repos/osee-havana/noarch/" >> /etc/yum.repos.d/osee-havana-noarch.repo
 echo "enabled=1" >> /etc/yum.repos.d/osee-havana-noarch.repo
 echo "gpgcheck=0" >> /etc/yum.repos.d/osee-havana-noarch.repo
 echo "skip_if_unavailable=1" >> /etc/yum.repos.d/osee-havana-noarch.repo
 echo "priority=1" >> /etc/yum.repos.d/osee-havana-noarch.repo




 echo "6th section"
 echo "[osee-havana-x86_64]" > /etc/yum.repos.d/osee-havana-x86_64.repo
 echo "name=osee-havana-x86_64" >> /etc/yum.repos.d/osee-havana-x86_64.repo
 echo "baseurl=http://9.47.161.115:8080/rhel_repos/osee-havana/x86_64/" >> /etc/yum.repos.d/osee-havana-x86_64.repo
 echo "enabled=1" >> /etc/yum.repos.d/osee-havana-x86_64.repo
 echo "gpgcheck=0" >> /etc/yum.repos.d/osee-havana-x86_64.repo
 echo "skip_if_unavailable=1" >> /etc/yum.repos.d/osee-havana-x86_64.repo
 echo "priority=1" >> /etc/yum.repos.d/osee-havana-x86_64.repo



 echo "7th section"
 echo "export OS_TENANT_NAME=admin" > /root/keystonerc
 echo "export OS_USERNAME=admin" >> /root/keystonerc
 echo "export OS_PASSWORD=admin" >> /root/keystonerc
 echo "export OS_AUTH_URL=http://9.114.96.250:5000/v2.0" >> /root/keystonerc
 echo "export OS_NO_CACHE=1" >> /root/keystonerc
 echo "export OS_REGION_NAME=RegionOne" >> /root/keystonerc
 chmod 755 /root/keystonerc
source /root/keystonerc



#optional
 yum install python-neutronclient -y
 yum install python-novaclient -y

echo "8th section"
 rm -f /root/.ssh/id_rsa*
 ssh-keygen -q -f /root/.ssh/id_rsa -N ""
 nova keypair-add --pub-key /root/.ssh/id_rsa.pub default-key



echo "9th section"
echo "About to start install of bosh cli gem before microbosh deploy(takes a few minutes)"
gem install  bosh_cli_plugin_micro --pre
gem install rake --pre
gem install escape_utils --pre
gem install mysql2 -v 0.3.11 --pre
gem install aws-sdk --pre
ruby -v
gem list

#Micro Bosh Deployment begins

rm -rf /root/bosh-workspace/deployments

mkdir -p /root/bosh-workspace/deployments/bluemix-openstack
mkdir -p /root/bosh-workspace/deployments/ace
cd /root/bosh-workspace/deployments/ace

mv /root/ronak/packages.zip packages.zip
cp packages.zip /root/ronak/
unzip packages.zip 
mv packages/* .
rm -rf packages
sudo rpm -ivh cf-cli_amd64.rpm
cd
source /root/keystonerc

cd /root/bosh-workspace/deployments/bluemix-openstack/
mv /root/ronak/micro_bosh.yml micro_bosh.yml
cp micro_bosh.yml /root/ronak

nova network-list | grep default | awk '{print "<net_id> "$2}' > key.txt
echo "<type> manual" >> key.txt
echo "<vm_name> default-openstack" >> key.txt
echo "<microbosh_vm_ip> 10.241.0.3" >> key.txt
echo "<instance_type> microboshcli" >> key.txt
echo "<auth_url> http://9.114.96.250:5000/v2.0/" >> key.txt
echo "<username> admin"   >> key.txt
echo "<api_key> admin" >> key.txt
echo "<tenant> admin" >> key.txt
echo "<default_key_name> default-key" >> key.txt

awk 'NR==FNR {a[$1]=$2;next} {for ( i in a) gsub(i,a[i])}1' key.txt micro_bosh.yml > micro_bosh.mod.yml
mv micro_bosh.yml micro_bosh.mod.yml.orig
mv micro_bosh.mod.yml  micro_bosh.yml



cd /root/bosh-workspace/deployments
bosh micro deployment bluemix-openstack
sudo echo yes | bosh micro deploy /root/bosh-workspace/deployments/ace/bosh-stemcell-2409-openstack-kvm-ubuntu.tgz --update-if-exists

cd /root/bosh-workspace/deployments
echo -e "admin\nadmin\n" |  bosh target https://10.241.0.3:25555
bosh upload stemcell /root/bosh-workspace/deployments/ace/bosh-stemcell-2409-openstack-kvm-ubuntu.tgz 
bosh upload release /root/bosh-workspace/deployments/ace/cf-146.tgz
sleep 5
bosh upload release /root/bosh-workspace/deployments/ace/cf-services-contrib-release.tgz


#Micro bosh deployment ends

#CF component deployment starts
mkdir -p /root/bosh-workspace/deployments/cf
echo "Fetching the cf demo.yml file."

cd /root/bosh-workspace/deployments/cf

mv /root/ronak/demo.yml /root/bosh-workspace/deployments/cf/demo.yml
cp demo.yml /root/ronak/

source /root/keystonerc


bosh status > temp1.txt 
grep UUID temp1.txt > temp2.txt 
awk '{print "DIRECTOR_UUID_CHANGE " "\""$2  "\""}' temp2.txt > temp.txt

nova network-list | grep default | awk '{print "<net_id> "$2}' >> temp.txt




echo "<network_name> default" >> temp.txt


echo "<nats_static_ip> 9.114.98.169" >> temp.txt
echo "<postgres_static_ip> 9.114.98.171" >> temp.txt
echo "<router_ip_address> 9.114.98.172" >> temp.txt




cp demo.yml demo.yml.orig
awk 'NR==FNR {a[$1]=$2;next} {for ( i in a) gsub(i,a[i])}1' temp.txt demo.yml > demo.mod.yml
mv -f demo.mod.yml demo.yml

bosh deployment /root/bosh-workspace/deployments/cf/demo.yml
echo yes | bosh deploy

echo yes | bosh restart cloud_controller


#CF component deployment ends

#Pushing an app starts
cd
cf target http://api.9.114.98.169.xip.io --trace
cf login admin
git clone https://github.com/cloudfoundry-community/cf_demoapp_ruby_rack.git
cd cf_demoapp_ruby_rack
cf push
cf apps


#Pushing an app ends









