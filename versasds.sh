#!/bin/bash

#VersaSDS程序目录
VSDS_PATH="/root/VersaSDS"
read -p "是否按照要求替换好内核 (y/n)，按其他键退出程序 " choice
case "$choice" in 
    y|Y )
        echo "已替换好内核，即将安装软件"
          ;;
    n|N ) 
        echo "请先替换内核，再安装软件"
        exit 0
        ;;
    * ) 
        echo "请先替换内核，再安装软件"
        exit 1
        ;;
esac

# 执行vsdsipconf
echo "-------------------------------------------------------------------"
vsdsipconf_path="${VSDS_PATH}/vsdsipconf-v1.0.0/vsdsipconf"

if [ -f "${vsdsipconf_path}" ]; then
    echo "安装网络配置工具，若已安装可跳过"
    read -p "是否已填写配置文件 (y/n)，按其他键跳过安装网络配置 " choice
    case "$choice" in 
        y|Y ) 
            # 执行脚本
            cd "${VSDS_PATH}/vsdsipconf-v1.0.0"
            ./vsdsipconf
            ;;
        n|N ) 
            echo "请先填写配置文件"
            echo "退出程序"
            exit 0
            ;;
        * ) 
            echo "退出网络配置工具安装"
            echo "程序继续执行"
            ;;
    esac
else
    echo "vsdsipconf 不存在，无法执行程序"
fi


# 执行iptool，配置ip
echo "-------------------------------------------------------------------"
iptool_path="${VSDS_PATH}/vsdsiptool-v1.0.0/vsdsiptool"

if [ -f "${iptool_path}" ]; then
    echo "ip 配置，若已配置 ip 可跳过"
    read -p "是否跳过 ip 配置 (y/n)，按其他键跳过 ip 配置 " choice
    case "$choice" in 
        y|Y ) 
            echo "退出 ip 配置"
            ;;
        n|N ) 
            while true; do
                echo "* * * * * * * * * * * * * * * *"
                echo "  请选择要执行的操作(1~3):"
                echo "  1: 配置Bonding网络"
                echo "  2: 配置普通网络"
                echo "  3: 结束"
                echo "* * * * * * * * * * * * * * * *"
                read choice1
                case $choice1 in
                    1) 
                        echo "请输入 bonding 网卡名、ip、网络接口1（子网卡1）、网络接口2（子网卡2） 和 bonding 模式"
                        read bond_name ip device1 device2 mode
                        cd "${VSDS_PATH}/vsdsiptool-v1.0.0"
                        ./vsdsiptool bonding create ${bond_name} -ip ${ip} -d ${device1} ${device2} -m ${mode}
                        ;;
                    2) 
                        echo "请输入 ip 和 网络接口（网卡）"
                        read ip device
                        cd "${VSDS_PATH}/vsdsiptool-v1.0.0"
                        ./vsdsiptool ip create -ip ${ip} -d ${device}
                        ;;
                    3) break ;;
                    *) echo "无效的选择，请重新输入" ;;
                esac
            done 
            ;;
        * )
            echo "退出 ip 配置"
            echo "程序继续执行"
            ;;
    esac
else
    echo "vsdsiptool 不存在，无法执行程序"
fi

# 执行vsdssshfree
echo "-------------------------------------------------------------------"
sshfree_path="${VSDS_PATH}/vsdssshfree-v1.0.0/vsdssshfree"

if [ -f "${sshfree_path}" ]; then
    echo "进行 ssh 免密配置，如已配置可跳过"

    read -p "是否已填写配置文件 (y/n)，按其他键跳过 ssh 免密配置 " ssh_configured
    case "$ssh_configured" in 
        y|Y ) 
            cd "${VSDS_PATH}/vsdssshfree-v1.0.0"
            
            # 执行 modify
            ./vsdssshfree m
            if [ $? -ne 0 ]; then
                echo "Error: 执行 ./vsdssshfree m 失败"
                exit 1
            fi
            
            # 执行 fe
            ./vsdssshfree fe
            if [ $? -ne 0 ]; then
                echo "Error: 执行 ./vsdssshfree fe 失败"
                exit 1
            fi
            
            # 执行 check
            ./vsdssshfree c
            if [ $? -ne 0 ]; then
                echo "Error: 执行 ./vsdssshfree c 失败"
                exit 1
            fi
            ;;
        n|N ) 
            echo "中断脚本，未填写配置文件"
            exit 1
            ;;
        * )
            echo "跳过 ssh 免密配置"
            ;;
    esac

