#!/bin/bash -i

dateYMD=`date +20%y%m%d`
routePath=/data/deploy/${dateYMD}
prodPath=/product/docker_mserver
uploadPath=/product/docker_nginx/nginx_root/files

arr=($1)
ENV_VALUE=$2
OVERLAY_NET=$3
IS_NAT=$4
TARGET_HOST=$5
IS_UPLOAD=$6
if [ ! $arr ]; then
  echo "arr IS NULL"
  exit
fi
echo ${arr[@]}
for i in ${arr[*]}; do
    arr1=(${i/\:/\ })
    SERVICE_NAME=${arr1[0]}
    SERVICE_PORT=${arr1[1]}
    echo "Sever_name"+${SERVICE_NAME}
        if [ ! -f ${prodPath}/${SERVICE_NAME}.jar ];then
                echo    "${SERVICE_NAME}.jar is not exist"
                exit
        fi
   # cp  ${routePath}/${SERVICE_NAME}.jar  ${prodPath}/
    if [[ `sudo docker service ls | grep ${SERVICE_NAME}` ]];
    then 
        # 停止运行中的容器
        sudo docker  service scale ${SERVICE_NAME}=0
	sleep 15s
    fi;
    # 启动
    if [[ `sudo docker  service ls | grep ${SERVICE_NAME}` ]]; 
        then
        # 容器已创建，只重启
        sudo  docker service scale ${SERVICE_NAME}=1
    else
          # 如果容器未创建，创建容器
	if [ ! $ENV_VALUE ]; then
		ENV_VALUE=dev
		echo "default use dev!"
	fi
	if [  ! ${OVERLAY_NET} ]; then
		echo "OVERLAY_NET is null"
		if [  "${IS_NAT}" = "true" ]; then
			echo "IS_NAT is true"
                	if [  ! ${TARGET_HOST} ]; then
				echo "TARGET_HOST is null"
				sudo docker service create -d --name ${SERVICE_NAME}   -e "MS_NAME=${SERVICE_NAME}"  -e "ENV_VALUE=${ENV_VALUE}" --mount type=bind,source=${prodPath},destination=/product/mserver -p ${SERVICE_PORT}:${SERVICE_PORT}   mserver:v3  /product/mserver/run_jar.sh
                	else 
				echo "TARGET_HOST is not null"
				sudo docker service create -d --name ${SERVICE_NAME}   -e "MS_NAME=${SERVICE_NAME}"  -e "ENV_VALUE=${ENV_VALUE}" --mount type=bind,source=${prodPath},destination=/product/mserver -p ${SERVICE_PORT}:${SERVICE_PORT} --constraint node.hostname==${TARGET_HOST}  mserver:v3  /product/mserver/run_jar.sh
			fi
        	else
			echo "IS_NAT is false"
			if [  ! ${TARGET_HOST} ]; then
                                echo "TARGET_HOST is null"
				sudo docker service create -d --name ${SERVICE_NAME}   -e "MS_NAME=${SERVICE_NAME}"  -e "ENV_VALUE=${ENV_VALUE}" --mount type=bind,source=${prodPath},destination=/product/mserver  mserver:v3  /product/mserver/run_jar.sh
                        else
                                echo "TARGET_HOST is not null"
				sudo docker service create -d --name ${SERVICE_NAME}   -e "MS_NAME=${SERVICE_NAME}"  -e "ENV_VALUE=${ENV_VALUE}" --mount type=bind,source=${prodPath},destination=/product/mserver  --constraint node.hostname==${TARGET_HOST}  mserver:v3  /product/mserver/run_jar.sh
                        fi
		fi	
	else
		echo "OVERLAY_NET is not null"
		if [  "${IS_NAT}" = "true" ]; then
                  	echo "IS_NAT is true"
		        if [  ! ${TARGET_HOST} ]; then
                                echo "TARGET_HOST is null"
				sudo docker service create -d --name ${SERVICE_NAME}  --network ${OVERLAY_NET}  -e "MS_NAME=${SERVICE_NAME}"  -e "ENV_VALUE=${ENV_VALUE}" --mount type=bind,source=${prodPath},destination=/product/mserver -p ${SERVICE_PORT}:${SERVICE_PORT}  mserver:v3  /product/mserver/run_jar.sh
                        else
                                echo "TARGET_HOST is not null"
				sudo docker service create -d  --name ${SERVICE_NAME}  --network ${OVERLAY_NET}  -e "MS_NAME=${SERVICE_NAME}"  -e "ENV_VALUE=${ENV_VALUE}" --mount type=bind,source=${prodPath},destination=/product/mserver -p ${SERVICE_PORT}:${SERVICE_PORT} --constraint node.hostname==${TARGET_HOST}  mserver:v3  /product/mserver/run_jar.sh
                        fi
                else
                        echo "IS_NAT is false"
                        if [  ! ${TARGET_HOST} ]; then
                                echo "TARGET_HOST is null"
				sudo docker service create -d --name ${SERVICE_NAME}  --network ${OVERLAY_NET}  -e "MS_NAME=${SERVICE_NAME}"  -e "ENV_VALUE=${ENV_VALUE}" --mount type=bind,source=${prodPath},destination=/product/mserver  mserver:v3  /product/mserver/run_jar.sh
                        else
                                echo "TARGET_HOST is not null"
				if [  "${IS_UPLOAD}" = "true" ]; then
					sudo docker service create -d --name ${SERVICE_NAME}  --network ${OVERLAY_NET}  -e "MS_NAME=${SERVICE_NAME}"  -e "ENV_VALUE=${ENV_VALUE}" --mount type=bind,source=${prodPath},destination=/product/mserver --mount type=bind,source=${uploadPath},destination=${uploadPath}  --constraint node.hostname==${TARGET_HOST}  mserver:v3  /product/mserver/run_jar.sh
				else
					sudo docker service create -d --name ${SERVICE_NAME}  --network ${OVERLAY_NET}  -e "MS_NAME=${SERVICE_NAME}"  -e "ENV_VALUE=${ENV_VALUE}" --mount type=bind,source=${prodPath},destination=/product/mserver  --constraint node.hostname==${TARGET_HOST}  mserver:v3  /product/mserver/run_jar.sh
                        	fi
			fi
                fi
	fi
	
    fi;
done
