PREFIX=test
FLAVOR=m1.medium
IMAGE=focal-server-cloudimg-amd64.img
SUBNET=default
N=6
OPT='--boot-from-volume 10'
HOST='all'
HA='True'
host_conf=""
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
			"3" ) create_instances $N $OPT;;
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
	for num in $(seq $1)
	do
	    openstack server create --flavor $FLAVOR --image $IMAGE --security-group allow_tcp_udp_icmp $host_conf $ha_conf --nic net-id=$SUBNET $2 $3 test${num}
	done
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
	openstack server list
}

config() {
	echo "select what you want config (prefix, flavor, image, subnet, n, opt, host, ha): "
	echo $PREFIX $FLAVOR $IMAGE $SUBNET $N $OPT $HOST $HA
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
		"n" )   
			echo $N
			read N
                        echo $N;;
		"opt" ) 
			echo $OPT
			read OPT
                        echo $OPT;;
		"ha" )
			echo $HA
			read HA
		        ha_conf=""
                	if [ $HA == 'True' ]; then
		                ha_conf="--property HA_Enabled=True"
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