else
    echo "vsdssshfree 工具不存在，无法执行"
fi

#执行vsdsinstaller-k -i，安装 DRBD/LINSTOR
echo "-------------------------------------------------------------------"
installerk_path="${VSDS_PATH}/vsdsinstaller-k-v1.0.1/vsdsinstaller-k"

if [ -f "${installerk_path}" ]; then
    echo "安装DRBD/LINSTOR，若已安装可跳过"
    read -p "是否已填写配置文件 (y/n)，按其他键跳过 DRBD/LINSTOR 安装 " choice
    case "$choice" in 
        y|Y ) 
            # 执行脚本
            cd "${VSDS_PATH}/vsdsinstaller-k-v1.0.1"
            ./vsdsinstaller-k -i
            ;;
        n|N ) 
            echo "退出程序"
            exit 0
            ;;
        * ) 
            echo "退出DRBD/LINSTOR安装"
            echo "程序继续执行"
            ;;
    esac
else
    echo "vsdsinstaller-k 不存在，无法执行程序"
fi


# 执行vsdsinstaller-u，安装 VersaSDS - Pacemaker/Corosync/crmsh  + targetcli
echo "-------------------------------------------------------------------"
installeru_path="${VSDS_PATH}/vsdsinstaller-u-v1.0.1/vsdsinstaller-u"

if [ -f "${installeru_path}" ]; then
    # echo "安装高可用软件和网络配置工具"
    echo "安装高可用软件，若已安装可跳过"
    read -p "是否已填写配置文件 (y/n)，按其他键跳过高可用软件安装 " choice
    case "$choice" in 
        y|Y ) 
            # 执行脚本
            cd "${VSDS_PATH}/vsdsinstaller-u-v1.0.1"
            ./vsdsinstaller-u
            cp /usr/lib/ocf/resource.d/heartbeat/portblock /usr/lib/ocf/resource.d/heartbeat/portblock.bak
            # cp "${VSDS_PATH}/portblock" /usr/lib/ocf/resource.d/heartbeat/
            # chmod 755 /usr/lib/ocf/resource.d/heartbeat/portblock
            # if grep -i "portblock.mod_iptablesversion" /usr/lib/ocf/resource.d/heartbeat/portblock; then
            #     echo "portblock RA替换成功"
            # else
            #     echo "portblock RA替换失败"
            # fi

            cp /usr/lib/ocf/resource.d/linbit/drbd /usr/lib/ocf/resource.d/linbit/drbd.bak
            # cp "${VSDS_PATH}/drbd" /usr/lib/ocf/resource.d/linbit/
            # chmod 755 /usr/lib/ocf/resource.d/linbit/drbd
            # if grep -i "drbd.mod_notconfiged_retryonce" /usr/lib/ocf/resource.d/linbit/drbd; then
            #     echo "drbd RA 替换成功"
            # else
            #     echo "drbd RA 替换失败"
            # fi
            ;;
        n|N ) 
            echo "请先填写配置文件"
            echo "退出程序"
            exit 0
            ;;
        * ) 
            echo "退出高可用软件安装"
            echo "程序继续执行"
            ;;
    esac
else
    echo "vsdsinstaller-u 不存在，无法执行程序"
fi

# 执行vsdspreset，VersaSDS 预配置
echo "-------------------------------------------------------------------"
preset_path="${VSDS_PATH}/vsdspreset-v1.0.1/vsdspreset"

if [ -f "${preset_path}" ]; then
    echo "VersaSDS 预配置，若已配置可跳过"
    read -p "是否进行 VersaSDS 预配置 (y/n)，按其他键跳过 VersaSDS 预配置 " choice
    case "$choice" in 
        y|Y ) 
            # 执行脚本
            cd "${VSDS_PATH}/vsdspreset-v1.0.1"
            ./vsdspreset
            ;;
        n|N ) 
            echo "退出程序"
            exit 0
            ;;
        * ) 
            echo "退出 VersaSDS 预配置"
            echo "程序继续执行"
            ;;
    esac
