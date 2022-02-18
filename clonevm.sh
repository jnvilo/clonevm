#!/usr/bin/env bash 


ARGPARSE_DESCRIPTION="Clone VirtualMachine"
source $(dirname $0)/argparse.bash || exit 1
argparse "$@" <<EOF || exit 1
parser.add_argument("name")
parser.add_argument("-t", "--template", help="Name of Template", default="RL8")
parser.add_argument("-a", "--ipaddress", help="IP Address")
#parser.add_argument("-v", "--vlan", help="Change the vlan interface", default="br202") 
EOF


UUID=`uuid`
[[ $IPADDRESS =~ ^[0-9]{1,3}\.[0-9]{1,3}\.([0-9]{1,3})\.[0-9]{1,3}$ ]]
BRNUM=${BASH_REMATCH[1]}
GATEWAY="10.200.${BRNUM}.1"




cat > /tmp/ifcfg-enp1s0 << EOF
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
NAME=enp1s0
UUID=$UUID
DEVICE=enp1s0
ONBOOT=yes
IPADDR=$IPADDRESS
PREFIX=24
GATEWAY=$GATEWAY
DNS1=10.200.203.3
EOF


echo "Going to clone: ${TEMPLATE} to ${NAME}"
virt-clone -o $TEMPLATE -n $NAME --auto-clone
virt-sysprep  -d ${NAME} --hostname ${NAME} \
	--enable udev-persistent-net,machine-id,bash-history,customize,net-hostname,net-hwaddr \
	--upload /tmp/ifcfg-enp1s0:/etc/sysconfig/network-scripts/ifcfg-enp1s0 


if [[ ${BRNUM} == "201" ]]
then 
	EDITOR='sed -i "s/br202/br201/g"' virsh edit ${NAME}
fi


if [[ ${BRNUM} == "203" ]]
then 
	EDITOR='sed -i "s/br202/br203/g"' virsh edit ${NAME}
fi






   
