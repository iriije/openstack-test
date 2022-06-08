# cli 환경 마련
## openstackclient 설치
#pip install python-openstackclient

## admin-openrc.sh 실행
#kolla-ansible post-deploy
#. /etc/kolla/admin-openrc.sh

# 인스턴스 생성을 위한 이미지 등록
openstack image create --disk-format qcow2 --container-format bare --property os_distro='ubuntu' \
        --public --file /opt/phci/data/openstack/u20-ssh-root-admin.qcow2 ubuntu20.04-ssh-root-admin

openstack image create --disk-format qcow2 --container-format bare --property os_distro='arch' \
        --public --file /opt/phci/data/openstack/cirros-0.5.2-x86_64-disk.img cirros-0.5.2-x86_64

echo "Register amphora image to glance"
openstack image create amphora-x64-haproxy.qcow2 --container-format bare --disk-format qcow2 \
        --property os_distro='ubuntu' \
        --private --tag amphora \
        --file /opt/phci/data/openstack/amphora-x64-haproxy.qcow2 \
        --property hw_architecture='x86_64' \
        --property hw_rng_model=virtio \
        --project service

# default flavor 생성
openstack flavor create --id 0 --ram 1024  --vcpus 1 --disk 10  c1m1
openstack flavor create --id 1 --ram 2048  --vcpus 1 --disk 10  c1m2
openstack flavor create --id 2 --ram 2048  --vcpus 2 --disk 10  c2m2
openstack flavor create --id 3 --ram 4096  --vcpus 2 --disk 10  c2m4
openstack flavor create --id 4 --ram 8192  --vcpus 4 --disk 10 c4m8
openstack flavor create --id 5 --ram 16384 --vcpus 8 --disk 10 c8m16

# network 설정
## provider network 설정
openstack network create --share --external --provider-physical-network physnet1 --provider-network-type flat provider
openstack subnet create --network provider --allocation-pool start=192.168.195.141,end=192.168.195.149 --dns-nameserver 192.168.203.100 --gateway 192.168.195.1 --subnet-range 192.168.195.0/24 "192.168.195.0/24" --no-dhcp

## private network 생성
openstack network create --share "management network"
openstack subnet create --network "management network" --dns-nameserver 192.168.203.100 --subnet-range 172.16.0.0/16 "172.16.0.0/16"

## private network 과 provider network 간 router 생성 및 연결
openstack router create router
openstack router add subnet router "172.16.0.0/16"
openstack router set --external-gateway provider --enable-snat router

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