else
    echo "vsdspreset 不存在，无法执行程序"
fi



#是否开启linstor-controller
echo "-------------------------------------------------------------------"
echo "请选择一个节点开启 linstor-controller 并开始进行集群配置"
# echo "如果集群的每个节点并未配置好 vg，请暂时不要开启 linstor-controller"
read -p "是否开启linstor-controller (y/n)，按其他键跳过开启 linstor-controller " choice
case "$choice" in 
    y|Y ) 
        # 执行脚本
        systemctl start linstor-controller
        ;;
    n|N ) 
        echo "跳过开启 linstor-controller"
        echo "程序继续执行"
        ;;
    * ) 
        echo "跳过开启 linstor-controller"
        echo "程序继续执行"
        ;;
esac

#开启linstor-satellite
systemctl start linstor-satellite

# 执行vsdsadm，配置 LVM 和 LINSTOR 集群
echo "-------------------------------------------------------------------"
vsdsadm_path="${VSDS_PATH}/vsdsadm-v1.0.1/vsdsadm"

if [ -f "${vsdsadm_path}" ]; then
    # echo "配置 LVM 和 LINSTOR 集群"
    # while true; do
    #     echo "* * * * * * * * * * * * * * * * * * * * * * * * * * *"
    #     echo "  提示：集群所有节点未配置好vg之前暂时不要进行pool和资源的操作"
    #     echo "  创建pool和资源之前请先开启linstor-controller"
    #     echo "  请选择要执行的操作(1~6):"
    #     echo "  1: 集群节点配置"
    #     echo "  2: 创建vg"
    #     echo "  3: 创建thin pool（请先进行1/2配置）"
    #     echo "  4: 创建thick pool（请先进行1/2配置）"
    #     echo "  5: 创建资源（请先创建Storage Pool）"
    #     echo "  6: 结束"
    #     echo "* * * * * * * * * * * * * * * * * * * * * * * * * *"
    #     read choice1
    #     case $choice1 in
    #     	1) 
    #             echo "请输入节名和 ip"
    #             read nodename ip
    #             cd "${VSDS_PATH}/vsdsadm-v1.0.0"
    #             ./vsdsadm stor node create ${nodename} -ip ${ip}
    #             linstor controller sp DrbdOptions/AutoEvictAllowEviction false
    #             ;;
    #         2) 
    #             echo "请输入 vg 名"
    #             read vgname
    #             echo "请输入 device（输入多个device请以“ ”隔开）"
    #             read -a devices
    #             cd "${VSDS_PATH}/vsdsadm-v1.0.0"
    #             ./vsdsadm stor lvm create ${vgname} -t vg -d ${devices[@]}
    #             ;;
    #         3) 
    #             echo "请输入节点名、thinpool 名和 vg 名"
    #             read node thinpool vgname
    #             cd "${VSDS_PATH}/vsdsadm-v1.0.0"
    #             ./vsdsadm stor lvm create thlv -t thinpool -vg ${vgname}
    #             ./vsdsadm stor storagepool create ${thinpool} -n ${node} -tlv ${vgname}/thlv
    #             ;;
    #         4) 
    #             echo "请输入节点名、 thickpool 名和 vg 名"
    #             read node thickpool vgname
    #             cd "${VSDS_PATH}/vsdsadm-v1.0.0"
    #             ./vsdsadm stor storagepool create ${thickpool} -n ${node} -lvm ${vgname}
    #             ;;
    #         5) 
    #             echo "请输入资源名"
    #             read resource
    #             echo "请输入diskful节点名，节点名之间以“ ”隔开"
    #             read -a diskfuls
    #             echo "请输入diskless节点名，节点名之间以“ ”隔开"
    #             read -a disklesses
    #             echo "请输入资源的size"
    #             read size
    #             echo "请输入存储池名字"
    #             read storagepool
    #             cd "${VSDS_PATH}/vsdsadm-v1.0.0"
    #             ./vsdsadm stor resource create ${resource} -s ${size} -n ${diskfuls[@]}  -sp ${storagepool}
    #             ./vsdsadm stor resource create ${resource} -diskless -n ${disklesses[@]}
    #             ;;
    #         6) break ;;
    #         *) echo "无效的选择，请重新输入" ;;
    #     esac
    # done
    echo "配置 LVM 和 LINSTOR 集群，如已配置可以跳过"
    read -p "是否配置 LVM 和 LINSTOR 集群 (y/Y)，按其他键跳过配置 LVM 和 LINSTOR 集群 " choice
    case "$choice" in 
        y|Y ) 
            # 创建 VG
            # echo "请输入 vg 名"
            # read vgname
            vgname="vgsds"  # 示例
            echo "请输入设备列表（多个设备以空格隔开）:"
            read -a devices

            cd "${VSDS_PATH}/vsdsadm-v1.0.1"
            # ./vsdsadm stor lvm create ${vgname} -t vg -d ${devices[@]}
            command="./vsdsadm stor lvm create $vgname -t vg -d ${devices[@]}"
            # echo "执行命令: $command"
            eval $command

            # 创建 Thin Pool（固定值）
            thinpool="thpool1"
            command="./vsdsadm stor lvm create $thinpool -t thinpool -vg $vgname"
            # echo "执行命令: $command"
            eval $command

            
            # 创建节点和 IP
            declare -a nodes_ips
            nodenames=()

            while true; do
                echo "请输入节点名和 IP 地址，用空格分隔 (输入 'done' 完成):"
                read -a node_ip
                if [[ "${node_ip[0]}" == "done" ]]; then
                    break
                fi
                nodes_ips+=("${node_ip[@]}")
            done

            if [ ${#nodes_ips[@]} -eq 0 ]; then
                echo "跳过配置 LINSTOR 集群"
            else
                for ((i=0; i<${#nodes_ips[@]}; i+=2)); do
                    nodename="${nodes_ips[i]}"
                    ip="${nodes_ips[i+1]}"
                    # ./vsdsadm stor node create ${nodename} -ip ${ip}
                    command="./vsdsadm stor node create ${nodename} -ip ${ip}"
                    # echo "执行命令: $command"
                    eval $command
                    nodenames+=(${nodename})
                done

                linstor controller sp DrbdOptions/AutoEvictAllowEviction false
                # echo ${nodenames[@]}
                
                # 创建存储池
                command="./vsdsadm stor storagepool create $thinpool -n ${nodenames[@]} -tlv ${vgname}/${thinpool}"
                # echo "执行命令: $command"
                eval $command

                # 创建资源（固定值）
                resource="linstordb"
                diskfuls=("${nodenames[@]}")
                # disklesses=()  # 空数组，因为没有 diskless 节点

                size="512M"
                storagepool="thpool1"  # 存储池名字固定为 thpool1

                # ./vsdsadm stor resource create ${resource} -s ${size} -n ${diskfuls[@]}  -sp ${storagepool}
                # ./vsdsadm stor resource create ${resource} -diskless -n ${disklesses[@]}
                command="./vsdsadm stor resource create $resource -s $size -n ${diskfuls[@]} -sp $storagepool"
                # echo "执行命令: $command"
                eval $command
            fi
            ;;
        * ) 
            echo "跳过配置 LVM 和 LINSTOR 集群"
            echo "程序继续执行"
            ;;
    esac
else
    echo "vsdsadm 不存在，无法执行程序"
fi

# 执行vsdscoroconf，配置 Corosync
echo "-------------------------------------------------------------------"
coroconf_path="${VSDS_PATH}/vsdscoroconf-v1.0.1/vsdscoroconf"

if [ -f "${coroconf_path}" ]; then
    echo "配置 Corosync，如已配置可以跳过"
    read -p "是否已填写配置文件 (y/n)，按其他键跳过 Corosync 配置 " choice
    case "$choice" in 
        y|Y ) 
            # 执行脚本
            cd "${VSDS_PATH}/vsdscoroconf-v1.0.1"
            # cp corosync.conf.bak /etc/corosync/corosync.conf
            ./vsdscoroconf
            ;;
        n|N ) 
            echo "退出程序"
            exit 0
            ;;
        * ) 
            echo "跳过 Corosync 配置"
            echo "程序继续执行"
            ;;
    esac
else
    echo "vsdscoroconf 不存在，无法执行程序"
fi

# 执行vsdshaconf，配置高可用
echo "-------------------------------------------------------------------"
ha_path="${VSDS_PATH}/vsdshaconf-v1.0.1/vsdshaconf"

if [ -f "${ha_path}" ]; then
    echo "配置高可用，如已配置可以跳过"
    read -p "是否已填写配置文件 (y/n)，按其他键跳过高可用配置 " choice
    case "$choice" in 
        y|Y ) 
            # 执行脚本
            cd "${VSDS_PATH}/vsdshaconf-v1.0.1"
            ./vsdshaconf build -p
            ./vsdshaconf build -l
            # ./vsdshaconf build -v
            crm res cleanup p_drbd_linstordb
            sleep 5
            # ./vsdshaconf build -t
            # ./vsdshaconf build -d
            # ./vsdshaconf build -i
            crm res ref
            sleep 15
            crm res ref
            sleep 15
            crm res ref
            sleep 15
            ;;
        n|N ) 
            echo "退出程序"
            exit 0
            ;;
        * ) 
            echo "跳过高可用配置"
            echo "程序继续执行"
            ;;
    esac
