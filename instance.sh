PREFIX=test
FLAVOR=c1m1
IMAGE=ubuntu20.04-ssh-root-admin
SUBNET="management network"
FIP='false'
N=50
BOOT_VOLUME='true'
HOST='all'
HA='true'
host_conf=""
boot_volume='--boot-from-volume 10'
ha_conf="--property HA_Enabled=True"


main() {	
	source admin-openrc.sh
	while :
	do
        	echo "========================"
		echo "  current instance(s)"
	        echo "========================"
		openstack server list
		echo "========================"
		echo "    instance manage"
		echo "========================"
		echo "1. show instance list"
		echo "2. show instance detail"
		echo "3. create instance(s)"
		echo "4. delete instance(s)"
		echo "5. config"
		echo "========================"
		read num
		case $num in
			"q" | "quit" ) echo "quit"
				break;;
			"1" ) : ;;
			"2" ) show_instance_detail;;
			"3" ) create_instances;;
			"4" ) delete;;	
			"5" ) config;;
			"*" ) echo "wrong number";;
		esac
	done
}

delete() {
        echo "========================"
        echo "1. delete with name"
        echo "2. delete with state Error"
        echo "3. delete all instance(s)"
        echo "========================"
        read num
        case $num in
                "q" | "quit" ) echo "quit";;
                "1" ) delete_with_name;;
                "2" ) delete_with_state;;
                "3" ) delete_all;;
                "*" ) echo "wrong number";;
        esac
}

show_instance_detail() {
	echo "========================"
        echo "  current instance(s)"
        echo "========================"
	openstack server list
        echo "id or name:"
        read name
        openstack server show $name
}

create_instances() {
	for num in $(seq $N)
	do
	    openstack server create --flavor $FLAVOR --image $IMAGE --security-group allow_tcp_udp_icmp $boot_volume $host_conf $ha_conf --nic net-id="$SUBNET" test${num}
	done
	sleep 5s
	if [ $FIP == 'true' ]; then
		for num in $(seq $N)
		do
	    		openstack server add floating ip test${num} $(openstack floating ip create provider | grep floating_ip | awk '{ print $4 }')
		done
	fi
}

delete_with_name() {
	echo "id or name:"
	read name
	server_list=$(openstack server list | grep $name | awk '{print $2}')
	delete_instances
}

delete_with_state() {
	server_list=$(openstack server list | grep ERROR | awk '{print $2}')
	delete_instances
}

delete_all() {
	server_list=$(openstack server list | awk 'NR > 3 {print $2}')
	delete_instances
	openstack floating ip delete $(openstack floating ip list | grep None | awk '{print $2}')
}

delete_instances() {
	volume_array=()
	for server in $server_list
        do
		volume_array+=($(openstack server show $server | grep volumes_attached | awk '{print $4}' | awk -F "'" '{print $2}'))
                openstack server delete $server
        done
	sleep 5s
	for volume in ${volume_array[@]}
	do
		openstack volume delete --force $volume
	done
}

config() {
	echo "select what you want config (prefix, flavor, image, subnet, fip, n, boot_volume, host, ha): "
	echo $PREFIX $FLAVOR $IMAGE $SUBNET $FIP $N $BOOT_VOLUME $HOST $HA
	read conf
	case $conf in
		"prefix" )
			echo $PREFIX
			read PREFIX
			echo $PREFIX;;
		"flavor" )
		        echo $FLAVOR	
			read FLAVOR
			echo $FLAVOR;;
		"image" )
		        echo $IMAGE	
			read IMAGE
                        echo $IMAGE;;
		"subnet" )
		        echo $SUBNET	
			read SUBNET
                        echo $SUBNET;;
		"fip" )   
			echo $FIP
			read FIP
                        echo $FIP;;
		"n" )   
			echo $N
			read N
                        echo $N;;
		"boot_volume" ) 
			echo $BOOT_VOLUME
			read BOOT_VOLUME
			boot_volume="--boot-from-volume 10"
			if [ $BOOT_VOLUME == 'false' ]; then
				boot_volume=""
			fi
                        echo $BOOT_VOLUME;;
		"ha" )
			echo $HA
			read HA
		        ha_conf="--property HA_Enabled=True"
                	if [ $HA == 'false' ]; then
		                ha_conf=""
		        fi
			echo $HA;;
		"host" )
			echo $HOST
			read HOST
			host_conf="--os-compute-api-version 2.74 --host $HOST"
		        if [ $HOST == 'all' ]; then
                		host_conf=""
		        fi
			echo $HOST;;
		"*" ) echo "wrong input"
	esac
}


main
