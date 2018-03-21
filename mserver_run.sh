#!/bin/bash -i

dateYMD=`date +20%y%m%d`
routePath=/data/deploy/${dateYMD}
prodPath=/product/docker_mserver
uploadPath=/product/docker_nginx/nginx_root/files

arr=($1)
ENV_VALUE=$2
IS_NAT=$3
IS_UPLOAD=$4
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
    if [[ `sudo docker ps -a | grep ${SERVICE_NAME}` ]];
    then
        # 停止运行中的容器
        sudo docker  stop ${SERVICE_NAME}
        sleep 15s
    fi;
    # 启动
    if [[ `sudo docker ps -a| grep ${SERVICE_NAME}` ]];
        then
        # 容器已创建，只重启
        sudo docker start ${SERVICE_NAME}
    else
          # 如果容器未创建，创建容器
        if [ ! $ENV_VALUE ]; then
                ENV_VALUE=dev
                echo "default use dev!"
        fi
        if [  "${IS_NAT}" = "true" ]; then
                echo "IS_NAT is true"
             if [   "${IS_UPLOAD}" = "true" ]; then
                echo "IS_UPLOAD is true"
                sudo docker run -d --name ${SERVICE_NAME}   -e "MS_NAME=${SERVICE_NAME}"  -e "ENV_VALUE=${ENV_VALUE}" -v ${prodPath}:/product/mserver -v ${uploadPath}:${uploadPath}  -p ${SERVICE_PORT}:${SERVICE_PORT}   mserver:v3  /product/mserver/run_jar.sh
             else
		echo "IS_UPLOAD is false"
		sudo docker run -d --name ${SERVICE_NAME}   -e "MS_NAME=${SERVICE_NAME}"  -e "ENV_VALUE=${ENV_VALUE}" -v ${prodPath}:/product/mserver  -p ${SERVICE_PORT}:${SERVICE_PORT}   mserver:v3  /product/mserver/run_jar.sh
	     fi
        else
                echo "IS_NAT is false"
             if [   "${IS_UPLOAD}" = "true" ]; then
                echo "IS_UPLOAD is true"
                sudo docker run -d --name ${SERVICE_NAME}   -e "MS_NAME=${SERVICE_NAME}"  -e "ENV_VALUE=${ENV_VALUE}" -v ${prodPath}:/product/mserver -v ${uploadPath}:${uploadPath}    mserver:v3  /product/mserver/run_jar.sh
             else
                echo "IS_UPLOAD is false"
                sudo docker run -d --name ${SERVICE_NAME}   -e "MS_NAME=${SERVICE_NAME}"  -e "ENV_VALUE=${ENV_VALUE}" -v ${prodPath}:/product/mserver    mserver:v3  /product/mserver/run_jar.sh
	     fi
        fi
    fi;
done