else
    echo "vsdshaconf 不存在，无法执行程序"
fi

#配置linstor-client
echo "-------------------------------------------------------------------"
echo "配置 linstor-client，如已配置可以跳过"
read -p "是否已配置好 linstor-controller 的高可用 (y/n)，按其他键跳过 linstor-client 配置 " choice
case "$choice" in 
    y|Y ) 
        # 执行脚本
        ip=`crm conf show vip_ctl | grep -oP 'ip=\K[^ ]+'`
        echo "[global]" > /etc/linstor/linstor-client.conf
        echo "controllers=${ip}" >> /etc/linstor/linstor-client.conf
        ;;
    n|N ) 
        echo "退出程序"
        exit 0
        ;;
    * ) 
        echo "跳过 linstor-client 配置"
        echo "程序继续执行"
        ;;
esac

# 执行csmpreinstaller，安装 docker & kubeadm 等软件
echo "-------------------------------------------------------------------"
csmpreinstaller_path="${VSDS_PATH}/csmpreinstaller-v1.0.0/csmpreinstaller"

if [ -f "${csmpreinstaller_path}" ]; then
    echo "安装 docker & kubeadm 等软件"
    read -p "是否执行安装 (y/n)，按其他键跳过安装 docker & kubeadm " choice
    case "$choice" in 
        y|Y ) 
            # 执行脚本
            cd "${VSDS_PATH}/csmpreinstaller-v1.0.0"
            ./csmpreinstaller
            ;;
        n|N ) 
            echo "退出程序"
            exit 0
            ;;
        * ) 
            echo "跳过安装 docker & kubeadm 等软件"
            echo "程序继续执行"
            ;;
    esac
else
    echo "csmpreinstaller 不存在，无法执行程序"
fi

# 执行csmdeployer，部署 CoSAN Manager
echo "-------------------------------------------------------------------"
csmdeployer_path="${VSDS_PATH}/csmdeployer-v1.0.2/csmdeployer"

if [ -f "${csmdeployer_path}" ]; then
    echo "部署 CoSAN Manager"
    read -p "是否已填写配置文件 (y/n) ，按其他键退出程序 " choice
    case "$choice" in 
        y|Y ) 
            # 执行脚本
            cd "${VSDS_PATH}/csmdeployer-v1.0.2"
            ./csmdeployer
            ;;
        n|N ) 
            echo "退出程序"
            exit 0
            ;;
        * ) 
            echo "跳过部署部署 CoSAN Manager"
            echo "程序继续执行"
            ;;
    esac
else
    echo "csmdeployer 不存在，无法执行程序"
fi
