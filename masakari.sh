HOST1=phci-11
HOST2=phci-12
HOST3=phci-13
SEG_NAME=test_segment

show_host() {
	openstack compute service list
	openstack segment host list $SEG_NAME
}

set_masakari() {
	pip install python-masakariclient
	openstack segment create $SEG_NAME auto COMPUTE
	sleep 10
	openstack segment host create $HOST1 COMPUTE SSH $SEG_NAME
	openstack segment host create $HOST2 COMPUTE SSH $SEG_NAME
	openstack segment host create $HOST3 COMPUTE SSH $SEG_NAME
}

restore_masakari() {
	openstack compute service set --enable $HOST1 nova-compute
	openstack compute service set --enable $HOST2 nova-compute
	openstack compute service set --enable $HOST3 nova-compute

	openstack segment host update --on_maintenance False $SEG_NAME $HOST1
	openstack segment host update --on_maintenance False $SEG_NAME $HOST2
	openstack segment host update --on_maintenance False $SEG_NAME $HOST3
}

main() {
	source admin-openrc.sh
        while :
        do
                echo "========================"
                echo "    masakari test"
                echo "========================"
                echo "0. openstack basic"
                echo "1. compute host status"
                echo "2. set up masakari"
                echo "3. restore masakari"
                echo "4. instance manage"
                echo "========================"

                read num
                case $num in
                        "q" | "quit" ) echo "quit"
                                break;;
                        "0" ) source init.sh;;
                        "1" ) show_host;;
                        "2" ) set_masakari;;
                        "3" ) restore_masakari;;
                        "4" ) source instance.sh;;
                        "*" ) echo "wrong number";;
                esac
        done
}

main
