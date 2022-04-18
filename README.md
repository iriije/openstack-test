## masakari.sh

0. openstack init: openstack cluster에 image 업로드, flavor 생성, 네트워크 설정, 유저 생성
1. compute host status: 현재 호스트 상태
2. setup masakari: segment 생성 segment에 호스트들 등록
3. restore masakari: host 다운 이후 다시 컴퓨트 서비스 enable, segment에서 호스트 maintenance 상태 변경
4. instance manage: source instance.sh 

## instance.sh

1. show instance list
2. show instance detail
3. create instances
4. delete instances
5. config (n = # of instances, host = target host, fip = floating ip, etc.)

## use case

1. 클러스터 설치 후, admin-openrc.sh, init.sh 수정
2. [source masakari.sh]
3. [0] -> [2] (인스턴스 생성과 masakari 기본적인 세팅)
4. [4] -> [5] -> [host] -> [phci-11] -> [3] (phci-11에서만 인스턴스를 생성하도록 지정 후 인스턴스 생성)
5. phci-11 down, evacuation complete, phci-11 reboot
6. [q] -> [3]


##### Enter q or Ctrl+c to quit
