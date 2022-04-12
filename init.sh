# cli 환경 마련
## openstackclient 설치
#pip install python-openstackclient

## admin-openrc.sh 실행
#kolla-ansible post-deploy
. /etc/kolla/admin-openrc.sh

# 인스턴스 생성을 위한 이미지 등록
## 이미지 다운로드
### cirros
curl -L http://download.cirros-cloud.net/0.5.2/cirros-0.5.2-x86_64-disk.img > cirros-0.5.2-x86_64-disk.img
### ubuntu
#curl -L https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img > focal-server-cloudimg-amd64.img
# wget http://pbs.piolink.com/base.img/u20-ssh-root-admin.qcow2
## 이미지 등록
### cirros
openstack image create cirros-0.5.2-x86_64-disk.img --container-format bare --disk-format qcow2 --private --file cirros-0.5.2-x86_64-disk.img --property hw_architecture='x86_64'
### ubuntu
openstack image create focal-server-cloudimg-amd64.img --container-format bare --disk-format qcow2 --public --file focal-server-cloudimg-amd64.img --property hw_architecture='x86_64'

# default flavor 생성
openstack flavor create --id 0 --ram 512   --vcpus 1 --disk 10  m1.tiny
openstack flavor create --id 1 --ram 1024  --vcpus 1 --disk 20  m1.small
openstack flavor create --id 2 --ram 2048  --vcpus 2 --disk 40  m1.medium
#openstack flavor create --id 3 --ram 4096  --vcpus 2 --disk 80  m1.large
#openstack flavor create --id 4 --ram 8192  --vcpus 4 --disk 160 m1.xlarge
#openstack flavor create --id 5 --ram 16384 --vcpus 6 --disk 320 m1.jumbo

# network 설정
## provider network 설정
openstack network create --share --external --provider-physical-network physnet1 --provider-network-type flat provider
openstack subnet create --network provider --allocation-pool start=192.168.195.141,end=192.168.195.149 --dns-nameserver 192.168.203.100 --gateway 192.168.195.1 --subnet-range 192.168.195.0/24 physnet1 --no-dhcp

## private network 생성
openstack network create --share default
openstack subnet create --network default --dns-nameserver 192.168.203.100 --subnet-range 172.16.0.0/24 default_subnet1

## private network 과 provider network 간 router 생성 및 연결
openstack router create router1
openstack router add subnet router1 default_subnet1
openstack router set --external-gateway provider --enable-snat router1

## 보안그룹
openstack security group create allow_tcp_udp_icmp

#openstack security group rule create --egress --proto tcp --remote-ip 0.0.0.0/0 --dst-port 1:65525 allow_tcp_udp_icmp
#openstack security group rule create --egress --proto udp --remote-ip 0.0.0.0/0 --dst-port 1:65525 allow_tcp_udp_icmp
#openstack security group rule create --egress --proto icmp --remote-ip 0.0.0.0/0 --dst-port 1:65525 allow_tcp_udp_icmp

openstack security group rule create --ingress --proto tcp --remote-ip 0.0.0.0/0 --dst-port 1:65525 allow_tcp_udp_icmp
openstack security group rule create --ingress --proto udp --remote-ip 0.0.0.0/0 --dst-port 1:65525 allow_tcp_udp_icmp
openstack security group rule create --ingress --proto icmp --remote-ip 0.0.0.0/0 --dst-port 1:65525 allow_tcp_udp_icmp

## user 추가
openstack user create --password admin jglee
openstack role add admin --project admin --user jglee

## 인스턴스 생성
#openstack server create --flavor m1.tiny --image cirros-0.5.2-x86_64-disk.img   --nic net-id=default --security-group allow_tcp_udp_icmp test1

# 인스턴스에 floating ip 추가
#openstack server add floating ip test1 $(openstack floating ip create provider | grep floating_ip | awk '{ print $4 }')

#openstack server list

